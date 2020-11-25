
import numpy as np
cimport numpy as np

from scipy.interpolate import interp1d
from scipy import optimize
from misc cimport cfunctions
from misc.Interpolant cimport Interpolant
cimport cython

from model.ModelObjects cimport Income, Returns

cdef class PolicyIterator:
	cdef:
		public Income y
		public Returns r
		public dict p
		public double[:] x

		public long maxiters, nx, ny, nz
		public list Vinterp

		public double[:,:,:] con, bond, stock, V
		public double[:,:] Rmat
		public double tol

	def __init__(self, params, returns, income, xgrid):
		self.p = params
		self.r = returns
		self.y = income
		self.x = xgrid
		self.tol = 1.0e-7
		self.maxiters = int(1e5)

		self.nx = params['nx']
		self.ny = income.ny
		self.nz = returns.nbeliefs
	
	def makeGuess(self):
		tempcon = (self.p['rb'] + 0.01) * np.asarray(self.x)
		self.con = np.tile(tempcon[:,None,None], (1,self.ny,self.nz))
		self.bond = (np.asarray(self.x)[:,np.newaxis,np.newaxis]  - np.asarray(self.con)) / 2.0
		self.stock = self.bond
		self.V = cfunctions.utility3d(self.con) / (1 - np.asarray(self.p['beta']))

	@cython.boundscheck(False)
	@cython.wraparound(False)
	def iterate(self):
		cdef:
			double[:,:,:] bond_update, stock_update, V_update, trans, epstrans
			double[:,:,:] izmutrans, iytrans
			double[:,:] A
			double[:] v0, v1, v, transvec
			double x0[2]
			double norm, xval, yval
			long ix, iy, iz, it
			list lb, ub
			object bounds, opts

		norm = 1e5
		it = 0

		if self.p['mutil'] == 0:
			bmin = 0
		else:
			bmin = 1.0e-8

		opts = {'gtol':1.0e-7}
		epstrans = np.reshape(self.r.eps_dist, (1,1,-1))

		while (norm > self.tol) and (it < self.maxiters):
			self.Vinterp = []
			for iy in range(self.y.ny):
				self.Vinterp.append([])
				for iz in range(self.nz):
					self.Vinterp[iy].append(Interpolant(self.x, self.V[:,iy,iz]))

			bond_update = np.zeros(np.shape(self.bond))
			stock_update = np.zeros(np.shape(self.stock))
			V_update = np.zeros(np.shape(self.V))
			for ix in range(self.nx):
				xval = self.x[ix]

				lb = [bmin, 0.0]
				ub = [xval - 1.0e-8, 1.0 - bmin]
				bounds = optimize.Bounds(lb, ub, keep_feasible=[True, True])

				for iy in range(self.y.ny):
					yval = self.y.values[iy]
					iytrans = np.reshape(self.y.trans[iy,:], (-1,1,1))

					for iz in range(self.nz):
						izmutrans = np.reshape(self.r.mu_trans[iz,:], (1,-1,1))
						trans = np.asarray(iytrans) * np.asarray(izmutrans) * np.asarray(epstrans)
						transvec = np.asarray(trans).flatten()

						fn = lambda v: -self.evaluateV(xval, iy, iz, transvec, v)

						x0[0] = self.bond[ix,iy,iz] + self.stock[ix,iy,iz]
						x0[1] = self.stock[ix,iy,iz] / x0[0]
						res = optimize.minimize(fn, np.asarray(x0), bounds=bounds, method='L-BFGS-B', options=opts)
						bond_update[ix,iy,iz] = res.x[0] * (1 - res.x[1])
						stock_update[ix,iy,iz] = res.x[0] * res.x[1]
						V_update[ix,iy,iz] = -fn(res.x)
			
			v0 = (np.asarray(self.bond) - np.asarray(bond_update)).flatten()
			v1 = (np.asarray(self.stock) - np.asarray(stock_update)).flatten()
			v = np.concatenate((v0, v1))
			norm = np.linalg.norm(v, ord=np.inf)
			
			print(f'Norm = {norm}')
			self.bond = bond_update
			self.stock = stock_update
			self.V = V_update

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

		b = v[0] * (1 - v[1])
		s = v[0] * v[1]
		c = xval - v[0]
		u = cfunctions.utility(c) + self.p['mutil'] * cfunctions.utility(b)

		x_next = np.zeros((self.r.neps,))
		V_next = np.zeros((self.ny,self.nz,self.r.neps))
		for iy2 in range(self.ny):
			for iz2 in range(self.nz):
				for ieps in range(self.r.neps):
					x_next[ieps] = (1 + self.p['rb']) * b + np.asarray(self.r.Rmat[iz,ieps]) * s + self.y.values[iy2]
				
				vtemp = self.Vinterp[iy2][iz2].interp_mat1d(x_next)
				V_next[iy2,iz2,...] = vtemp

		EV = np.dot(trans, np.asarray(V_next).flatten())

		return u + self.p['beta'] * EV