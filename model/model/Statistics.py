import numpy as np

class StatValue:
	def __init__(self, descr, value):
		self.descr = descr
		self.value = value

class Statistics:
	def __init__(self, simulator):
		self.sim = simulator
		self.pctiles = np.array([10, 25, 50, 75, 90, 95, 99])

		self.wealthStatistics()
		self.equityStatistics()

	def wealthStatistics(self):
		# Cash-on-hand
		self.mean_x = StatValue(
			"x, mean",
			self.sim.cash[:,0].mean())

		pctiles_x = np.percentile(self.sim.cash[:,0], self.pctiles)
		self.pctiles_x = list()
		for i in range(len(pctiles_x)):
			self.pctiles_x.append(StatValue(
				f'x, {self.pctiles[i]}th percentile',
				pctiles_x[i]))

		# Assets
		self.wealth = self.sim.stocks[:,0] + self.sim.bonds[:,0]
		self.mean_a = StatValue(
			"b + s, mean",
			self.wealth.mean())

	def equityStatistics(self):
		stockholder = self.sim.stocks[:,0] > 1.0e-8
		self.share_stockholder = StatValue(
			"stockholders",
			stockholder.mean())

		leftStocks = (self.sim.stocks[:,0] > 1.0e-8) * (self.sim.stocks[:,3] <= 1.0e-8)
		self.gross_stockholder_flow_1yr = StatValue(
			"gross stockholder inflow/outflow, 1-year",
			leftStocks.mean())

		leftStocks = (self.sim.stocks[:,0] > 1.0e-8) * (self.sim.stocks[:,7] <= 1.0e-8)
		self.gross_stockholder_flow_2yr = StatValue(
			"gross stockholder inflow/outflow, 2-year",
			leftStocks.mean())

		cond_eshare = np.asarray(self.sim.stocks)[stockholder,0] / self.wealth[stockholder]
		self.cond_eshare = StatValue(
			"mean equity share among stockholders",
			cond_eshare.mean())

		self.cond_mean_a = StatValue(
			"mean b + s if stockholder",
			self.wealth[stockholder].mean()
			)

	def print(self):
		stats = [
			self.mean_x,
			self.pctiles_x,
			self.mean_a,
			self.share_stockholder,
			self.gross_stockholder_flow_1yr,
			self.gross_stockholder_flow_2yr,
			self.cond_eshare,
			self.cond_mean_a
		]

		for stat in stats:
			if isinstance(stat, list):
				for el in stat:
					print(el.descr + " = " + str(el.value))
			else:
				print(stat.descr + " = " + str(stat.value))