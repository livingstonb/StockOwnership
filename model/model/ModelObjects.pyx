
import numpy as np
cimport numpy as np
from misc.RandomVariables import DiscreteNormal, Rouwenhorst

cdef class Returns:
	def __init__(self, mu, width, n_eps, sd_eps):
		if width > 0:
			self.mu_beliefs = np.array([0-width, 0+width])
			self.mu_trans = np.array([[0.7, 0.3], [0.3, 0.7]])
			self.mu_dist = np.array([0.5, 0.5])
			self.nbeliefs = 2
		else:
			self.mu_beliefs = np.array([0.0])
			self.mu_trans = np.array([[1.0]])
			self.mu_dist = np.array([1.0])
			self.nbeliefs = 1

		if n_eps == 1:
			self.eps_dist = np.array([1.0])
			self.eps_values = np.array([0.0])
			self.neps = 1
		else:
			eps_distr = DiscreteNormal(0, sd_eps, n_eps, 2)
			self.eps_dist = eps_distr.dist
			self.eps_values = eps_distr.values
			self.neps = n_eps

		logR = (np.asarray(self.mu_beliefs)[:,np.newaxis]
			+ np.asarray(self.eps_values)[np.newaxis,:])
		R = np.exp(logR)
		ER = np.matmul(np.matmul(self.mu_dist, R), self.eps_dist)
		self.Rmat = R * (1 + mu) / ER

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