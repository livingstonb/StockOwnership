import numpy as np
cimport numpy as np

from libc.math cimport fmax, fmin

cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double grid_interp(double[:] grid1, double[:] grid2,
	double[:,:,:,:] values, double x, double y, long j, long k):
	cdef:
		long ix, iy
		double wx, wy

	ix = fastSearchSingleInput(grid1, x)
	iy = fastSearchSingleInput(grid2, y)

	wx = (grid1[ix] - x) / (grid1[ix] - grid1[ix-1])
	wx = fmin(fmax(wx, 0), 1)

	wy = (grid2[iy] - y) / (grid2[iy] - grid2[iy-1])
	wy = fmin(fmax(wy, 0), 1)

	return (
		wx * wy * values[ix-1,iy-1,j,k]
			+ (1 - wx) * wy * values[ix,iy-1,j,k]
			+ wx * (1 - wy) * values[ix-1,iy,j,k]
			+ (1 - wx) * (1 - wy) * values[ix,iy,j,k]
		)


cdef class Interpolant:
	def __init__(self, grid, values):
		self.grid = grid
		self.ngrid = grid.shape[0]
		self.values = values

	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double interp_2ind(self, double x, int j, int k):
		cdef:
			long ix
			double z

		ix = fastSearchSingleInput(self.grid, x)

		z = (self.grid[ix] - x) / (self.grid[ix] - self.grid[ix-1])
		z = fmin(fmax(z, 0), 1)
		return z * self.values[ix-1,j,k] + (1 - z) * self.values[ix,j,k]

	@cython.boundscheck(False)
	@cython.wraparound(False)
	def interp_mat1d(self, double[:] x, int j, int k):
		cdef:
			double[:] fitted
			long n, i

		n = x.shape[0]
		fitted = np.zeros(np.shape(x))

		for i in range(n):
			fitted[i] = self.interp_2ind(x[i], j, k)

		return fitted

	# @cython.boundscheck(False)
	# @cython.wraparound(False)
	# def interp_mat2d(self, double[:,:] x, int j, int k):
	# 	cdef:
	# 		double[:,:] fitted
	# 		long n, m, i, j

	# 	n = x.shape[0]
	# 	m = x.shape[1]
	# 	fitted = np.zeros(np.shape(x))

	# 	for i in range(n):
	# 		for j in range(m):
	# 			fitted[i,j] = self.interp(x[i,j])

	# 	return fitted

	# @cython.boundscheck(False)
	# @cython.wraparound(False)
	# def interp_mat3d(self, double[:,:,:] x):
	# 	cdef:
	# 		double[:,:,:] fitted
	# 		long n, m, l, i, j, k

	# 	n = x.shape[0]
	# 	m = x.shape[1]
	# 	l = x.shape[2]
	# 	fitted = np.zeros((n,m,l))

	# 	for i in range(n):
	# 		for j in range(m):
	# 			for k in range(l):
	# 				fitted[i,j,k] = self.interp(x[i,j,k])

	# 	return fitted

cdef class Interpolant2D:
	def __init__(self, grid1, grid2, values):
		self.grid1 = grid1
		self.grid2 = grid2
		self.values = values

	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double interp(self, double x, double y, int j, int k):
		cdef:
			long ix, iy
			double wx, wy

		ix = fastSearchSingleInput(self.grid1, x)
		iy = fastSearchSingleInput(self.grid2, y)

		wx = (self.grid1[ix] - x) / (self.grid1[ix] - self.grid1[ix-1])
		wx = fmin(fmax(wx, 0), 1)

		wy = (self.grid2[iy] - y) / (self.grid2[iy] - self.grid2[iy-1])
		wy = fmin(fmax(wy, 0), 1)

		return (
			wx * wy * self.values[ix-1,iy-1,j,k]
				+ (1 - wx) * wy * self.values[ix,iy-1,j,k]
				+ wx * (1 - wy) * self.values[ix-1,iy,j,k]
				+ (1 - wx) * (1 - wy) * self.values[ix,iy,j,k]
			)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef long fastSearchSingleInput(double[:] grid, double val):
	cdef:
		long lower, upper, midpt = 0
		double valMidpt = 0.0
		long nGrid = grid.shape[0]

	if val >= grid[nGrid-1]:
		return nGrid - 1
	elif val <= grid[0]:
		return 1

	lower = -1
	upper = nGrid

	while (upper - lower) > 1:
		midpt = (upper + lower) >> 1
		valMidpt = grid[midpt]

		if val == valMidpt:
			return midpt + 1
		elif val > valMidpt:
			lower = midpt
		else:
			upper = midpt

	if val > valMidpt:
		return midpt + 1
	else:
		return midpt