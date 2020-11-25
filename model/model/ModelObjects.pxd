
cdef class Returns:
	cdef:
		public double[:,:] mu_trans, Rmat
		public double[:] mu_beliefs, eps_dist, eps_values, mu_dist, mu_cdf
		public long nbeliefs, neps

cdef class Income:
	cdef:
		public double[:,:] trans
		public double[:] dist, values, cdf
		public double minval
		public long ny