(module pyscheme scheme
  (require scheme/foreign)
  (unsafe!)

  (define libpython #f)

  (define (init [lib "libpython"])
    (set! libpython (ffi-lib lib)))

  (define (id->string id)
    (symbol->string (quote id)))
    

  (define-syntax (define-cpyfunc stx)
    (syntax-case stx ()
                 [(define-cpyfunc id type)
                  #'(define-values (id) 
                                   (values (get-cpyfunc (symbol->string (quote id))
                                                        type)))]))



  (define (get-cpyfunc name type)
    (lambda args
      (if libpython
        (apply (get-ffi-obj name libpython type) args)
        (error "Call init before using any Python C functions"))))
  
  (define-cpyfunc Py_Initialize (_fun -> _void))
  (provide init Py_Initialize define-cpyfunc)

  ) 
