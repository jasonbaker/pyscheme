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

    (define PyObject (_cpointer 'pyobject))

    (define-cpyfunc Py_Initialize (_fun -> _void))
    (define-cpyfunc Py_Finalize (_fun -> _void))
    (define-cpyfunc PyRun_SimpleString (_fun _string -> _int))
    (define-cpyfunc PyRun_SimpleFile (_fun _pointer _string -> _int))
    (define-cpyfunc PyString_FromString(_fun _string -> PyObject))
    (define-cpyfunc PyString_AsString(_fun PyObject -> _string))
    (define-cpyfunc PyImport_Import(_fun PyObject -> PyObject))
    (define-cpyfunc PyObject_GetAttr (_fun PyObject PyObject -> PyObject))
    (define-cpyfunc PyObject_GetAttrString (_fun PyObject _string -> PyObject))

    ;; Ref counting
    (define-cpyfunc Py_IncRef (_fun PyObject -> _void))
    (define-cpyfunc Py_DecRef (_fun PyObject -> _void))

    (provide (all-defined-out))
    ) 
