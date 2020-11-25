import numpy as np
from scipy.interpolate import interp1d
from scipy import optimize
from matplotlib import pyplot as plt

from model.PolicyIterator import PolicyIterator
from model.ModelObjects import Income, Returns

def create_grid(gmin, gmax, gcurv, n):
	grid = np.linspace(0, 1, num=n)
	grid = grid ** (1.0 / gcurv)
	grid = gmin + (gmax - gmin) * grid
	return grid

def get_params():
	params = dict()
	params['nx'] = 75
	params['xcurv'] = 0.2
	params['xmax'] = 25
	params['beta'] = 0.5
	params['rb'] = 0.005
	params['mutil'] = 0.1
	return params

def main():
	params = get_params()

	r_mu = 0.01
	width = 0
	n_eps = 3
	sd_eps = 0.001
	returns = Returns(r_mu, width, n_eps, sd_eps)

	mu = 0.25
	sigma = 0.05
	rho = 0.7
	ny = 3
	income = Income(mu, sigma, rho, ny)
	
	xgrid = dict()
	xgrid['vec'] = create_grid(income.values[0], params['xmax'], params['xcurv'], params['nx'])
	xgrid['bc'] = xgrid['vec'][...,np.newaxis,np.newaxis]
		
	policyIterator = PolicyIterator(params, returns, income, xgrid['vec'])
	policyIterator.makeGuess()
	policyIterator.iterate()

	print(np.asarray(returns.eps_values))
	
	plotAllocation(policyIterator)

def plotAllocation(policyIterator):
	fig, axes = plt.subplots(nrows=3, ncols=3)
	assets = np.asarray(policyIterator.bond) + np.asarray(policyIterator.stock)
	chi = np.asarray(policyIterator.stock) / assets
	chi = np.nan_to_num(chi)
	for iy in range(2):
		for iz in range(3):
			axes[iy,iz].plot(policyIterator.x, np.asarray(chi[:,iy,iz]))
	
	plt.show()
	

if __name__ == "__main__":
	main()
