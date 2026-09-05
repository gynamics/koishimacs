;;; my-misc.el --- My miscellaneous elisp scripts  -*- lexical-binding: t -*-

;; Author: gynamics
;; Maintainer: gynamics
;; Package-Version: 0.1
;; Package-Requires: ((emacs "26.1"))
;; URL: https://github.com/gynamics/my-misc.el
;; Keywords: convenience


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; Here are some useful short functions I collected that are not
;; shipped with Emacs, all started with a `my-misc-` prefix.

;;; Code:

(defun my-misc-mark-whole-line (&optional arg)
  "Set mark ARG lines from line beginning of point or move mark one line.
When invoked interactively without a prefix argument and no active
region, mark moves to beginning of line.
When invoked interactively without a prefix argument, and region is
active, mark moves one line away of point (i.e., forward if mark is at
or after point, back if mark is before point), thus extending the region
by one line.  Since the direction of region extension depends on the
relative position of mark and point, you can change the direction by
\\[exchange-point-and-mark]."
  (interactive "P")
  (if (region-active-p)
      (progn
        (setq arg (if arg (prefix-numeric-value arg)
                    (if (< (mark) (point)) -1 1)))
        (set-mark
         (save-excursion
           (goto-char (mark))
           (forward-line arg)
           (point))))
    (progn
      (move-beginning-of-line nil)
      (push-mark
       (save-excursion
         (forward-line (prefix-numeric-value arg))
         (point))
       nil t))))

(defun my-misc-unfill-paragraph (&optional region)
  "Make a multi-paragraph REGION into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(defun my-misc-eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its VALUE."
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

(defun my-misc-dedicate-window-toggle ()
  "Toggle sticky buffer to current window."
  (interactive)
  (set-window-dedicated-p
   (selected-window)
   (not (window-dedicated-p (selected-window)))))

;; This can be used as the :output argument for org-babel
(defun my-misc-asset-directory (&optional output-file)
  "If current buffer is a file, return path <file-name>.assets/OUTPUT-FILE.
Otherwise, return <temporary-file-directory>/OUTPUT-FILE."
  (let ((name (buffer-file-name)))
    (if (file-exists-p name)
        (let ((asset-dir
               (concat (file-name-sans-extension (file-name-base name))
                       ".assets/")))
          (unless (file-exists-p asset-dir)
            (mkdir asset-dir))
          (file-name-concat asset-dir output-file))
      (file-name-concat (temporary-file-directory) output-file))))

(defun my-misc-loaddefs-regenerate (dir &optional generate-full)
  "Regenerate loaddefs for given DIR.
Universal argument GENERATE-FULL is passed to `loaddefs-generate'."
  (interactive "DPath of pacakge: \nP")
  (let ((output
         (concat (file-name-as-directory dir)
                 (replace-regexp-in-string
                  "\\(\\.el\\|-[0-9]\\{1,8\\}\\(\\.[0-9]+\\)\\)+$" ""
                  (file-name-nondirectory (directory-file-name dir)))
                 "-autoloads.el")))
    (loaddefs-generate dir output nil nil nil generate-full)))

(defun my-misc-loaddefs-regenerate-subdirs (dir &optional all-in-one)
  "Regenerate loaddefs for all subdirectories under DIR.
When universal argument ALL-IN-ONE is given, compose them into
one single `loaddefs.el' and byte-compile it."
  (interactive "DPath of parent directory: \nP")
  (dolist (child (file-name-all-completions "" dir))
    (when (and (directory-name-p child)
               (not (member child '("./" "../" ".git/" "archives/" "gnupg/"))))
      (message "Regenerate loaddefs for %s ..." child)
      (let ((subdir (concat (file-name-as-directory dir) child)))
        (when all-in-one
          (let ((all-in-file
                 (concat (file-name-as-directory dir) "loaddefs.el")))
            (when (file-exists-p all-in-file)
              (delete-file all-in-file))
            (loaddefs-generate subdir all-in-file)
            (byte-compile-file all-in-file))
          (my-misc-loaddefs-regenerate subdir t))))))

;; there is an async version provided by koishimacs, which needs async
(defun my-misc-byte-force-recompile-subdirs (dir)
  "Call `byte-force-recompile' on all subdirectories of DIR."
  (interactive "DPath of parent directory: ")
  (dolist (child (file-name-all-completions "" dir))
    (when (and (directory-name-p child)
               (not (member child '("./" "../" ".git/" "archives/" "gnupg/"))))
      (byte-force-recompile
       (concat (file-name-as-directory dir) child)))))

(defun my-misc-adjust-alpha (fg bg)
  "Set window opacity to (FG . BG) by setting frame parameter `alpha'."
  (declare (obsolete my-misc-adjust-alpha-background "29"))
  (interactive
   "nForeground Transparency Value 0 - 100 opaque: \n\
nBackground Transparency Value 0 - 100 opaque: ")
  (set-frame-parameter (selected-frame) 'alpha `(,fg . ,bg)))

(defun my-misc-adjust-alpha-background (value)
  "Set window opacity to VALUE by setting frame parameter `alpha-background' ."
  (interactive "nTransparency Value 0 - 100 opaque: ")
  (set-frame-parameter (selected-frame) 'alpha-background value))

(provide 'my-misc)
;;; my-misc.el ends here
