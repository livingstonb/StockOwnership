import numpy as np
cimport numpy as np

from model.ModelObjects cimport Parameters, Income, Returns
from misc.Interpolant cimport Interpolant
from libc.math cimport fmax

cdef class Simulator:
	cdef:
		public Interpolant binterp, sinterp
		double[:] x, xgrid, b, s, c
		long[:] iy, iz
		public long T, n, tkeep
		Parameters p
		Income income
		Returns returns
		public object bonds, stocks, con, cash, earnings, beliefs

	def __init__(self, bond, stock, params, income, returns, xgrid):
		self.p = params
		self.T = params.Tsim
		self.n = params.nsim
		self.tkeep = 8
		self.income = income
		self.returns = returns
		self.xgrid = xgrid

		self.binterp = Interpolant(self.xgrid, bond)
		self.sinterp = Interpolant(self.xgrid, stock)
		self.bonds = np.zeros((self.n, self.tkeep))
		self.stocks = np.zeros((self.n, self.tkeep))
		self.con = np.zeros((self.n, self.tkeep))
		self.cash = np.zeros((self.n, self.tkeep))
		self.earnings = np.zeros((self.n, self.tkeep))
		self.beliefs = np.zeros((self.n, self.tkeep), dtype=np.int32)

	def initialize(self):
		self.x = self.xgrid[0] * np.ones((self.n,))
		self.b = np.zeros((self.n,))
		self.s = np.zeros((self.n,))
		self.c = np.zeros((self.n,))

		np.random.seed(2009)

		yrand = np.random.random(size=(self.n,))
		self.iy = np.argmax(
			yrand[:,np.newaxis] <= np.asarray(self.income.cdf)[np.newaxis,:],
			axis=1)

		zrand = np.random.random(size=(self.n,))
		self.iz = np.argmax(
			zrand[:,np.newaxis] <= np.asarray(self.returns.mu_cdf)[np.newaxis,:],
			axis=1)

	def simulate(self):
		cdef:
			long it, kt = 0

		self.initialize()
		for it in range(self.T):
			self.compute_decisions()

			if it >= self.T - self.tkeep:
				self.bonds[:,kt] = np.asarray(self.b)
				self.stocks[:,kt] = np.asarray(self.s)
				self.cash[:,kt] = np.asarray(self.x)
				self.con[:,kt] = np.asarray(self.c)
				self.earnings[:,kt] = np.asarray(self.income.values)[self.iy]
				self.beliefs[:,kt] = np.asarray(self.iz)
				kt += 1

			self.update_income()
			self.update_cash()
			self.update_beliefs()

	def compute_decisions(self):
		cdef:
			long i, iy, iz
			double xval

		for i in range(self.n):
			iy = self.iy[i]
			iz = self.iz[i]
			xval = self.x[i]
			self.b[i] =  self.binterp.interp_2ind(xval, iy, iz)
			self.s[i] = self.sinterp.interp_2ind(xval, iy, iz)
			self.c[i] = fmax(xval - self.b[i] - self.s[i], 1.0e-8)

	def update_income(self):
		yrand = np.random.random(size=(self.n,))
		self.iy = np.argmax(
			yrand[:,np.newaxis] <= np.asarray(self.income.cumtrans)[self.iy,:],
			axis=1)

	def update_cash(self):
		cdef:
			long[:] ieps
			double[:] Rvals
			long i, iieps, iy

		# epsrand = np.random.random(size=(self.n,))
		# ieps = np.argmax(
		# 	epsrand[:,np.newaxis] <= np.asarray(self.returns.eps_cumdist)[np.newaxis,:],
		# 	axis=1)

		for i in range(self.n):
			# iieps = ieps[i]
			iy = self.iy[i]
			self.x[i] = (1 + self.p.rb) * self.b[i] + (1 + self.returns.mu_s) * self.s[i] + self.income.values[iy]

	def update_beliefs(self):
		zrand = np.random.random(size=(self.n,))
		self.iz = np.argmax(
			zrand[:,np.newaxis] <= np.asarray(self.returns.mu_cumtrans)[self.iz,:],
			axis=1)