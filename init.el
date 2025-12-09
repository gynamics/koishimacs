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

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(let* ((literate-config (concat user-emacs-directory "koishimacs.org"))
       (lispcode-config (concat (file-name-sans-extension literate-config) ".el"))
       (bytecode-config (concat lispcode-config "c")))
  (when (file-exists-p literate-config)
    ;; If code config is pre-compiled and newer, then load it
    ;; Firstly try byte code (.elc)
    (if (and (file-exists-p bytecode-config)
             (file-newer-than-file-p bytecode-config literate-config))
        (load-file bytecode-config)
      ;; Then try lisp code (.el)
      (if (and (file-exists-p lispcode-config)
               (file-newer-than-file-p lispcode-config literate-config))
          (load-file lispcode-config)
        ;; Otherwise use org-babel to tangle the literate configuration
        (progn
          ;; do not load any org modules before tangling
          (defvar org-modules nil)
          (require 'org)
          ;; do not produce bytecode on the first tangle
          (org-babel-load-file literate-config))))
    ))

(provide 'init)
;;; init.el ends here
