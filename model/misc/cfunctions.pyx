
import numpy as np
cimport numpy as np
from libc.math cimport log

cdef double utility(double c):
	return log(c)

cdef double[:] utility1d(double[:] c):
	return np.log(c)

cdef double[:,:,:] utility3d(double[:,:,:] c):
	return np.log(c)