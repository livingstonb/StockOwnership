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
	params = Parameters()

	width = 0.005
	n_eps = 3
	sd_eps = 0.001
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
	fig, axes = plt.subplots(nrows=1, ncols=2)
	assets = np.asarray(policyIterator.bond) + np.asarray(policyIterator.stock)
	chi = np.asarray(policyIterator.stock) / assets
	chi = np.nan_to_num(chi)

	iy = 0
	for iz in range(2):
		axes[iz].plot(policyIterator.x, np.asarray(chi[:,iy,iz]))
		axes[iz].set_ylim(0, 1)

	axes[0].set_title("Pessimistic")
	axes[0].set(xlabel='wealth', ylabel='equity share of portfolio')
	axes[1].set_title("Optimistic")
	axes[1].set(xlabel='wealth', ylabel='equity share of portfolio')

	fig.tight_layout()
	plt.savefig('output/portfolio_allocation.png')
	plt.show()
	

if __name__ == "__main__":
	main()
