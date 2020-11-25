
cdef class Returns:
	cdef:
		public double[:,:] mu_trans, Rmat
		public double[:] mu_beliefs, eps_dist, eps_values, mu_dist
		public long nbeliefs, neps

cdef class Income:
	cdef:
		public double[:,:] trans
		public double[:] dist, values
		public long ny