
import numpy as np
cimport numpy as np

cdef class Interpolant:
	cdef:
		double[:] grid, values
		long ngrid
	cdef double interp(self, double x)