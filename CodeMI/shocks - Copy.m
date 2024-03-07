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
            2020           2        2020           4   
          2]
  2020	Peak occurred 2019Q4 April 	2020 	2	2
  %} 

fig_n1=1;
ne=0; nf = 1; ny = 0;
ne = input('Enter a number for ne: ');  % Display by epoch if still desires
nf = input('Enter a number for nf: ');  % Select sample size
ny = input('Enter a number for ny: ');  % Display by each year
% ================ Daily rate and volume data ================
[spread,txts,raws]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.xlsx','A2:AZ1715');
size(spread) %    1244          47
sdate = datenum(raws(:,1),'mm/dd/yyyy');
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
%} 
% Weekly volume weighted median rates
% FIND THIS FILE
%size(ratevw)  1271     8  full daily series sdate
% ============== Weekly Rates and reserve data
[rates,txt,raw]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_weekly.xlsx','A7:N267'); % UPDATE to 12/27?/2022
size(rates) % 261    13 
wdate = datenum(raw(:,1),'mm/dd/yyyy');
%{
rates(:,1:2) = effr;  1 rate, 2 vol
rates(:,3:4) = obfr;
rates(:,5:6) = tgcr;
rates(:,7:8) = bgcr;
rates(:,9:10) = sofr;
rates(:,11) = spread(:,41); %IOR
rates(:,12) = spread(:,44); %ONRPP Treasuries "Treasury GCF Repo® Weighted Average Rate"
rates(:,13) = spread(:,43); %ONRPP "MBS GCF Repo® Weighted Average Rate"
%}

%{
Shocks: FOMC rate hikes, IOR and ONRRP changes, Repo spikes (Duffie)
FOMC
2019 Fed Rate Cuts: Mid-Cycle Adjustment		
31-Oct-19	-25	1.50% to 1.75%
Sept. 19, 2019	-25	1.75% to 2.0%
Aug. 1, 2019	-25	2.0% to 2.25%

Fed Rate Hikes 2015 to 2018: Returning to Normalcy		
20-Dec-18	25	2.25% to 2.50%
Sept. 27, 2018	25	2.0% to 2.25%
Jun. 14, 2018	25	1.75% to 2.0%
22-Mar-18	25	1.50% to 1.75%
Dec. 14, 2017	25	1.25% to 1.50%
15-Jun-17	25	1.00% to 1.25%
16-Mar-17	25	0.75% to 1.00%
Dec. 15, 2016	25	0.5% to 0.75%
Dec. 17, 2015	25	0.25% to 0.50%
		
2019 Fed Rate Cuts: Mid-Cycle Adjustment		
31-Oct-19	-25	1.50% to 1.75%
Sept. 19, 2019	-25	1.75% to 2.0%
Aug. 1, 2019	-25	2.0% to 2.25%

break2 = 571:1236;
datetime(sdate(begn(2)), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(endn(2)), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
571: 03/16/2020 to 05/04/2022

2020 Fed Rate Cuts: Coping with Covid-19		
16-Mar-20	-100	0% to 0.25%
3-Mar-20	-50	1.0% to 1.25% <-- change begin date
datetime(sdate(562), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')
03/03/2020
spread(562,1)  1.5900
  
break3 = 1237:1271;
datetime(sdate(begn(3)), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
datetime(sdate(endn(3)), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
05/05/2022 to  12/29/2022
FOMC Meeting Date	Rate Change (bps)	Federal Funds Rate
2022 Fed Rate Hikes: Taming Inflation
14-Dec-22	50	4.25% to 4.50%
2-Nov-22	75	3.75% to 4.00%
21-Sep-22	75	3.00% to 3.25%
27-Jul-22	75	2.25% to 2.5%
16-Jun-22	75	1.5% to 1.75%
5-May-22	50	0.75% to 1.00%
17-Mar-22	25	0.25% to 0.50%


Administered rate:
Repo spikes
%}

%{
======================== Spreadss ================================
EFFR-IOR,  SOFR-IOR,  ONRRP-IOR
%}
hsof_ior=plot(sdate(1:endind), dshock(:,10),'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
%hsof_ior=plot(sdate(~outliers),si(~outliers),'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
hold on  % dshock(:,10)
he_ior=plot(sdate(1:endind), dshock(:,11),'r','LineWidth',1) % EFFR-IOR
hold on %dshocks(:,11)
honrpp_ior=plot(sdate(1:endind), dshock(:,12),'g','LineWidth',1) % ONRPP-IOR
hold on %dshocks(:,12)


hsof_ior=plot(sdate(1:endind),(spread(1:endind,43)-spread(1:endind,42))*100,'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
%hsof_ior=plot(sdate(~outliers),si(~outliers),'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
hold on  % dshock(:,10)
he_ior=plot(sdate(1:endind),(spread(1:endind,1)-spread(1:endind,41))*100,'r','LineWidth',1) % EFFR-IOR
hold on %dshocks(:,11)
honrpp_ior=plot(sdate(1:endind),(spread(1:endind,41)-spread(1:endind,41))*100,'g','LineWidth',1) % ONRPP-IOR
hold on %dshocks(:,12)


%{
================================= SHOCKS ==============================
FOMC  B_E DATE	Change	From	To
IOR   F-H Date	From	To
ONRRP I-K
Spikes L-O 737058	12/29/2017	-3	-33.6	-12  (M N O)
Date 	SOFR-IOR 	GCF-IOR	TGCR-OR
	(bps) 	 (bps) 	 (bps) 
TARGETU Date Date change
TARGETL Date Date change
%}
%{
weird error
shocks(1502:1503) 
4.0000       NaN    3.7500    0.50
4.5000       NaN    4.2500    0.5000

File data 
12/14/2022 	4	12/14/2022	3.75	0.5
12/15/2022	4.5	12/15/2022	4.25	0.5

%}
[mshocks,txts2,raws2]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.xlsx','Shocks1','A4:U1612');
size(mshocks) %    1244          47
sdate2 = datenum(raws2(:,1),'mm/dd/yyyy'); % Shocks assume sample k=2
%mshocks(isnan(shocks))=0;
% Spikes 737240	6/29/2018	17	28.3	15

% 7/28/2016 to 11/3/2022 0:00  FINISH Duffie spikes
%{
d spikes (x,y)
datetime(d, 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')
datetime(d, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yy')
737042  9.53107  12/13/2017
737140 10.3208   03/21/2018
737425 23.003   12/31/2018
737685 45.654   09/17/2019
738597 10.6869  03/17/2022
738868 11.6065  12/13/2022
%}
%{
FOMC dates 
fdate = datenum(fomc,'mm/dd/yyyy')
pdate = datenum(spikes,'mm/dd/yyyy')
fomc=[
'10/31/2019' 737729
'9/19/2019'  737687
'8/1/2019'   737638
'3/16/2020'  737866
'3/3/2022'   738583
'1/31/2023'
'12/14/2022'
'11/2/2022'
'9/21/2022'
'7/27/2022'
'6/16/2022'
'5/5/2022'
'3/17/2022']
fomc1=["10/31/2019","9/19/2019","8/1/2019","3/16/2020","3/3/2022"]
      737729
      737687
      737638
      737866
      738583
fomc=["1/31/2023","12/14/2022","11/2/2022","9/21/2022","7/27/2022","6/16/2022","5/5/2022","3/17/2022","3/3/2022"]
      738917
      738869
      738827
      738785
      738729
      738688
      738646
      738597
      %}
%Duffie spread spikes
% 
spikes=["12/29/2017","3/29/2018","5/31/2018","6/29/2018","12/6/2018","12/31/2018","1/2/2019","1/3/2019","1/31/2019","2/28/2019","3/29/2019","4/30/2019","7/1/2019","7/3/2019","7/5/2019","9/16/2019","9/17/2019","9/18/2019","9/25/2019","9/30/2019","10/15/2019","10/16/2019","10/31/2019","3/16/2020","3/17/2020"]
iorb=["12/18/2017","12/21/2017","03/22/2018","06/14/2018","09/27/2018","012/20/2018","05/2/2019","08/1/2019","09/19/2019","10/31/2019","1/30/2020","3/4/2020","3/16/2020","9/19/2019","10/31/2019","1/30/2020","3/4/2020","3/16/2020","6/17/2021","3/17/2022","5/5/2022","6/16/2022","7/28/2022","9/22/2022","11/3/2022"]

%{
ONRRP Award
3/22/2018
6/14/2018
9/27/2018
12/20/2018
8/1/2019
3/4/2020
3/16/2020
6/17/2021
3/17/2022
5/5/2022
6/16/2022
7/28/2022
9/22/2022
11/3/2022
12/15/2022
%}

rpp=["3/22/2018","6/14/2018","9/27/2018","12/20/2018","8/1/2019","3/4/2020","3/16/2020","6/17/2021","3/17/2022","5/5/2022","6/16/2022","7/28/2022","9/22/2022","11/3/2022","12/15/2022"]
rdate = datenum(rpp,'mm/dd/yyyy')
%{
737141
      737225
      737330
      737414
      737638
      737854
      737866
      738324
      738597
      738646
      738688
      738730
      738786
      738828
      738870
%}

% ======================================================================
%{
ne = 1:
normalcy   12/4/2017		8/1/2019    445   860
covid		8/2/2019		5/4/2022    861  1551    
inflation   5/5/2022		12/29/2022 1552  1714

ny=1 Choose year
2017  213   463  {'1/3/2017'} - '12/29/2017'}
2018  464   712  {'1/2/2018'} - {'12/31/2018'} 
2019  713   963  {'1/2/2019'} - {'12/31/2019'}    
2020  964  1214  {'1/2/2020'} - {'12/31/2020'}    
2021 1215  1465  {'1/4/2021'} - {'12/31/2021'}  
2022 1466  1714  {'1/3/2022'} - {'12/29/2022'} 

nf =  1  Select sample
1 03/04/2016 - 12/29/2022
2 07/28/2016 - 12/29/2022 IOR starts (before this date IOER or IORR)
3 01/02/2017 - 12/29/2022 

epochs (sub samples for tests of Fed inclination to accomodate rate volatility)
if ne == 1
%begn = [1 572 1109 1];  epochs
%endn = [571 1108 1271 1289];
finish index for begn, endn

k=1 % normalcy
meanratesd= mean(dratesbp(begn(k):endn(k),:))
sdratesd= std(dratesbp(begn(k):endn(k),:))
covrd=cov(dratesbp(begn(k):endn(k),:))

meanvold= mean(voldbp(begn(k):endn(k),:))
sdvold= std(voldbp(begn(k):endn(k),:))
covvd=cov(voldbp(begn(k):endn(k),:))
k=1 % normalcy
%}

% ================= Sample statistics, plots, dispersion =============== 
% volatility (maybe a new code or function volonrates?
nf = 2;
if nf ~= 0  % Do for a select sample
begn = [1 106 213 ];
endn = [1714 1714 1714]
switch nf   % Select sample size
   case 1 % 03/04/2016 - 12/29/2022
       k=1  
   case 2  % 07/28/2016 - 12/29/2022 IOR starts
       k=2
   case 3 % 01/02/2017
       k=3
end
end
begn(k)
endn(k)

% drates are volume weighted median rates
% drates 1% 25% 75% 99% are spread(:5:8) for EFFR
% check quintiels if exist for OBFR, TGCR, BDCR, SOFR
drates =spread(begn(k):endn(k),1:8:33);
vold =spread(begn(k):endn(k),2:8:34);
target=spread(begn(k):endn(k),3:4);
dratesbp= drates*100;

endind=size(mshocks,1);
dshocks=zeros(endind,13);
dshocks(:,1) = mshocks(:,1);  % FOMC
dshocks(:,2) = (mshocks(:,5)-mshocks(:,4))*100;  % IOR
dshocks(:,3) = (mshocks(:,7)-mshocks(:,6))*100;  % ONRRP
for t=1:endind
    if mshocks(t,8)~=0 & mshocks(t+1,8)~=0
        dshocks(t+1,4) = (mshocks(t+1,8)-mshocks(t,8))*100;  % TargetU
    end
end

for t=1:endind
    if mshocks(t,9)~=0 & mshocks(t+1,9)~=0
        dshocks(t+1,5) = (mshocks(t+1,9)-mshocks(t,9))*100;  % TargetL
    end
end
dsk = [mshocks(:,8:9)  dshocks(:,4:5)]; % check target shock calculation

dshocks(:,6:8) = mshocks(:,8:10); % SOFR-IOR 	GCF-IOR	TGCR-OR  Duffie
dshocks(:,10) = (spread(1:endind,43)-spread(1:endind,42))*100; %SOFR-IOR % NYFED
dshocks(:,11) = (spread(1:endind,1)-spread(1:endind,41))*100;  %EFFR-IOR
dshocks(:,12) = (spread(1:endind,44)-spread(1:endind,41))*100; %ONRRP-IOR

%{
dummy variables for shocks
k=1  FOMC change
k=2  IOR  change
k=3  ONRRP change
K=4  TargetU change
K=5  TargetD change
k=6  End of quarter
%} 
h=zeros(endind,6);
for j=1:endind
    for k=1:6
    if dshocks(j,k) >0 
        h(j,k) =1
    end
    end
   
end
%Q(isnan(Q))=0;
dshock2= dshock;
dshock2(dshock2==0)=nan; 
%dshocks(isnan(dshocks))=0;
%{
Don't plot zero values
drates(2:endind,1)-drates(1:endind-1,1)*100);
isNZ=(~y==0);           % addressing logical array of nonzero elements
plot(x(isNZ),y(isNZ))   % plot only the subset
 or
yplot=y;              % make a copy of the data specifically for plotting
yplot(yplot==0)=nan;  % replace 0 elements with NaN
plot(x,yplot)
isNZ=(~dshocks==0); 
%}
%isNZ=(~dshocks==0); didn't work
dshock2= dshocks;
dshock2(dshock2==0)=nan; 

%{
Plots of rates and shocks
Plots of volumens and shocks
"r"	[1 0 0]	
"green"	"g"	[0 1 0]	
"blue"	"b"	[0 0 1]	
"cyan"	"c"	[0 1 1]	
"magenta"	"m"	[1 0 1]	
"yellow"	"y"	[1 1 0]	
"black"	"k"	[0 0 0]	
"white"	"w"	[1 1 1]
"gold"
%}   

%{
Don't plot zero observations
yplot=y;              % make a copy of the data specifically for plotting
yplot(yplot==0)=nan;  % replace 0 elements with NaN
plot(x,yplot)
or
isNZ=(~y==0);           % addressing logical array of nonzero elements
plot(x(isNZ),y(isNZ))   % plot only the subset

yyaxis left
title('Plots with Different y-Scales')
xlabel('Values from 0 to 25')
ylabel('Left Side')

yyaxis right
ylabel('Right Side')

%}
% ---------------Plot level of EFFR rate and Shocks ----------------------
% which are changes in FOMC, IOR, ONRRP
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(:,1)*100):25:max(drates(:,1)*100)];
yyaxis right
hE = plot(sdate(begn(k):endn(k)),drates(:,1)*100) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
ylabel('Basis points')
hold on
yyaxis left
hF = plot(sdate(begn(k):endn(k)),dshock2(:,1)) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock2(:,2)); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock2(:,3)); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock2(:,4),'--k','Linewidth',2); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock2(:,5),'--k','Linewidth',2); % TARGETL
hold on
ylabel('Change in basis points')
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%{
hF = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),5)*100); % TARGETL
hold on
%}
%hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  % cyan
set(hF,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 5,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hIOR,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 5,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0 ] ); % magenta
set(hRRP,'LineStyle', 'none','Marker', 'square','MarkerSize', 5,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', '-','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', '-','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow


%{
stackedplot(X,Y)
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(drates(:,1)*100):25:max(drates(:,1)*100)];
yyaxis right
stackedplot(sdate(begn(k):endn(k)),dshock2(:,1:3),"FOMC","IOR","RRP")
%}


h=[hE hF hIOR hRRP hU hL];
hLegend = legend(h,'EFFR','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

% Level EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Log first difference EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Distance from targets EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');


% -------------------- percent change effr and shocks ------------------
volrates = (log(drates(2:endind,1))-log(drates(1:endind-1,1)))*100;
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(volrates)*100:25:max(volrates)*100];
hE = plot(sdate(begn(k):endn(k)-1),volrates(1:endind-1,1)*100) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hF = plot(sdate(begn(k):endn(k)),dshocks(:,1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshocks(:,2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshocks(:,3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshocks(:,4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshocks(:,5)*100); % TARGETL
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%{
hF = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),5)*100); % TARGETL
hold on
%}
%hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  % cyan
set(hF,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hIOR,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % magenta
set(hRRP,'LineStyle', 'none','Marker', 'square','MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow

h=[hE hF hIOR hRRP hU hL];
hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

% Different realized volatility measures
%{
Use 252 day trailing window of std calculate three ways
Volatility is calculated using publicly released weekly snapshots for 
52-week trailing windows, as the standard deviation of the first difference
M = movstd(A,k) returns an array of local k-point standard deviation value
a. straight r_t-r_{t+1}
b. log(r_t)-log(r_{t+1})
c. with kernel K
%}
%dratesbp = drates(1:endind,1)*100;

%a
%vol1rates = (log(drates(2:endind,1))-log(drates(1:endind-1,1)))*100; %
%change

measure = zeros(endind,3);
volrates = zeros(endind,3);
measure(:,1) = dratesbp(2:endind,1)-dratesbp(1:endind-1,1)
measure(:,2) = dratesbp(2:endind,1)-dratesbp(1:endind-1,1)
measure(:,3) = log(dratesbp(2:endind,1))-log(dratesbp(1:endind-1,1));
volrates(2:endind,1,1) = measure3; % log pct change
volrates(2:endind,2) = movstd(measure(:,2),252);
volrates(2:endind,3) = movstd(measure(:,3),252);
%vol1rates = (log(drates(2:endind,1))-log(drates(1:endind-1,1)))*100;
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(volrates)*100:25:max(volrates)*100];
hE1 = plot(sdate(begn(k):endn(k)-1),volrates(1:endind-1,1)*100) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hE2 = plot(sdate(begn(k):endn(k)-1),volrates(1:endind-1,2)) %,'LineStyle', 'none');
hold on
hE3 = plot(sdate(begn(k):endn(k)-1),volrates(1:endind-1,3)*100) %,'LineStyle', 'none');
hold on

hF = plot(sdate(begn(k):endn(k)),dshock2(:,1)) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock2(:,2)); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock2(:,3)); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshocks(:,4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshocks(:,5)*100); % TARGETL
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%{
hF = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),5)*100); % TARGETL
hold on
%}
%hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
set(hE1,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % cyan
set(hE2,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0]);  % cyan
set(hE3,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);  % cyan

set(hF,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hIOR,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % magenta
set(hRRP,'LineStyle', 'none','Marker', 'square','MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow

h=[hE1 hE2  hE3  hF hIOR hRRP];
hLegend = legend(h,'EFFR pct change','std level 252 day window','std log 252 day window','FOMC change','IOR change','ONRRP change','location', 'NorthWest' );
legend('boxoff')

h=[hE hF hIOR hRRP hU hL];
hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

%{ 
Volatility is calculated using publicly released weekly snapshots for 
52-week trailing windows, as the standard deviation of the first difference
M = movstd(A,k) returns an array of local k-point standard deviation values. 
Each standard deviation is calculated over a sliding window of length k 
across neighboring elements of A. When k is odd, the window is centered 
about the element in the current position. When k is even, the window is 
centered about the current and previous elements. The window size is 
automatically truncated at the endpoints when there are not enough elements
to fill the window. When the window is truncated, the standard deviation is
taken over only the elements that fill the window. M is the same size as A.

https://www.cmegroup.com/education/articles-and-reports/cme-sofr-futures-and-sofr-volatility.html
The implied volatility rates are averages of mid-level rates for bid and 
ask "at-money-quotations" on selected currencies at 11:00 a.m. on the last business day of the month.
Suzanne Elio at (212) 720-6449 or suzanne.elio@ny.frb.org.
https://seekingalpha.com/article/4501215-implied-volatility

historical volatility
a. v_t = std(r_t-r_{t-1})
b. v_t = std(log{r_t}-log{r_{t-1}})
c. See how Gara does it, moving window:
 b 52-week trailing windows, as the standard deviation of the first difference
 M = movstd(A,k) returns k = 52 for weeks??
%}
v=zeros(size(drates(begn(k):endn(k),:)));
for t=begn(k)+1:endn(k)
v(t,:) = std(drates(t,:)-drates(t-1,:));
v(t,:) = std(log(drates(t,:))-log(drates(t-1,:)));
end

% Level EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Log first difference EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks.fig');

% Volatility 3 measures plus shocks
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/volmeasures.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/volmeasures.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/volmeasures.fig');

% Distance from targets EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Dispersion
% drates 1% 25% 75% 99% are spread(:5:8) for EFFR
% check quintiels if exist for OBFR, TGCR, BDCR, SOFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/disperionshocks.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/disperionshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/disperionshocks.fig');

distable = zeros(endind,3);
disptable =  [sdate(begn(k):endn(k),1) raws(begn(k):endn(k),1)  d(:,1)]
disptable =  [sdate(begn(k):endn(k),1)  d(:,1)]
raws(begn(k):endn(k),1)
% ======================= END SAMPLE ANALYSIS ========================

% ================= ANNUAL statistics, plots, dispersion =============== 
% How to do this, with a separate function for a) sample, b) annual
if ny ~= 0  % Do for each year
begn = [213 464 713  964 1215 1466];
endn = [463 712 963 1214 1454 1714];

meanratesd=zeros(6,5);
medianratesd=zeros(6,5);  
sdratesd=zeros(6,5); 
%covrd = zeros(6,6,5

meanvold=zeros(6,5); 
medianvold=zeros(6,5); 
meanvold=zeros(6,5); 
sdvold=zeros(6,5); 
%covrd = zeros(6,6,5

% check dates
raws(begn)
raws(endn)

for k=1:6
drates(begn(k):endn(k),:)=spread(begn(k):endn(k),1:8:33);
vold(begn(k):endn(k),:) =spread(begn(k):endn(k),2:8:34);
% insert operation or plot: level, pct change, distance from targets (see
% Gara)
% DK dispersion index by sample or year
end
dratesbp = drates*100;

for k = 1:6
meanratesd(k,:)  = mean(drates(begn(k):endn(k),:) )
medianratesd(k,:) = median(drates(begn(k):endn(k),:))
sdratesd(k,:)  = std(drates(begn(k):endn(k),:) )
% covrd=cov(dratesbp(begn(k):endn(k),:)) Think how to do by year

meanvold(k,:)  = mean(vold(begn(k):endn(k),:))
medianvold(k,:)  = median(vold(begn(k):endn(k),:))
sdvold(k,:)  = std(vold(begn(k):endn(k),:))
% covvd=cov(dratesbp(begn(k):endn(k),:))
end

end % if ny ~=0 choice
%{
 ==================================================================
Plots of rates and shocks by year
Plots of volumens and shocks
"r"	[1 0 0]	
"green"	"g"	[0 1 0]	
"blue"	"b"	[0 0 1]	
"cyan"	"c"	[0 1 1]	
"magenta"	"m"	[1 0 1]	
"yellow"	"y"	[1 1 0]	
"black"	"k"	[0 0 0]	
"white"	"w"	[1 1 1]
%}   

% ---------------Plot level of EFFR rate and Shocks ----------------------
% which are changes in FOMC, IOR, ONRRP
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(:,1)*100):25:max(drates(:,1)*100)];
hE = plot(sdate(begn(k):endn(k)),drates(:,1)*100) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hF = plot(sdate(begn(k):endn(k)),dshocks(:,1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshocks(:,2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshocks(:,3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshocks(:,4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshocks(:,5)*100); % TARGETL
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%{
hF = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),5)*100); % TARGETL
hold on
%}
%hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  % cyan
set(hF,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hIOR,'LineStyle', 'none', 'Marker','x', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % magenta
set(hRRP,'LineStyle', 'none','Marker', 'square','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow

h=[hE hF hIOR hRRP hU hL];
hLegend = legend(h,'EFFR','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

% Level EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Log first difference EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Distance from targets EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');


% -------------------- percent change effr and shocks ------------------
volrates = (log(drates(2:endind,1))-log(drates(1:endind-1,1)))*100;
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(volrates)*100:25:max(volrates)*100];
hE = plot(sdate(begn(k):endn(k)-1),volrates(1:endind-1,1)*100) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hF = plot(sdate(begn(k):endn(k)),dshocks(:,1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshocks(:,2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshocks(:,3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshocks(:,4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshocks(:,5)*100); % TARGETL
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%{
hF = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),1)*100) %,'LineStyle', 'none'); FOMC
hold on
hIOR = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),2)*100); % IOR
hold on
hRRP = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),3)*100); % ONRRP
hold on
hU = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),4)*100); % TARGETU
hold on
hL = plot(sdate(begn(k):endn(k)),dshock(begn(k):endn(k),5)*100); % TARGETL
hold on
%}
%hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  % cyan
set(hF,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hIOR,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % magenta
set(hRRP,'LineStyle', 'none','Marker', 'square','MarkerSize', 4,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', ':','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow

h=[hE hF hIOR hRRP hU hL];
hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

% Level EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');

% Log first difference EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/pctshocks.fig');

% Distance from targets EFFR
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/levelshocks.fig');
% ======================= END ANNUAL ANALYSIS ========================


%{
% ================ subplots for EFFR target, and percentiles ==============
By sample or year?
%}
            
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
a1 = subplot( 1, 2, 1 );
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h1=[hE hL hU];
hLegend = legend(h1,'EFFR','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
%set(gcf, 'PaperPositionMode', 'auto');
% save plot

a2 = subplot( 1, 2, 2 );
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hD1 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),2)*100); % 25 pct
hold on
hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
hold on
yline(meaneffr,'--b','Median') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h2=[hE hD1 hD2];
hLegend = legend(h2,'EFFR','25 percentile','75 percentile','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
% save plot

%SAVE WHICH PLOTS??
if k==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.fig');
elseif k==2
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.eps');
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.fig');
elseif k==3
    % t for target rates
    % p for percentiles
    % s for subplots
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.fig')
end

%{
=============== Duffie Krishnamirthy dispersion index ====================
Sample or annual?
https://www.mathworks.com/help/matlab/ref/function.html
Syntax function [y1,...,yN] = myfun(x1,...,xM)
Description example
function [y1,...,yN] = myfun(x1,...,xM) declares a function named myfun 
that accepts inputs x1,...,xM and returns outputs y1,...,yN. This 
declaration statement must be the first executable line of the function. 
Valid function names begin with an alphabetic character, and can contain 
letters, numbers, or underscores

function ave = calculateAverage(x)
    ave = sum(x(:))/numel(x); 
end
Call the function from the command line.

z = 1:99;
ave = calculateAverage(z)

function [d]=dkdispersion(drates,vold. begn(k),endn(k))
% drates are volume weighted median rates
% drates 1% 25% 75% 99% are spread(:5:8) for EFFR
% check quintiles if exist for OBFR, TGCR, BDCR, SOFR
yi,t(m) denotes the rate at time t on instrument i, maturing in m days. We first
adjust the rate to remove term-structure effects, obtaining the associated “overnightequivalent” rate as
ybi,t = yi,t(m) − (OISt(m) − OISt(1)),The dispersion index D_t at day t as the weighted mean absolute deviation of the cross-sectional adjusted rate
distribution on that day.


%}
% 
% drates are volume weighted median rates for rates for each year
% drates 1% 25% 75% 99% are spread

function d=dkdispersion(drates,vold, begn(k),endn(k))
endind=size(drates,1);
d=zeros(size(drates,1));
vtot=zeros(size(drates,1));
mrate=zeros(size(drates,1));
mrater=zeros(size(drates,1));
absdiff=zeros(size(drates,1));

for t=1:endind %begn(k):endn(k)
    for i=1:5 
    vtot(t)=  vtot(t)+ vold(t,i); % volume at t of all f ON rates
    %mrate(t) = mrate(t)+ vold(t,i)*drates(t,i); % volume-weighted mean rate
    mrate(t) = mrate(t)+ drates(t,i); % since drate is a volume-weighted mean rate
    end
    % for now, the on equiv rate is the rate in data
    meanr(t) =mrate(t)/vtot(t);
    for i=1:5   
        absdiff(t,i) = vold(t,i)*(abs(rrbp(t,i)- meanr(t)));
    end  
end
absd = sum(absdiff,2);
vt= sum(vold,2);
d = absd(t)./(vt);
end % end function

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(d):1:max(d)];
%ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
%hold on
hD = plot(sdate(begn(k):endn(k)),d(begn(k):endn(k)))
%hD = plot(sdate(begn(k):endn(k)),d) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hD,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
%set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % cyan
%set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
%set(hL,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
%set(hU,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow
%h=[hE hO hL hU hD1 hD2];
%hLegend = legend(h,'EFFR','OBFR','Lower target','Upper target','25 percentile','75 percentile','location', 'NorthWest' );
h=[hD];
hLegend = legend(h,'Duffie-Krishnamurthy dispersion index 3/04/2016-12/29/2022','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('Dispersion (basis points)');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
% brushed 0/17/2019  March 2020 check coordinates
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionDK.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionDK.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionDK.fig');
%{
10.31       {'12/6/2018' }      737400 
5.1332	    {'3/18/2020' }		737868
151.1424	{'4/19/2019' }		737534
14.5682	    {'4/15/2022' }		738626
209.2487	{'12/29/2022'}		738884
%}

%{
==================== Gara Deviation of EFFR from targets ==================
Sample or annual?
the volatility of the fed funds rate, let ¯ρt denote the value-weighted
fed funds rate (average for day t). Let ρmaxt be the upper bound for the FOMC policy target
band for day t, and let ρmint be the lower bound of the band. Define the deviation from target
on day t, denoted Dt
%}
% function []=gara()
g  = zeros(size(drates(begn(k):endn(k),1)));
%g  = zeros(size(spread,1));
%for t=1:T
for t=begn(k):endn(k)
if  target(t,1)< drates(t,1) %upper target
g(t) = drates(t,1) - target(t,1); %upper target
elseif drates(t,1) < target(t,2)
g(t) = drates(t,1) - target(t,2); %lower target
end
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']); 
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100) %,'LineStyle', 'none');
hold on
hG = plot(sdate(begn(k):endn(k)),g*100) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);  % black
set(hU,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);  % red
set(hL,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0]);  % greed
set(hG,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % cyan
%set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
%set(hL,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
%set(hU,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
%set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
%set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow
%h=[hE hO hL hU hD1 hD2];
%hLegend = legend(h,'EFFR','OBFR','Lower target','Upper target','25 percentile','75 percentile','location', 'NorthWest' );
%legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('Dispersion');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
%set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);

% ====================== Simple regressions ===========================
%
%[theta,sec,R2,R2adj,vcv,F] = olsgmm(drates(2:endind,:), xx,nlag,nw); 
[theta,sec,R2,R2adj,vcv,F] = olsgmm(drates(2:endind,:),drates(1:endind-1,:),nlag,nw);  % constant
param = [theta sec,R2,R2adj,vcv,F]
ones(size(drates,1)-1);
nlag = 12;
nw = 1;
xx= [ones(size(drates,1)-1) drates(1:endind-1,:)  ];

%rates
[theta,sec,R2,R2adj,vcv,F] = olsgmm(drates(2:end,:),xx1,nlag,nw);  % constant
param = [theta sec,R2,R2adj,vcv,F]

[beta,sec,R2,R2adj,vcv,F] = olsgmm(drates(2:end,:), xx2,nlag,nw)
param = [beta sec]

[beta,sec,R2,R2adj,vcv,F] = olsgmm(drates(2:end,:), xx3,nlag,nw)
param = [beta sec]

% Volatility
ones(size(volrates,1)-1);
xx4 = [volrates(1:endind-1,:) ]
xx5= [volrates(1:endind-1,3) dshocks(1:endind-1,10:12)]
%SOFR_IOR(1:end-1) EFFR_IOR(1:end-1) ONRRP_IOR(1:end-1)]
%xx5= [volrates(1:endind-1,3) dshocks(1:endind-1,6:8) ]
xx6= [volrates(1:endind-1,3) dshocks(1:endind-1,1:3)]
[theta,sec,R2,R2adj,vcv,F] = olsgmm(volrates(2:endind,3),volrates(1:endind-1,3),nlag,nw);  % constant
param = [theta sec,R2,R2adj,vcv,F]

[theta,sec,R2,R2adj,vcv,F] = olsgmm(volrates(2:endind,3),xx6,nlag,nw);  % constant
param = [theta sec]
param = [theta sec,R2,R2adj,vcv,F]
%{
param =
    0.9997    0.0008
    0.0000    0.0000
   -0.0000    0.0000
    0.0000    0.0000
R2 = 0.9980
%}

[theta,sec,R2,R2adj,vcv,F] = olsgmm(volrates(2:endind,3),xx5,nlag,nw);  % constant
param = [theta sec]
param = [theta sec,R2,R2adj,vcv,F]
%{
param =
    1.0001    0.0008
    0.0000    0.0000
    0.0000    0.0000
    0.0000    0.0000
R2adj = 0.9980
%}

xx7= [ones(size(volrates,1)-1,1) dshocks(1:endind-1,10:12)];
[theta,sec,R2,R2adj,vcv,F] = olsgmm(volrates(2:endind,3),xx7,nlag,nw);  % constant
param = [theta sec]
param = [theta sec,R2,R2adj,vcv,F]
%{
no constant
    0.0004    0.0006
   -0.0108    0.0018
    0.0032    0.0010
R2 =  -1.1467
%}

%{
constant
param =
    0.1538    0.0115
    0.0011    0.0002
    0.0054    0.0017
    0.0002    0.0004
R2 = 0.1739


% log pct change and std models

%{
Bertolini FF variance model
Model banks' liquidity management  and official intervention policies 
jointly in a setting which explicitly accounts for the main institutional 
features of the US Federal Funds market
- EGARCH(1,1) Exponential Garch  (Nelson)
- persistent deviations of (log of) conditional from 
  unconditional variance:
  beta1 h(t)+ beta2 z(t) + log(1+gamma N(t), trading day effects??
  z(t) target rate as a proportion of penalty rate tp test different target
  rates

Empirical model of the FF rate
r(t) = mu(t) + sig(t)*nu(t), nu(t) zero mean iid shock 
after fed  injects reserves m(t)

a. mu(t) =E[r(t)] ,  include lag to test martingale hypothesis

mu(t) =beta1 r(t-1) + beta2 k(t) + beta3 (rstar(t)-rstar(t-1)
k(t) days before and after holidayes, end of qtr, end of year dummies
mu(t) =beta1 r(t-1) + beta2 (r(t-1)-r(t-2)) + beta3 (r(t-2)-r(t-3))  beta2 k(t) + beta3 (rstar(t)-rstar(t-1)

b. sig2 = E(r(t)-mu(t))^2
log(var(t)-beta1*h(t)- beta2*z(t) - log(1+gamma N(t)=
log(var(t-1)-beta1*h(t-1)- beta2*z(t-1) - log(1+gamma N(t-1) 
+ beta3 abs(nu(t))+  beta4*nu(t)
h(t) calendar effects, regime dummies, see text
N(t) number of nontrading days betn t and t-1

allow for assymmetric innovations v(t-1) on each day's variance

EGARCH(1,1) econometrics toolbox
https://www.mathworks.com/help/econ/egarch.html
Mdl = egarch(P,Q) creates an EGARCH conditional variance model object (Mdl)
 with a GARCH polynomial with a degree of P, and ARCH and leverage 
polynomials each with a degree of Q. All polynomials contain all 
consecutive lags from 1 through their degrees, and all coefficients are 
NaN values.

This shorthand syntax enables you to create a template in which you specify 
the polynomial degrees explicitly. The model template is suited for unrestricted parameter estimation, that is, estimation without any parameter equality constraints. However, after you create a model, you can alter property values using dot notation.
%}

Guyon volality models:
Trend features are features that capture a recent trend in the asset price 
in order to learn the leverage effect, i.e., the fact that volatility tends
to rise when asset prices fall. The most importantexample of a trend feature 
is a weighted sum of past daily returns

(3.12) Volatility_t = \beta_0 + \beta_1R_{1,t} + \beta_2\R^Q(2,t)_t

Volatility(t) denotes either some
implied volatility (e.g., the VIX) observed at t, or some future realized 
volatility right after t (e.g., realized
over day t + 1). 
\emph{Trend features} are features that capture a recent trend in the asset
price in order to learn the leverage effect, i.e., the fact that volatility
tends to rise when asset prices fall. The most important example of a trend
feature is a weighted sum of past daily returns

\begin{equation*}
(3.1) R_{1,t} := \sum_{}^{} K_1(t − t_i) r_t_i
ti≤t
\end{equation*}
where

\begin{equation*} % e time-shifted power laws (TSPL):
K^{\lamba}=\lamba exp(-\lambda*\tau)
\end{equation*}

\begin{equation*}
(3.1) R^Q_{2,t} := \sum_{i,j}^{} K^Q_2(t − t_i,t − t_j) r_t_i*r_t_j
ti≤t
\end{equation*}
where

\begin{equation*}
(3.2) rti
:=
Sti − Sti−1
Sti−1
\end{equation*}
denotes the daily return between day ti−1 and day ti
, and K1 : R≥0 → R≥0 is a convolution kernel
that puts more or less weight on past daily returns based on the lag t − ti
, i.e., on how far in the past the daily return was observed. The kernel K1 typically decreases towards zero: the impact of a
given daily return fades away over time. Other examples o trend features include the weighted sum of negative parts of past daily returns
% ==================== Example PLOT ===================================
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hO = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),2)*100);
hold on
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
hD1 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),2)*100); % 25 pct
hold on
hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
hold on
yline(meaneffr,'--b','Median') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % cyan
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[ 0 1 0] );  % green
set(hL,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  % black
set(hU,'LineStyle', 'none','Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0 ] );  
set(hD1,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % clay
set(hD2,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow
h=[hE hO hL hU hD1 hD2];
hLegend = legend(h,'EFFR','OBFR','Lower target','Upper target','25 percentile','75 percentile','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
% to remove point, brush data, mark point, right click, remove
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
ylim([min(drates(begn(k):endn(k),1)*100) max(drates(begn(k):endn(k),1)*100)]);
%set([hXLabel, hYLabel, hText],'FontSize',10);
%set( hTitle,'FontSize', 10,'FontWeight', 'bold');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'off'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'LineWidth'   , 1         );
set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
% save plot
if k==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrnorms.fig');
elseif k==2
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.eps');
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrcovds.fig');
elseif k==3
    % t for target rates
    % p for percentiles
    % s for subplots
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/dailyeffrpis.fig')
end

