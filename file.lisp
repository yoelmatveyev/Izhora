(in-package :cl-izhora)

(defun print-machine-state (machine &key (stream t))
  (let
      ((a0 (aref (izhora-a machine) 0))
       (a1 (aref (izhora-a machine) 1))
       (a2 (aref (izhora-a machine) 2))
       (a3 (aref (izhora-a machine) 3))
       (pc (izhora-pc machine))
       (ct (izhora-counter machine)))
    (unless (zerop a0) (format stream "A0 : ~4,'0X~%" a0))
    (unless (zerop pc) (format stream "PC : ~4,'0X~%" pc))
    (unless (zerop ct) (format stream "CT : ~4,'0X~%" ct))
    (loop for x from 0 to #xFFFF do
      (unless (zerop (aref (izhora-code machine) x))
	(format stream "~4,'0X ~8,'0X~%" x (aref (izhora-code machine) x))))))


(defun save-machine-state (machine file &key comment)
  (with-open-file
      (stream (concatenate 'string file ".izh")
	      :direction :output :if-exists :supersede)
    (when comment
      (format stream "#~a~%" comment))
    (print-machine-state machine :stream stream))
  t)
