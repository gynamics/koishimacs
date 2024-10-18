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

;; only keep a minimal subset of native features for custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(enable-recursive-minibuffers t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(native-comp-async-report-warnings-errors nil)
 '(package-quickstart t)
 '(scroll-bar-mode nil)
 '(size-indication-mode t)
 '(tab-always-indent t)
 '(tab-width 2)
 '(tool-bar-mode nil)
 '(undo-limit (expt 2 20)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "SRC" :slant normal :weight regular :height 130 :width normal))))
 '(fixed-pitch-serif ((t (:weight bold :family "DejaVu Sans Mono")))))

;; Don't attempt to find/apply special file handlers to files loaded during startup.
(let ((file-name-handler-alist nil)
      (literate-config (concat user-emacs-directory "koishimacs.org"))
      (code-config (concat user-emacs-directory "koishimacs.el")))
  (when (file-exists-p literate-config)
    ;; If config is pre-compiled and newer, then load it
    (if (and (file-exists-p code-config)
             (file-newer-than-file-p code-config literate-config))
        (load-file code-config)
      (progn
        ;; Otherwise use org-babel to tangle the literate configuration
        (require 'org)
        (org-babel-load-file literate-config)))
    ))

(provide 'init)
;;; init.el ends here
