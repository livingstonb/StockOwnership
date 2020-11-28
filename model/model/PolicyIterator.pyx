
import numpy as np
cimport numpy as np

from scipy.interpolate import interp1d
from scipy import optimize
from misc cimport cfunctions
from misc.Interpolant cimport Interpolant, Interpolant2D
cimport cython

from model.ModelObjects cimport Income, Returns, Parameters

from cython.operator cimport dereference

from libc.math cimport exp, log, sqrt, pow, fabs

cdef class PolicyIterator:
	cdef:
		public Income y
		public Returns r
		public Parameters p
		public double[:] x, mgrid, lgrid

		public long maxiters, nx, ny, nz, curr_iz, curr_iy
		public Interpolant Vinterp, coninterp
		public Interpolant2D emuc_b_interp, emuc_s_interp

		public double [:,:,:] emuc_b, emuc_s
		public double[:,:,:] con, bond, stock, V
		public double[:,:] Rmat, curr_trans
		public double tol

		double[:] curr_R
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
		tempcon = 0.5 * np.asarray(self.x)
		self.con = np.tile(tempcon[:,None,None], (1,self.ny,self.nz))

		self.bond = np.zeros(np.shape(self.con))
		self.stock = np.zeros(np.shape(self.con))

		for ix in range(self.nx):
			for iy in range(self.ny):
				for iz in range(self.nz):
					if iz == 1:
						self.bond[ix,iy,iz] = (self.x[ix]  - self.con[ix,iy,iz]) / 2.0
						self.stock[ix,iy,iz] = self.bond[ix,iy,iz]
					else:
						self.bond[ix,iy,iz] = self.x[ix]  - self.con[ix,iy,iz]
						self.stock[ix,iy,iz] = 0

		util = np.asarray(cfunctions.utility3d(self.con, self.p.riskaver))
		if self.p.mutil > 0:
			util += + self.p.mutil * np.asarray(
				cfunctions.utility3d(self.bond, self.p.riskaver))

		if self.nz + self.ny == 2:
			self.V = util / (1 - self.p.beta)
		else:
			A = np.kron(self.r.mu_trans, self.y.trans)
			A = np.kron(A, np.eye(self.nx))
			util = util.reshape((-1,1))
			B = np.eye(self.nx * self.nz * self.ny) - self.p.beta * A
			Vvec = np.linalg.solve(B, util)
			self.V = Vvec.reshape((self.nx, self.ny, self.nz))


	@cython.boundscheck(False)
	@cython.wraparound(False)
	def iterate(self):
		cdef:
			double[:,:,:] bond_update, stock_update, trans, epstrans
			double[:,:,:] izmutrans, iytrans, iytrans_aug
			double[:] v0, v1, v, bgrid
			double x0[2]
			double xb1[20]
			double xb2[20]
			double norm, xval, yval, bopt, st, bstar, cstar, focval
			long ix, iy, iz, it, ib, nb
			object bounds, opts, result
			bint constrained

		norm = 1e5
		it = 0

		if self.p.mutil == 0:
			bmin = 0
		else:
			bmin = 1.0e-8

		epstrans = np.reshape(self.r.eps_dist, (1,1,-1))

		while (norm > self.tol) and (it < self.maxiters):
			self.coninterp = Interpolant(self.x, self.con)
			self.computeEMUC()

			bond_update = np.zeros(np.shape(self.bond))
			stock_update = np.zeros(np.shape(self.stock))
			for ix in range(self.nx):
				self.curr_xval = self.x[ix]
				bgrid = np.linspace(1.0e-8, self.curr_xval - 1.0e-8, num=20)
				for iy in range(self.ny):
					self.curr_iy = iy
					curr_ytrans = np.reshape(self.y.trans[iy,:], (-1, 1))
					for iz in range(self.nz):
						self.curr_iz = iz

						# rhs = self.p.beta * (np.asarray(self.emuc_s[ix,iy,iz]) - np.asarray(self.emuc_b[ix,iy,iz]))
						# bstar = cfunctions.dutilityinv(rhs / self.p.mutil, self.p.riskaver)

						# rhs = self.p.mutil * cfunctions.dutility(bstar, self.p.riskaver) + self.p.beta * np.asarray(self.emuc_b[ix,iy,iz])
						# cstar = cfunctions.dutilityinv(rhs, self.p.riskaver)

						constrained = False

						rhs = self.p.beta * np.asarray(self.emuc_s[ix,iy,iz])
						cstar = cfunctions.dutilityinv(rhs, self.p.riskaver)

						if (cstar <= 0) or (cstar > self.curr_xval):
							constrained = True

						if not constrained:
							rhs = self.p.beta * (np.asarray(self.emuc_s[ix,iy,iz]) - np.asarray(self.emuc_b[ix,iy,iz]))
							bstar = cfunctions.dutilityinv(rhs / self.p.mutil, self.p.riskaver)

							st = self.x[ix] - bstar - cstar
							if (st <= 0) or (rhs <= 0):
								constrained = True

						if not constrained:
							stock_update[ix,iy,iz] = st
							bond_update[ix,iy,iz] = bstar
						else:
							stock_update[ix,iy,iz] = 0
							self.curr_trans = np.reshape(curr_ytrans * np.reshape(self.r.mu_trans[iz,:], (1, -1)), (1, -1))

							self.zbrak(bmin, self.curr_xval-1.0e-8, 20, xb1, xb2, &nb)
							# bond_update[ix,iy,iz] = self.zriddr(xb1[0], xb2[0])
							bond_update[ix,iy,iz] = self.rtsec(xb1[0], xb2[0])


						# st = self.x[ix] - bstar - cstar
						# if st > 0:
						# 	stock_update[ix,iy,iz] = st
						# 	bond_update[ix,iy,iz] = bstar
						# else:
						# 	stock_update[ix,iy,iz] = 0
						# 	self.curr_trans = np.reshape(curr_ytrans * np.reshape(self.r.mu_trans[iz,:], (1, -1)), (1, -1))
						# 	bond_update[ix,iy,iz] = self.rtsec(bmin, self.curr_xval - 1.0e-8)

			v0 = (np.asarray(self.bond) - np.asarray(bond_update)).flatten()
			v1 = (np.asarray(self.stock) - np.asarray(stock_update)).flatten()
			v = np.concatenate((v0, v1))
			norm = np.linalg.norm(v, ord=np.inf)
			
			if (it == 0) or ((it+1) % 1 == 0):
				print(f'Iteration {it+1}, Norm = {norm}')

			self.bond = bond_update
			self.stock = stock_update
			self.con = np.asarray(self.x)[:,np.newaxis,np.newaxis] - np.asarray(self.bond) - np.asarray(self.stock)

			it += 1
	
		print("Converged")
	
	cdef double bondFOC_no_stock(self, double b):
		cdef:
			double[:] xp
			long iz2, iy2
			double lhs, rhs, ptrans

		lhs = (cfunctions.dutility(self.curr_xval - b, self.p.riskaver)
				- self.p.mutil * cfunctions.dutility(b, self.p.riskaver))

		xp = (1 + self.p.rb) * b + np.asarray(self.y.values)

		rhs = 0.0
		for iy2 in range(self.ny):
			for iz2 in range(self.nz):
				ptrans = self.r.mu_trans[self.curr_iz,iz2] * self.y.trans[self.curr_iy,iy2]
				rhs += ptrans * cfunctions.dutility(
					self.coninterp.interp_2ind(xp[iy2], iy2, iz2), self.p.riskaver)
		return lhs - self.p.beta * (1 + self.p.rb) * rhs

	@cython.boundscheck(False)
	@cython.wraparound(False)
	def computeEMUC(self):
		cdef:
			Interpolant coninterp
			double[:,:,:] u1p
			double[:,:] epsdistvec, strans, Rs_u1p, xp
			double[:] a, bgrid, bpgrid
			double bmin
			long ix, iy, iz, ib

		coninterp = Interpolant(self.x, self.con)
		epsdistvec = np.reshape(self.r.eps_dist, (-1,1))

		if self.p.mutil == 0:
			bmin = 0
		else:
			bmin = 1.0e-8

		bgrid = np.linspace(0, 1, num=100)
		bgrid = np.power(bgrid, 1.0 / 0.2)
		bgrid = bmin + (self.p.xmax - 2 * bmin) * np.asarray(bgrid)
		bpgrid = (1 + self.p.rb) * np.asarray(bgrid)

		self.emuc_b = np.zeros((self.nx,self.ny,self.nz))
		self.emuc_s = np.zeros((self.nx,self.ny,self.nz))
		for ix in range(self.nx):
			for iy in range(self.ny):
				ytrans = np.reshape(self.y.trans[iy,:], (-1, 1))
				for iz in range(self.nz):
					strans = np.reshape(ytrans * np.reshape(self.r.mu_trans[iz,:], (1, -1)), (1, -1))
					a = (1 + self.p.rb) * self.bond[ix,iy,iz] + np.asarray(self.r.Rmat[iz,:]) * self.stock[ix,iy,iz]
					xp = np.asarray(a) + np.reshape(self.y.values, (-1, 1))

					u1p = np.zeros((self.ny, self.nz, self.r.neps))
					for iz2 in range(self.nz):
						for iy2 in range(self.ny):
							conp = coninterp.interp_mat1d(xp[iy2,:], iy2, iz2)
							u1p[iy2,iz2,:] = cfunctions.dutility1d(np.ravel(conp), self.p.riskaver)

					u1pr = np.reshape(u1p, (self.ny * self.nz, self.r.neps))
					self.emuc_b[ix,iy,iz] = (1 + self.p.rb) * np.dot(strans, np.matmul(u1pr, epsdistvec))

					Rs_u1p = np.asarray(u1pr) * np.reshape(self.r.Rmat[iz,:], (1, -1))
					self.emuc_s[ix,iy,iz] = np.dot(strans, np.matmul(Rs_u1p, np.reshape(self.r.eps_dist, (-1,1))))

	# @cython.boundscheck(False)
	# @cython.wraparound(False)
	# def computeEMUC(self):
	# 	cdef:
	# 		double[:,:,:] u1p
	# 		double[:,:] strans, ytrans, xp, u1pr, Rs_u1p
	# 		double[:] R, conp
	# 		long im, il, iz, iy, iz2, iy2
	# 		double m, l

	# 	coninterp = Interpolant(self.x, self.con)
	# 	self.emuc_b = np.zeros((100, 100, self.ny, self.nz))
	# 	self.emuc_s = np.zeros((100, 100, self.ny, self.nz))

	# 	grid = np.linspace(0, 1, num=100)
	# 	grid = np.power(grid, 1.0 / 0.2)

	# 	if self.p.mutil == 0:
	# 		bmin = 0
	# 	else:
	# 		bmin = 1.0e-8

	# 	self.mgrid = bmin + (self.x[self.nx-1] - 2 * bmin) * grid
	# 	self.lgrid = grid * (1.0 - bmin)


	# 	for im in range(100):
	# 		m = self.mgrid[im]
	# 		for il in range(100):
	# 			l = self.lgrid[il]
	# 			for iy in range(self.ny):
	# 				ytrans = np.reshape(self.y.trans[iy,:], (-1, 1))
	# 				for iz in range(self.nz):
	# 					strans = np.reshape(ytrans * np.reshape(self.r.mu_trans[iz,:], (1, -1)), (1, -1))
	# 					R = 1 + self.p.rb * (1 - l) + np.asarray(self.r.rmat[iz,:]) * l
	# 					xp = np.reshape(R, (1, -1)) * m + np.reshape(self.y.values, (-1, 1))

	# 					u1p = np.zeros((self.ny, self.nz, self.r.neps))
	# 					for iz2 in range(self.nz):
	# 						for iy2 in range(self.ny):
	# 							conp = coninterp.interp_mat1d(xp[iy2,:], iy2, iz2)
	# 							u1p[iy2,iz2,:] = cfunctions.dutility1d(np.ravel(conp), self.p.riskaver)

	# 					u1pr = np.reshape(u1p, (self.ny * self.nz, self.r.neps))

	# 					self.emuc_b[im,il,iy,iz] = (1 + self.p.rb) * np.dot(strans, np.matmul(u1pr, np.reshape(self.r.eps_dist, (-1,1))))

	# 					Rs_u1p = np.asarray(u1pr) * np.reshape(self.r.Rmat[iz,:], (1, -1))
	# 					self.emuc_s[im,il,iy,iz] = np.dot(strans, np.matmul(Rs_u1p, np.reshape(self.r.eps_dist, (-1,1))))

	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double rtsec(self, double x1, double x2):
		cdef:
			long j
			double fl, f, dx, swap, xl, rts
			double xacc = 1.0e-9

		fl = self.bondFOC_no_stock(x1)
		f = self.bondFOC_no_stock(x2)

		if fabs(fl) < fabs(f):
			rts = x1
			xl = x2
			swap = fl
			fl = f
			f = swap
		else:
			xl = x1
			rts = x2

		for j in range(100):
			dx = (xl - rts) * f / (f - fl)
			xl = rts
			fl = f
			rts += dx
			f = self.bondFOC_no_stock(rts)
			if (fabs(dx) < xacc) | (f == 0.0):
				return rts

		return np.nan

	@cython.boundscheck(False)
	@cython.wraparound(False)
	cdef double zriddr(self, double x1, double x2):
		cdef:
			long j
			double ans, fh, fl, fm, fnew, s, xh, xl, sm, xnew, tsn
			double xacc = 1.0e-9
			double unused = -1.11e30

		fl = self.bondFOC_no_stock(x1)
		fh = self.bondFOC_no_stock(x2)

		if ((fl > 0.0) and (fh < 0.0)) or ((fl < 0.0) and (fh > 0.0)):
			xl = x1
			xh = x2
			ans = unused

			for j in range(100):
				xm = 0.5 * (xl + xh)
				fm = self.bondFOC_no_stock(xm)
				s = sqrt(fm * fm - fl * fh)
				if s == 0.0:
					return ans

				if fl >= fh:
					tsn = 1.0
				else:
					tsn = -1.0
				xnew = xm + (xm - xl) * (tsn * fm / s)

				if fabs(xnew - ans) <= xacc:
					return ans

				ans = xnew
				fnew = self.bondFOC_no_stock(ans)

				if fnew >= 0.0:
					tsn = 1.0
				else:
					tsn = -1.0

				if tsn * fm != fm:
					xl = xm
					fl = fm
					xh = ans
					fh = fnew
				elif tsn * fl != fl:
					xh = ans
					fh = fnew
				elif tsn * fh != fh:
					xl = ans
					fl = fnew
				else:
					return np.nan

				if fabs(xh - xl) <= xacc:
					return ans

		elif fl == 0.0:
			return x1
		elif fh == 0.0:
			return x2

		raise Exception("Root not bracketed")

	cdef void zbrak(self, double x1, double x2, long n, double[] xb1, double[] xb2, long *nb):
		cdef:
			long nbb, i
			double x, fp, fc, dx

		nbb = 0
		dx = (x2 - x1) / float(n)
		x = x1
		fp = self.bondFOC_no_stock(x)

		for i in range(n):
			x += dx
			fc = self.bondFOC_no_stock(x)

			if (fc * fp <= 0.0):
				xb1[nbb] = x - dx
				xb2[nbb] = x

				nbb += 1

				if nb[0] == nbb:
					return

			fp = fc

		nb[0] = nbb + 1