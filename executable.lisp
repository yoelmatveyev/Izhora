(in-package :cl-izhora)

;; Simple wrapper for making an executable compiler with buildapp

(defun main (args)
  (let ((machine (make-izhora)))
    (asm-compile-file-to-machine (second args) machine)
    (save-machine machine (third args))))
