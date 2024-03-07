
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
daily=1;
nf=1
rates = input('Enter a number for rates: ');  % Display by epoch if still desires
% rates = 1;  % rate volatility
% rates = 0;  % volume volatility

% ================ Daily rate and volume data ================
%FIX duplicate read statement line 1921
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

rated=spread(:,1:8:33);
rrbp=rated*100;
vold=spread(:,2:8:34);
ior=spread(:,41)*100;
sofr=spread(:,42)*100;
rrpreward=spread(:,43)*100;
onrrp=rrpreward;
ior(isnan(ior))=0;
sofr(isnan(sofr))=0;
onrrp(isnan(onrrp))=0;

[mshocks,txts2,raws2]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.xlsx','Shocks1','A3:U1716');
size(mshocks) %    1244          47
sdate2 = datenum(raws2(:,1),'mm/dd/yyyy'); % Shocks assume sample k=2
%mshocks(isnan(shocks))=0;
% Spikes 737240	6/29/2018	17	28.3	15
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
dshocks(isnan(dshock2))=0;

% ================= Select sample ====================
ne=0; nf = 0; ny = 0;
ne = input('Enter a number for ne: ');  % Display by epoch if still desires
nf = input('Enter a number for nf: ');  % Select sample size
ny = input('Enter a number for ny: ');  % Display by each year

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
1 03/04/2016 - 12/29/2022 NYFed rates series start date  4
2 07/28/2016 - 12/29/2022 IOR starts (before this date IOER or IORR)
2 01/02/2017
%}

nf=1
if nf ~= 0
begn = [4 106 213];
endn = [1714 1714 1714];
switch nf   % Select sample size
   case 1 % 03/04/2016 - 12/30/2022  4
       k=1  
   case 2  % 07/28/2016 - 12/29/2022 IOR starts 106
       k=2
   case 3 % 01/02/2017 213
       k=3
end
end

% ================= Volatility measures ============
% Different realized volatility measures
%{
Use 252 day trailing window of std calculate three ways
Volatility is calculated using publicly released weekly snapshots for 
52-week trailing windows, as the standard deviation of the first difference
M = movstd(A,k) returns an array of local k-point standard deviation value
a. log(r_t)-log(r_{t+1})
b. std deviation (log(r_t)-log(r_{t+1}))
c. movstd(vol_b,244) with kernel K=244 or 252
Both models are estimated via OLS on daily data, using a 260-day rolling window 
to allow their parameters to adapt to a changing environment.

Hamilton Figure 1 displays the sample histogram for fid, drawn for comparison with the Normal distribution. Forty-six percent of the observations are exactly zero, 
while 25 observations exceed 5 standard deviations. If fid were an i.i.d. Gaussian time series, one would not expect to see even one 5 standard deviation outlier. Often these outliers occur on days that Gurkaynak, Sack, and

%}

%{
While GARCH, FIGARCH and stochastic volatility models propose statistical
constructions which mimick volatility clustering in financial time series, they
do not provide any economic explanation for it.
%}
%{
Duffie Among our other explanatory variables are measures of the volatility of the federal funds rate and of the 
strength of the relationship between pairs of counterparties. In
to capture the volatility of the federal funds rate, we start with 
a dollar-weighted average during a given minute t of the interest rates of all loans made in that minute. 
We then measure the time-series sample standard deviation of these minute-by-minute average rates 
over the previous 30 minutes, denoted or(t). 
The median federal funds rate volatility is about 3 basis points, but ranges from under 1 basis point to 87 basis points, with a sample standard deviation of 4 basis points. Our measure of sender-receiver relationship strength for a particular pair (i,j) of counterparties, denoted Sij, is the dollar volume of transactions sent by i to j over the previous month divided by the dollar volume of all trans- actions sent by i to the top 100 institutions. The receiver-sender relationship strength Rij is the dollar volume of transactions received by i from j over the previous month divided by the dollar volume of all transactions received by i from

The formal definition of the primary metric I study, market volatility, is the standard deviation of 1
minute returns: s
⌃Ni
=sqrt(sum 1 through n(ri -rbar)^2/(n-1))
%}
measure1 = zeros(endn(k),5);
measure2 = zeros(endn(k),5);
measure3 = zeros(endn(k),5);
measure4 = zeros(endn(k),5);
if rates == 1
%measure1(begn(k)+1:endn(k),:) = abs(rrbp(begn(k)+1:endn(k),:)-rrbp(begn(k):endn(k)-1,:));
%measure2(begn(k)+1:endn(k),:) = abs(rrbp(begn(k)+1:endn(k),:)-rrbp(begn(k)+1:endn(k)-1,3));
measure1 = log(rrbp(begn(k)+1:endn(k),:))-log(rrbp(begn(k):endn(k)-1,:));
measure2 = std(measure1(:,1:5));
measure3 = movstd(measure1,244);
elseif rates ==0
measure1(begn(k)+1:endn(k),:) = abs(vold(begn(k)+1:endn(k),:)-rrbp(begn(k):endn(k)-1,:));
measure2(begn(k)+1:endn(k),:) = abs(vold(begn(k)+1:endn(k),:)-rrbp(begn(k)+1:endn(k)-1,3));
measure3(begn(k)+1:endn(k),:) = log(vodl(begn(k)+1:endn(k),:))-log(rrbp(begn(k):endn(k)-1,:));
end
volrates1(begn(k)+1:endn(k),:) = measure3(begn(k)+1:endn(k),:); % log pct change
volrates2(begn(k)+1:endn(k),2) = movstd(measure(:,2),252);
volrates3(begn(k)+1:endn(k),:) = movstd(measure3(begn(k)+1:endn(k),:),252);

% measure 1  log percent change
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(volrates)*100:25:max(volrates)*100];
%hE1 = 
hE=plot(sdate(begn(k)+1:endn(k)),measure1(:,1))
hold on
hO=plot(sdate(begn(k)+1:endn(k)),measure1(:,2)) %,'LineStyle', 'none');
hold on
hT=plot(sdate(begn(k)+1:endn(k)),measure1(:,3)) %,'LineStyle', 'none');
hold on
hB=plot(sdate(begn(k)+1:endn(k)),measure1(:,4)) %,'LineStyle', 'none');
hold on
hS=plot(sdate(begn(k)+1:endn(k)),measure1(:,5)) %,'LineStyle', 'none');
hold on
%
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold
h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%legend('EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%h=[hE hF hIOR hRRP hU hL];
%hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gcf, 'PaperPositionMode', 'auto');
if rates ==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates.fig')
elseif rates ==0
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.fig')
end

% just a row of sample stdev
% measure 2  standard deviation of log percent change
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(volrates)*100:25:max(volrates)*100];
%hE1 = 
hE=plot(sdate(begn(k)+1:endn(k)),measure2(:,1))
hold on
hO=plot(sdate(begn(k)+1:endn(k)),measure2(:,2)) %,'LineStyle', 'none');
hold on
hT=plot(sdate(begn(k)+1:endn(k)),measure2(:,3)) %,'LineStyle', 'none');
hold on
hB=plot(sdate(begn(k)+1:endn(k)),measure2(:,4)) %,'LineStyle', 'none');
hold on
hS=plot(sdate(begn(k)+1:endn(k)),measure2(:,5)) %,'LineStyle', 'none');
hold on
%
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold
h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%legend('EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%h=[hE hF hIOR hRRP hU hL];
%hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gcf, 'PaperPositionMode', 'auto');
if rates ==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates2.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates2.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates2.fig')
elseif rates ==0
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol.fig')
end


% measure 3  Moving standard deviation of log percent change
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(volrates)*100:25:max(volrates)*100];
%hE1 = 
hE=plot(sdate(begn(k)+1:endn(k)),measure3(:,1))
hold on
hO=plot(sdate(begn(k)+1:endn(k)),measure3(:,2)) %,'LineStyle', 'none');
hold on
hT=plot(sdate(begn(k)+1:endn(k)),measure3(:,3)) %,'LineStyle', 'none');
hold on
hB=plot(sdate(begn(k)+1:endn(k)),measure3(:,4)) %,'LineStyle', 'none');
hold on
hS=plot(sdate(begn(k)+1:endn(k)),measure3(:,5)) %,'LineStyle', 'none');
hold on
%
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold
h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%legend('EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%h=[hE hF hIOR hRRP hU hL];
%hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gcf, 'PaperPositionMode', 'auto');
if rates ==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates3.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates3.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangerates3.fig')
elseif rates ==0
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol3.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol3.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/logpctchangevol3.fig')
end

%OLD
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(volrates)*100:25:max(volrates)*100];
%hE1 = 
hE=plot(sdate(begn(k+1):endn(k)),volrates3(begn(k+1):endn(k),1)) %,'LineStyle', 'none');
hold on
hO=plot(sdate(begn(k+1):endn(k)),volrates3(begn(k+1):endn(k),2)) %,'LineStyle', 'none');
hold on
hT=plot(sdate(begn(k+1):endn(k)),volrates3(begn(k+1):endn(k),3)) %,'LineStyle', 'none');
hold on
hB=plot(sdate(begn(k+1):endn(k)),volrates3(begn(k+1):endn(k),4)) %,'LineStyle', 'none');
hold on
hS=plot(sdate(begn(k+1):endn(k)),volrates3(begn(k+1):endn(k),5)) %,'LineStyle', 'none');
hold on
%
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold
h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%legend('EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
%h=[hE hF hIOR hRRP hU hL];
%hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(gcf, 'PaperPositionMode', 'auto');
if rates ==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangerates.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangerates.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangerates.fig')
elseif rates == 0
    print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.fig')
end


% OLD but modified
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(volrates)*100:25:max(volrates)*100];
hE1 = plot(sdate(begn(k):endn(k)-1),measure1(:,1)) %,'LineStyle', 'none');
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
hE2 = plot(sdate(begn(k):endn(k)-1),measure3(:,1)) %,'LineStyle', 'none');
hold on
%hE3 = plot(sdate(begn(k):endn(k)-1),volrates(1:end-1,3)*100) %,'LineStyle', 'none');
%hold on
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

%h=[hE1 hE2  hE3  hF hIOR hRRP];
%hLegend = legend(h,'EFFR pct change','std level 252 day window','std log 252 day window','FOMC change','IOR change','ONRRP change','location', 'NorthWest' );
h=[hE1 hE2];
hLegend = legend(h,'EFFR log pct change','std log 252 day window','location', 'NorthWest' );
legend('boxoff')

%h=[hE hF hIOR hRRP hU hL];
%hLegend = legend(h,'EFFR pct change','FOMC','IOR','RRP','Lower target','Upper target','location', 'NorthWest' );
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
if rates ==1
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/volmeasureEFFR.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/volmeasureEFFR.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/volmeasureEFFR.fig')
elseif rates == 0
    print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/msdlogpctchangevol.fig')
end

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

% ==================== Models ==================
ones(size(rrbp(begn(k)-1:begn(k),1)));
nlag = 12;
nw = 1;
xx= [ones(size(drates,1)-1) drates(1:endind-1,:)  ];
% spreads
%{
hT10Y2Y=plot(sdate(1:endind),spread(1:endind,46),'g','LineWidth',1) % T10Y2Y
hold on 
hT10Y3M=plot(sdate(1:endind),spread(1:endind,47)-spread(1:endind,42),'m','LineWidth',1) % T10Y3M 47
hold on
hsof_ior=plot(sdate(1:endind),(spread(1:endind,43)-spread(1:endind,42))*100,'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
%hsof_ior=plot(sdate(~outliers),si(~outliers),'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
hold on 
he_ior=plot(sdate(1:endind),(spread(1:endind,1)-spread(1:endind,41))*100,'r','LineWidth',1) % EFFR-IOR
hold on 
honrpp_ior=plot(sdate(1:endind),(spread(1:endind,41)-spread(1:endind,41))*100,'g','LineWidth',1) % ONRPP-IOR
%}

IOR = spread(:,41);
ONRRP = spread(:,43);
ONRRP(isnan(ONRRP))=0;
endind = size(spread,1)
hT10Y2Y= spread(:,endind,50)*100; % hT10Y2Y
T10Y3M= spread(:,endind,51)*100;
SOFR_IOR= (spread(:,42)-spread(:,41))*100; % SOFR-IOR 
EFFR_IOR=(spread(:,1)-spread(:,41))*100; % EFFR-IOR
ONRRP_IOR= (ONRRP-spread(:,41))*100; % ONRPP-IOR

xx1=[rrbp(begn(k)+1:endn(k),:)];
xx2=[rrbp(begn(k)+1:endn(k),:) SOFR_IOR(begn(k)+1:endn(k)) EFFR_IOR(begn(k)+1:begn(k)) ONRRP_IOR(begn(k)+1:begn(k))]
xx3=[rrbp(begn(k)+1:endn(k),:) IOR(begn(k)+1:endn(k)) ONRRP(begn(k)-1:endn(k))]
%be=rrbp(begn(k):endn(k)-1,1)/rrbp(begn(k)+1:endn(k),1)
%
% Rates
[theta1,sec1,R2,R2adj,vcv,F1] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx1,nlag,nw);  % constant
%param1 = [theta1 sec1,R2,R2adj,F1]
vcv1

[theta2,sec2,R2,R2adj,vcv,F2] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx2,nlag,nw);  % constant
%param2 = [theta2 sec2,R2,R2adj,F2]
vcv

[theta3,sec3,R2,R2adj,vcv,F3] = olsgmm(rrbp(begn(k):endn(k)-1,:), xx2,nlag,nw)
%param3 = [theta3 sec3 R2,R2adj,vcv,F3]






% Bertolini, Bertola Garch model Day to Day MP and the volatility of the FF
% interest rates
%{
Empirical model of variance of the Federal Funds rate Variance
Bertelini 
Model variance of the fed funds rate \sigma^2_t)=E_t(r_t-\mu_t)^2 as
function of 
- \xi$ maintenance period effects
- h calendar effects
- N non trading days
- z =1-ratio of target rate r* to penalty rate, or IOR, or EFFR-IOR
\begin{equation*}
log(\sigma^2_t) - \Xi_{s_t} -\omega h_t-\zeta z_t - log(1-\gamma N_t)= 
\lambda(log(\sigma^2_{t-1}) - \xi_{s_{t-1}} -\omega h_{t-1}-\zeta z_{t-1} - log(1-\gamma N_{t-1})+\alpha |v_{t-1}| + \theta v_{t-1}
\end{equation*}



Me unless another factor can substitute for  maintenance period effects $\xi$ 
Empirical model of variance of the Federal Funds rate Variance
Bertelini 
\begin{equation*}
log(\sigma^2_t)  -\omega h_{t-1}-\zeta z_t = 
\lambda(log(\sigma^2_{t-1})  -\omega h_{t-1}-\zeta z_{t-1} +\alpha |v_{t-1}| + \theta v_{t-1}
\end{equation*}

Assume a t distribution for the innovations and obtain ML estimates of the parameters by numerical optimization

%}
%{
Vector graphics}
https://github.com/FSund/latex-examples/tree/master/vector-graphics


