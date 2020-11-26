
import numpy as np
cimport numpy as np
from misc.RandomVariables import DiscreteNormal, Rouwenhorst

cdef class Returns:
	def __init__(self, mu_s, width, n_eps, sd_eps, pswitch=None):
		self.mu_s = mu_s

		if width > 0:
			self.mu_beliefs = np.array([mu_s - width, mu_s + width])

			if pswitch is None:
				self.mu_trans = np.array([[0.7, 0.3], [0.3, 0.7]])
				self.mu_dist = np.array([0.5, 0.5])
			else:
				self.mu_trans = np.array([
					[1-pswitch[0], pswitch[0]],
					[pswitch[1], 1-pswitch[1]]
					])
				# Ergodic distribution
				dist = np.ones((1, 2)) / 2.0

				for i in range(1,100):
					dist = np.matmul(dist, self.mu_trans)
				self.mu_dist = dist.flatten()

			self.nbeliefs = 2
		else:
			self.mu_beliefs = np.array([mu_s])
			self.mu_trans = np.array([[1.0]])
			self.mu_dist = np.array([1.0])
			self.nbeliefs = 1

		self.mu_cdf = np.cumsum(self.mu_dist)
		self.mu_cumtrans = np.cumsum(self.mu_trans, axis=1)

		if n_eps == 1:
			self.eps_dist = np.array([1.0])
			self.eps_values = np.array([0.0])
			self.neps = 1
		else:
			eps_distr = DiscreteNormal(0, sd_eps, n_eps, 2)
			self.eps_dist = eps_distr.dist
			self.eps_cumdist = np.cumsum(self.eps_dist)
			self.eps_values = eps_distr.values
			self.neps = n_eps

		logR = (np.asarray(self.mu_beliefs)[:,np.newaxis]
			+ np.asarray(self.eps_values)[np.newaxis,:])
		self.Rmat = np.exp(logR)

		self.R_actual = np.exp(mu_s + np.asarray(self.eps_values))

cdef class Income:
	def __init__(self, mu, sigma, rho, n):
		if n == 1:
			self.dist = np.array([1.0])
			self.trans = np.array([[1.0]])
			self.values = np.array([mu])
			self.ny = n
		else:
			rouwenhorst = Rouwenhorst(0, sigma, rho, n)
			self.dist = rouwenhorst.dist
			self.trans = rouwenhorst.trans

			y = np.exp(rouwenhorst.values)
			self.values = mu * y / np.dot(y, self.dist)
			self.ny = self.values.shape[0]

		self.cdf = np.cumsum(self.dist)
		self.cumtrans = np.cumsum(self.trans, axis=1)
		self.minval = np.amin(self.values)

cdef class Parameters:
	def __init__(self, params=None):
		self.nx = 75
		self.xcurv = 0.2
		self.xmax = 25
		self.beta = 0.8
		self.rb = 0.005
		self.mutil = 0.01
		self.riskaver = 1.0
		self.Tsim = 1000
		self.nsim = int(1e5)

		if params is not None:
			for key, value in params.items():
				self.set(key, value)

	def set(self, name, value):
		if hasattr(self, name):
			setattr(self, name, value)
		else:
			raise Exception(f'"{name}" is not a valid parameter')
