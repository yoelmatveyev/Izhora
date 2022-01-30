(in-package :cl-izhora)

;;; Supposed wrapper for making an executable compiler with buildapp
;;; NOR WORKING YET !!! :-)

(defun main (args)
  (let ((machine (make-izhora)))
    (asm-compile-file-to-machine (second args) machine)
    (save-machine machine (third args))))
