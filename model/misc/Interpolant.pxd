
import numpy as np
cimport numpy as np

cdef double grid_interp(double[:] grid1, double[:] grid2,
	double[:,:,:,:] values, double x, double y, long j, long k)

cdef class Interpolant:
	cdef:
		double[:,:,:] values
		double[:] grid
		long ngrid
	cdef double interp_2ind(self, double x, int j, int k)

cdef class Interpolant2D:
	cdef:
		double[:,:,:,:] values
		double[:] grid1, grid2
	cdef double interp(self, double x, double y, int j, int k)