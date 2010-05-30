(module conv scheme
  (require pyscheme/c)

  (define scheme->pyobj
    (match-lambda
     [(? integer? i) (PyInt_FromLong i)]
     [(? real? r) (PyFloat_FromDouble r))

  (provide scheme->pyobj)
)
