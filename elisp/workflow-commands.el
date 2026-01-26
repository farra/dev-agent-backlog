;;; workflow-commands.el --- Task workflow commands for dev-agent-backlog -*- lexical-binding: t; -*-

;; Author: dev-agent-backlog
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1") (org "9.0"))
;; Keywords: org, project, tasks

;;; Commentary:

;; Emacs commands for the dev-agent-backlog workflow.
;; These complement the Claude Code slash commands for users who prefer Emacs.

;;; Code:

(require 'org)
(require 'url-util)

(defgroup dab nil
  "dev-agent-backlog task workflow."
  :group 'org
  :prefix "dab-")

(defcustom dab-backlog-file "backlog.org"
  "Name of the backlog file."
  :type 'string
  :group 'dab)

(defcustom dab-task-id-regexp "\\[\\([A-Z]+-[0-9]+-[0-9]+\\)\\]"
  "Regexp matching task IDs like [PROJECT-NNN-XX]."
  :type 'regexp
  :group 'dab)

(defun dab--find-backlog-file ()
  "Find the backlog file by searching up the directory tree."
  (let ((dir (locate-dominating-file default-directory dab-backlog-file)))
    (when dir
      (expand-file-name dab-backlog-file dir))))

(defun dab--extract-task-id (heading)
  "Extract task ID from HEADING."
  (when (string-match dab-task-id-regexp heading)
    (match-string 1 heading)))

;;;###autoload
(defun dab-task-queue ()
  "Queue the task at point into backlog.org Active section.
Run this while point is on a TODO headline in a design doc."
  (interactive)
  (unless (org-at-heading-p)
    (user-error "Not on a heading"))
  (let* ((source-file (buffer-file-name))
         (heading (org-get-heading t t t t))
         (task-id (dab--extract-task-id heading))
         (effort (org-entry-get nil "EFFORT"))
         (backlog-file (dab--find-backlog-file)))
    (unless task-id
      (user-error "No task ID found in heading (expected %s)" dab-task-id-regexp))
    (unless backlog-file
      (user-error "Could not find %s in parent directories" dab-backlog-file))
    (let ((source-link (format "[[file:%s::*%s][%s in %s]]"
                               (file-relative-name source-file
                                                   (file-name-directory backlog-file))
                               (url-hexify-string heading)
                               task-id
                               (file-name-nondirectory source-file))))
      (find-file backlog-file)
      (goto-char (point-min))
      (unless (re-search-forward "^\\*\\* Active" nil t)
        (user-error "Could not find '** Active' section in %s" dab-backlog-file))
      (org-end-of-subtree)
      (insert (format "\n\n*** TODO %s\n:PROPERTIES:\n:DESIGN: %s%s\n:END:\n\n"
                      heading
                      source-link
                      (if effort (format "\n:EFFORT: %s" effort) "")))
      (message "Queued %s into %s" task-id dab-backlog-file))))

;;;###autoload
(defun dab-goto-design ()
  "Jump to the design doc of the current task via its :DESIGN: property."
  (interactive)
  (let ((design (org-entry-get nil "DESIGN")))
    (unless design
      (user-error "No :DESIGN: property found"))
    (when (string-match "\\[\\[\\([^]]+\\)\\]" design)
      (org-link-open-from-string (match-string 0 design)))))

;; Alias for backwards compatibility
(defalias 'dab-goto-source 'dab-goto-design)

(provide 'workflow-commands)
;;; workflow-commands.el ends here
