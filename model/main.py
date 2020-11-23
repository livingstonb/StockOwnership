import numpy as np
from scipy.interpolate import interp1d
from scipy import optimize
from matplotlib import pyplot as plt

def create_grid(gmin, gmax, gcurv, n):
	grid = np.linspace(0, 1, num=n)
	grid = grid ** (1.0 / gcurv)
	grid = gmin + (gmax - gmin) * grid
	return grid

def get_params():
	params = dict()
	params['nx'] = 75
	params['xcurv'] = 0.1
	params['xmin'] = 0
	params['xmax'] = 25
	params['beta'] = 0.9
	params['rb'] = 0.005
	params['mutil'] = 0.1
	return params

def get_rdist():
	returns = dict()
	returns['dist'] = np.array([0.3, 0.4, 0.3])
	returns['grid'] = np.array([-0.01, 0.0, 0.01])
	returns['mu'] = np.array([0, 0.01, 0.015])
	returns['mutrans'] = np.array([[1/3, 1/3, 1/3], [1/3, 1/3, 1/3], [1/3, 1/3, 1/3]])
	returns['pmu'] = np.array([1/3, 1/3, 1/3])
	returns['nz'] = len(returns['mu'])
	return returns

def utility(c):
	return np.log(c)

def utility1(c):
	return 1.0 / c

class PolicyIterator:
	def __init__(self, params, returns, income, xgrid):
		self.p = params
		self.r = returns
		self.y = income
		self.x = xgrid
		self.tol = 1.0e-7
		self.maxiters = 1e5
		
		self.con = None
		self.bond = None
		self.stock = None
		self.V = None
	
	def makeGuess(self):
		self.con = self.p['rb'] * self.x['vec']
		self.con = np.tile(self.con[...,np.newaxis], (1,3))
		self.bond = (self.x['bc']  - self.con) / 2.0
		self.stock = self.bond
		self.V = utility(self.con) / (1 - self.p['beta'])
		
	def iterate(self):
		norm = 1e5
		it = 0
		
		A = np.array([[1, 0], [0, 1], [1, 1]])
		lb = np.array([1.0e-8, 0, 0])

		while (norm > self.tol) and (it < self.maxiters):
			self.Vinterp = []
			for iz in range(self.r['nz']):
				self.Vinterp.append(interp1d(self.x['vec'], self.V[:,iz], bounds_error=False, fill_value=(self.V[0,iz],self.V[-1,iz])))
			
			bond_update = np.zeros(self.bond.shape)
			stock_update = np.zeros(self.stock.shape)
			V_update = np.zeros(self.V.shape)
			for ix in range(self.p['nx']):
				ub = np.array([np.inf, np.inf, self.x['vec'][ix] - 1.0e-5])
				constraint = optimize.LinearConstraint(A, lb, ub, keep_feasible=True)
	
				for iz in range(self.r['nz']):
					fn = lambda v: -self.evaluateV(ix, iz, v)
					x0 = np.array([self.bond[ix,iz], self.stock[ix,iz]])
					res = optimize.minimize(fn, x0, constraints=(constraint), method='trust-constr')
					bond_update[ix,iz] = res.x[0]
					stock_update[ix,iz] = res.x[1]
					V_update[ix,iz] = -fn(res.x)
				
			self.V = V_update
			
			v0 = (self.bond - bond_update).flatten()
			v1 = (self.stock - stock_update).flatten()
			v = np.concatenate((v0, v1))
			norm = np.linalg.norm(v, ord=np.inf)
			
			print(f'Norm = {norm}')
			self.bond = bond_update
			self.stock = stock_update

			it += 1
		
		print("Converged")

	def evaluateV(self, ix, iz, v):
		b = v[0]
		s = v[1]
		c = self.x['vec'][ix] - b - s
		u = utility(c) + self.p['mutil'] * utility(b)

		x_next = (1 + self.p['rb']) * b + (1 + self.r['grid'] + self.r['mu'][iz]) * s + self.y
		
		V_next = np.zeros((len(self.r['grid']),))
		for iz2 in range(self.r['nz']):
			V_next +=  self.Vinterp[iz2](x_next) / 3.0
		EV = V_next.dot(self.r['dist'])

		return u + self.p['beta'] * EV
		

def main():
	params = get_params()

	ygrid = np.array([0.25])
	
	xgrid = dict()
	xgrid['vec'] = create_grid(ygrid[0], params['xmax'], params['xcurv'], params['nx'])
	xgrid['bc'] = xgrid['vec'][...,np.newaxis]
	
	returns = get_rdist()
	
	policyIterator = PolicyIterator(params, returns, ygrid, xgrid)
	policyIterator.makeGuess()
	policyIterator.iterate()
	
	plotAllocation(policyIterator)

def plotAllocation(policyIterator):
	fig, axes = plt.subplots(nrows=1, ncols=3)
	assets = policyIterator.bond + policyIterator.stock
	chi = policyIterator.stock / assets
	chi = np.nan_to_num(chi)
	for ip in range(3):
		axes[ip].plot(policyIterator.x['vec'], chi[:,ip])
	
	plt.show()
	

if __name__ == "__main__":
	main()
