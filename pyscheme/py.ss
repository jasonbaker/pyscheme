(module py scheme
  (require pyscheme/c)
  (require scheme/foreign)
  (unsafe!)

  (define symbol->pystring (compose PyString_FromString
                                    symbol->string))
  
  (define (pyimport dotted-name)
        (PyImport_Import (symbol->pystring dotted-name)))
          
  (provide pyimport)
)
  
