---
date: 2023-11-29
created: 2023-11-29T14:32:43+09:00
updated: 2023-11-29T16:16:56+09:00
permalink: "/emacs-ghq-projectile/"
tags:
  - Emacs
share: true
---


Create a timer that periodically imports [ghq](https://github.com/x-motemen/ghq) directories to [projectile](https://github.com/bbatsov/projectile)-known-projects.

```lisp
(defun projectile-update-known-projects-with-ghq ()
  (interactive)
  (when (executable-find "ghq")
    (make-process :name "ghq"
                  :buffer (get-buffer-create "*ghq*")
                  :command (list shell-file-name shell-command-switch "ghq list --full-path")
                  :sentinel (lambda (process event)
                              (when-let
                                  ((buffer (process-buffer process))
                                   ((eq (process-status process) 'exit))
                                   ((zerop (process-exit-status process)))
                                   (output (with-current-buffer buffer (buffer-string))))
                                (kill-buffer buffer)
                                (cl-loop for dir
                                         in (split-string output "\n" t)
                                         unless (projectile-ignored-project-p dir)
                                         do (cl-pushnew (file-name-as-directory (abbreviate-file-name dir))
                                                        projectile-known-projects)
                                         finally (projectile-merge-known-projects)))))))

(defmacro setq-timer (var timer)
  `(progn
     (if (bound-and-true-p ,var)
         (cancel-timer ,var))
     (setq ,var ,timer)))

(setq-timer projectile-update-known-projects-timer
            (run-with-idle-timer 300 t (lambda () (projectile-update-known-projects-with-ghq))))
```
