import numpy as np
from scipy.interpolate import interp1d
from scipy import optimize
from matplotlib import pyplot as plt

from model.PolicyIterator import PolicyIterator
from model.ModelObjects import Income, Returns, Parameters
from model.Simulator import Simulator
from model.Statistics import Statistics

def create_grid(gmin, gmax, gcurv, n):
	grid = np.linspace(0, 1, num=n)
	grid = grid ** (1.0 / gcurv)
	grid = gmin + (gmax - gmin) * grid
	return grid

def calibrate():
	x0 = np.zeros((5,))
	x0[0] = 0.95 # beta
	x0[1] = 1 # riskaver
	x0[2] = 0.1 # belief dispersion
	x0[3] = 0.4 # p(pessimistic -> optimistic)
	x0[4] = 0.2 # p(optimistic -> pessimistic)

	opts = {'eps': 1.0e-7}
	optimize.root(obj_fn, np.asarray(x0),
		method='hybr')

def obj_fn(x):
	print(f'beta = {x[0]}')
	print(f'riskaver = {x[1]}')
	print(f'belief width = {x[2]}')
	print(f'P(pessimistic -> optimistic) = {x[3]}')
	print(f'P(optimistic -> pessimistic) = {x[4]}')

	pdict = dict()
	pdict['rb'] = 0.0
	pdict['beta'] = x[0]
	pdict['mutil'] = 0.05
	pdict['riskaver'] = x[1]
	pdict['nx'] = 50
	pdict['xmax'] = 50
	pdict['nsim'] = int(1e6)
	params = Parameters(pdict)

	mu_s = 0.0171
	width = x[2]
	n_eps = 5
	sd_eps = 0.0625
	pswitch = [x[3], x[4]]
	returns = Returns(mu_s, width, n_eps, sd_eps, pswitch)

	mu = 0.25
	sigma = 0.05
	rho = 0.8
	ny = 5
	income = Income(mu, sigma, rho, ny)
	
	xgrid = dict()
	xgrid['vec'] = create_grid(income.values[0], params.xmax, params.xcurv, params.nx)
	xgrid['bc'] = xgrid['vec'][...,np.newaxis,np.newaxis]

	policyIterator = PolicyIterator(params, returns, income, xgrid['vec'])
	policyIterator.makeGuess()
	policyIterator.iterate()

	sim = Simulator(policyIterator.bond, policyIterator.stock, params,
		income, returns, xgrid['vec'])
	sim.simulate()

	stats = Statistics(sim)
	stats.print()

	z = np.zeros((5,))
	z[0] = stats.share_stockholder.value - 0.25
	z[1] = stats.gross_stockholder_flow_2yr.value - 0.08
	z[2] = stats.cond_eshare.value - 0.4
	z[3] = stats.mean_a.value - 3.5
	z[4] = stats.cond_mean_a.value - 9.0

	return z


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
	calibrate()
