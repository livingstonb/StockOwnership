
import numpy as np
cimport numpy as np

cdef class Interpolant:
	cdef:
		double[:,:,:] values
		double[:] grid
		long ngrid
	cdef double interp(self, double x, int j, int k)