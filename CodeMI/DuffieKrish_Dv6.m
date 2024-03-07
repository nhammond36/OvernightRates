% Duffie Krishnamurti diversity index 
% Our objective is to show how the current setting of U.S.-dollar money markets limits
% the passthrough effectiveness of the Federal Reserve%s monetary policy. We focus on
% frictions associated with imperfect competition, regulation, infrastructure, and other
% forms of institutional segmentation within money markets.
% Empirically, dispersion across money market interest rates is a primary indicator
% of the level of passthrough inefficiency. We present a new index of rate dispersion
% in U.S. short-term money markets, the weighted mean absolute deviation of the crosssectional 
% distribution of overnight-equivalent rates, after adjusting for premia associated
% with credit risk and term structure. 
%
% Loyd BoE . An OIS contract is
% an over-the-counter trade derivative in which two counterparties exchange fixed and floating
% interest rate payments. The floating interest rate on OIS contracts is the overnight interbank
% rate, a measure of the de facto monetary policy stance.
% IDEA literature, motivated by Stock and Watson (2012) and Mertens and Ravn (2013), combined 
% high-frequency identification techniques with structural vector autoregression methods to 
% estimate the macroeconomic effects of monetary policy shocks

% OIS data Bloomberg
% FWCM <GO> will give you what you want (Forward Curve Matrix). You can select a curve and then 
% get the forwards by Tenor and Start Date. Or use the BCurveStrip and BCurveFwd in Excel.

% load NYFed short rate data.
[spread,txts,raws]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv6.xlsx','A445:AS1715');
size(spread) %    1244          47
sdate = datenum(raws(:,1),'mm/dd/yyyy');
fig_n1=1
%{
NYFedOvernightRates data in columns
Effective Date
Rate Type
Rate (%)	
Volume (Billions of dollars)
Target Rate From (%) Lo
Target Rate To (%) Hi
1st Percentile (%)
25th Percentile (%)
75th Percentile (%)
99th Percentile (%)
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
%} 

% ================= NY Fed SOFR data =======================
[s,txts,raws] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/SOFRnyfed.xlsx','A2:Q654');
%{
https://www.newyorkfed.org/markets/reference-rates/sofr
Oct 6, 2022 - {'03/02/2020'}
s(:,1:4) 30-Day Average SOFR	90-Day Average SOFR	180-Day Average SOFR	SOFR Index	Revision Indicator (Y/N)	Footnote ID
txts(:,1:2) Effective Date	Rate Type

DATA
30-Day  90-Day  180-Day  Index

The Secured Overnight Financing Rate (SOFR) is a broad measure of the cost 
of borrowing cash overnight collateralized by Treasury securities. The SOFR
includes all trades in the Broad General Collateral Rate plus bilateral 
Treasury repurchase agreement (repo) transactions cleared through the 
Delivery-versus-Payment (DVP) service offered by the Fixed Income Clearing 
Corporation (FICC), which is filtered to remove a portion of transactions 
considered “specials”. Note that specials are repos for specific-issue 
collateral, which take place at cash-lending rates below those for general 
collateral repos because cash providers are willing to accept a lesser 
return on their cash in order to obtain a particular security.
The SOFR is calculated as a volume-weighted median of transaction-level 
tri-party repo data collected from the Bank of New York Mellon as well as 
GCF Repo transaction data and data on bilateral Treasury repo transactions 
cleared through FICC's DVP service, which are obtained from the U.S. 
Department of the Treasury’s Office of Financial Research (OFR). Each 
business day, the New York Fed publishes the SOFR on the New York Fed 
website at approximately 8:00 a.m. ET.
For more information on the SOFR’s publication schedule and methodology, 
see Additional Information about Reference Rates Administered by the New 
York Fed.
%}
size(s) %653     4
ss = flipud(s );
txtss = flipud(txts); % {'03/02/2020'} - 10/06/2022

% =================Daily rates, volumes ===============
begn = [1 571 1109];
endn = [570 1108 1271];
%}
%{ 
New breaks
1. 12/4/2017 - 8/01/2019  1 -   417
Normalcy,  mid cycle adjstment
2.  8/02/2019 - 05/04/2022  418-1108
Coping with covid

3. 05/05/2022 - 12/29/2022 1109 1271
Taming inflation

begn = [1 418 1109];
endn = [417 1108 1271];
1. 12/4/2017 - 8/01/2019  1 -   417
Normalcy,  mid cycle adjstment
2.  8/02/2019 - 05/04/2022  418-1108
Coping with covid

3. 05/05/2022 - 12/29/2022 1109 1271
Taming inflation
%}
endind= size(spread,1) 
begn = [1 572 1109 1];
endn = [571 1108 1271 endind];


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


% ============== volume weighted rates =========================
% EFFR-OBFR with target rates and disperson 25 and 75 percentile
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
n = input('Enter a number for chart rates: ');
n=2
switch n
   case 1
       k=1
        case 2
           k=2
           case 3
               k=3
end
vmeaneffr= mean(vdrates(begn(k):endn(k),1))*100
vsdeffr= std(vdrates(begn(k):endn(k),1))*100
   
meaneffr= mean(drates(begn(k):endn(k),1))*100
sdeffr= std(drates(begn(k):endn(k),1))*100
            
% All rates
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%{
hE = plot(sdate(begn(k):endn(k)),vdrates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hS = plot(sdate(begn(k):endn(k)),vdrates(begn(k):endn(k),2)*100) %,'LineStyle', 'none');
hold on
hO = plot(sdate(begn(k):endn(k)),vdrates(begn(k):endn(k),3)*100);
hold on
%}
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
%hS = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),5)*100) %,'LineStyle', 'none');
%hold on
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
yline(meaneffr,'--b','Mean') 
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

% =============== Duffie Krishnamurti diversion index D ================
%{
spread data
drates =spread(:,1:8:40);
vold =spread(:,2:8:40);
vdsum=sum(vold(:,1:5),2); %wrates1(:,2:2:10),2);                % Total volume
vdrates(:,1:5) = (drates(:,1:5).*vold(:,1:5))./vdsum(:);
target = spread(:,3:4); % NaN until 4/19/2019 	2.44	59	2.25	2.5
begintarget = 789-447+1;
quantileeffr=spread(:,5:8); 
%}
%{
We let yi,t(m) denote the rate at time t on instrument i, maturing in m days. We first
adjust the rate to remove term-structure effects, 
obtaining the associated "overnight-equivalent” rate as
yhat_(i,t) = yi,t(m) − (OISt(m) − OISt(1)), (4.1)
The dispersion index D at day t as the weighted mean absolute deviation of the cross-sectional adjusted rate
distribution on that day. That is,
D_t =1/ (sum_{i}^{}v_{i,t}) times 
(sum_{i}^{}v_{i,t} |yhat_{i,t} − y¯t|) (4.2)
where vi,t is the estimated outstanding amount of this instrument on day t, in dollars,
and y¯t is the volume-weighted mean rate, defined by
y¯t = [(sum_{i}^{}(v_{i,t}) times yhat_{i,t})]/(sum_{i}^{}v_{i,t})
P
i
%}

d=zeros(size(spread,1),5);
begn = [1 572 1109 1];
endn = [571 1108 1271 1271];
endind= size(spread,1) 
n=4  % full sample
switch n
   case 1  % normalcy
       k=1
   case 2 % covid
       k=2
   case 3 % taming inflation
        k=3
   case 4 % full sample
        k = 4
    case 5 % annual
        % k = 4  figure out
end
%{
vmeaneffr= mean(vdrates(begn(k):endn(k),1))*100
vsdeffr= std(vdrates(begn(k):endn(k),1))*100
meaneffr= mean(drates(begn(k):endn(k),1))*100
sdeffr= std(drates(begn(k):endn(k),1))*100
%}
% DO beginT, endT for cases 1:4 and annually
T = endn(k)- begn(k)+1
vtot = zeros(T,1);
d = zeros(T,1);
mrate = zeros(T,1);
meanr = zeros(T,1);
%
%{
T size(spread,1);
vtot = zeros(size(spread,1));
d = zeros(size(spread,1));
mrate = zeros(size(spread,1));
meanr = zeros(size(spread,1));
%}
%for t=1:T    
for t=begn(k):endn(k)
    for i=1:5 
    vtot(t)=  vtot(t)+ vold(t,i); % volume at t
    mrate(t) = mrate(t)+ vold(t,i)*drates(t,i); 
    end
    % for now, the on equiv rate is the rate in data
    meanr(t) =mrate(t)/vtot(t);
    for i=1:5   
     d(t) = d(t)+(1/vtot(t))*vold(t,i)*(abs(drates(t,i)- meanr(t)));
    end
end
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
%hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
%hold on
hD = plot(sdate(begn(k):endn(k)),d(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
%set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] ); % cyan
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
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
% Duffie spread spikes
% 
spikes=["12/29/2017","3/29/2018","5/31/2018","6/29/2018","12/6/2018","12/31/2018","1/2/2019","1/3/2019","1/31/2019","2/28/2019","3/29/2019","4/30/2019","7/1/2019","7/3/2019","7/5/2019","9/16/2019","9/17/2019","9/18/2019","9/25/2019","9/30/2019","10/15/2019","10/16/2019","10/31/2019","3/16/2020","3/17/2020"]

["6/15/2017 0:00
12/14/2017 0:00
iorb=["12/18/2017","12/21/2017","03/22/2018","06/14/2018","09/27/2018","012/20/2018","05/2/2019","08/1/2019","09/19/2019","10/31/2019","1/30/2020","3/4/2020","3/16/2020","9/19/2019","10/31/2019","1/30/2020","3/4/2020","3/16/2020","6/17/2021","3/17/2022","5/5/2022","6/16/2022","7/28/2022","9/22/2022","11/3/2022"]

%{
ONRRP Award
%}
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
% =============== Gara D ==============
%{
737685    5
the volatility of the fed funds rate, let ¯ρt denote the value-weighted
fed funds rate (average for day t). Let ρmaxt be the upper bound for the FOMC policy target
band for day t, and let ρmint be the lower bound of the band. Define the deviation from target
on day t, denoted Dt
%}
g  = zeros(T,1);
%g  = zeros(size(spread,1));
%for t=1:T
for t=begn(k):endn(k)
if  target(t,2)< drates(t,1) %upper target
g(t) = drates(t,1) - target(t,2); %upper target
elseif drates(t,1) < target(t,1)
g(t) = drates(t,1) - target(t,1); %lower target
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
hG = plot(sdate(begn(k):endn(k)),g(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hU,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
set(hL,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);  % blue
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

% =============== volatility ==============
% Percent change in EFFR first difference of logs
%{
volf = ((rates['FF']-rates['FF'].shift(1)) / rates['FF'].shift(1))
volf = ((ff-ff.shift(1))/ff.shift(1))*100
percent
%}
volf = zeros(size(rates,1),size(rates,2));
for k = 1:5
    for i=2:size(rates,1)
    volf(i,k) = log(rates(i,k))-log(rates(i-1,k))
    end
end

% running 5 day standard deviation
[y2,txt,raw] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/MPRsultsJ2.xlsx','A1:F525');
y2r =flip(y2)

% weekly mean and standard deviations
jj=1;
for k=1:size(y2r,1)/5
    %for j=1:5:size(y2r,1)/5
        y2wm(k,:) = mean(y2r(y2r(jj:jj+4,:)
        y2ws(k,:) = std(y2r(y2r(jj:jj+4,:)
        jj=jj+5
end
% k = 1 jj=1: 1,2,3,4,5
% k = 2 jj=6: 6,7,8,9.10
% k = 4 jj=11: 11,12,13,14,15
%
% monthly mean and standard deviations
jj=1;
for k=1:size(y2r,1)/20
    %for j=1:20:size(y2r,1)/20
        y2mm(k,:) = mean(y2r(y2r(jj:jj+4,:)
        y2ms(k,:) = std(y2r(y2r(jj:jj+4,:)
        jj=jj+5
end
% k = 1 jj=1: 1,2,3,4,5
% k = 2 jj=6: 6,7,8,9.10
% k = 4 jj=11: 11,12,13,14,15

