
import numpy as np
cimport numpy as np
from libc.math cimport log, pow, fabs

# ctypedef double (*cfptr)(double)

cdef double utility(double c, double gam):
	if gam == 1.0:
		return log(c)
	else:
		return pow(c, 1 - gam) / (1 - gam)

cdef double dutility(double c, double gam):
	return pow(c, -gam)

cdef double dutilityinv(double u, double gam):
	return pow(u, -1/gam)

cdef double[:] dutility1d(double[:] c, double gam):
	return np.power(c, -gam)

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

cdef double rtsec(cfptr fn, void* args, double x1, double x2, double xacc):
	cdef:
		long j
		double fl, f, dx, swap, xl, rts

	fl = fn(x1, args)
	f = fn(x2, args)

	if fabs(fl) < fabs(f):
		rts = x1
		xl = x2
		swap = fl
		fl = f
		f = swap
	else:
		xl = x1
		rts = x2

	for j in range(100):
		DX = (xl - rts) * f / (f - fl)
		xl = rts
		fl = f
		rts += dx
		f = fn(rts, args)
		if (fabs(dx) < xacc) | (f == 0.0):
			return rts

	return np.nan