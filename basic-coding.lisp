(in-package :cl-izhora)

(defun set-command (machine addr jmp op)
  (setf
   (aref (izhora-code machine) addr)
   (+ (logand op #xffff) (ash (logand jmp #xffff) 16))))

(defun set-data (machine addr data)
  (setf (aref (izhora-code machine) addr) data))

(defun set-data-list (machine addr l)
  (loop for x from 0 to (1- (length l)) do
    (setf (aref (izhora-code machine) (+ addr x)) (nth x l))))
