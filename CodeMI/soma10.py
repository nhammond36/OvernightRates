from datetime import datetime
dateparse = lambda x: datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.animation as animation
# from matplotlib.animation import FuncAnimation
import matplotlib as mpl
# matplotlib.font_manager._rebuild()
import matplotlib.font_manager as font_manager
mpl.rcParams['font.family'] = 'sans-serif'
mpl.rcParams['font.sans-serif'] = 'Lato'
import numpy as np
import pandas as pd
import dateparser
from matplotlib.dates import DateFormatter
import matplotlib.dates as mdates
%matplotlib inline
import plotly.express as px
#

# Federal Funds rate, Reserves plots
df = pd.read_csv(r'C:/Users/Owner/Documents/Research/Data/FRED/FRED_TOMO/Reserves_FF4.csv',\
                    usecols=[0, 1, 2, 3],  parse_dates=['DATE'])
# DATE	TOTRESNS	NONBORRES	FEDFUNDS	FPC	RESBALNS	FFBUYS	EFFR	PCETRIM1M158SFRBDAL	UNRATE	UNRATENSA	BBKMGDP
df_final=df
df_final=df.dropna(how='any')
res  = df_final.loc[:, "TOTRESNS"]
resb = df_final.loc[:, "BORROW"]
ff = df_final.loc[:, "FEDFUNDS"]
print(ff)
# volf = ((rates['FF']-rates['FF'].shift(1)) / rates['FF'].shift(1))
volf = ((ff-ff.shift(1))/ff.shift(1))*100
# percent
df_final["volf"] = volf
print(volf)
# irb2 = float(iorb)
# irb = rates['IORB'].apply(lambda x: float(x))
print(df_final.columns)
varnames=df_final.columns
list(varnames)
# varnames = rates.head()
df_final.info()
df_final.columns = df_final.columns.str.strip()
rates_final['DATE'] = pd.to_datetime(df_final['DATE'],format='%m/%d/%Y')
# , dayfirst=True)
df = rates_final.loc[:, "DATE"]
print(date)
x = df_final['DATE']
print(x)
# x = stirs['DATE']
# , dtype=np.datet
# x = rates.loc[:,"Date"]
df_final.plot(x="DATE", y="FEDFUNDS")
print(df_final.columns)
df_final.plot(x="DATE", y="TOTRESNS")
print(df_final.columns)
# ----------plot all variables
# output to static HTML file\n",
# output_file(\"stocks.html\", title=\"stocks.py example\")\n",
#
# output_file(\C:/Users/Owner/Documents/Research/SOMA/Soma_lines.html\,title=\"Soma data\")
# create a new plot with a title and axis labels,
# fig = plt.figure(figsize =(4, 4))
fig, ax1 = plt.subplots()
color = 'tab:red'
ax1.set_xlabel('Date')
ax1.set_ylabel('Reserves', color=color)
lns1=ax1.plot(x, res,'r-',label='Reserves (billions $)')
ax1.tick_params(axis='y', labelcolor=color)
ax2 = ax1.twinx()
# instantiate a9 second axes that shares the same x-axis
color = 'tab:blue'
color2 = 'tab:green'
# ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y/%m'))
# /%d'))
ax2.set_ylabel('Percent (x.xx)', color=color)  # we already handled the x-label with ax1
lns2=ax2.plot(x, ff, 'b.-',label='Federal Funds rate')
lns3=ax2.plot(x, volf*100,'g:',label='Fed funds rate (pct change)')
fig.tight_layout()
plt.title("Federal funds, change in funds rate, total reserves")
# added these three lines
lns = lns1+lns2+lns3
labs = [l.get_label() for l in lns]
plt.legend(lns, labs, loc='upper left')
plt.savefig('C:/Users/Owner/Documents/Research/SOMA/Soma_data2.png',dpi = 'figure',bbox_inches = 'tight',pad_inches = 0.15)
plt.show()
# Scattplot  Reserves versus  FF volatility
# output to static HTML file
# output_file(\"C:/Users/Owner/Documents/Research/SOMA/scatter_ff.html\",title=\"Fed funds rates and reserves\")
# create a new plot with a title and axis labels,)
N = len(ff)
# x = parse_dates
z = res
y = volf
colors = np.random.rand(N)
# area = (30 * np.random.rand(N))**2  # 0 to 15 point radii
# area = [20*2**n for n in range(len(res))]
area = res*.01
plt.figure(figsize =(6, 4))
plt.title('Fed Funds rate volatility vs total reserves',fontsize=12)
plt.scatter(z, y, s=area,c='g', alpha=0.5)
# fontweight ='bold')
# volres=plt.scatter(z, y, marker='o',s=area, c='c', alpha=0.5)
plt.xlabel('Reserves')
plt.ylabel('FF rate volatility')
plt.legend()
plt.savefig('C:/Users/Owner/Documents/Research/SOMA/ffvol_reserves.png',dpi='figure',bbox_inches='tight',pad_inches=0.15)
plt.show()
#
# Animate FF volatility versus reserves scatter plot
# fig = plt.figure(figsize =(6, 4))
# ax = py.axes(xlim=(0, 1), ylim=(0, 1))
# volres = plt.scatter([], [], s=10)
volres=plt.scatter([], [])
nrates = rates.to_numpy()
# print(rates)
# print(nrates.shape)
print("shape nrates= ",np.shape(nrates))
print("dimensions nrates= ",len(nrates.shape))
vn = nrates[:,1]
yn = nrates[:,4]
# print(nrates[ :,2])
# rates({"A": rates.res, "B": rates.volf}).to_numpy()
def init():
    volres.set_offsets([])
    volres.set_facecolor([])
    return volres,


def animate(i):
    volres.set_offsets([vn[i], yn[i]])
    # data = np.hstack((vn[:i,np.newaxis], yn[:i, np.newaxis]))
    # volres.set_offsets(data)
    return volres,


anim = animation.FuncAnimation(fig, animate, init_func=init, frames=len(x)+1,
                               interval=200, blit=False, repeat=False)
anim.save(' C:/Users/Owner/Documents/Research/SOMA/volres.mp4')
# ani = animation.FuncAnimation(fig, animate, np.arange(1, 200), init_func=init,
# create a new plot with a title and axis labels,)
y = ff
colors = np.random.rand(N)
# area = (30 * np.random.rand(N))**2  # 0 to 15 point radii
plt.figure(figsize =(5, 4))
plt.title('Fed Funds rate vs total reserves',fontsize = 12, fontweight ='bold')
plt.scatter(z, y, s=area,c='g', alpha=0.5)
plt.xlabel('Reserves')
plt.ylabel('Fed Funds rates')
plt.legend()
plt.show()
plt.savefig('C:/Users/Owner/Documents/Research/SOMA/ff_reserves.png')
