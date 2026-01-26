;;; workflow-commands.el --- Task workflow commands for dev-agent-backlog -*- lexical-binding: t; -*-

;; Author: dev-agent-backlog
;; Version: 2.0.0
;; Package-Requires: ((emacs "27.1") (org "9.0"))
;; Keywords: org, project, tasks

;;; Commentary:

;; Emacs commands for the dev-agent-backlog workflow.
;; These complement the Claude Code slash commands for users who prefer Emacs.
;;
;; Load this file in your Emacs config:
;;   (load "/path/to/elisp/workflow-commands.el")
;;
;; Or add to load-path and require:
;;   (add-to-list 'load-path "/path/to/elisp")
;;   (require 'workflow-commands)

;;; Code:

(require 'org)
(require 'url-util)
(require 'seq)
(require 'map)

;;;; Customization

(defgroup backlog nil
  "dev-agent-backlog task workflow."
  :group 'org
  :prefix "backlog/")

(defcustom backlog/backlog-file "backlog.org"
  "Name of the backlog file."
  :type 'string
  :group 'backlog)

(defcustom backlog/design-dir "docs/design"
  "Relative path to design docs directory."
  :type 'string
  :group 'backlog)

(defcustom backlog/task-id-regexp "\\[\\([A-Z]+-[0-9]+-[0-9]+\\)\\]"
  "Regexp matching task IDs like [PROJECT-NNN-XX]."
  :type 'regexp
  :group 'backlog)

(defcustom backlog/valid-statuses
  '("Draft" "Review" "Accepted" "Active" "Complete" "Archived")
  "Valid status values for design documents."
  :type '(repeat string)
  :group 'backlog)

;;;; Internal Helpers

(defun backlog/--find-project-root ()
  "Find project root by looking for backlog.org."
  (locate-dominating-file default-directory backlog/backlog-file))

(defun backlog/--find-backlog-file ()
  "Find the backlog file by searching up the directory tree."
  (let ((root (backlog/--find-project-root)))
    (when root
      (expand-file-name backlog/backlog-file root))))

(defun backlog/--find-design-dir ()
  "Find the design docs directory."
  (let ((root (backlog/--find-project-root)))
    (when root
      (expand-file-name backlog/design-dir root))))

(defun backlog/--extract-task-id (heading)
  "Extract task ID from HEADING."
  (when (string-match backlog/task-id-regexp heading)
    (match-string 1 heading)))

;;;; Backlog Commands

;;;###autoload
(defun backlog/task-queue ()
  "Queue the task at point into backlog.org Active section.
Run this while point is on a TODO headline in a design doc."
  (interactive)
  (unless (org-at-heading-p)
    (user-error "Not on a heading"))
  (let* ((source-file (buffer-file-name))
         (heading (org-get-heading t t t t))
         (task-id (backlog/--extract-task-id heading))
         (effort (org-entry-get nil "EFFORT"))
         (backlog-file (backlog/--find-backlog-file)))
    (unless task-id
      (user-error "No task ID found in heading (expected %s)" backlog/task-id-regexp))
    (unless backlog-file
      (user-error "Could not find %s in parent directories" backlog/backlog-file))
    (let ((source-link (format "[[file:%s::*%s][%s in %s]]"
                               (file-relative-name source-file
                                                   (file-name-directory backlog-file))
                               (url-hexify-string heading)
                               task-id
                               (file-name-nondirectory source-file))))
      (find-file backlog-file)
      (goto-char (point-min))
      (unless (re-search-forward "^\\*\\* Active" nil t)
        (user-error "Could not find '** Active' section in %s" backlog/backlog-file))
      (org-end-of-subtree)
      (insert (format "\n\n*** TODO %s
:PROPERTIES:
:DESIGN: %s%s
:HANDOFF:
:WORKED_BY:
:END:

" heading source-link (if effort (format "\n:EFFORT: %s" effort) "")))
      (message "Queued %s into %s" task-id backlog/backlog-file))))

;;;###autoload
(defun backlog/goto-design ()
  "Jump to the design doc of the current task via its :DESIGN: property."
  (interactive)
  (let ((design (org-entry-get nil "DESIGN")))
    (unless design
      (user-error "No :DESIGN: property found"))
    (when (string-match "\\[\\[\\([^]]+\\)\\]" design)
      (org-link-open-from-string (match-string 0 design)))))

;;;; Design Doc Helpers

(defun backlog/design--extract-metadata (file keyword)
  "Extract #+KEYWORD: value from FILE header."
  (when (file-exists-p file)
    (with-temp-buffer
      (insert-file-contents file nil 0 1000)
      (goto-char (point-min))
      (when (re-search-forward (format "^#\\+%s:\\s-*\\(.+\\)$" keyword) nil t)
        (string-trim (match-string 1))))))

(defun backlog/design-extract-status (file)
  "Extract #+STATUS: value from FILE."
  (backlog/design--extract-metadata file "STATUS"))

(defun backlog/design-extract-category (file)
  "Extract #+CATEGORY: value from FILE."
  (backlog/design--extract-metadata file "CATEGORY"))

(defun backlog/design-extract-title (file)
  "Extract #+TITLE: value from FILE."
  (backlog/design--extract-metadata file "TITLE"))

(defun backlog/design-get-all-docs (&optional dir)
  "Get list of all numbered .org design docs in DIR."
  (let ((design-dir (or dir (backlog/--find-design-dir))))
    (when design-dir
      (seq-filter
       (lambda (f)
         (string-match-p "^[0-9]+-" (file-name-nondirectory f)))
       (directory-files design-dir t "\\.org$")))))

;;;###autoload
(defun backlog/design-next-number ()
  "Return the next available doc number."
  (interactive)
  (let* ((docs (backlog/design-get-all-docs))
         (next (1+ (apply #'max 0
                          (mapcar (lambda (f)
                                    (if (string-match "^\\([0-9]+\\)-" (file-name-nondirectory f))
                                        (string-to-number (match-string 1 (file-name-nondirectory f)))
                                      0))
                                  docs)))))
    (message "Next available doc number: %03d" next)
    next))

;;;###autoload
(defun backlog/design-goto-doc (number)
  "Jump to design doc by NUMBER."
  (interactive "nDoc number: ")
  (let ((file (car (seq-filter
                    (lambda (f)
                      (string-match-p (format "^%03d-" number)
                                      (file-name-nondirectory f)))
                    (backlog/design-get-all-docs)))))
    (if (and file (file-exists-p file))
        (find-file file)
      (user-error "No doc with number %d" number))))

;;;###autoload
(defun backlog/design-status-report ()
  "Show a summary of document statuses."
  (interactive)
  (let ((status-counts (make-hash-table :test 'equal)))
    (dolist (file (backlog/design-get-all-docs))
      (let ((status (or (backlog/design-extract-status file) "Unknown")))
        (puthash status (1+ (gethash status status-counts 0)) status-counts)))
    (message "Status report:\n%s"
             (string-join
              (sort (map-apply (lambda (k v) (format "  %-10s %3d" k v))
                               status-counts)
                    #'string<)
              "\n"))))

;;;###autoload
(defun backlog/design-category-report ()
  "Show a summary of document categories."
  (interactive)
  (let ((cat-counts (make-hash-table :test 'equal)))
    (dolist (file (backlog/design-get-all-docs))
      (let ((cat (or (backlog/design-extract-category file) "uncategorized")))
        (puthash cat (1+ (gethash cat cat-counts 0)) cat-counts)))
    (message "Category report:\n%s"
             (string-join
              (sort (map-apply (lambda (k v) (format "  %-12s %3d" k v))
                               cat-counts)
                    #'string<)
              "\n"))))

;;;; README.org Index Reconciliation

(defun backlog/design--get-table-files ()
  "Get list of (number . filename) from tables in current buffer."
  (let (files)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              "^|\\s-*\\([0-9]+\\)\\s-*|.*\\[\\[file:\\([^]]+\\.org\\)\\]" nil t)
        (push (cons (string-to-number (match-string 1))
                    (match-string 2))
              files)))
    (nreverse files)))

;;;###autoload
(defun backlog/design-sync-status ()
  "Update status column in tables from actual #+STATUS: in linked files.
Run this in the design docs README.org buffer."
  (interactive)
  (let ((design-dir (file-name-directory (buffer-file-name)))
        (updates 0)
        (errors nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              "^|\\s-*\\([0-9]+\\)\\s-*|\\s-*\\[\\[file:\\([^]]+\\.org\\)\\]\\[[^]]+\\]\\]\\s-*|\\s-*\\([^|]+\\)|" nil t)
        (let* ((num (match-string 1))
               (file (expand-file-name (match-string 2) design-dir))
               (current-status (string-trim (match-string 3)))
               (actual-status (backlog/design-extract-status file)))
          (cond
           ((null actual-status)
            (push (format "%s: no #+STATUS: found" num) errors))
           ((not (string= current-status actual-status))
            (let ((status-start (match-beginning 3))
                  (status-end (match-end 3)))
              (delete-region status-start status-end)
              (goto-char status-start)
              (insert (format "%-10s" actual-status))
              (cl-incf updates)))))))
    (if errors
        (message "Updated %d statuses. Errors: %s" updates (string-join errors ", "))
      (message "Updated %d statuses." updates))))

;;;###autoload
(defun backlog/design-verify-links ()
  "Check that all linked files in tables exist.
Run this in the design docs README.org buffer."
  (interactive)
  (let ((design-dir (file-name-directory (buffer-file-name)))
        (missing nil))
    (dolist (entry (backlog/design--get-table-files))
      (let ((file (expand-file-name (cdr entry) design-dir)))
        (unless (file-exists-p file)
          (push (format "%03d: %s" (car entry) (cdr entry)) missing))))
    (if missing
        (message "Missing files:\n%s" (string-join (nreverse missing) "\n"))
      (message "All linked files exist."))))

;;;###autoload
(defun backlog/design-find-unlisted ()
  "Find .org files in design dir not listed in this index.
Run this in the design docs README.org buffer."
  (interactive)
  (let* ((design-dir (file-name-directory (buffer-file-name)))
         (listed (mapcar #'cdr (backlog/design--get-table-files)))
         (all-docs (backlog/design-get-all-docs design-dir))
         (unlisted (seq-filter
                    (lambda (f)
                      (not (member (file-name-nondirectory f)
                                   (mapcar #'file-name-nondirectory
                                           (mapcar (lambda (l) (expand-file-name l design-dir)) listed)))))
                    all-docs)))
    (if unlisted
        (message "Unlisted docs:\n%s"
                 (string-join (mapcar #'file-name-nondirectory unlisted) "\n"))
      (message "All docs are listed in the index."))))

;;;###autoload
(defun backlog/design-stale-check ()
  "Find docs where README status doesn't match actual status.
Run this in the design docs README.org buffer."
  (interactive)
  (let ((design-dir (file-name-directory (buffer-file-name)))
        (stale nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              "^|\\s-*\\([0-9]+\\)\\s-*|\\s-*\\[\\[file:\\([^]]+\\.org\\)\\]\\[[^]]+\\]\\]\\s-*|\\s-*\\([^|]+\\)|" nil t)
        (let* ((num (match-string 1))
               (file (expand-file-name (match-string 2) design-dir))
               (readme-status (string-trim (match-string 3)))
               (actual-status (backlog/design-extract-status file)))
          (when (and actual-status (not (string= readme-status actual-status)))
            (push (format "%s: README='%s' actual='%s'"
                          num readme-status actual-status)
                  stale)))))
    (if stale
        (message "Stale entries:\n%s" (string-join (nreverse stale) "\n"))
      (message "All statuses are in sync."))))

;;;; Feature check

(defun backlog/loaded-p ()
  "Return t if workflow-commands is loaded."
  t)

;;;; Provide

(provide 'workflow-commands)
;;; workflow-commands.el ends here
