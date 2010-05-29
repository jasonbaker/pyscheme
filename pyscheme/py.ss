(module py scheme
  (require pyscheme/c)

  (define symbol->pystring (compose PyString_FromString
                                    symbol->string))
  
  (define pyobj%
    (class object%
      (init-field ptr)
      (super-new)))
  
  
  (define (pyimport [dotted-name null]
                    #:from [from null]
                    #:import [import- null]
                    )
    (if dotted-name
        (new pyobj% [obj-pointer (PyImport_Import (symbol->pystring dotted-name))])
        null))
          
  (provide pyimport)
)
  
