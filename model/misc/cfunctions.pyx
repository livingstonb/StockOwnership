
import numpy as np
cimport numpy as np
from libc.math cimport log, pow

cdef double utility(double c, double gam):
	if gam == 1.0:
		return log(c)
	else:
		return pow(c, 1 - gam) / (1 - gam)

cdef double[:] utility1d(double[:] c, double gam):
	if gam == 1.0:
		return np.log(c)
	else:
		return np.power(c, 1 - gam) / (1 - gam)

cdef double[:,:,:] utility3d(double[:,:,:] c, double gam):
	if gam == 1.0:
		return np.log(c)
	else:
		return np.power(c, 1 - gam) / (1 - gam)