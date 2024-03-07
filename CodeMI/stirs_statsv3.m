%{ =======================  NBER BUSINESS CYCLE DATES ======================
 Busness Cycle Dating Committee Announcements
 [Peak_year, Peak_month, Trough_year, Trough_month, Contracton:Peak to Trough (Months)]
  nbdates =[1953           6        1954           5          10
            1957           8        1958           4           8
            1960           4        1961           2          10  
            1969          12        1970          11          11
            1973          11        1975           3          16
            1980           1        1980           7           6
            1981           7        1982          11          16
            1990           7        1991           3           8
            2001           3        2001          11           8
            2007          12        2009           6          18
            2020           2        2020           4           2]
%}
%y	2020	Peak occurred 2019Q4 April 	2020 	2	2 

% ------------------------- Weekly Rates -----------------------------------
[rates,txt,raw]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_weekly.xlsx','A2:AO352');
size(rates) % 351    40
%{
rates(:,1:8) = effr;  1 rate, 2 vol
rates(:,9:16) = obfr;
rates(:,17:24) = tgcr;
rates(:,35:32) = bgcr;
rates(:,33:40) = sofr;
writetimetable(rateT1,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_weekly.xlsx');
load('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_v4','datef','ratesf') % 01-Mar-2016 to 15-7-2022
t = datetime(datef(:,1),'InputFormat','MM/dd/yyyy'); 
%}
%{
% ---------------------- Reserves -
DPSACBW027SBOG	Deposits, All Commercial Banks, Billions of U.S. Dollars, Weekly, Seasonally Adjusted
A2254 3/2/2016 to D2603 11/9/2022
DATE	WRESBAL	TLAACBW027SBOG	DPSACBW027SBOG
https://fred.stlouisfed.org/series/WRESBAL Liabilities and Capital: Other Factors Draining Reserve Balances: Reserve Balances with Federal Reserve Banks: Week Average (
https://fred.stlouisfed.org/series/TLAACBW027SBOG Total Assets, All Commercial Banks (TLAACBW027SBOG)
https://fred.stlouisfed.org/graph/?id=DPSACBW027SBOG, Deposits, All Commercial Banks (DPSACBW027SBOG)
3/2/2016 - 9/28/2022
%}
[res,txtr,rawr] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/WRESBAL_BankAssetsv7.xlsx','A2254:G2603');
size(res)  %350     3
%{
col 1 WRESBAL	weekly reserves	
col 2 TLAACBW027SBOG commercial bank Total Assets
col 3 DPSACBW027SBOG commercial bank deposits
col 4 Nan
col 5 TREAST
col 6 SOFR
reserven = reserves/deposits  col1/col3
res(1:10,1:3)
2421.445	15707.4483	11028.7043
2481.508	15727.0208	11064.1523
2515.893	15771.6722	11084.6896
2499.512	15730.2548	11076.3844
2422.534	15732.8091	11118.499
%}

rr =rates(:,1:8:40);
volm =rates(:,2:8:40);
reservesn= res(:,1)./res(:,3); % billions
mdate = datenum(raw(:,1),'mm/dd/yyyy');
fig_n1=1

% Daily rates, percentiles, and volume data
[spread,txts,raws]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv6.xlsx','A447:AW1716');
size(spread) %    1293          47
sdate = datenum(raws(:,1),'mm/dd/yyyy')
%{
NYFedOvernightRates data in columns
Effective Date
Rate Type
col 1 Rate (%)	
col 2 Volume (Billions of dollars)
col 3 Target Rate From (%)
col 4 Target Rate To (%)
col 5 1st Percentile (%)
col 6 25th Percentile (%)
col 7 75th Percentile (%)
col 8 99th Percentile (%)
Intra Day - Low (%)
Intra Day - High (%)
Standard Deviation (%)
30-Day Average SOFR
90-Day Average SOFR
180-Day Average SOFR
SOFR Index
Revision Indicator (Y/N)
Footnote ID
07/15/2022	EFFR	1.58	97

04/03/2018	EFFR	1.69	90	1.5	1.75	1.65	1.68	1.69	1.8	
04/03/2018	OBFR	1.68	177			1.22	1.68	1.69	1.77	
04/03/2018	TGCR	1.81	321			1.5	1.8	1.82	1.84	
04/03/2018	BGCR	1.81	344			1.5	1.8	1.82	1.97	
04/03/2018	SOFR	1.83	825			1.62	1.81	1.91	2	
5 rates time 8 data items = 40 columns per rate
%} 
%{
Routine to zoom in to arrows of graph
function pan = zoomin(ax,areaToMagnify,panPosition)
% AX is a handle to the axes to magnify
% AREATOMAGNIFY is the area to magnify, given by a 4-element vector that defines the
%      lower-left and upper-right corners of a rectangle [x1 y1 x2 y2]
% PANPOSTION is the position of the magnifying pan in the figure, defined by
%        the normalized units of the figure [x y w h]
%}
% ============= value weighted daily rates
drates =spread(:,1:8:40);
vold =spread(:,2:8:40);
vdsum=sum(vold(:,1:5),2); %wrates1(:,2:2:10),2);                % Total volume
vdrates(:,1:5) = (drates(:,1:5).*vold(:,1:5))./vdsum(:);
target = spread(:,3:4); % NaN until 4/19/2019 	2.44	59	2.25	2.5
begintarget = 789-447+1;
quantileeffr=spread(:,5:8);   
quantilesofr=spread(:,37:40); 
% spreads
sohr_ior = spread(1:size(spread,1),43)-spread(1:size(spread,1),42)*100;
effr_ior = spread(1:size(spread,1),1)-spread(1:size(spread,1),42)*100;
size(effr_ior) % 1270   

% IOR, RRPust, RRPmbs
% col 3 Target Rate From (%)
% col 4 Target Rate To (%)
% col 5 1st Percentile (%)
% col 6 25th Percentile (%)
% col 7 75th Percentile (%)
% col 8 99th Percentile (%)
% Compute volume weighted means and percentiles
%drates1(:,1:2:9) = rd(:,1:5).*vold(:,1:5); % Rates
              % Volume, each rate


% ====================== Probplots ==============================
%{
 https://stats.stackexchange.com/questions/92141/pp-plots-vs-qq-plots
As @vector07 notes, probability plot is the more abstract category of which
pp-plots and qq-plots are members. Thus, I will discuss the distinction 
between the latter two. The best way to understand the differences is to 
think about how they are constructed, and to understand that you need to 
recognize the difference between the quantiles of a distribution and the 
proportion of the distribution that you have passed through when you reach 
a given quantile.Approximately 68% of the y-axis (region between red lines)
corresponds to 1/3 of the x-axis (region between blue lines). That means 
that when we use
the proportion of the distribution we have passed through to evaluate the 
match between two distributions (i.e., we use a pp-plot), we will get a lot
of resolution in the center of the distributions, but less at the tails. On
the other hand, when we use the quantiles to evaluate the match between two
distributions (i.e., we use a qq-plot), we will get very good resolution at
the tails, but less in the center. (Because data analysts are typically 
more concerned about the tails of a distribution, which will have more 
effect on inference for example, qq-plots are much more common than 
pp-plots.)

'normal'	Normal probability plot	All values
'exponential'	Exponential probability plot	Nonnegative values
'extreme value'	Extreme value probability plot	All values
'half normal'	Half-normal probability plot	All values
'lognormal'	Lognormal probability plot	Positive values
'logistic'	Logistic probability plot	All values
'loglogistic'	Loglogistic probability plot	Positive values
'rayleigh'	Rayleigh probability plot	Positive values
'weibull'	Weibull probability plot	Positive values


dist='normal'
h = probplot(dist,spread(:,1:8:33));
he = probplot(dist,spread(:,1));
hs = probplot(dist,spread(:,33));
ho = probplot(dist,spread(:,2));
ht = probplot(dist,spread(:,3));
hb = probplot(dist,spread(:,4));
%}

switch n

case 1
fig_n1= fig_n1+1;
maxy = max(spread(:,1:8:33))
maxy1 = max(maxy)
miny =  min(spread(:,1:8:33))
miny1=min(miny)
endind = size(sdate,1);
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);%March 2 2016 to Nov 9 2023
%yyaxis right
%plot(mdate(1:endind), reservesnn,'-r','LineWidth',1) % reserves_n
%hold on  % 
%ylabel('reserves/ commercial deposits $ billions') 
%yyaxis left
hE = probplot(dist,spread(:,1));
hold on
hS = probplot(dist,spread(:,33));
hold on
hO = probplot(dist,spread(:,2));
hold on
hT= probplot(dist,spread(:,3));
hold on
hB = probplot(dist,spread(:,4));
hold on
xtickangle(45)

hXLabel=xlabel('rates (percent)');
hYLabel=ylabel('probability');
%datetick('x', 'mm/dd/yyyy','keepticks')
%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
xtickangle(45)
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
h=[hE hO hT hB hS];
hLegend=legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','Location', 'northwest') 
hTitle=title({'Distribution of US overnight rates'});
% Adjust Font and Axes Properties
set(gca,'FontName','Helvetica');
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
%'XTick'       , 0:50:maxx1, ...
%'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateOTB_pplot.tex');

 case 2
fig_n1=fig_n1+1;     
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
maxy=max(spread(:,9:8:25)) %rates
maxy1=max(maxy)
miny =  min(spread(:,9:8:25)); 
miny1=min(miny)
%maxx=max(spread(:,10:8:26)) %volumes
%maxx1=max(maxx)
hO = probplot(dist,spread(:,2));
hold on
hT = probplot(dist,spread(:,3));
hold on
hB = probplot(dist,spread(:,4));
hold on
xtickangle(45)
set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );  
set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  

h=[hO hT hB];
hLegend = legend(h,'OBFR','TGCR','BGCR','location', 'NorthWest' );
legend('boxoff')
hTitle=title({'Distribution of US overnight rates'});
%hTitle=title({'US overnight rates'},{'OBFR','TGCR','BGCR'});
hXLabel=xlabel('rates (percent)');
hYLabel=ylabel('probability');
%hText=text(1,2,'\leftarrow sin(\pi)')
% Set up annotation
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
%axPos is [xMin,yMin,xExtent,yExtent]
%The limits, i.e. min and max of the axes.
xMinMax = xlim;
yMinMax = ylim;
%axis([0 2*pi -1.5 1.5])
axis([xlim ylim])
xAnnotation = axPos(1) + ((fig_n1 - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3)
yAnnotation = axPos(2) + ((fig_n1 - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4)
zx = x(y==maxy1); 
zy = y(x==yAnnotation); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
xAn = [xAnnotation-.05,xAnnotation]
yAn = [yAnnotation-.01,yAnnotation]
a=annotation('textarrow',xAn,yAn,'String',{'y=x'});
a.color = 'red'
a.fontsize=9

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
%'XTick'       , 0:50:maxx1, ...
%'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateOTB_pplot.tex');

 case 3
fig_n1=fig_n1+1;     
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
maxy=max(spread(:,1),spread(:,33))
maxy1=max(maxy)
miny=min(spread(:,1),spread(:,33))
miny1=min(maxy)
%maxx=max(spread(:,33),spread(:,34))
%maxx1=max(maxx)
hE = probplot(dist,spread(:,1));
hold on
hE = probplot(dist,spread(:,33));
hold on
xtickangle(45)

set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );

h=[hE hS];
hLegend = legend(h,'EFFR','SOFR','location', 'NorthWest' );
legend('boxoff')
hTitle=title({'Distribution of US overnight rates'}); %,{'EFFR','SOFR'});
hXLabel=xlabel('rates (percent)');
hYLabel=ylabel('probability');
%hText=text(1,2,'\leftarrow sin(\pi)')
% Set up annotation
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
%axPos is [xMin,yMin,xExtent,yExtent]
%The limits, i.e. min and max of the axes.
xMinMax = xlim;
yMinMax = ylim;
%axis([0 2*pi -1.5 1.5])
axis([xlim ylim])
xAnnotation = axPos(1) + ((fig_n1 - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3)
yAnnotation = axPos(2) + ((fig_n1 - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4)
zx = x(y==maxy1); 
zy = y(x==yAnnotation); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
xAn = [xAnnotation-.05,xAnnotation]
yAn = [yAnnotation-.01,yAnnotation]
a=annotation('textarrow',xAn,yAn,'String',{'y=x'});
a.color = 'red'
a.fontsize=9

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.2:maxy1, ...
  'LineWidth'   , 1         );   
% 'XTick'       , 0:50:maxx1, ...
%  'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateES_pplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateES_pplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateES_pplot.tex');
otherwise
end

% plot individual years EFFR AND SOHR
% 2018
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(20:271,1));
hold on
hS = probplot(dist,spread(20:271,33));
hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates EFFR and SOHR 2018'});

% 2019
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(272:522,1));
hold on
hS = probplot(dist,spread(272:522,33));
hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates EFFR and SOHR 2019'});

% 2020
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(523:774,1));
hold on
hS = probplot(dist,spread(523:774,33));
hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates EFFR and SOHR 2020'});

% 2021
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(775:1025,1));
hold on
hS = probplot(dist,spread(775:1025,33));
hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates EFFR and SOHR 2021'});

% 2022
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(1022:1244,1));
hold on
hS = probplot(dist,spread(1022:1244,33));
hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates EFFR and SOHR 2022'});


fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);

% plot individual years EFFR
% 2018
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(20:271,1));
hold on
%hS= probplot(dist,spread(20:271,33));
%hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - EFFR 2018'});

% 2019
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(272:522,1));
hold on
%hS = probplot(dist,spread(272:522,33));
%hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - EFFR 2019'});

% 2020
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(523:774,1));
hold on
%hS = probplot(dist,spread(523:774,33));
%hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - EFFR 2020'});

% 2021
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(775:1025,1));
hold on
%hS = probplot(dist,spread(775:1025,33));
%hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - EFFR 2021'});

% 2022
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE = probplot(dist,spread(1022:1244,1));
hold on
%hS = probplot(dist,spread(1022:1244,33));
%hold on
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - EFFR 2022'});

   
% plot individual years SOHR
% 2018
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%hE = probplot(dist,spread(20:271,1));
%hold on
hS = probplot(dist,spread(20:271,33));
hold on
%set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - SOHR 2018'});

% 2019
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%hE = probplot(dist,spread(272:522,1));
%hold on
hS = probplot(dist,spread(272:522,33));
hold on
%set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - SOHR 2019'});

% 2020
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%hE = probplot(dist,spread(523:774,1));
%hold on
hS = probplot(dist,spread(523:774,33));
hold on
%set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - SOHR  2020'});

% 2021
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%hE = probplot(dist,spread(775:1025,1));
%hold on
hS = probplot(dist,spread(775:1025,33));
hold on
%set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - SOHR  2021'});

% 2022
fig_n1 = fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%hE = probplot(dist,spread(1022:1244,1));
%hold on
hS = probplot(dist,spread(1022:1244,33));
hold on
%set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hTitle=title({'Distribution of US overnight rates - SOHR  2022'});

%}

%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
% print -depsc2 finalPlot1.eps
print -depsc2 onrate_pctchangev2.eps
print -depsc2
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONrate_weekly.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONrate_weekly.eps')
exportgraphics(gcf,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONrate_weekly.eps','ContentType','vector')
%print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/onrate_weekly.eps','-dpdf')

matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratesOTB_reservesn_scatterv5.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyrates_reservesn_scatterv5.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratesES_reservesn_scatterv5.tex');

% ======================== qq plots ===============================
%{
col 5 1st Percentile (%)
col 6 25th Percentile (%)
col 7 75th Percentile (%)
col 8 99th Percentile (%)
spread(:,5:8:37)
%}

% ========================= robust covariance =======================
%{
sig = robustcov(x) returns the robust covariance estimate sig of the multivariate data contained in x.

[sig,mu] = robustcov(x) also returns an estimate of the robust Minimum Covariance Determinant (MCD) mean, mu.

[sig,mu,mah] = robustcov(x) also returns the robust distances mah, computed as the Mahalanobis distances of the observations using the robust estimates of the mean and covariance.

[sig,mu,mah,outliers] = robustcov(x) also returns the indices of the observations retained as outliers in the sample data, outliers.

example
[sig,mu,mah,outliers,s] = robustcov(x) also returns a structure s that contains information about the estimate.

example
[___] = robustcov(x,Name,Value) returns any of the arguments shown in the previous syntaxes, using additional options specified by one or more Name,Value pair arguments. For example, you can specify which robust estimator to use or the start method to use for the attractors.
%}

%{
2017   1 -   19  12/4/2017 12/29/2017
2018  20 -  270   1/2/2018 12/31/2018
2019 271 -  521   1/2/2019 12/31/2019
2020 522 -  772   1/2/2020 12/31/2020
2021 773 - 1023   1/4/2021 12/31/2021
2022 1024 -1244   1/3/2022 11/17/2022

%}

datetime(sdate(20:270), 'ConvertFrom', 'datenum', 'Format', 'dd/MM/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(271:522), 'ConvertFrom', 'datenum', 'Format', 'dd/MM/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(271:522), 'ConvertFrom', 'datenum', 'Format', 'dd/MM/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(271:522), 'ConvertFrom', 'datenum', 'Format', 'dd/MM/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(271:522), 'ConvertFrom', 'datenum', 'Format', 'dd/MM/yyyy')  %recommended, although I'd recomend using yyyy instead of yy


[sig,mu,mah,outliers,s] = robustcov(spread(:,1:8:33))
[sig,mu,mah,outliers,s] = robustcov(spread(:,9:8:25))
[sig,mu,mah,outliers,s] = robustcov(spread(:,1), spread(:,33))

covrates = cov(spread(:,1:8:33))
%{
    1.0387    1.0381    1.0307    1.0381    1.0401
    1.0381    1.0403    1.0327    1.0398    1.0411
    1.0307    1.0327    1.0349    1.0421    1.0426
    1.0381    1.0398    1.0421    1.0497    1.0502
    1.0401    1.0411    1.0426    1.0502    1.0527
%}
covrates = cov(spread(1:19,1:8:33))      %2017
covrates = cov(spread(19:270,1:8:33))    %2018
covrates = cov(spread(1:270,1:8:33))
covrates = cov(spread(271:521,1:8:33))   %2019
covrates = cov(spread(522:772,1:8:33))   %2020
covrates = cov(spread(773:1023,1:8:33))  %2021
covrates = cov(spread(1024:1244,1:8:33)) %2022
%{
%}

murates = mean(spread(:,1:8:33))
%  1.1509    1.1420    1.1381    1.1395    1.1509
murates = mean(spread(1:19,1:8:33))
murates = mean(spread(20:270,1:8:33))

murates = mean(spread(1:270,1:8:33))
murates = mean(spread(271:521,1:8:33))
murates = mean(spread(522:772,1:8:33))
murates = mean(spread(773:1023,1:8:33))
murates = mean(spread(1024:1244,1:8:33))
%{
murates =

    1.3042    1.1953    1.2126    1.2516    1.2968
    1.8242    1.8115    1.8061    1.8320    1.8283

    1.7876    1.7681    1.7643    1.7912    1.7909
    2.1655    2.1627    2.1784    2.1771    2.1989
    0.3596    0.3579    0.3525    0.3455    0.3495
    0.0598    0.0484    0.0481    0.0366    0.0665
    1.3586    1.3506    1.3220    1.3191    1.3207
%}
  
sdrates = std(spread(:,1:8:33))
%  1.0192    1.0199    1.0173    1.0246    1.0260
sdrates = std(spread(1:19,1:8:33))
sdrates = std(spread(20:270,1:8:33))

sdrates = std(spread(1:270,1:8:33))
sdrates = std(spread(271:521,1:8:33))
sdrates = std(spread(522:772,1:8:33))
sdrates = std(spread(773:1023,1:8:33))
sdrates = std(spread(1024:1244,1:8:33))
%{
sdrates =
    0.1279    0.1496    0.1460    0.1570    0.1313
    0.3113    0.3263    0.3134    0.3032    0.2896

    0.3300    0.3541    0.3404    0.3305    0.3124
    0.3315    0.3398    0.3898    0.3889    0.3900
    0.5722    0.5698    0.5684    0.5717    0.5803
    0.0215    0.0229    0.0221    0.0200    0.0272
    1.2041    1.2017    1.1643    1.1682    1.1886

%}

% ======================== rolling mean, std ========================
%{
 Python lesson https://goodboychan.github.io/python/datacamp/time_series_
analysis/2020/06/11/01-Window-Functions-Rolling-and-Expanding-Metrics.html
calculate rolling quantiles to describe changes in the dispersion of a time
series over time in a way that is less sensitive to outliers than using the
mean and standard deviation.
Let's calculate rolling quantiles - at 10%, 50% (median) and 90% - of the distribution

https://goodboychan.github.io/python/datacamp/time_series_analysis/2020/06/11/01-Window-Functions-Rolling-and-Expanding-Metrics.html

Matlab https://www.mathworks.com/matlabcentral/answers/499929-efficient-moving-quantile-function
https://www.mathworks.com/matlabcentral/fileexchange/84200-movquant?s_tid=prof_contriblnk
%}

mmean=movmean(spread(:,1:8:33),30,5)
fig_n1=fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
plot(sdate, mmean)
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
h=[hE hO hT hB hS]; 
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR', 'Location', 'northwest')
legend('boxoff')
hTitle=title({'30 day rolling means of US overnight rates 2018-2022'});
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)

set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/rollingmean_30days.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/rollingmean_30days.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\rollingmean_30days.tex');

size(mmean) %1244           5

%M = movstd(A,k) returns an array of local k-point standard deviation 
% values. Each standard deviation is calculated over a sliding window of 
% length k across neighboring elements of A.
mstd= movstd(spread(:,1:8:33),30)
fig_n1=fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
plot(sdate, mstd)
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
h=[hE hO hT hB hS]; 
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR', 'Location', 'northwest')
legend('boxoff')
hTitle=title({'30 day rolling standard deviation of US overnight rates 2018-2022'});
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)

set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/rollingstd_30days.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/rollingstd_30days.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\rollingstd_30days.tex');

% movmedian
% med = movmedian( A , k )
med = movmedian(spread(:,1:8:33),30,5)
% =========================== Quantiles ================================
%{
Percentiles https://www.mathworks.com/help/matlab/ref/prctile.html

Quintiles
col 5 1st Percentile (%)
col 6 25th Percentile (%)
col 7 75th Percentile (%)
col 8 99th Percentile (%)

-Q = quantile(A,p) returns quantiles of elements in input data A for the 
cumulative probability or probabilities p in the interval [0,1].
https://www.mathworks.com/help/matlab/ref/quantile.html
If A is a vector, then Q is a scalar or a vector with the same length as p.
Q(i) contains the p(i) quantile.

If A is a matrix, then Q is a row vector or a matrix, where the number of 
rows of Q is equal to length(p). The ith row of Q contains the p(i) 
quantiles of each column of A.

- Rolling quintiles
movquant https://www.mathworks.com/matlabcentral/fileexchange/84200-movquant
The equivalent of medfilt1 (p=0.5) , movmax (p=1) and movmin (p=0), but for arbitrary quantiles p.
quant_X = movquant(X, p, n, dim, nanflag, padding)

X - N-dimensional array:
spread(:,5:8)   % EFFR 
spread(:,13:16) % OBFR
spread(:,21:24) % TGCR
spread(:,29:32) % BGCR
spread(:,37:40) % SOFR

for day 1, sum the prob of each rate and prob
spread(1,5) + s
p .01, .25, .75, .99
n - Width of the moving window
dim - dimension to operate across. Default: first non-singleton dimension of X.
%   
quant_X = movquant(X, p, 30, dim, nanflag, padding)
%}
%select quintile q


n=30 % number of days window
p = [.01 .25 .75 .99]
dim = 1; % EFFR, OBFR, TGCR, BGCR, SOHR
%qX=zeros(size(spread,1),dim*4);
rate = 1 % EFFR, SOHR, OBFR, TGCR, BGCR
fig_n1=fig_n1+ 1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);%March 2 2016 to Nov 9 2023
%yyaxis right
%plot(mdate(1:endind), reservesnn,'-r','LineWidth',1) % reserves_n
%hold on  % 
%ylabel('reserves/ commercial deposits $ billions') 
%yyaxis left

switch rate
case 1
qXhe = zeros(size(spread,1),size(p,2));
qXhe(:,1) = movquant(spread(:,5), p(1), 30, 1, nanflag, padding);
qXhe(:,2) = movquant(spread(:,6), p(2), 30, 1, nanflag, padding);
qXhe(:,3) = movquant(spread(:,7), p(3), 30, 1, nanflag, padding);
qXhe(:,4) = movquant(spread(:,8), p(4), 30, 1, nanflag, padding);
hE = plot(sdate,spread(:,5:8));
hold on
hqE=plot(sdate,qXhe) 
hold on
case 2
qXhs = zeros(size(spread,1),size(p,2));
qXhs(:,1) = movquant(spread(:,37), p(1), 30, 1, nanflag, padding);
qXhs(:,2) = movquant(spread(:,38), p(2), 30, 1, nanflag, padding);
qXhs(:,3) = movquant(spread(:,39), p(3), 30, 1, nanflag, padding);
qXhs(:,4) = movquant(spread(:,40), p(4), 30, 1, nanflag, padding);
hS = plot(sdate,spread(:,37:40));
hold on
hqS=plot(sdate,qXhs) 
hold on
case 3
qXho = zeros(size(spread,1),size(p,2));
qXho(:,1) = movquant(spread(:,13), p(1), 30, 1, nanflag, padding);
qXho(:,2) = movquant(spread(:,14), p(2), 30, 1, nanflag, padding);
qXho(:,3) = movquant(spread(:,15), p(3), 30, 1, nanflag, padding);
qXho(:,4) = movquant(spread(:,16), p(4), 30, 1, nanflag, padding);
hO = plot(sdate,spread(:,13:16));
hold on
hqO=plot(sdate,qXho) 
hold on
case 4
qXht = zeros(size(spread,1),size(p,2));
qXht(:,1) = movquant(spread(:,21), p(1), 30, 1, nanflag, padding);
qXht(:,2) = movquant(spread(:,22), p(2), 30, 1, nanflag, padding);
qXht(:,3) = movquant(spread(:,23), p(3), 30, 1, nanflag, padding);
qXht(:,4) = movquant(spread(:,24), p(4), 30, 1, nanflag, padding);
hT= plot(sdate,spread(:,21:24));
hold on
hqT=plot(sdate,qXht) 
hold on
case 5
qXhb = zeros(size(spread,1),size(p,2));
qXhb(:,1) = movquant(spread(:,29), p(1), 30, 1, nanflag, padding);
qXhb(:,2) = movquant(spread(:,30), p(2), 30, 1, nanflag, padding);
qXhb(:,3) = movquant(spread(:,31), p(3), 30, 1, nanflag, padding);
qXhb(:,4) = movquant(spread(:,32), p(4), 30, 1, nanflag, padding);
hB = plot(sdate,spread(:,29:32));
hold on
hqB=plot(sdate,qXhb) 
hold on
xtickangle(45)
datetick('x', 'mm/dd/yyyy','keepticks')
otherwise
    end


% Test movequant 
% https://www.mathworks.com/matlabcentral/fileexchange/84200-movquant?s_tid=prof_contriblnk
% 2-D example with NaN
X = randn(10, 2);
X(1,1) = nan;
% for p=0, 0.5, 1 this should do the same as medfilt1/movmin/movmax.
Xmedquant = movquant(X, 0.5, 3);  % default: zero-padding, as in medfilt1
%Xmed = medfilt1(X, 3); % requires Signal Processing Toolbox.
%assert(isequaln(Xmedquant, Xmed));
%Xmaxquant1 = movquant(X, 1, 3, [], [], 'truncate');
n=3 % number of days window
dim = size(X,2);
nanflag='includenan'
padding='zeropad'
quant_X = movquant(X, p, 30, dim, nanflag, padding)
xx= 1:1:10;
fig_n1 = fig_n1 + 1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
plot(xx,Xmedquant,'b')
hold on
plot(xx,X,'g')
hold on
legend('Xmedquant','X')
legend('boxoff')

%quant_X = movquant(X, p, 30, dim, nanflag, padding)
%{
check file
%Nov 2022 quintiles ROWS % EFFR, OBFR, TGCR, BGCR, SOHR 
% COLS 1% 25% 75% 99%
1.55	1.57	1.58	1.7
1.52	1.56	1.58	1.7
1.43	1.49	1.54	1.7
1.43	1.49	1.55	1.7
1.45	1.51	1.55	1.7
1.55	1.57	1.58	1.7

FILE DATA
1% EFFR
3.84
3.83
3.84
3.84
3.84
3.84
3.84
3.84
3.84
3.84

1 - 99 % OBFR
3.73	3.8	3.83	4
3.74	3.8	3.83	4
3.75	3.8	3.83	4
3.75	3.8	3.83	4
3	    3.8	3.83	4
3.75	3.8	3.83	3.95
3.77	3.8	3.83	4
3.76	3.8	3.83	3.95
3.76	3.8	3.83	4
3.75	3.8	3.83	4

         ↑
Invalid expression. Check for missing multiplication operator, missing or unbalanced delimiters,
or other syntax error. To construct matrices, use brackets instead of parentheses.
 
% 3/3/2016
0.15	0.36	0.37	0.42
0.33	0.36	0.37	0.45
0.29	0.36	0.37	0.42
0.34	0.36	0.37	0.5
0.29	0.36	0.37	0.42
0.15	0.36	0.37	0.42
         ↑
%}

% ======================== Quantile regression ============================
%{
https://sites.google.com/site/econometricsacademy/econometrics-models/quantile
-regression?pli=1
nstead of estimating the model with average effects using the OLS linear 
model, the quantile regression produces different effects along the 
distribution (quantiles) of the dependent variable. 

https://www.mathworks.com/matlabcentral/fileexchange/32115-quantreg-x-y-tau-order-nboot
x=(1:1000)';
y=randn(size(x)).*(1+x/300)+(x/300).^2;
[p,stats]=quantreg(x,y,.9,2);
plot(x,y,x,polyval(p,x),x,stats.yfitci,'k:')
legend('data','2nd order 90th percentile fit','95% confidence interval','location','best')
%}   
 
%r(527) 1.15	1.76	1.77	2.1 spread(81:size(spread,1),21:24)

drates = [spread(:,1) spread(:,9) spread(:,17) spread(:,25)  spread(:,33)] 
dratesq = [spread(:,5:8) spread(:,13:16) spread(:,21:24) spread(:,29:32) spread(:,37:40)] 
% moving average of quantile data rates
lag = 6;
simple = movavg(dratesq,'simple',lag)


xax=[1 25 75 99];
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
he=plot(sdate,spread(:,5:8)*100)
hold on 
ho=plot(sdate,spread(:,13:16)*100)
hold on
ht=plot(sdate,spread(:,21:24)*100);
hold on
hb=plot(sdate,spread(:,29:32)*100);
hold on
hs=plot(sdate,spread(:,37:40)*100);
hold on
xtickangle(45)
datetick('x', 'mm/dd/yyyy','keepticks')
hXLabel=xlabel('daily');
hYLabel=ylabel({'rate';'basis points'});
hLegend=legend('.01',',25','.75','.99')
legend('boxoff')
hTitle=title({'Quantiles of BGCR rates 2018-2022'});
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%legend('EFFR','OBFR','TGCR','BGCR','SOHR')

% Probplots
dist = 'norm';
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
rate =1 
switch rate
    case 1
hE1 = probplot(dist,spread(:,1)*100);
hold on
hE = probplot(dist,spread(:,5:8)*100);
hold on
case 2
hO1 = probplot(dist,spread(:,9)*100);
hold on
hO = probplot(dist,spread(:,13:16)*100);
hold on
case 3
hT1 = probplot(dist,spread(:,17)*100);
hold on
hT = probplot(dist,spread(:,21:24)*100);
hold on
case 4
hB1 = probplot(dist,spread(:,25)*100);
hold on
hB = probplot(dist,spread(:,29:32)*100);
hold on
case 5
hS1 = probplot(dist,spread(:,33)*100);
hold on
hS = probplot(dist,spread(:,37:40)*100);
hold on
    otherwise
end
xtickangle(45)
%datetick('x', 'mm/dd/yyyy','keepticks')
%hXLabel=xlabel({'percent';'daily'});
hXLabel=xlabel({'basis points';'daily'});
hYLabel=ylabel({'rate';'basis points'});
hLegend=legend('daily','.01',',25','.75','.99')
legend('boxoff')
hTitle=title({'Probability plot BGCR quantiles 2018-2022'});
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
%set(hE,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%legend('EFFR','OBFR','TGCR','BGCR','SOHR')

%{
FIT DISTRIBUTION AND PLOT
https://www.mathworks.com/help/stats/fit-a-nonparametric-distribution-with-pareto-tails.html
probplot(data);
hold on
p = fitdist(data,'tlocationscale');
h = plot(gca,p,'PlotType',"probability"); 
set(h,'color','r','linestyle','-');
title('Probability Plot')
legend('Normal','Data','t location-scale','Location','SE')
hold off

y1 = tpdf(x,5);
y2 = tpdf(x,10);
y3 = tpdf(x,50);

probplot(data);
hold on
p = fitdist(data,'tlocationscale');
h = plot(gca,p,'PlotType',"probability"); 
set(h,'color','r','linestyle','-');
title('Probability Plot')
legend('Normal','Data','t location-scale','Location','SE')
hold off
%}

probplot(spread(:,1));
hold on
p = fitdist(spread(:,1),'tlocationscale');
h = plot(gca,p,'PlotType',"probability"); 
set(h,'color','r','linestyle','-');
title('Probability Plot')
legend('Normal','Data','t location-scale','Location','SE')
hold off

% spreads
sohr_ior = spread(1:size(spread,1),43)-spread(1:size(spread,1),42)*100;
effr_ior = spread(1:size(spread,1),1)-spread(1:size(spread,1),42)*100;
size(effr_ior) % 1270   

fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hEI=plot(sdate,effr_ior);
hold on
hSI=plot(sdate,sohr_ior);
hold on
xtickangle(45)
datetick('x', 'mm/dd/yyyy','keepticks')
set(hEI,'LineStyle', 'none', 'Marker','x','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
set(hSI,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
h=[hEI hSI]
hXLabel=xlabel({'basis points';'daily'});
hYLabel=ylabel({'spread';'basis points'});
hLegend=legend(h,'EFFR-IOR','SOFR-IOR')
legend('boxoff')
hTitle=title({'Spreads EFFR-IOR, SOFR-IOR 2018-2022'});




x = [spread(81:size(spread,1),5:8) spread(81:size(spread,1),21:24) spread(81:size(spread,1),29:32) ];  % TGCR BGCR
%p = zeros(12,5);
% experiment 1 x(:,2:3) p01 p5
% experiment 2 fail
[p(:,5),stats]=quantreg(x,sohr_ior,.99);
[p(:,4),stats]=quantreg(x,sohr_ior,.75);
[p(:,3),stats]=quantreg(x,sohr_ior,.5);
[p(:,2),stats]=quantreg(x,sohr_ior,.25);
[p(:,1),stats]=quantreg(x,sohr_ior,.01);

% experiment 3 x(:,1) x(:,2) x(:,3)
[pe,stats]=quantreg(x(:,1:4),sohr_ior,.5);
[pt,stats]=quantreg(x(:,5:8),sohr_ior,.5);
[pb,stats]=quantreg(x(:,9:12),sohr_ior,.5);
be=sohr_ior\x(:,1:4);
bt=sohr_ior\x(:,5:8);
bb=sohr_ior\x(:,9:12);

% experiment 4 EFFR on repo market rates
%y=spread(81:size(spread,1),43);
%y=spread(81:size(spread,1),42);
y=spread(81:size(spread,1),1);
%x(:,5:12)
[p1,stats]=quantreg(x(:,5:12),y,.01);
[p25,stats]=quantreg(x(:,5:12),y,.25);
[p5,stats]=quantreg(x(:,5:12),y,.5);
[p75,stats]=quantreg(x(:,5:12),y,.75);
[p99,stats]=quantreg(x(:,5:12),y,.99);
be_all = y\x(:,5:12);




b =sohr_ior\x; % ols
xax = [.01 .25 .75 .99];
xax=1:8;
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
h5=plot(xax,p5)
hold on 
h01=plot(xax,p01)
hold on
hols=plot(xax,b);
hold on
hXLabel=xlabel({'quantile';'EFFR 1-4','TGCR 1-4','BGCR 5-8'});
hYLabel=ylabel('SOHR-IOR');
legend('\tau=.5','\tau=.01','OLS')

xax=1:4;
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
he=plot(xax,pe)
hold on 
ht=plot(xax,pt)
hold on
hb=plot(xax,pb);
hold on
holse=plot(xax,be);
hold on
holst=plot(xax,bt);
hold on
holsb=plot(xax,bb);
hold on
hXLabel=xlabel('quantile');
%hXLabel=xlabel({'quantile';'EFFR 1-4','TGCR 1-4','BGCR 1-4'});
hYLabel=ylabel('SOHR-IOR');
legend('EFFR','TGCR','BGCR','EFFRols','TGCRols','BGCRols')
%legend('\tau=.5','\tau=.01','OLS')

% 4
xax=1:8;
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
h1=plot(xax,p1)
hold on 
h25=plot(xax,p25)
hold on
h5=plot(xax,p5);
hold on
h75=plot(xax,p75);
hold on
h99=plot(xax,p99);
hold on
hols=plot(xax,be_all);
hold on
%{
holse=plot(xax,be);
hold on
holst=plot(xax,bt);
hold on
holsb=plot(xax,bb);
hold on
%}
%hXLabel=xlabel('quantile');
hXLabel=xlabel({'quantile';'TGCR 1-4','BGCR 1-4'});
hYLabel=ylabel('EFFR');
%legend('EFFR','TGCR','BGCR','EFFRols','TGCRols','BGCRols')
legend('\tau=.01','\tau=.25','\tau=.5','\tau=.75','\tau=.99','OLS')

%{

p =
   -0.0269
    0.4489
    0.0323
   -0.3468
    0.1026
    0.5433
   -0.6300
   -0.0910

size(p) 8     1
stats = struct with fields:
     pboot: [200×8 double]
       pse: [0.0204 0.0380 0.0216 0.0190 0.0206 0.0288 0.0287 0.0145]
    yfitci: [1190×2 double]

2) .01
p =

   -0.3409
   -0.0562
    2.8726
   -0.7339
    0.8079
    1.2543
   -1.5470
   -2.1593

stats = struct with fields:
     pboot: [200×8 double]
       pse: [0.1385 0.0503 0.2204 0.1053 0.1290 0.0414 0.1946 0.0890]
    yfitci: [1190×2 double]


%}

%[p,stats]=quantreg(x,sohr_ior,.75,2);
%{
Exiting: Maximum number of function evaluations has been exceeded
         - increase MaxFunEvals option.
         Current function value: 32.761339 
%}
%
fig_n1= fig_n1+1;
maxy = max(spread(:,1:8:33))
maxy1 = max(maxy)
miny =  min(spread(:,1:8:33))
miny1=min(miny)
endind = size(sdate,1);
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);%March 2 2016 to Nov 9 2023
%yyaxis right
%plot(mdate(1:endind), reservesnn,'-r','LineWidth',1) % reserves_n
%hold on  % 
%ylabel('reserves/ commercial deposits $ billions') 
%yyaxis left
hE = probplot(dist,spread(:,5:8));
hold on
hS = probplot(dist,spread(:,37:40));
hold on
hO = probplot(dist,spread(:,13:16));
hold on
hT= probplot(dist,spread(:,21:24));
hold on
hB = probplot(dist,spread(:,29:32));
hold on
xtickangle(45)

hXLabel=xlabel('rates (percent)');
hYLabel=ylabel('probability');
%datetick('x', 'mm/dd/yyyy','keepticks')
%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
xtickangle(45)
set(hE,'LineStyle', 'none','Marker', 'o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
h=[hE hO hT hB hS];
hLegend=legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','Location', 'northwest') 
hTitle=title({'Distribution Quintiles 1% 25% 75% 99% of US overnight rates'});
% Adjust Font and Axes Properties
set(gca,'FontName','Helvetica');
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
%'XTick'       , 0:50:maxx1, ...
%'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB_pplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateOTB_pplot.tex');

% REFERENCE
%mmean =movstd(spread(:,1:8:33),30)    
%mstd= movmean(spread(:,1:8:33),30)
   
% =================== Example plot ==========================
%{
a=annotatation('textarrow',x,y,'string','y=x');
a.color = 'red
a.fontszie=9
xticks=(0:10:maxx);
%}

%{
endind= size(spread,1)  
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]), ''FontName'',''Times-Roman'',''FontSize'',10;']);
%n = input('Enter a number for chart rates: ');
n=1
sz=20
switch n
    case 1
maxx=max(spread(:,2:8:34))
maxy=max(spread(:,1:8:33))
maxx1=max(maxx)
maxy1=max(maxy)
hE = scatter(spread(1:endind,2),spread(1:endind,1),sz,'.','MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]) 
hold on
hS = scatter(spread(1:endind,34),spread(1:endind,33),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] ) 
hold on
hO = scatter(spread(1:endind,10),spread(1:endind,9),sz,'+','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
hold on
hT = scatter(spread(1:endind,18),spread(1:endind,17),sz,'v','MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );
hold on
hB = scatter(spread(1:endind,26),spread(1:endind,25),sz,'*','MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );
hold on
xtickangle(45)
%{
% set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'Marker', '.','MarkerSize', 2,'MarkerFaceColor',[0 0 0]);
set(hS,'Marker','diamond', 'MarkerSize', 2,'MarkerFaceColor',[1 0 0] );
set(hO,'Marker', 'v','MarkerSize', 2,'MarkerFaceColor',[0 0 1] );  
set(hT,'Marker', '<','MarkerSize', 2,'MarkerFaceColor',[0 1 0] );  
set(hB,'Marker', '>','MarkerSize', 2,'MarkerFaceColor',[1 0 1] ); 
%}
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')
hTitle=title({'US overnight rates'}) %,{'EFFR','OBFR','TGCR','BGCR','SOFR'});
hXLabel=xlabel('volumes ($ billions)');
hYLabel=ylabel('percent');
hold on
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );

%{
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
axPos is [xMin,yMin,xExtent,yExtent]

Then, you get the limits, i.e. min and max of the axes.

xMinMax = xlim;
yMinMax = ylim;
Finally, you can calculate the annotation x and y from the plot x and y.

xAnnotation = axPos(1) + ((xPlot - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3);
yAnnotation = axPos(2) + ((yPlot - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4);
Use xAnnotation and yAnnotation as x and y coordinates for your annotation.
annotation(figure1,'textbox',[0.2726 0.638 0.1111 0.05249],...
        'String',{'Slope = Hp'},...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'FitBoxToText','off');
%}


for i=1:endind
    if spread(i,33)== 5.25
        fprintf('index = %3d,\n', i);
        %fprintf('Date = %10s,\n', raws(i,1));
        %print(raws{i,1})
        %print(sdate(i,1))
        %print(i)
        disp(num2str(sdate(i,1),'%.0f'))
    end
end
% i = 450
%datestr(sdate(450,:))   '17-Sep-2019'
%spread(450,33) = 5.25
%{
04/06/2018	SOFR	1.75	1.65	1.7	1.8	1.84	845
04/05/2018	EFFR	1.69	1.65	1.68	1.7	1.81	88
04/05/2018	OBFR	1.69	1.4	1.68	1.7	1.8	173
04/05/2018	TGCR	1.7	1.6	1.7	1.7	1.75	331
04/05/2018	BGCR	1.7	1.6	1.7	1.7	1.85	349
04/05/2018	SOFR	1.75	1.65	1.7	1.81	1.85	829
04/04/2018	EFFR	1.69	1.65	1.68	1.7	1.8	83
04/04/2018	OBFR	1.69	1.55	1.68	1.7	1.8	176
04/04/2018	TGCR	1.7	1.57	1.69	1.7	1.74	327
04/04/2018	BGCR	1.7	1.57	1.7	1.7	1.81	348
04/04/2018	SOFR	1.74	1.65	1.7	1.79	1.84	859

%}

% Set up annotation
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
%axPos is [xMin,yMin,xExtent,yExtent]
%The limits, i.e. min and max of the axes.
xMinMax = xlim;
yMinMax = ylim;
%axis([0 2*pi -1.5 1.5])
axis([xlim ylim])
xAnnotation = axPos(1) + ((fig_n1 - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3)
yAnnotation = axPos(2) + ((fig_n1 - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4)
zx = x(y==maxy1); 
zy = y(x==yAnnotation); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
xAn = [xAnnotation-.05,xAnnotation]
yAn = [yAnnotation-.01,yAnnotation]
a=annotation('textarrow',xAn,yAn,'String',{'y=x'});
a.color = 'red'
a.fontsize=9
%Use xAnnotation and yAnnotation as x and y coordinates for your annotation.
% String: Find date for point z = x(y==6.585); 
%{ 
% find x that correonds to y
zx = x(y==maxy1); 
zy = y(x==maxx1); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
a.color = 'red'
a.fontsize=9
%}
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_volumescatter.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_volumescatter.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrate_volumescatter.tex');
%{
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesES_reservesn_scatterv4.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumes_reservesn_scatterv4.eps')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesOTB_reservesn_scatterv5.eps')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesES_reservesn_scatterv4.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumes_reservesn_scatterv4.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesOTB_reservesn_scatterv5.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesES_reservesn_scatterv4.tex');
%}
 case 2
fig_n1=fig_n1+1;     
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
maxx=max(spread(:,10:8:26))
maxy=max(spread(:,9:8:25))
maxx1=max(maxx)
maxy1=max(maxy)
hO = scatter(spread(1:endind,10),spread(1:endind,9),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);
hold on
hT = scatter(spread(1:endind,18),spread(1:endind,17),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[0 1 0]);
hold on
hB = scatter(spread(1:endind,26),spread(1:endind,25),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);
hold on
%datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
%{
set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );  
set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
%}
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hO hT hB];
hLegend = legend(h,'OBFR','TGCR','BGCR','location', 'NorthWest' );
legend('boxoff')
hTitle=title({'US overnight rates'});
%hTitle=title({'US overnight rates'},{'OBFR','TGCR','BGCR'});
hXLabel=xlabel({'volumes','$ billions'});
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')
% Set up annotation
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
%axPos is [xMin,yMin,xExtent,yExtent]
%The limits, i.e. min and max of the axes.
xMinMax = xlim;
yMinMax = ylim;
%axis([0 2*pi -1.5 1.5])
axis([xlim ylim])
xAnnotation = axPos(1) + ((fig_n1 - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3)
yAnnotation = axPos(2) + ((fig_n1 - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4)
zx = x(y==maxy1); 
zy = y(x==yAnnotation); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
xAn = [xAnnotation-.05,xAnnotation]
yAn = [yAnnotation-.01,yAnnotation]
a=annotation('textarrow',xAn,yAn,'String',{'y=x'});
a.color = 'red'
a.fontsize=9

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');


set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
%'XTick'       , 0:50:maxx1, ...
%'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB__volumescatter.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateOTB__volumescatter.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateOTB_volumescatter.tex');

 case 3
fig_n1=fig_n1+1;     
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
maxy=max(spread(:,1),spread(:,2))
maxx=max(spread(:,33),spread(:,34))
maxx1=max(maxx)
maxy1=max(maxy)
hE = scatter(spread(1:endind,2),spread(1:endind,1),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]) %,'Exclude',spread(:,1)<4) 
hold on
hS = scatter(spread(1:endind,34),spread(1:endind,33),sz,'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]) %,'Exclude',spread(:,33)<4) 
hold on
xtickangle(45)
%{
set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none','Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
%}

h=[hE hS];
hLegend = legend(h,'EFFR','SOFR','location', 'NorthWest' );
legend('boxoff')
hTitle=title({'US overnight rates'}); %,{'EFFR','SOFR'});
hXLabel=xlabel({'volumes','$ billions'});
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')
% Set up annotation
axPos = get(gca,'Position'); %# gca gets the handle to the current axes
%axPos is [xMin,yMin,xExtent,yExtent]
%The limits, i.e. min and max of the axes.
xMinMax = xlim;
yMinMax = ylim;
%axis([0 2*pi -1.5 1.5])
axis([xlim ylim])
xAnnotation = axPos(1) + ((fig_n1 - xMinMax(1))/(xMinMax(2)-xMinMax(1))) * axPos(3)
yAnnotation = axPos(2) + ((fig_n1 - yMinMax(1))/(yMinMax(2)-yMinMax(1))) * axPos(4)
zx = x(y==maxy1); 
zy = y(x==yAnnotation); 
zxd=[zx-5, zx]
zyd=[zy-.05, zy]
a=annotation('textarrow',zxd,zyd,'string','y=x');
xAn = [xAnnotation-.05,xAnnotation]
yAn = [yAnnotation-.01,yAnnotation]
a=annotation('textarrow',xAn,yAn,'String',{'y=x'});
a.color = 'red'
a.fontsize=9

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:50:maxx1, ...
  'YTick'       , 0:.2:maxy1, ...
  'LineWidth'   , 1         );   
% 'XTick'       , 0:50:maxx1, ...
%  'YTick'       , 0:.5:maxy1, ..
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateES__volumescatter.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateES__volumescatter.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateES_volumescatter.tex');
otherwise
end
%}

% =========================== volatility =================================
%vol1= log(spread(2:endind,1:8:33))-log(spread(1:endind-1,1:8:33));