
import numpy as np
cimport numpy as np

from scipy.interpolate import interp1d
from scipy import optimize
from misc cimport cfunctions
from misc.Interpolant cimport Interpolant

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
		tempcon = self.p['rb'] * np.asarray(self.x)
		self.con = np.tile(tempcon[:,None,None], (1,self.y['ny'],self.r['nz']))
		self.bond = (np.asarray(self.x[:,None,None])  - np.asarray(self.con)) / 2.0
		self.stock = self.bond
		self.V = cfunctions.utility3d(self.con) / (1 - np.asarray(self.p['beta']))
		
	def iterate(self):
		cdef:
			double[:,:,:] bond_update, stock_update, V_update
			double[:,:] A, ytrans
			double[:] lb, ub, x0, v0, v1, v
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
					# self.Vinterp[iy].append(
					# 	interp1d(self.x, self.V[:,iy,iz],
					# 		bounds_error=False, fill_value=(self.V[0,iy,iz], self.V[-1,iy,iz]))
					# )
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
					ytrans = np.asarray(self.y['trans'][iy,:]).reshape((1,-1))

					for iz in range(self.r['nz']):
						fn = lambda v: -self.evaluateV(xval, ytrans, iy, iz, v)
						x0 = np.array([self.bond[ix,iy,iz], self.stock[ix,iy,iz]])
						res = optimize.minimize(fn, x0, constraints=(constraint), method='trust-constr')
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

	cdef double evaluateV(self, double xval, double[:,:] ytrans, long iy, long iz, double[:] v):
		cdef:
			double[:,:] x_next, V_next
			double b, s, c, u, EV
			long iz2

		b = v[0]
		s = v[1]
		c = xval - b - s
		u = cfunctions.utility(c) + self.p['mutil'] * cfunctions.utility(b)

		x_next = (1 + self.p['rb']) * b + np.asarray(self.Rmat[iz,:]) * s + self.y['bc']
		
		V_next = np.zeros(np.shape(x_next))
		for iz2 in range(self.r['nz']):
			V_next +=  np.asarray(self.Vinterp[iy][iz2].interp_mat2d(x_next)) / float(self.r['nz'])

		EV = np.matmul(np.matmul(ytrans, V_next), self.rshockdist)

		return u + self.p['beta'] * EV