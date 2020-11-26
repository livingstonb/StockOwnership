
cdef class Returns:
	cdef:
		public double[:,:] mu_trans, Rmat, mu_cumtrans
		public double[:] mu_beliefs, eps_dist, eps_values, mu_dist, mu_cdf
		public double[:] eps_cumdist, R_actual
		public long nbeliefs, neps

cdef class Income:
	cdef:
		public double[:,:] trans, cumtrans
		public double[:] dist, values, cdf
		public double minval
		public long ny

cdef class Parameters:
	cdef:
		public double xcurv, xmax, beta, rb, mutil
		public double riskaver, r_s
		public long nx, Tsim, nsim