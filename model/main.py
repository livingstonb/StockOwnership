import numpy as np

def create_grid(gmin, gmax, gcurv, n):
	grid = np.linspace(0, 1, num=n)
	grid = np.pow(grid, 1.0 / gcurv)
	grid = gmin + (gmax - gmin) * grid
	return grid

def get_params():
	params = dict()
	params['nx'] = 100
	params['xcurv'] = 0.1
	params['xmin'] = 0
	params['xmax'] = 500
	params['beta'] = 0.95
	params['rb'] = 0.005

def get_beliefs():
	returns = dict()
	returns['dist'] = np.zeros((3, 2))
	returns['dist'][..., 0] = np.array([0.5, 0.1, 0.0])
	returns['dist'][..., 1] = np.array([0.0, 0.1, 0.5])
	returns['grid'] = np.array([[0.05], [0.0], [-0.02]])
	returns['trans'] = 
	return returns

def utility(c):
	return np.log(c)

def utility1(c):
	return 1.0 / c

def valueFn(Vlast, x, iz, b, s, ygrid, expectation):
	c = x - b - s
	u = utility(c)

	xprime = (1 + params['rb']) * b + (1 + returns['grid']) * s + ygrid


def iterateV():


def main():
	params = get_params()

	xgrid = dict()
	xgrid['vec'] = create_grid(0, params['xmax'], params['xcurv'], params['nx'])
	xgrid['bc'] = xgrid['vec'][...,np.newaxis]
	ygrid = 0.25

	conguess = (ygrid + params['rb'] * xgrid['vec']) / 2.0
	V = utility(conguess) / (1 - params['beta'])
	V = np.tile(V[...,np.newaxis], (1,3))

	tol = 1.0e-7
	err = 1.0e5
	maxiters = 1e5
	it = 0

	expectation = 

	while (err > tol) and (it < maxiters):
		iterateV(V)
		it += 1