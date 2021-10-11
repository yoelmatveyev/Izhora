(in-package :cl-izhora)

(defun print-machine (machine &key (stream t))
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


(defun save-machine (machine file &key comment)
  (with-open-file
      (stream (concatenate 'string file ".izh")
	      :direction :output :if-exists :supersede)
    (when comment
      (format stream "#~a~%" comment))
    (print-machine machine :stream stream))
  t)

(defun load-machine (file)
  (let (machine)
    (with-open-file
	(stream (concatenate 'string file ".izh")
		:direction :input :if-does-not-exist nil)
      (when stream
	(setf machine (make-izhora))
	(loop for line = (read-line stream nil)
              while line
              do (unless (or (find #\# line) (zerop (length line)))
		   (if (find #\: line)
		       (progn  (when (search "A0" line)
				 (setf (aref (izhora-a machine) 0)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t)))
			       (when (search "A1" line)
				 (setf (aref (izhora-a machine) 1)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t)))
			       (when (search "A2" line)
				 (setf (aref (izhora-a machine) 2)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t)))
			       (when (search "A3" line)
				 (setf (aref (izhora-a machine) 3)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t)))
			       (when (search "PC" line)
				 (setf (izhora-pc machine)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t)))
			       (when (search "CT" line)
				 (setf (izhora-counter machine)
				       (parse-integer line :start 3 :radix 16 :junk-allowed t))))
		       (setf (aref (izhora-code machine)
				   (parse-integer line :radix 16 :junk-allowed t))
			     (parse-integer line :start 4 :radix 16 :junk-allowed t)))))))
    machine))
