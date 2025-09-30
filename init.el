;;; init.el --- entry of configurations to koishimacs -*- lexical-binding: t -*-

;; Author: gynamics
;; Maintainer: gynamics
;; Version: 5.0.0
;; Package-Requires:
;; Homepage:


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

;; Koishimacs -- The Emacs in Your Subconsciousness

;;; Code:

;; feel free to set a larger gc-cons-threshold
(setq gc-cons-threshold (expt 2 26)
      gc-cons-percentage 0.15)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-quickstart t))


(let ((literate-config (concat user-emacs-directory "koishimacs.org"))
      (code-config (concat user-emacs-directory "koishimacs.el")))
  (when (file-exists-p literate-config)
    ;; If config is pre-compiled and newer, then load it
    (if (and (file-exists-p code-config)
             (file-newer-than-file-p code-config literate-config))
        (load-file code-config)
      ;; Otherwise use org-babel to tangle the literate configuration
      (progn
        ;; do not load any org modules before tangling
        (defvar org-modules nil)
        (require 'org)
        (org-babel-load-file literate-config)))
    ))

(provide 'init)
;;; init.el ends here
