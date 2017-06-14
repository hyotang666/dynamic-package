# Dynamic-package
Another package inferred system.

## Abstraction
### Current lisp world
ASDF introduces package inferred system.
### Issues
It is annoying to write `DEFPACKAGE` many times.
### Proposal
Making package automatically.

## How to use.
Write asd like below.

```lisp
(in-package :asdf)
(load-system :dynamic-package) ; <--- Load dynamic-package before defsystem.
(defsystem :my-product
  :default-component-class dynamic-package:file ; <--- Specify.
  :components ((:file "file")))
```

Each file which specified `dynamic-package:file` as asdf component class does not need to write `DEFPACKAGE` nor `IN-PACKAGE`.
Package is made automatically.
Package name is calculated as 'system-name.file-name', but except when system-name is same with file-name, such name becomes package name.
In the example code above, package MY-PRODUCT.FILE is made.

NOTE - More precisely, package name is cluculated like `(read-from-string "system-name.file-name")`, so package name case depends on readtable case.

To export, import, shadow, and shadowing-import symbols, you need to use apropreate functions with wrapping with `EVAL-WHEN`.
Dynamic-package provides useful short hand for it.
`DYNAMIC-PACKAGE:CONTOL` is macro which syntax is almost same with `DEFPACKAGE`.

```lisp
(dynamic-package:control
  (:export #:test)
  (import-from :foo #:bar))
(defun test()
  (bar ...))
```

## Installation
TODO
