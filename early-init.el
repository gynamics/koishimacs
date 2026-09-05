;;; early-init.el --- early emacs initialization -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:
;; Firstly, set a larger `gc-cons-threshold' to reduce gc stalls.
(setq gc-cons-threshold (expt 2 26)
      gc-cons-percentage 0.15)

;; Setup `load-path-filter-function', only available for emacs-31+
;; We should only use built-in functions here to make full use of cache.
(defvar my/lpf--cache-file
  (file-name-concat user-emacs-directory "load-path-filter-cache.el"))

(defvar my/lpf--cache
  (if (file-readable-p my/lpf--cache-file)
      (with-temp-buffer
        (insert-file-contents my/lpf--cache-file)
        (goto-char 0)
        (condition-case nil
            (read (current-buffer))
          (error (make-hash-table :test #'equal))))
    (make-hash-table :test #'equal))
  "A cache used by function `my:lpf', which is a hash table.
Each hash table entry is a FILE name, and value is filtered PATH.")

(defun my:lpf-validate ()
  "Remove all invalid entries from `my/lpf--cache'."
  (interactive)
  (maphash (lambda (k v)
             (unless (file-directory-p (car v))
               (remhash k my/lpf--cache)))
           my/lpf--cache))

;; save cache when exit emacs
(add-hook 'kill-emacs-hook
          #'(lambda ()
              (my:lpf-validate)
              (with-temp-file my/lpf--cache-file
                (insert (prin1-to-string my/lpf--cache)))))

(defvar my/lpf--cache-training t
  "If this is non-nil, start training when my/lpf--cache missed.")

(defvar my/lpf--cache-validate t
  "If this is non-nil, validate each entry found in cache before load.
If invalid, erase it from the cache.")

(defun my:lpf-match (path file suffixes)
  (catch 'found
    (dolist (x (mapcar #'(lambda (suf) (concat file suf)) suffixes))
      (if-let* ((res (mapcan #'(lambda (p)
                                 (when (file-readable-p (file-name-concat p x))
                                   (list p)))
                             path)))
          (throw 'found res)))))

(defun my:lpf-train (path file suffixes)
  (if (or (file-directory-p file)
          (not my/lpf--cache-training))
      path
    (when-let*
        ((val (my:lpf-match path file suffixes)))
      (puthash file val my/lpf--cache))))

(defun my:lpf (path file suffixes)
  (if-let* ((val (gethash file my/lpf--cache)))
      ;; cache hitted
      (progn
        (when (and my/lpf--cache-validate
                   (null (my:lpf-match val file suffixes)))
          (setq val (my:lpf-train path file suffixes)))
        ;; append val to the beginning of path, this ensures it works correctly
        ;; when there are dirty values that are not validated
        (append val path))
    ;; otherwise, start training, this may be painful when hit rate is low.
    (or (my:lpf-train path file suffixes)
        path)))

(setq load-path-filter-function #'my:lpf)

(provide 'early-init)
;;; early-init.el ends here
