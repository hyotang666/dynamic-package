(defpackage #:dynamic-package (:use #:common-lisp)
  (:export #:control ; helper
	   #:file ; subclass of asdf component.
	   ))
(in-package #:dynamic-package)

(defun ensure-package(c)
  (let((package-name(make-package-name c)))
    (or (find-package package-name)
	(make-package package-name :use '(:cl)))))

(defun make-package-name(component)
  (read-from-string ; to use implementation dependent readtable case.
    (let((system-name(asdf:coerce-name(asdf:component-system component)))
	 (file-name(asdf:component-name component)))
      (if(string= system-name file-name)
	system-name
	(concatenate 'string system-name "." file-name)))))

(defmacro control(&rest clause*)
  (flet((SORT-CLAUSE(clause*)
	  (loop :for clause :in clause*
		:when (find (car clause) '(:shadow :shadowing-import-from)
			    :test #'eq)
		:collect clause :into first
		:else :if (eq :use (car clause))
		:collect clause :into second
		:else :if (eq :import-from (car clause))
		:collect clause :into third
		:else :if (eq :export (car clause))
		:collect clause :into fourth
		:else :do (error "Unknown package control ~S" clause)
		:finally (return (nconc first second third fourth)))))
    `(EVAL-WHEN(:COMPILE-TOPLEVEL :LOAD-TOPLEVEL :EXECUTE)
       ,@(mapcan #'make-form (SORT-CLAUSE clause*)))))

(defun make-form (clause)
  (flet((finder(&optional package)
	  `(LAMBDA(NAME)
	     (OR (FIND-SYMBOL(STRING NAME),@(when package (list package)))
		 (ERROR "Symbol ~S is not exist in ~S"
			name ,(or package '*package*))))))
    (case(car clause)
      (:use (mapcar (lambda(package)
		      `(USE-PACKAGE ',package))
		    (cdr clause)))
      (:import-from `((IMPORT (MAPCAR ,(finder (cadr clause)) ',(cddr clause)))))
      (:shadowing-import-from `((SHADOWING-IMPORT (MAPCAR ,(finder(cadr clause))
							  ',(cddr clause)))))
      (:shadow `((SHADOW (MAPCAR ,(finder) ',(cdr clause)))))
      (:export `((EXPORT (MAPCAR (LAMBDA(NAME)
				   (INTERN(STRING NAME)))
				 ',(cdr clause))))))))

(defclass file(asdf:cl-source-file)())

(defmethod asdf:perform :around(o(c file))
  (let((*package*(ensure-package c)))
    (call-next-method)))
