(module c scheme
  (require scheme/foreign)
  (require scheme/promise)
  (unsafe!)

  (define *libpython-path* "libpython")

  (define libpython
    (delay 
      (ffi-lib *libpython-path*)))
  
  (define (set-libpython-path! path)
    (set! *libpython-path* path))

  (define (get-libpython)
    (force libpython))

  (define-syntax (define-cpyfunc stx)
    (syntax-case stx ()
      [(define-cpyfunc id type)
       #'(define-values (id) 
           (values (get-cpyfunc (symbol->string (quote id)) type))) ]))

  (define (get-cpyfunc name type)
    (lambda args
          (apply (get-ffi-obj name (get-libpython) type) args)))

  (define pyobj%
    (class* object% (printable<%>)
      (init-field ptr)
      (super-new)

      (define/public (__repr__)
        (PyString_AsString (PyObject_Repr ptr)))
      (define/public (__str__)
        (PyString_AsString (PyObject_Str ptr)))
      (define/public (custom-display port)
        (display (__repr__) port))
      (define/public (custom-write port)
        (write (__repr__) port))))
  
  (define (get-ptr pyobj)
    (get-field ptr pyobj))
  
  ;; Raw PyObject, doesn't get finalized.  May also be used for non-borrowed objects
  (define _rpyobject (_cpointer 'pyobject))
  (define _pyobject
    (make-ctype _rpyobject
                get-ptr
                (lambda (o)
                  (register-finalizer o Py_DecRef)
                  (new pyobj% [ptr o]))))

  (define-cpyfunc Py_Initialize (_fun -> _void))
  (define-cpyfunc Py_Finalize (_fun -> _void))
  (define-cpyfunc PyRun_SimpleString (_fun _string -> _int))
  (define-cpyfunc PyRun_SimpleFile (_fun _pointer _string -> _int))
  (define-cpyfunc PyString_FromString(_fun _string -> _pyobject))
  (define-cpyfunc PyString_AsString(_fun _pyobject -> _string))
  (define-cpyfunc PyImport_Import(_fun _pyobject -> _pyobject))
  (define-cpyfunc PyImport_ImportModule(_fun _string -> _pyobject))

  (define-cpyfunc PyInt_FromLong(_fun _long -> _pyobject))

  (define-cpyfunc PyFloat_FromDouble(_fun _double* -> _pyobject))
  (define-cpyfunc PyObject_GetAttr (_fun _pyobject _pyobject -> _pyobject))
  (define-cpyfunc PyObject_GetAttrString (_fun _pyobject _string -> _pyobject))
  (define-cpyfunc PyObject_Repr (_fun _rpyobject -> _pyobject))
  (define-cpyfunc PyObject_Str (_fun _rpyobject -> _pyobject))

  ;; Ref counting
  (define-cpyfunc Py_IncRef (_fun _rpyobject -> _void))
  (define-cpyfunc Py_DecRef (_fun _rpyobject -> _void))

  (provide (all-defined-out))
  ) 
