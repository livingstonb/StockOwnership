import numpy as np
from scipy import stats

class DiscreteNormal:
	def __init__(self, mu, sigma, n, width):
		x = np.linspace(
			mu - width * sigma, mu + width * sigma, num=n)
		self.values = x

		if n == 2:
			self.dist = 0.5 * np.ones((n,))
		else:
			self.dist = np.ones((n,))
			self.dist[0] = stats.norm.cdf(
				x[0] + 0.5 * (x[1] - x[0]), loc=mu, scale=sigma)

			for i in range(1, n-1):
				p1 = stats.norm.cdf(
					x[i] + 0.5 * (x[i+1] - x[i]), loc=mu, scale=sigma)
				p2 = stats.norm.cdf(
						x[i] - 0.5 * (x[i] - x[i-1]), loc=mu, scale=sigma)
				self.dist[i] = p1 - p2

			self.dist[n-1] = 1 - self.dist[:n-1].sum()

		Ex = x.dot(self.dist)

		s = np.power(x, 2.0).dot(self.dist) - Ex ** 2.0
		SDx = np.sqrt(s)
		self.err = SDx - sigma

class Rouwenhorst:
	def __init__(self, mu, sigma, rho, n):
		width = np.sqrt((n-1) * sigma ** 2.0 / (1-rho) ** 2.0)
		self.values = np.linspace(mu-width, mu+width, n)
		p0 = (1 + rho) / 2.0
		trans = np.array([[p0, 1-p0], [1-p0, p0]])

		if n > 2:
			for i in range(n-2):
				m = trans.shape[0]
				cstr = np.zeros((m, 1))
				cstr_ext = np.zeros((m+1, 1))

				mat1 = np.concatenate((trans, cstr), axis=1)
				mat1 = p0 * np.concatenate((mat1, cstr_ext.T))

				mat2 = np.concatenate((cstr, trans), axis=1)
				mat2 = (1-p0) * np.concatenate((mat2, cstr_ext.T))

				mat3 = np.concatenate((trans, cstr), axis=1)
				mat3 = (1-p0) * np.concatenate((cstr_ext.T, mat3))

				mat4 = np.concatenate((cstr, trans), axis=1)
				mat4 = p0 * np.concatenate((cstr_ext.T, mat4))

				trans = mat1 + mat2 + mat3 + mat4

			trans = trans / np.sum(trans, axis=1)[:,np.newaxis]

		# Ergodic distribution
		dist = np.ones((1, n)) / float(n)

		for i in range(1,100):
			dist = np.matmul(dist, trans)

		self.trans = trans
		self.dist = dist.flatten()