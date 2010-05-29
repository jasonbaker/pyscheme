(module c scheme
  (require scheme/foreign)
  (unsafe!)

  (define libpython #f)

  (define (init [lib "libpython"])
    (set! libpython (ffi-lib lib))
    (Py_Initialize))

  (define-syntax (define-cpyfunc stx)
    (syntax-case stx ()
                 [(define-cpyfunc id type)
                  #'(define-values (id) 
                                   (values (get-cpyfunc (symbol->string (quote id)) type))) ]))

    (define (get-cpyfunc name type)
      (lambda args
        (if libpython
          (apply (get-ffi-obj name libpython type) args)
          (error "Call init before using any Python C functions"))))

  (define pyobj%
    (class object%
      (init-field ptr)
      (super-new)))
  
  (define (get-ptr pyobj)
    (get-field ptr pyobj))
  
  ;; Raw PyObject, doesn't get finalized.  May also be used for borrowed objects
  (define _rpyobject (_cpointer 'pyobject))
  (define _pyobject
    (make-ctype _rpyobject
                get-ptr
                (lambda (o)
                  (Py_IncRef o)
                  (register-finalizer o Py_DecRef)
                  (new pyobj% [ptr o]))))

    (define-cpyfunc Py_Initialize (_fun -> _void))
    (define-cpyfunc Py_Finalize (_fun -> _void))
    (define-cpyfunc PyRun_SimpleString (_fun _string -> _int))
    (define-cpyfunc PyRun_SimpleFile (_fun _pointer _string -> _int))
    (define-cpyfunc PyString_FromString(_fun _string -> _pyobject))
    (define-cpyfunc PyString_AsString(_fun _pyobject -> _string))
    (define-cpyfunc PyImport_Import(_fun _pyobject -> _pyobject))
    (define-cpyfunc PyObject_GetAttr (_fun _pyobject _pyobject -> _pyobject))
    (define-cpyfunc PyObject_GetAttrString (_fun _pyobject _string -> _pyobject))

    ;; Ref counting
    (define-cpyfunc Py_IncRef (_fun _rpyobject -> _void))
    (define-cpyfunc Py_DecRef (_fun _rpyobject -> _void))

    (provide (all-defined-out))
    ) 
