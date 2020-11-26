
import os
import pandas as pd
import numpy as np


def estimate(data, name):
	mu = data['logR'].values.mean()
	sigma = data['logR'].values.std()

	print(f'{name}:')
	print(f'\tmu = {mu}')
	print(f'\tsigma = {sigma}')
	print(f'\tE[R_m - R_f] = {np.exp(mu + (sigma ** 2) / 2)}')


# sp 500
filepath = os.path.join('input', 'sp500_tr.csv')
df = pd.read_csv(filepath)
df = df[['Date', 'Close']]
df['Date'] = pd.to_datetime(df['Date'], format='%Y-%m-%d')

sp500 = df.rename(columns={'Close': 'sp500', 'Date': 'date'})
sp500 = sp500[['date', 'sp500']]

# pce price index
filepath = os.path.join('input', 'pce.csv')
df = pd.read_csv(filepath)
df['DATE'] = pd.to_datetime(df['DATE'], format='%Y-%m-%d')

pce = df.rename(columns={'PCEPI': 'pce', 'DATE': 'date'})
pce = pce[['date', 'pce']]

# t-bill yield
filepath = os.path.join('input', 'tbill.csv')
df = pd.read_csv(filepath)
df['DATE'] = pd.to_datetime(df['DATE'], format='%Y-%m-%d')

tbill = df.rename(columns={'TB3MS': 'tbill', 'DATE': 'date'})
tbill = tbill[['date', 'tbill']]

# merge
df = pd.merge(sp500, pce, how='outer', left_on='date', right_on='date')
df = pd.merge(df, tbill, how='outer', left_on='date', right_on='date')

# Clean
df = df.set_index('date')
quarterly = df.resample('q').mean()
quarterly.index = quarterly.index.to_period("Q")
quarterly['tbill'] = quarterly['tbill'].apply(
	lambda x: np.power(1 + 0.01 * x, 0.25) - 1)

annual = quarterly[quarterly.index.quarter == 1]
annual['year'] = annual.index.year
annual = annual.set_index('year')
annual.index = pd.PeriodIndex(annual.index, freq='Y')

# Computation
for data in [quarterly, annual]:
	infl = (data['pce'] - data['pce'].shift(1)) / data['pce'].shift(1)
	data['r_rf'] = data['tbill'].values - infl.values
	del data['tbill']

	realsp500 = data['sp500'] / data['pce']
	data['r_m'] = (realsp500 - realsp500.shift(1)) / realsp500.shift(1)

	data['rp'] = data['r_m'].values - data['r_rf'].values
	data['logR'] = np.log(1 + data['rp'].values)



# ### ESTIMATE QUARTERLY MOMENTS FOR 1990-2019 ###
years = (quarterly.index >= "1990Q1") & (quarterly.index <= "2019Q4")
sample = quarterly[years]
estimate(sample, "Quarterly, 1990-2019")


### ESTIMATE ANNUAL MOMENTS FOR 1990-2019 ###
years = (annual.index >= "1990") & (annual.index <= "2019")
sample = annual[years]
estimate(sample, "Annual, 1990-2019")

### ESTIMATE BOOMS AND BUSTS SEPARATELY ###
# boom


