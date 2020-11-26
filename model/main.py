import numpy as np
from scipy.interpolate import interp1d
from scipy import optimize
from matplotlib import pyplot as plt

from model.PolicyIterator import PolicyIterator
from model.ModelObjects import Income, Returns, Parameters

def create_grid(gmin, gmax, gcurv, n):
	grid = np.linspace(0, 1, num=n)
	grid = grid ** (1.0 / gcurv)
	grid = gmin + (gmax - gmin) * grid
	return grid

def main():
	pdict = dict()
	pdict['r_s'] = 0.025
	pdict['beta'] = 0.8
	pdict['mutil'] = 0.02
	pdict['nx'] = 50
	params = Parameters(pdict)

	width = 0.03
	n_eps = 5
	sd_eps = 0.01
	returns = Returns(params.r_s, width, n_eps, sd_eps)

	mu = 0.25
	sigma = 0.05
	rho = 0.7
	ny = 3
	income = Income(mu, sigma, rho, ny)
	
	xgrid = dict()
	xgrid['vec'] = create_grid(income.values[0], params.xmax, params.xcurv, params.nx)
	xgrid['bc'] = xgrid['vec'][...,np.newaxis,np.newaxis]

	policyIterator = PolicyIterator(params, returns, income, xgrid['vec'])
	policyIterator.makeGuess()
	policyIterator.iterate()
	
	plotAllocation(policyIterator)

def plotAllocation(policyIterator):
	fig, axes = plt.subplots(nrows=3, ncols=2)
	assets = np.asarray(policyIterator.bond) + np.asarray(policyIterator.stock)
	chi = np.asarray(policyIterator.stock) / assets
	chi = np.nan_to_num(chi)

	for iy in range(3):
		for iz in range(2):
			axes[iy,iz].plot(policyIterator.x, np.asarray(chi[:,iy,iz]))
			axes[iy,iz].set_ylim(0, 1)

		axes[iy,0].set_title("Pessimistic")
		axes[iy,0].set(xlabel='wealth', ylabel='equity share of portfolio')
		axes[iy,1].set_title("Optimistic")
		axes[iy,1].set(xlabel='wealth', ylabel='equity share of portfolio')

	fig.tight_layout()
	plt.savefig('output/portfolio_allocation.png')
	plt.show()
	

if __name__ == "__main__":
	main()
