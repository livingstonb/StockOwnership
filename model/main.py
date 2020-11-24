import numpy as np
from scipy.interpolate import interp1d
from scipy import optimize
from matplotlib import pyplot as plt

from model.PolicyIterator import PolicyIterator

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
	params['beta'] = 0.9
	params['rb'] = 0.005
	params['mutil'] = 0.05
	return params

def get_rdist():
	returns = dict()
	returns['dist'] = np.array([0.3, 0.4, 0.3])
	returns['grid'] = np.array([-0.005, 0.0, 0.005])
	returns['mu'] = np.array([0, 0.01, 0.015])
	returns['mutrans'] = np.array([[1/3, 1/3, 1/3], [1/3, 1/3, 1/3], [1/3, 1/3, 1/3]])
	returns['pmu'] = np.array([1/3, 1/3, 1/3])
	returns['nz'] = len(returns['mu'])
	return returns

def get_income():
	income = dict()
	income['vec'] = np.array([0.2, 0.3])
	income['bc'] = income['vec'][...,np.newaxis]
	income['trans'] = np.array([[0.5, 0.5],[0.5, 0.5]])
	income['ny'] =  len(income['vec'])
	return income

def main():
	params = get_params()

	ygrid = get_income()
	
	xgrid = dict()
	xgrid['vec'] = create_grid(ygrid['vec'][0], params['xmax'], params['xcurv'], params['nx'])
	xgrid['bc'] = xgrid['vec'][...,np.newaxis,np.newaxis]
	
	returns = get_rdist()
	
	policyIterator = PolicyIterator(params, returns, ygrid, xgrid['vec'])
	policyIterator.makeGuess()
	policyIterator.iterate()
	
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
