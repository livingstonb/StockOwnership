import numpy as np
cimport numpy as np

cdef class Simulator:
	cdef:
		public double[:] x
		public long[:] iy, iz

	def __init__(self):
 		

	def initialize(self):
		self.x = self.income.minval * np.ones((self.n,))

		yrand = np.random.random(size=(self.n,))
		self.iy = np.argmax(
			yrand[:,np.newaxis] <= np.asarray(self.income.cdf)[np.newaxis,:],
			axis=1)

		zrand = np.random.random(size=(self.n,))
		self.iz = np.argmax(
			zrand[:,np.newaxis] <= np.asarray(self.returns.mu_cdf)[np.newaxis,:],
			axis=1)

	