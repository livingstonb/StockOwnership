
ctypedef double (*cfptr)(double, void*)

cdef double utility(double c, double gam)

cdef double dutility(double c, double gam)

cdef double dutilityinv(double u, double gam)

cdef double[:] dutility1d(double[:] c, double gam)

cdef double[:] utility1d(double[:] c, double gam)

cdef double[:,:,:] utility3d(double[:,:,:] c, double gam)

cdef double rtsec(cfptr fn, void* args, double x1, double x2, double xacc)