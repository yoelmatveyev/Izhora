(defsystem :izhora
  :name "Izhora CA Simulator"
  :version "0.0.1"
  :maintainer "Yoel Matveyev"
  :author "Yoel Matveyev"
  :licence "GNU General Public License v3.0"
  :description "A virtual machine simulating a cellular automation computer"
  :long-description "A virtual machine simulating a cellular automation computer with a simple OISC/RISC architecture"
  :components ((:file "package")	
	       (:file "izhora")
	       (:file "basic-coding")
	       (:file "assembler")
	       (:file "macro-commands")
	       (:file "file")
	       (:file "display")))

