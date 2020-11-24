
import numpy as np
cimport numpy as np

from scipy.interpolate import interp1d
from scipy import optimize
from misc cimport cfunctions
from misc.Interpolant cimport Interpolant
cimport cython

cdef class PolicyIterator:
	cdef:
		public dict p, r, y
		public object interp
		public double[:] x

		public long maxiters
		public list Vinterp

		public double[:,:,:] con, bond, stock, V
		public double[:,:] Rmat
		public double[:] rshockdist, rshockgrid
		public double tol

	def __init__(self, params, returns, income, xgrid):
		self.p = params
		self.r = returns
		self.y = income
		self.x = xgrid
		self.tol = 1.0e-7
		self.maxiters = int(1e5)

		self.rshockdist = np.array([0.25, 0.25, 0.25, 0.25])
		self.rshockgrid = np.array([-0.002, -0.001, 0.001, 0.002])

		self.Rmat = 1 + np.asarray(self.rshockgrid).reshape((1,-1)) + self.r['grid'].reshape((-1,1))
	
	def makeGuess(self):
		tempcon = (self.p['rb'] + 0.01) * np.asarray(self.x[:,None]) + 0.5 * np.reshape(self.y['vec'], (1,-1))
		self.con = np.tile(tempcon[:,:,None], (1,1,self.r['nz']))
		self.bond = (np.asarray(self.x[:,None,None])  - np.asarray(self.con)) / 2.0
		self.stock = self.bond
		self.V = cfunctions.utility3d(self.con) / (1 - np.asarray(self.p['beta']))

	@cython.boundscheck(False)
	@cython.wraparound(False)
	def iterate(self):
		cdef:
			double[:,:,:] bond_update, stock_update, V_update, trans
			double[:,:] A
			double[:] lb, ub, x0, v0, v1, v, transvec
			double norm, xval, yval
			long ix, iy, iz, it

		norm = 1e5
		it = 0
		
		A = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
		lb = np.array([1.0e-8, 0.0, 0.0])

		while (norm > self.tol) and (it < self.maxiters):
			self.Vinterp = []
			for iy in range(self.y['ny']):
				self.Vinterp.append([])
				for iz in range(self.r['nz']):
					self.Vinterp[iy].append(Interpolant(self.x, self.V[:,iy,iz]))

			bond_update = np.zeros(np.shape(self.bond))
			stock_update = np.zeros(np.shape(self.stock))
			V_update = np.zeros(np.shape(self.V))
			for ix in range(self.p['nx']):
				xval = self.x[ix]
				ub = np.array([np.inf, np.inf, xval - 1.0e-5])
				constraint = optimize.LinearConstraint(A, lb, ub, keep_feasible=True)

				for iy in range(self.y['ny']):
					yval = self.y['vec'][iy]
					iytrans = np.reshape(self.y['trans'][iy,:], (-1,1,1))

					for iz in range(self.r['nz']):
						izmutrans = np.reshape(self.r['mutrans'][iz,:], (1,-1,1))
						epstrans = np.reshape(self.rshockdist, (1,1,-1))
						trans = iytrans * izmutrans * epstrans
						transvec = np.asarray(trans).flatten()

						fn = lambda v: -self.evaluateV(xval, iy, iz, transvec, v)
						x0 = np.array([self.bond[ix,iy,iz], self.stock[ix,iy,iz]])
						res = optimize.minimize(fn, x0, constraints=(constraint), method='SQSLP')
						bond_update[ix,iy,iz] = res.x[0]
						stock_update[ix,iy,iz] = res.x[1]
						V_update[ix,iy,iz] = -fn(res.x)
				
			self.V = V_update
			
			v0 = (np.asarray(self.bond) - np.asarray(bond_update)).flatten()
			v1 = (np.asarray(self.stock) - np.asarray(stock_update)).flatten()
			v = np.concatenate((v0, v1))
			norm = np.linalg.norm(v, ord=np.inf)
			
			print(f'Norm = {norm}')
			self.bond = bond_update
			self.stock = stock_update

			it += 1
		
		print("Converged")


	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double evaluateV(self, double xval, long iy, long iz, double[:] trans, double[:] v):
		cdef:
			double[:,:,:] V_next
			double[:] x_next, vtemp
			double b, s, c, u, EV
			long iy2, iz2, ieps

		b = v[0]
		s = v[1]
		c = xval - b - s
		u = cfunctions.utility(c) + self.p['mutil'] * cfunctions.utility(b)

		x_next = np.zeros((self.rshockdist.shape[0],))
		V_next = np.zeros((self.y['ny'],self.r['nz'],self.rshockdist.shape[0]))
		for iy2 in range(self.y['ny']):
			for iz2 in range(self.r['nz']):
				for ieps in range(self.rshockdist.shape[0]):
					x_next[ieps] = (1 + self.p['rb']) * b + np.asarray(self.Rmat[iz,ieps]) * s + self.y['vec'][iy2]
				
				vtemp = self.Vinterp[iy2][iz2].interp_mat1d(x_next)
				for ieps in range(self.rshockdist.shape[0]):
					V_next[iy2,iz2,ieps] = vtemp[ieps]

		EV = np.dot(trans, np.asarray(V_next).flatten())

		return u + self.p['beta'] * EV