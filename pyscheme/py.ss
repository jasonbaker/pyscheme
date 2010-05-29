(module py scheme
  (require pyscheme/c)
  (require scheme/foreign)
  (unsafe!)

  (define symbol->pystring (compose PyString_FromString
                                    symbol->string))
  
  (define-syntax define-from-mod-attrs
    (syntax-rules ()
      [(define-from-mod-attrs mod a)
       (define-values (a) (PyObject_GetAttrString mod (symbol->string (quote a))))]
      [(define-from-mod-attrs mod a1 a2 ...)
       (begin
         (define-values (a1) (PyObject_GetAttrString mod (symbol->string (quote a1))))
         (define-from-mod-attrs a2 ...))]))
  
  (define-syntax pyimport-
    (syntax-rules ()
     [(pyimport- (#:from m #:import a ...))
       (define-from-mod-attrs (PyImport_ImportModule(symbol->string (quote m))) a ...)]
     [(pyimport- p)
      (define-values (p)
        (values (PyImport_ImportModule (symbol->string (quote p)))))]))
  
  (define-syntax pyimport
    (syntax-rules ()
      [(pyimport p)
       (pyimport- p)]
      [(pyimport p q ...)
       (begin
         (pyimport- p)
         (pyimport q ...))]))

  (define (getattr pyobj sym-name)
    (PyObject_GetAttrString pyobj (symbol->string sym-name)))

  (provide pyimport pyimport- define-from-mod-attrs getattr init)
)
  
