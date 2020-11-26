
import numpy as np
cimport numpy as np

from scipy.interpolate import interp1d
from scipy import optimize
from misc cimport cfunctions
from misc.Interpolant cimport Interpolant
cimport cython

from model.ModelObjects cimport Income, Returns, Parameters

from libc.math cimport exp, log, sqrt, pow

cdef class PolicyIterator:
	cdef:
		public Income y
		public Returns r
		public Parameters p
		public double[:] x

		public long maxiters, nx, ny, nz
		public Interpolant Vinterp

		public double[:,:,:] con, bond, stock, V
		public double[:,:] Rmat
		public double tol

		double[:] curr_R, curr_trans
		double curr_xval

	def __init__(self, params, returns, income, xgrid):
		self.p = params
		self.r = returns
		self.y = income
		self.x = xgrid
		self.tol = 1.0e-7
		self.maxiters = int(1e5)

		self.nx = params.nx
		self.ny = income.ny
		self.nz = returns.nbeliefs
	
	def makeGuess(self):
		tempcon = (self.p.rb + 0.01) * np.asarray(self.x)
		self.con = np.tile(tempcon[:,None,None], (1,self.ny,self.nz))
		self.bond = (np.asarray(self.x)[:,np.newaxis,np.newaxis]  - np.asarray(self.con)) / 2.0
		self.stock = self.bond
		self.V = cfunctions.utility3d(self.con, self.p.riskaver) / (1 - np.asarray(self.p.beta))

	@cython.boundscheck(False)
	@cython.wraparound(False)
	def iterate(self):
		cdef:
			double[:,:,:] bond_update, stock_update, V_update, trans, epstrans
			double[:,:,:] izmutrans, iytrans, iytrans_aug
			double[:,:] A
			double[:] v0, v1, v, transvec, lb, ub, Rvec
			double x0[2]
			double xf[2]
			double norm, xval, yval, sav
			long ix, iy, iz, it
			object bounds, opts, result

		norm = 1e5
		it = 0

		if self.p.mutil == 0:
			bmin = 0
		else:
			bmin = 1.0e-8
		lb = np.array([bmin, 0.0])

		opts = {'gtol':1.0e-9, 'ftol':1.0e-9, 'eps':5.0e-8}
		epstrans = np.reshape(self.r.eps_dist, (1,1,-1))

		while (norm > self.tol) and (it < self.maxiters):
			self.Vinterp = Interpolant(self.x, self.V)

			bond_update = np.zeros(np.shape(self.bond))
			stock_update = np.zeros(np.shape(self.stock))
			V_update = np.zeros(np.shape(self.V))
			for ix in range(self.nx):
				self.curr_xval = self.x[ix]
				ub = np.array([self.curr_xval - 1.0e-8, 1.0 - bmin])
				bounds = optimize.Bounds(lb, ub, keep_feasible=[True, True])

				for iy in range(self.y.ny):
					iytrans = np.reshape(self.y.trans[iy,:], (-1,1,1))
					iytrans_aug =  np.asarray(iytrans) * np.asarray(epstrans)

					for iz in range(self.nz):
						izmutrans = np.reshape(self.r.mu_trans[iz,:], (1,-1,1))
						trans = np.asarray(iytrans_aug) * np.asarray(izmutrans)
						self.curr_trans = np.asarray(trans).flatten()
						self.curr_R = self.r.Rmat[iz,:]

						x0[0] = self.bond[ix,iy,iz] + self.stock[ix,iy,iz]
						x0[1] = self.stock[ix,iy,iz] / (self.bond[ix,iy,iz] + self.stock[ix,iy,iz])
						result = optimize.minimize(lambda v: -self.evaluateV(v), np.asarray(x0),
							bounds=bounds, method='L-BFGS-B', options=opts)

						# x0[0] = (self.bond[ix,iy,iz] + self.stock[ix,iy,iz]) / self.curr_xval
						# x0[0] = log(x0[0] / (1 - x0[0]))
						# x0[1] = self.stock[ix,iy,iz] / (self.bond[ix,iy,iz] + self.stock[ix,iy,iz])
						# x0[1] = sqrt(x0[1] / (1-x0[1]))
						# result = optimize.minimize(lambda v: -self.evaluateV(v), np.asarray(x0),
						# 	method='Powell', options=opts)
						# xf[0] = exp(result.x[0]) / (1 + exp(result.x[0]))
						# xf[1] = pow(result.x[1], 2.0) / (1 + pow(result.x[1], 2.0))
						# sav = xf[0] * self.curr_xval
						# bond_update[ix,iy,iz] = sav * (1 - xf[1])
						# stock_update[ix,iy,iz] = sav * xf[1]
						bond_update[ix,iy,iz] = result.x[0] * (1 - result.x[1])
						stock_update[ix,iy,iz] = result.x[0] * result.x[1]
						V_update[ix,iy,iz] = -result.fun
			
			v0 = (np.asarray(self.bond) - np.asarray(bond_update)).flatten()
			v1 = (np.asarray(self.stock) - np.asarray(stock_update)).flatten()
			v = np.concatenate((v0, v1))
			norm = np.linalg.norm(v, ord=np.inf)
			
			if (it == 0) or ((it+1) % 5 == 0):
				print(f'Iteration {it+1}, Norm = {norm}')

			self.bond = bond_update
			self.stock = stock_update
			self.V = V_update

			it += 1
		
		print("Converged")


	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double evaluateV(self, double[:] v):
		cdef:
			double[:,:,:] V_next
			double[:] x_next, vtemp
			double b, s, c, u, EV, sav
			long iy2, iz2, ieps

		b = v[0] * (1 - v[1])
		s = v[0] * v[1]
		c = self.curr_xval - b - s
		u = cfunctions.utility(c, self.p.riskaver
			) + self.p.mutil * cfunctions.utility(b, self.p.riskaver)

		x_next = np.zeros((self.r.neps,))
		V_next = np.zeros((self.ny,self.nz,self.r.neps))
		for iy2 in range(self.ny):
			for iz2 in range(self.nz):
				x_next = (1 + self.p.rb) * b + np.asarray(
					self.curr_R) * s + self.y.values[iy2]
				vtemp = self.Vinterp.interp_mat1d(x_next, iy2, iz2)
				V_next[iy2,iz2,...] = vtemp

		EV = np.dot(self.curr_trans, np.asarray(V_next).flatten())

		return u + self.p.beta * EV