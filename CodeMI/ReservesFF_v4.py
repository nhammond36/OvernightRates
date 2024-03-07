# import libraries
from datetime import datetime
dateparse = lambda x: datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.express as px
df = pd.read_csv(r'C:/Users/Owner/Documents/Research/Data/FRED/FRED_TOMO/RESERVES_FF.csv', na_values=".",\
                    usecols=[0, 1, 2, 3,4,5,6,7,8],  parse_dates=['DATE'])
# DATE	TOTRESNS	BORROW	FEDFUNDS	PCETRIM1M158SFRBDAL	UNRATE	UNRATENSA	BBKMGDP
# TOTRESNS This series is a sum of total reserve balances maintained plus vault cash used to satisfy required reserves
# NONBORRES Equals total reserves (TOTRESNS), less total borrowings from the Federal Reserve (BORROW).
df_final=df
df_final.replace('.', np.nan, None, regex=True)
df_final=df.dropna(how='any')
res  = df_final.loc[:, "TOTRESNS"]
resb = df_final.loc[:, "BORROW"]
ff = df_final.loc[:, "FEDFUNDS"]
print(ff)
# volf = ((ff-ff.shift(1))/ff.shift(1))*100
# #df_final.loc[:,"volf"] = volf
# df_final.loc[0,df_final["volf"]]=0
#  value is trying to be set on a copy of a slice from a Data
# Frame
# Try using .loc[row_indexer,col_indexer] = value instead
# https://www.stackvidhya.com/add-row-to-dataframe/
# concat([new_row,df. loc[:]]). reset_index(drop=True)
# concat([new_row,df_final. loc[:]]). reset_index(drop=True)
# line = pd.DataFrame({'name': 'dean', 'age': 45, 'sex': 'male'}, index=[0])
# concatenate two dataframe
# df2 = pd.concat([line,df.ix[:]]).reset_index(drop=True)
# https://stackoverflow.com/questions/43408621/add-a-row-at-top-in-pandas-dataframe
# df_final.loc[0,9]=0
# volf[0]=0
# print(volf)
# df_final['DATE'] =
pd.to_datetime(df_final['DATE'],format='%m/%d/%Y')
# , dayfirst=True)
date = df_final.loc[:, "DATE"]
print('DATE')
x = df_final['DATE']
print(x)
# Extract year and Month
df_final['Year'] = pd.to_datetime(df_final['DATE']).dt.year
df_final['Month'] = pd.to_datetime(df_final['DATE']).dt.month
df_final['mon_yr'] = pd.to_datetime(df_final['DATE']).dt.to_period('M')
year  = df_final.loc[:, "Year"]
month  = df_final.loc[:, "Month"]
mon_yr  = df_final.loc[:, "mon_yr"]
print(year)
print(month)
varnames=df_final.columns
list(varnames)
# varnames = rates.head()
df_final.info()
df_final.columns = df_final.columns.str.strip()
#
df_final.plot(x="DATE", y="FEDFUNDS")
print(df_final.columns)
df_final.plot(x="DATE", y="TOTRESNS")
print(df_final.columns)
#
# Reserves, FF, soma7.py code
N = len(ff)
z = res
y = volf
# NEW BL PLOTS
# PCETRIM1M158SFRBDAL	UNRATE	UNRATENSA	BBKMGDP
pce= df_final["PCETRIM1M158SFRBDAL"]
# # Fed fund vs reserves
x = res
y = ff
maxx = max(res)
minx = min(res)
maxy = max(ff)
miny = min(ff)
fig = px.scatter(df_final, x=res, y=ff)
fig.show()
#
fig = px.scatter(df_final, x='TOTRESNS', y='FEDFUNDS',
      size_max=45)
# range_x=[minx,maxx], range_y=[miny,maxy])
fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReservesscatterplot.html")
fig.show()
# log_x= True,
#
print(len('TOTRESNS'))
print(len('FEDFUNDS'))
print(len('TOTRESNS'))
print(len('Month'))
print(len('mon_yr'))
px.scatter(df_final, x='TOTRESNS', y='FEDFUNDS',
       animation_group= mon_yr, size='FEDFUNDS', color=month, hover_name=month)
# range_x=[minx,maxx], range_y=[miny,maxy])
fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 300
fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReservesscatterplot2.html")
fig.show()
# log_x= True,
#
# fig = px.scatter(df_final, x='TOTRESNS', y='FEDFUNDS', animation_frame=year,
#    animation_group=mon_yr, size=pce, color=mon_yr, hover_name=mon_yr,
#    log_x= True, range_x=[minx,maxx], range_y=[miny,maxy])
# fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 300
# fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReservesscatterplot2.html")
# fig.show()
#
# Fed funds volatility vs reserves
maxv = max(volf)
minv = min(volf)
# fig = px.scatter(df_final, x=res, y=volf)
# fig.show()
# ERROR vold 542, res 541
#
# fig = px.scatter(df_final, x='TOTRESNS', y=volf, animation_frame=mon_yr,
#      animation_group=mon_yr, log_x= True, size_max=45, range_x=[minx,maxx],range_y=[minv,maxv])
# fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReserves2scatterplot3.html")
# fig.show()
#
# fig = px.scatter(df_final, x='TOTRESNS', y=volf, log_x= True,
#      size_max=volf, range_x=[minx,maxx], range_y=[minv,maxv])
# fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReserves2scatterplot4.html")
# fig.show()
# fig = px.scatter(df_final, x='TOTRESNS', y=volf, animation_frame=year,
#      animation_group=month, log_x= True, size=pce, range_x=[minx,maxx],
#      range_y=[minv,maxv])
# fig.write_html("C:/Users/Owner/Documents/Research/MonetaryPolicy/FFvReserves2scatterplot5.html")
# fig.show()
#
# FANCIER GRAPHS
# fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 700
# fig.show()
# fig = px.scatter(rates_final, x='TOTRESNS', y='FEDFUNDS', animation_frame=year,
#     animation_group=month, size=ff, color=month, hover_name=year,
#     log_x= True, size_max=45, range_x=[minx,maxx], range_y=[miny,maxy])
#
fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 100
fig.show()
fig = px.scatter(df_final,x='TOTRESNS', y='FEDFUNDS', animation_frame= year,
      animation_group=month, size=ff, color=year, hover_name=month, log_x=True,
      range_x=[minx,maxx], range_y=[miny,maxy])
# Tune marker appearance and layout
fig.update_traces(mode='markers', marker=dict(sizemode='area',
 ))
fig.update_layout(
 title='Fed funds rates v reserves, 1959~2022',
 xaxis=dict(
 title='Reserves',
 gridcolor='white',
 type='log',
 gridwidth=2,
 ),
 yaxis=dict(
 title='Fed funds rate (x.xx pct)',
 gridcolor='white',
 gridwidth=2,
 ),
 paper_bgcolor='rgb(243, 243, 243)',
 plot_bgcolor='rgb(243, 243, 243)',
)
fig.layout.updatemenus[0].buttons[0].args[1]["frame"]["duration"] = 600
fig.write_html("'C:/Users/Owner/Documents/Research/SOMA/FF_reposcatterplot.html")
fig.show()
#
# IMPORT DAILY Data
stirs = pd.read_csv(r'C:/Users/Owner/Documents/Research/Data/FRED/FRED_TOMO/SOMArates4.csv', na_values=".",  usecols=[0,1,2,3,4,5,6,7], parse_dates=['DATE'])
# DATE	RPONTSYD	RRPONTSYD	RPTSYD	RRPTSYD	EFFR	RPONTTLD	RRPONTTLD
stirs_final = stirs
stirs_final.replace('.', np.nan, None, regex=True)
stirs_final=stirs.dropna(how='any')
stirs_final.info()
stirs_final.dtypes
# Overnight Reverse Repurchase Agreements: Total Securities Sold by the Federal Reserve in the Temporary Open Market Operations
# stirs_final.astype('float').dtypes
stirs_final.columns = stirs.columns.str.strip()
# stirs['DATE'] = pd.to_datetime(stirs['DATE'])
stirs_final['DATE'] = pd.to_datetime(stirs_final['DATE'], format="%m/%d/%Y")
date = stirs_final.loc[0:, "DATE"]
print(date)
effrate = stirs_final.loc[:,"EFFR"]
type(effrate)
repo = stirs_final.loc[:, "RPONTSYD"]
rrepo = stirs_final.loc[:, "RRPONTSYD"]
trepo = stirs_final.loc[:, "RPONTTLD"]
trrepo = stirs_final.loc[:, "RRPONTTLD"]
print(effrate)
print(repo)
print(rrepo)
print(trepo)
print(trrepo)
x = stirs_final['DATE']
print(date)
print(x)
