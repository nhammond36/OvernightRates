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


% ================ Daily rate and volume data ================
%FIX duplicate read statement line 1921
[spread,txts,raws]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv8.xlsx','A2:AZ1715');
size(spread) %    1244          47
sdate = datenum(raws(:,1),'mm/dd/yyyy');
rated=spread(:,1:8:33);
rrbp=rated*100;
vold=spread(:,2:8:34);
ior=spread(:,41)*100;
sofr=spread(:,42)*100;
rrpreward=spread(:,43)*100;
target = spread(:,3:4);
target(isnan(target))=0;
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
[rates,txt,raw]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_weekly.xlsx','A2:AR358'); % UPDATE to 12/27?/2022
size(rates) % 357    43   start 1   A2  2/28/2016 0:00
%                               2   A3  3/6/2016 0:00
%                         end 357 A247 12/25/2022  
wdate = datenum(raw(:,1),'mm/dd/yyyy');
size(rates(22:357,:)) %  336    43
%{
rates(:,1:8) = effr;  1 rate, 2 vol
rates(:,9:16) = obfr;
rates(:,17:24) = tgcr;
rates(:,35:32) = bgcr;
rates(:,33:40) = sofr;
rates(:,41) = IOR
rates(:,42) = ONRRPust
rates(:,43) = ONRPPmbs
%}

%{
% ---------------------- Add Reserves ---------------
DPSACBW027SBOG	Deposits, All Commercial Banks, Billions of U.S. Dollars, Weekly, Seasonally Adjusted
DATE	WRESBAL	TLAACBW027SBOG	DPSACBW027SBOG
https://fred.stlouisfed.org/series/WRESBAL Liabilities and Capital: Other Factors Draining Reserve Balances: Reserve Balances with Federal Reserve Banks: Week Average (
https://fred.stlouisfed.org/series/TLAACBW027SBOG Total Assets, All Commercial Banks (TLAACBW027SBOG)
https://fred.stlouisfed.org/graph/?id=DPSACBW027SBOG, Deposits, All Commercial Banks (DPSACBW027SBOG)
%}
[res,txtr,rawr] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/WRESBAL_BankAssetsv7.xlsx','A2254:G2610');
% 3/2/2016' 1 2254
% 7/27/2016  2275 336
% 12/28/2016  2297
% 12/27/2017 to 12/28/2022	3017.889  update from {'11/13/2022'}
% or 2350 1/11/2023	2830.144
size(res)  %262     6
%{
col 1 WRESBAL	weekly reserves
	Liabilities  and Capital: Other Factors Draining Reserve Balances: Reserve Balances with Federal Reserve Banks: Week Average (WRESBAL)
    billions $ NSaar
col 2 TLAACBW027SBOG commercial bank Total Assets
    Total Assets, All Commercial Banks (TLAACBW027SBOG)
    billions $ SAR
    Assets: Securities Held Outright: U.S. Treasury Securities: All: Wednesday Level (TREAST)
    millions $ not SA
col 3 DPSACBW027SBOG commercial bank deposits
    DPSACBW027SBOG Deposits, All Commercial Banks 
    billions $ Saar
col 4 Nan
col 5 TREAST
col 6 SOFR
reserven = reserves/deposits  col1/col3 Is it there?
%}
rr =rates(:,1:8:39);
rrbp=rr*100;
volw =rates(:,2:8:40);
reservesn= res(:,1)./res(:,3); % billions/billions = millions?
ior = rates(:,41);
onrrpust = rates(:,42);
onrrpmbs = rates(:,43);
%{
0.3169    2.2810    1.7701    0.0000 .1790
0.3199    2.2888    1.7786    0.0000 .1799
0.3189    2.2959    1.7788    0.0000 .1793
0.3089    2.2941    1.7804    0.0000 .1735
0.3018    2.2884    1.7763    0.0000 .1699
%}

% CHECK
rr(352:357,1:5)
volm(352:357,1:5)
rates(352:357,41:43)
rates(352:357,1:8:39)
rates(352:357,2:8:40)
%{
data 
3.9	3.836	3.888
3.9	3.812	3.865
3.9	3.819	3.878
3.9	4.309	4.349
3.9	4.308	4.354
file
 3.9000    3.8360    3.8880
    3.9000    3.8120    3.8650
    3.9000    3.8190    3.8780
    3.9000    4.3090    4.3490
    3.9000    4.3080    4.3540

%}
%{
Routine to zoom in to arrows of graph see
function pan = zoomin(ax,areaToMagnify,panPosition)
in stires.v6.m
function anxy = ax2annot(ax,xy)
%}

% ==================== Weekly levels rates ===================
%{
Scatter plot with scaling for values of dots
https://www.mathworks.com/matlabcentral/answers/268595-marker-size-based-on-value
%}

%{ Plot TS of rates and reserves

if nf ~= 0
begn = [2 22 45];
endn = [357 357 357];
begr = [2 22 45]; % 1 3/2/2016 2 3/9/2016 22 {'7/27/2016'} 45 {'1/4/2017'  }
endr = [357 357 357];
%size(rates(22:357,:)) %  336    43
switch nf   % Select sample size
   case 1 % 03/04/2016 - 12/29/2022
       k=1  
       name = "weeklyratesreservessample1";
       %   1  {'3/02/2016'}
       % 357   {'12/28/2022'}
   case 2  % 07/28/2016 - 12/29/2022 IOR starts
       k=2
       name = "weeklyratesreservessample2";
       % 22   {'7/27/2016'}
   case 3 % 01/02/2017
       k=3
       name = "weeklyratesreservessample3";
       % 45   {'1/4/2017'}
   otherwise
      disp('Unknown method')
end
% stats RATES
%Mean
resmn=zeros(3,3);
resm=zeros(3,3);
ratesmn=zeros(3,5);
ratesm=zeros(3,5);
volwmn=zeros(3,5);
volwm=zeros(3,5);
% for k = 1:3 ALL SAMPLES (unlikely)
resm(k,1)= mean(res(begr(k):endr(k),1))
resm(k,2)= mean(res(begr(k):endr(k),3))
resm(k,3)= mean(reservesn(begr(k):endr(k),1))
resmn(k,1)= median(res(begr(k):endr(k),1))
resmn(k,2)= median(res(begr(k):endr(k),3))
resmn(k,3)= median(reservesn(begr(k):endr(k),1))
ratesm(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
ratesmn(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
volwm(k,1:5)= mean(volw(begn(k):endn(k),1:5))
volwmn(k,1:5)= median(volw(begn(k):endn(k),1:5))
%end
% Std
ressd=zeros(3,3);
ratesd=zeros(3,5);
%for k = 1:3
ressd(k,1)= std(res(begr(k):endr(k),1))
ressd(k,2)= std(res(begr(k):endr(k),2))
ressd(k,3)= std(reservesn(begr(k):endr(k),1))
ratesd(k,1:5)= std(rrbp(begn(k):endn(k),1:5))
volwsd(k,1:5)= std(volw(begn(k):endn(k),1:5))
%end

elseif ne~=0
begn = [23  183 324 23 ];
endn = [181 323 358 358] ;
%{
1. 12/4/2017 - 8/01/2019  23 -   181
Normalcy,  mid cycle adjstment
7/28/2016 - 8/10/2019 23-181
2.  8/02/2019 - 05/04/2022  182 323
8/4/2019 0:00 - 4/24/2022 0:00
Coping with covid
3. 05/05/2022 - 12/29/2022 324-358
Taming inflation
5/1/2022 0:00
4. ALL 12/4/2017-12/29/2022
%}
switch ne   % Select sample size
    case 1
    k== 1 % Normalization
    case 2
    k==2 % Covid
    case 3
    k==3 % Inflation
    otherwise
      disp('Unknown method.')
    %case 4 % free, to be defined Full time series
end
% stats RATES CORRECT LATER FOR NE
%Median
resm=zeros(k,3);
ratesmn=zeros(k,5);
ratesmn=zeros(k,5);
ratesm=zeros(k,5);
volwm=zeros(k,5);
volwmn=zeros(k,5);
resmn(k,1)= mean(res(begr(k):endr(k),1))
resmn(k,2)= mean(res(begr(k):endr(k),3))
resmn(k,3)= mean(reservesn(begr(k):endr(k),1))
resm(k,1)= median(res(begr(k):endr(k),1))
resm(k,2)= median(res(begr(k):endr(k),3))
resm(k,3)= median(reservesn(begr(k):endr(k),1))
ratesmn(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
ratesm(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
volwmn(k,1:5)= mean(volw(begn(k):endn(k),1:5))
volwm(k,1:5)= median(volw(begn(k):endn(k),1:5))
% Std
ressd=zeros(k,3);
ratesd=zeros(k,5);
volwsd=zeros(k,5);
ressd(k,1)= std(res(begr(k):endr(k),1))
ressd(k,2)= std(res(begr(k):endr(k),3))
ressd(k,3)= std(reservesn(begn(k):endr(k),1))
ratesd(k,1:5)= std(rrbp(begn(k):endn(k),1))
volwsd(k,1:5)= std(volw(begn(k):endn(k),1:5))

% Make table 
statsres(1,:)=resmn(k,1:3);
statsres(2,:)=resm(k,1:3);
statsres(3,:)=ressd(k,1:3);

statsrates(1,:)=ratesmn(k,1:5);
statsrates(2,:)=ratesm(k,1:5);
statsrates(3,:)=ratesd(k,1:5);
statsvol(1,:)=volwmn(k,1:5);
statsvol(2,:)=volwm(k,1:5);
statsvol(3,:)=volwsd(k,1:5);


elseif  ny ~= 0  % DO for each year
    % RATES
    %2016 7/24/2016        2- 44 3/2/2016-12/25/2016
    %2016 7/24/2016 0:00  22- 44 7/24/2016-12/25/2016
    %2017 1/1/2017 0:00   45- 98 1/1/2017-12/31/201
    %2018 1/7/2018 0:00   99-149 1/7/2018-12/30/2018
    %2019 1/6/2019 0:00  150-201 1/6/2019-12/29/2019
    %2020 1/5/2020 0:00  202-253 1/5/2020-12/27/2020
    %2021 1/3/2021 0:00  254-305 1/3/2021-12/26/2021 
    %2022 1/2/2022 0:00  306-357 1/2/2022-12/25/2022
    %
    %RES

% 2016-2022, position 8 7/28/2016 - 12/29/2016
begn = [2  45 99 150 202 254 306 22];
endn = [44  98 149 201 253 305 357 44];
resm =zeros(7,3);
resmn =zeros(7,3);
ressd =zeros(7,3);
ratesm =zeros(7,5);
ratesmn =zeros(7,5);
ratesd =zeros(7,5);

volwm=zeros(7,5); 
volwmn=zeros(7,5); 
volwsd=zeros(7,5); 


% stats RATES
%Mean and Median
for k = 1:7
resm(k,1)= mean(res(begn(k):endn(k),1)) % WRESBAL 
resm(k,2)= mean(res(begn(k):endn(k),3)) % Comml deposits
resm(k,3)= mean(reservesn(begn(k):endn(k),1)) % Normalized reserves
resmn(k,1)= median(res(begn(k):endn(k),1))
resmn(k,2)= median(res(begn(k):endn(k),3))
resmn(k,3)= median(reservesn(begn(k):endn(k),1))
ratesm(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
ratesmn(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
volwm(k,1:5)= mean(volw(begn(k):endn(k),1:5));
volwmn(k,1:5)= median(volw(begn(k):endn(k),1:5));
end
% Std
for k = 1:7
ressd(k,1)= std(res(begn(k):endn(k),1));
ressd(k,2)= std(res(begn(k):endn(k),3));
ressd(k,3)= std(reservesn(begn(k):endn(k),1));
ratesd(k,1:5)= std(rrbp(begn(k):endn(k),1:5));
volwsd(k,1:5)= std(volw(begn(k):endn(k),1:5));
end

for k=1:7
ressd(k,3)= std(reservesn(begn(k):endn(k),1));
end
end

% Make table 
kk = 1
for k=1:7
statsresy(kk,1:3) =resm(k,:);
statsresy(kk+1,1:3) =resmn(k,:);
statsresy(kk+2,1:2) =ressd(k,1:2);
statsresy(kk+2,3) =ressd(k,3);
kk = kk+3
end

kk = 1
for k=1:7
statsresy(kk+2,3) =ressd(k,3);
kk=kk+3
end

kk = 1
for k=1:7
statsratesy(kk,1:5) =ratesmn(k,:);
statsratesy(kk+1,1:5) =ratesm(k,:);
statsratesy(kk+2,1:5) =ratesd(k,:)*1000;
kk=kk+3
end


kk = 1
for k=1:7
%for   j=1:3
statsvoly(kk,1:5) = volwmn(k,:);
statsvoly(kk+1,1:5) = volwm(k,:);
statsvoly(kk+2,1:5) =volwsd(k,:);
%end
kk=kk+3
end

%{
>> v
v = 4188.79020478639
>> round(v*100)/100
ans =4188.79
%}

%{
[filepath,name,ext] = fileparts(file)
S1 = filepath;
S2 = name;
S3 = ext;
ext = ".fig"
ext = ".eps"
ext = ".tex"

filepath = "C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/"
name = "weeklyratesreservessample1";

savefig('%s%s.fig', filepath, name)
print('%s%s.eps', filepath, name)
matlab2tikz('%s%s.tex', filepath, name)
 
savefig(C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtall_reserves.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtall_reserves.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumewgtall_reserves.tex');
%}


% stats RATES
%Mean
for k = 1:4
resm(k,1)= median(res(begn(k):endn(k),1))
ratesm(k,1:5)= median(ratevw1(begn(k):endn(k),1:2:9))
end

% Std
for k = 1:4
sdresv(k,2)= std(res(begn(k):endn(k),1))
sdratese(k,1:5)= std(ratevw1(begn(k):endn(k),1:2:9))
end


% PLOT WEEKLY SAMPLE
% RATES
begn = [2 22 45];
endn = [357 357 357];
switch nf
    case 1;
      k=1
    case 2;
      k=2
    case 3;
      k=3
end
    
    
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); 
hE=plot(wdate(begn(k):endn(k)),rates(begn(k):endn(k),1)*100,'LineWidth',1) % EFFR
hold on
hO=plot(wdate(begn(k):endn(k)),rates(begn(k):endn(k),3)*100,'LineWidth',1) % OBFR
hold on
hT=plot(wdate(begn(k):endn(k)),rates(begn(k):endn(k),5)*100,'LineWidth',1) % TGCR
hold on
hB=plot(wdate(begn(k):endn(k)),rates(begn(k):endn(k),7)*100,'LineWidth',1) % BGCR
hold on
hS=plot(wdate(begn(k):endn(k)),rates(begn(k):endn(k),9)*100,'LineWidth',1) % SOHR
hold on
hR=plot(wdate(begn(k):endn(k)),reservesn(begn(k):endn(k),1)*1000,'LineWidth',1) % TOTRESN  billions xx.00
hold on
%{ 
aggregate reserves relative to commercial banks' assets
 aggregate reserves normalized by banks' total
 assets to control for the growth of the banking industry
 billions/billions
    0.1790
    0.1799
    0.1793
    0.1735
    0.1699
3017.889 wresbal 12/29/2022

%}
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);  % black
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] ); % red
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] ); % blue 
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] ); % green 
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % deep yellow  [1 0 1] magenta
set(hR,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);   % cyan
h=[hE hO hT hB hS hR]; 
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','Reserves (normalized)','Location', 'northwest') 
legend('boxoff')
hXLabel=xlabel('weekly');
hYLabel=ylabel('basis points/$millions');
%hTitle=title({'US volume weighted overnight rates and reserves'});
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
%set(hTitle,'FontName','AvantGarde','Fontsize',10);

savefig('%s%s.fig', filepath, name)
print('%s%s.eps', filepath, name)
matlab2tikz('%s%s.tex', filepath, name)
%Error using savefig (line 43)
%H must be an array of handles to valid figures.
%{
if k == 1
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/weeklyreservessample1.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/weeklyratesreservessample1.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\weeklyratesreservessample1.tex');

elseif k==2
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/weeklyratesreservessample2.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/weeklyratesreservessample2.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality2\weeklyratesreservessample2.tex');
elseif k==3
    savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtpi_reserves.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtpi_reserves.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumewgtpi_reserves.tex');
else
     savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtall_reserves.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumewgtall_reserves.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumewgtall_reserves.tex');
end
%}

%Transactions
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); 
yyaxis right
hE=plot(wdate(begn(k):endn(k)),volw(begn(k):endn(k),1)*100,'LineWidth',1) % EFFR
hold on
hO=plot(wdate(begn(k):endn(k)),volw(begn(k):endn(k),2)*100,'LineWidth',1) % OBFR
hold on
hT=plot(wdate(begn(k):endn(k)),volw(begn(k):endn(k),3)*100,'LineWidth',1) % TGCR
hold on
hB=plot(wdate(begn(k):endn(k)),volw(begn(k):endn(k),4)*100,'LineWidth',1) % BGCR
hold on
hS=plot(wdate(begn(k):endn(k)),volw(begn(k):endn(k),5)*100,'LineWidth',1) % SOHR
hold on
hYLabel=ylabel('$billions')
yyaxis left
hR=plot(wdate(begn(k):endn(k)),reservesn(begn(k):endn(k))*1000,'LineWidth',1) % TOTRESN  billion/billwion = millions xxx.00 millions
hold on
hYLabel=ylabel('$millions');
% hR=plot(wdate(begn(k):endn(k)),res(begn(k):endn(k),1)*.01,'LineWidth',1) % TOTRESN  billions xx.00
%{ 
aggregate reserves relative to commercial banks' assets
 aggregate reserves normalized by banks' total
 assets to control for the growth of the banking industry
 billions/billions
    0.1790
    0.1799
    0.1793
    0.1735
    0.1699
3017.889 wresbal 12/29/2022
%}
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold [1 0 1] magenta  
set(hR,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  
h=[hE hO hT hB hS hR]; 
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','Reserves (normalized)','Location', 'northwest') 
legend('boxoff')
hXLabel=xlabel('weekly');
%hYLabel=ylabel('$billions, $millions');
%hTitle=title({'US volume weighted overnight rates and reserves'});
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
%set(hTitle,'FontName','AvantGarde','Fontsize',10);

%%%


fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); 
hE=plot(wdate(begn(k):endn(k)),ratevw1(begn(k):endn(k),2)*100,'LineWidth',1) % EFFR
hold on
hO=plot(wdate(begn(k):endn(k)),ratevw1(begn(k):endn(k),4)*100,'LineWidth',1) % OBFR
hold on
hT=plot(wdate(begn(k):endn(k)),ratevw1(begn(k):endn(k),6)*100,'LineWidth',1) % TGCR
hold on
hB=plot(wdate(begn(k):endn(k)),ratevw1(begn(k):endn(k),8)*100,'LineWidth',1) % BGCR
hold on
hS=plot(wdate(begn(k):endn(k)),ratevw1(begn(k):endn(k),10)*100,'LineWidth',1) % SOHR
hold on
hR=plot(wdate(begn(k):endn(k)),res(begn(k):endn(k),1)*.01,'LineWidth',1) % TOTRESN  billions xx.00
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
set(hR,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  
h=[hE hO hT hB hS hR]; 
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','reserves','Location', 'northwest') 
legend('boxoff')
hXLabel=xlabel('weekly');
hYLabel=ylabel('$billions xxx.xx');
%hTitle=title({'US volume weighted overnight rates and reserves'});
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
%set(hTitle,'FontName','AvantGarde','Fontsize',10);
if k == 1
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/weeklyreservessample1.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/weeklyvolumereservessample1.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\weeklyvolumereservessample1.tex');
elseif k==2
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/weeklyvolumereservessample.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/weeklyvolumereservessample.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality2\weeklyvolumereservessample.tex');
elseif k==3
    savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumepi_reserves.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumepi_reserves.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumepi_reserves.tex');
else
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumeall_reserves.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumeall_reserves.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumeall_reserves.tex');  
end

% ================ Scatter/demand plots =====================
%plot(mdate(1:endind-1), volres1(1:endind-1,1),'LineWidth',1) % reserves_n
%hold on  % 
%{
plot(reservesn(1:endind-1,1), vol1(1:endind-1,1)*.01,'LineWidth',1) % EFFR
hold on ratevw1
plot(reservesn(1:endind-1,1), vol1(1:endind-1,2),'LineWidth',1) % OBFR
hold on
plot(reservesn(1:endind-1,1), vol1(1:endind-1,3),'LineWidth',1) % TGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,4),'LineWidth',1) % BGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,5) ,'LineWidth',1) % SOHR
hold on
%plot(mdate(1:endind-1), volres1(1:endind-1,1),'LineWidth',1) % reserves_n
%hold on  % 
%datetick('x', 'mm/dd/yyyy','keepticks')
%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
%axis([datenum(2016,03,03)  datenum(2022,11,09) miny maxy])
%axis([datenum(1963,01,01)  datenum(2022,01,01) NBRy(1) NBRy(2)])
xtickangle(45)
legend('EFFR','OBFR','TGCR','BGCR','SOHR')
title({'Volatility (percent change) of US overnight rates and level of reserves'});
ax.FontSize = 8
%}

%{
scatter(x,y,sz) specifies the circle sizes. To use the same size for all the circles, specify sz as a scalar. To plot each circle with a different size, specify sz as a vector or a matrix.

example
scatter(x,y,sz,c) specifies the circle colors. You can specify one color for all the circles, or you can vary the color. For example, you can plot all red circles by specifying c as "red".

example
scatter(___,"filled") fills in the circles. Use the "filled" option with any of the input argument combinations in the previous syntaxes.

example
scatter(___,mkr) specifies the marker type.

sz = 25;
c = linspace(1,10,length(x));
scatter(x,y,sz,c,'filled')

gscatter(x,y,g) creates a scatter plot of x and y, grouped by g. The inputs x and y are vectors of the same size.

example
gscatter(x,y,g,clr,sym,siz) specifies the marker color clr, symbol sym, and size siz for each group.

gscatter(x,y,g,clr,sym,siz,doleg) controls whether a legend is displayed on the graph. gscatter creates a legend by default.

example
gscatter(x,y,g,clr,sym,siz,doleg,xnam,ynam) specifies the names to use for the x-axis and y-axis labels. If you do not provide xnam and ynam, and the x and y inputs are variables with names, then gscatter labels the axes with the variable names.

example
gscatter(ax,___) uses the plot axes specified by the axes object ax. Specify ax as the first input argument followed by any of the input argument combinations in the previous syntaxes.

example
h = gscatter(___) returns graphics handles corresponding to the groups in g.

You can pass in [] for clr, sym, and siz to use their default values.
%}


% --------- scatter plots weekly rates, reserves
switch nf
    case 1
        %{
        m=['.','v','<','>','o'];
        c=['b','c','g','m','r']'
        for i=1:size(rr,2)
        scatter(reservesnn(1:endind), rr(1:endind,i), 'MarkerFaceColor', c(i,:),'Marker',m(i))
        end
        % ,mkr
        %}
    hE=scatter(reservesn(1:endind), rr(1:endind,1),sz,'k','filled') % EFFR
    hold on
    hO=scatter(reservesn(1:endind), rr(1:endind,2),sz,'c','filled') % OBFR
    hold on
    hT=scatter(reservesn(1:endind), rr(1:endind,3),sz,'g','filled') % TGCR
    hold on
    hB=scatter(reservesn(1:endind),rr(1:endind,4),sz,'m','filled') % BGCR
    hold on
    hS=scatter(reservesn(1:endind),rr(1:endind,5),sz,'b','filled') % SOHR
    hold on
        %set(hE,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
        %set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
        %set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
        %set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
        %set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
        %set(hRn,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  
        h=[hE hO hT hB hS]; 
        hLegend=legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR','location','northwest')
        %,'Orientation','horizontal')
        legend('boxoff')  
    case 2
        hE=scatter(reservesn(1:endind), rr(1:endind,1),sz,'k','filled') % EFFR
        hold on
        hO=scatter(reservesn(1:endind),rr(1:endind,2),sz,'b','filled') % SOHR
        hold on
        set(hE,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
        set(hO,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
        set(hRn,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);         
        h=[hE hS]; 
        hLegend = legend(h,'EFFR','OBFR','Location', 'northwest')' %,'Orientation','horizontal') ,
        legend('boxoff')
         case 3
        hO=scatter(reservesn(1:endind), rr(1:endind,5),sz,'c','filled') % OBFR
        hold on
        hT=scatter(reservesn(1:endind), rr(1:endind,3),sz,'g','filled') % TGCR
        hold on
        hB=scatter(reservesn(1:endind),rr(1:endind,4),sz,'m','filled') % BGCR
        hold on
        set(hS,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
        set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
        set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
        %set(hRn,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  
        h=[hS hT hB]; 
        hLegend = legend(h,'SOFR','TGCR','BGCR','Location', 'northwest') %,'Orientation','horizontal') ,
        legend('boxoff')
    otherwise
        disp('other value')
end
hTitle=title({'US overnight rates and reserves/bank deposits'});
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6); %,'nortwest','Orientation','horizontal','boxoff');
% set([legend, gca] ,'FontSize', 6);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyrates_reservesn_scatter.fig')

%matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesES_reservesn_scatterv4.tex');
%matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesES_reservesn_scatterv4.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratesOTB_reservesn_scatterv5.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyrates_reservesn_scatterv5.tex');
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratesES_reservesn_scatterv5.tex');

 % ----------- Demand: Scatter plots, weekly rates and volumes 
 reservesnn=reservesn*10000;
 nf=2; % Choose graph
x=reservesn;
sz = 15;
c = linspace(1,10,length(x));
nf=3
fig_n1= fig_n1+1;
miny =  min(min(rr(:,:))); 
maxy = max(max(rr(:,:)));
endind = size(mdate,1)-1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'' );']);
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%''FontName'',''Times-Roman'',''FontSize'',10;']);
hXLabel=xlabel({'reserves ($ billion)'});
hYLabel=ylabel({'volumes ($ billions)'});
hTitle=title({'US overnight rate volumes and reserves/bank deposits'});
xtickangle(45)
switch n
    case 1
        %{
        m=['.','v','<','>','o'];
        c=['b','c','g','m','r']'
        for i=1:size(rr,2)
        scatter(reservesnn(1:endind), rr(1:endind,i), 'MarkerFaceColor', c(i,:),'Marker',m(i))
        end
        % ,mkr
        %}
    hE=scatter(reservesn(1:endind), volm(1:endind,1),sz,'k','filled') % EFFR
    hold on
    hO=scatter(reservesn(1:endind), volm(1:endind,2),sz,'c','filled') % OBFR
    hold on
    hT=scatter(reservesn(1:endind), volm(1:endind,3),sz,'g','filled') % TGCR
    hold on
    hB=scatter(reservesn(1:endind),volm(1:endind,4),sz,'m','filled') % BGCR
    hold on
    hS=scatter(reservesn(1:endind),volm(1:endind,5),sz,'b','filled') % SOHR
    hold on
        %set(hE,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
        %set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
        %set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
        %set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
        %set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
        h=[hE hO hT hB hS]; 
        hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOHR', 'location','northwest')
        legend('boxoff')
    case 2
        hE=scatter(reservesn(1:endind), volm(1:endind,1),sz,'k','filled') % EFFR
        hold on
        hO=scatter(reservesn(1:endind),volm(1:endind,2),sz,'b','filled') % SOHR
        hold on
        set(hE,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
        set(hO,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
        h=[hE hO]; 
        hLegend = legend(h,'EFFR','SOHR','Location', 'northwest') 
        legend('boxoff')
        set(hRn,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);         
    %SAVE FILES
    case 3
        hS=scatter(reservesn(1:endind), volm(1:endind,5),sz,'c','filled') % OBFR
        hold on
        hT=scatter(reservesn(1:endind), volm(1:endind,3),sz,'g','filled') % TGCR
        hold on
        hB=scatter(reservesn(1:endind),volm(1:endind,4),sz,'m','filled') % BGCR
        hold on
        %{
        set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
        set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
        set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  
        set(hRn,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 1]);  
        %}
        h=[hS hT hB]; 
        hLegend = legend(h,'SOFR','TGCR','BGCR','Location', 'northeast')
        %,'Orientation','horizontal')
        legend('boxoff')
    otherwise
        disp('other value')
end
%hTitle=title({'US overnight rate volumes and reserves/bank deposits'});
% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
% set([legend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8)
set(hTitle,'FontName','AvantGarde','Fontsize',10);
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumes_reservesn_scatterv.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumes_reservesn_scatterv.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumes_reservesn_scatter.tex');

savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesEO_reservesn_scatterv.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesEO_reservesn_scatterv.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesES_reservesn_scatter.tex');

savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesSTB_reservesn_scatterv.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/ONweeklyratevolumesSTB_reservesn_scatter.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\ONweeklyratevolumesSTB_reservesn_scatter.tex');


% ------------ Time series of Weekly rates and SOMA holdings

% DO I need to compare reserves and normalized reserves?
% Fix variables labels
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%, ''FontName'',''Times-Roman'',''FontSize'',10;']);
%Times-Roman
yyaxis right
hRn=plot(wdate(1:endind), reservesn(1:endind),'-r','LineWidth',1) % reserves_n
ax=gca;
ax.YAxis(2).Color = [0 1 1];
ylabel({'reserves/deposits','$ billion'}) 
hold on  
yyaxis left
ax.YAxis(1).Color = [0 0 1];
%ylabel({'rates','percent'}) 
hold on  % 
yyaxis left
hR=plot(wdate(1:endind), res(1:endind,5),'b','LineWidth',1) % reserves_n
%ylabel('SOMA UST holdings $ millions') 
hold on  %
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
hLegend=legend('Fed Reserve UST holdings','Reserves/deposits') 

fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]), ''FontName'',''Times-Roman'',''FontSize'',10;']);
ax=gca;
%yyaxis right
plot(wdate(1:endind), reservesnn(1:endind),'-r','LineWidth',1) % reserves_n
ylabel('reserves/deposits') 
hold on  % 
%yyaxis leftt
%plot(mdate(1:endind), res(1:endind,5),'b','LineWidth',1) % reserves_n
%ylabel('SOMA UST holdings $ millions') 
hold on  %
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
legend('Reserves/deposits','Fed Reserve UST holdings') ,

fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%, ''FontName'',''Times-Roman'',''FontSize'',10;']);
%Times-Roman
ax=gca;
ax.FontSize = 6
%yyaxis left
%plot(mdate(1:endind), reservesnn(1:endind),'-r','LineWidth',1) % reserves_n
%label('reserves/deposits') 
%hold on  % 
%yyaxis right
plot(wdate(1:endind), res(1:endind,5),'b','LineWidth',1) % reserves_n
ylabel('SOMA UST holdings $ millions') 
hold on  %
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
%legend('Reserves/deposits','Fed Reserve UST holdings') ,

% ================== Daily rates and volumes =================
%{
%Use xAnnotation and yAnnotation as x and y coordinates for your annotation.
% String: Find date for point z = x(y==6.585); 
%}
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


% ================ Daily rate/volumes levels =============================

% -----------epochs, subsamples for Fed tolerance of volatility -----------
%{
 Break in TS for epochs, subsamples for Fed tolerance of volatility
break 1 spread(570:571,1) 1.1000 0.2500 spread(1:570,:) 1:570
break 2 spread(571:1137,:)  .25 - .83                   571:1236
break 3 spread(1137:1271,:)) 1.58 - ?                   1237:1271
https://www.forbes.com/advisor/investing/fed-funds-rate-history/
%}\%{
break1 = 1:570;
datetime(sdate(570), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
12/04/2017 03/13/2020 (570) OR ??  03/02/2020 (562)

spread(563,1)  1.0900   
sdate(563) 737854  03/04/2020
datetime(sdate(563), 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy

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
4. ALL 12/4/2017-12/29/2022

begn = [1 418 1109]; %excel [6 90 234] (-5 for weekly)  what is the
difference??
endn = [417 1108 1271]; %excel [89 233 267]

begn = [1 572 1109 1];
endn = [571 1108 1271 1289]; %1289
endind= size(spread,1) 
%}

% All unsecured benchmarks and repo bencymarkes are Daily volume weighted median rates
%size(ratevw)  %1271     8  full daily series sdate
% --------- the data are value weighted median daily rates -----------
% https://blog.quantinsti.com/vwap-strategy/
drates =spread(:,1:8:33);
vold =spread(:,2:8:34);
vdsum=sum(vold(:,1:5),2); %wrates1(:,2:2:10),2);                % Total volume

target = spread(:,3:4); % NaN until 4/19/2019 obs 789	2.44	59	2.25	2.5
begintarget = 789-447+1;
quantileeffr=spread(:,5:8); 
quantileobfr=spread(:,13:16); % NaN until 4/19/2019 
quantiletgcr=spread(:,21:24);
quantilebgcr=spread(:,28:32);
quantilesofr=spread(:,37:40); 
% spreads
sohr_ior = spread(1:size(spread,1),43)-spread(1:size(spread,1),42)*100;
effr_ior = spread(1:size(spread,1),1)-spread(1:size(spread,1),42)*100;
size(effr_ior) % 1270   


% -------------- FFR within targets, dispersion plots -------------------
% target, and percentiles
% EFFR-OBFR with target rates and disperson 25 and 75 percentile

%{}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ne = input('Enter a number for chart rates: ');
ne=2
switch n
   case 1
       k=1
        case 2
           k=2
           case 3
               k=3
end
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
%}
            
% -------------- subplots for EFFR target, and percentiles ----------------
%For Sample
%EDIT this section
target = spread(:,3:4); % NaN until 4/19/2019 obs 789	2.44	59	2.25	2.5
begintarget = 789-447+1;
quantileeffr=spread(:,5:8); 
%quantileobfr=spread(:,13:16); % NaN until 4/19/2019 
%quantiletgcr=spread(:,21:24);
%quantilebgcr=spread(:,28:32);
quantilesofr=spread(:,37:40);
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
a1 = subplot( 1, 2, 1 );
hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
%yline(meaneffr,'--b','Mean') 
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
%yline(meaneffr,'--b','Median') 
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
hE = semilogy(sdate(1:endind),spread(1:endind,1)*100) %,'LineStyle', 'none');
hold on
hS = semilogy(sdate(1:endind),spread(1:endind,33)*100) %,'LineStyle', 'none');
hold on
hO = semilogy(sdate(1:endind),spread(1:endind,9)*100);
hold on
hT = semilogy(sdate(1:endind),spread(1:endind,17)*100);
hold on
hB = semilogy(sdate(1:endind),spread(1:endind,25)*100);
hold on
%}
hE = plot(sdate(1:endind),drates(1:endind,1)*100) %,'LineStyle', 'none');
hold on
hS = plot(sdate(1:endind),drates(1:endind,5)*100) %,'LineStyle', 'none');
hold on
hO = plot(sdate(1:endind),drates(1:endind,2)*100);
hold on
hT = plot(sdate(1:endind),drates(1:endind,3)*100);
hold on
hB = plot(sdate(1:endind),drates(1:endind,4)*100);
hold on
            

% ----------- Time series weighted median rates -----------------
%  Choose for all ne, nf, ny to disaggregate 
% Later build into code to display by
% - A;; securities EFFR OBFR TGCR BGCR SOFR
% - EO unsecured benchmarket references
% - repo STB benchmarket references
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
%begn = [1 572 1109 1];
%endn = [571 1108 1271 1289];
switch nf   % Select sample size
   case 1 % 03/04/2016 - 12/30/2022  4
       k=1  
   case 2  % 07/28/2016 - 12/29/2022 IOR starts 106
       k=2
   case 3 % 01/02/2017 213
       k=3
end
% At end after TS, spreads, dispersion, targets end
% 
% stats DAILY RATES  SAMPLE
% Mean
ratedm=zeros(k,5);
voldm=zeros(k,5);
ratedm(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
voldm(k,1:5)= mean(vold(begn(k):endn(k),1:5))
% Median
ratedmn=zeros(k,5);
voldmn=zeros(k,5);
ratedmn(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
voldmn(k,1:5)= median(vold(begn(k):endn(k),1:5))

% Stdev
ratedsd=zeros(k,5);
voldsd=zeros(k,5);
ratedsd(k,1:5)= std(rrbp(begn(k):endn(k),1))
volddsd(k,1:5)= std(vold(begn(k):endn(k),1:5))

% Make table 
statsrates(1,:)=ratedmn(k,1:5);
statsrates(2,:)=ratedm(k,1:5);
statsrates(3,:)=ratedsd(k,1:5);
%
statsvold(1,:)=voldmn(k,1:5);
statsvold(2,:)=voldm(k,1:5);
statsvold(3,:)=voldsd(k,1:5);
end

if ny ~= 0  % DO for each year
begn = [4   213 464 713  964 1215 1466]; %106,212 short 2016 start 7/28
endn = [212 463 712 963 1214 1465 1714];
% To capture all of 2016 start begn(1) endn(2)
% k=1 03/06/2016 - 07/27/2016
% k=2 07/28/2016 - 12/30/2016


% stats RATES and VOLUMES
% Rates and volumes time series
% Mean
ratedmn=zeros(8,5);
voldm=zeros(8,5);
% Median
ratedmn=zeros(8,5);
voldmn=zeros(8,5);

% Stdev
ratedsd=zeros(8,5);
voldsd=zeros(8,5);

%{
ratesmn(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
ratesm(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
volwmn(k,1:5)= mean(volw(begn(k):endn(k),1:5));
volwm(k,1:5)= median(volw(begn(k):endn(k),1:5));
%}

%Mean
for k=1:7
ratedmn(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
voldmn(k,1:5)= mean(vold(begn(k):endn(k),1:5))
%Median
ratedm(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
voldm(k,1:5)= median(vold(begn(k):endn(k),1:5))
% Std
ratedsd(k,1:5)= std(rrbp(begn(k):endn(k),1))
voldsd(k,1:5)= std(vold(begn(k):endn(k),1:5))
end
%{
for print quality
voldm(1,1:5)= median(vold(begn(1):endn(1),1:5))
voldm(2,1:5)= median(vold(begn(2):endn(2),1:5))
voldm(3,1:5)= median(vold(begn(3):endn(3),1:5))
voldm(4,1:5)= median(vold(begn(4):endn(4),1:5))
voldm(5,1:5)= median(vold(begn(5):endn(5),1:5))
voldm(6,1:5)= median(vold(begn(6):endn(6),1:5))
voldm(7,1:5)= median(vold(begn(7):endn(7),1:5))
voldm(8,1:5)= median(vold(106:212,1:5))
%volm2019= median(vold(begn(2):endn(2),1:5));
%}

%for k = 2:8 % start 7/28/2016 see note above
kk = 1
for k=1:8
statsratedy(kk,1:5) =ratedmn(k,:);
statsratedy(kk+1,1:5) =ratedm(k,:);
statsratedy(kk+2,1:5) =ratedsd(k,:)*1000;
kk=kk+3
end

%{
kk=1 
kk=123
k=1 2016
statmean(1,
statmedian(2,
statstdev(3,)
kk=123

kk=4 = kk+3
k=2 2017
stat(4,
statmedian(5,
statstdev(6,)
kk=4 5 6 

k=3 2018
kk 7 8 9

k=4 2019
kk 10 11 12

k=5 2020
kk 13 14 15

k=6 2021
kk 16 17 18

k=7 2022
kk 19 20 21
%}


kk = 1
for k=1:7
statsvoldy(kk,1:5) = voldmn(k,:);
statsvoldy(kk+1,1:5) = voldm(k,:);
statsvoldy(kk+2,1:5) =voldsd(k,:);
kk=kk+3
end

%{
>> v
v = 4188.79020478639
>> round(v*100)/100
ans =4188.79
%}


% Make table 
statsquintile=zeros(size(spread,1),20);
statsrated(1,:)=ratedmn(k,1:5);
statsrated(2,:)=ratedm(k,1:5);
statsrated(3,:)=ratedsd(k,1:5);
statsvold(1,:)=voldmn(k,1:5);
statsvold(2,:)=voldm(k,1:5);
statsvold(3,:)=voldsd(k,1:5);



% Sort quintiles by year
statsquintile(:,1:4) = spread(:,5:8)*100;   %EFFR
statsquintile(:,5:8) = spread(:,13:16)*100; %OBFR
statsquintile(:,9:12) = spread(:,21:24)*100; %TGFR
statsquintile(:,13:16) = spread(:,29:32)*100; %BGFR
statsquintile(:,17:20) = spread(:,37:40)*100; %SOFR

%%%
meanrated=zeros(7,5);
medianrated=zeros(7,5);  
sdrated=zeros(7,5); 
%covrd = zeros(7,7,5)

meanvold=zeros(7,5); 
medianvold=zeros(7,5); 
meanvold=zeros(7,5); 
sdvold=zeros(7,5); 


% Samples put back where it belongs nf ne 0
%begn = [23 46 99 151 203 255 307];
%endn = [357 357 357 357 357 357 357];
ratesmn =zeros(7,5);
ratesm =zeros(7,5);
ratesd =zeros(7,5);

voldmn=zeros(7,5); 
voldm=zeros(7,5); 
voldsd=zeros(7,5); 
% stats RATES
%Mean
for k = 1:7 % start 7/28/2016 see note above
ratesm(k,1:5)= mean(rrbp(begn(k):endn(k),1:5))
voldm(k,1:5)= mean(vold(begn(k):endn(k),1:5));
end
%Median
for k = 1:7
ratesmn(k,1:5)= median(rrbp(begn(k):endn(k),1:5))
voldmn(k,1:5)= median(vold(begn(k):endn(k),1:5));
end
% Std
for k = 1:7
ratesd(k,1:5)= std(rrbp(begn(k):endn(k),1:5));
voldsd(k,1:5)= std(vold(begn(k):endn(k),1:5));
end

kk = 1
for k=1:7
statsratesy(kk,1:5) =ratesmn(k,:);
statsratesy(kk+1,1:5) =ratesm(k,:);
statsratesy(kk+2,1:5) =ratesd(k,:)*1000;
kk=kk+3
end

kk = 1
for k=1:7
%for   j=1:3
statsvoly(kk,1:5) = volwmn(k,:);
statsvoly(kk+1,1:5) = volwm(k,:);
statsvoly(kk+2,1:5) =volwsd(k,:);
%end
kk=kk+3
end

%{
>> v
v = 4188.79020478639
>> round(v*100)/100
ans =4188.79
%}

%covrd = zeros(6,6,5)
%switch ny
end  % if ny ~= 1
% ------------- Stacked barchart rates volumes REDO for nf =1
%{
The bar documentation states "If y is a matrix, then bar groups the bars according to the rows in y", so you need to translate your matrix:
bar(P.','stacked')
endind= size(spread,1) 
bar(vold','stacked')
%}

% Annual median weighted rate and volume changes data for barcharts
for k=2:7
delratemn(k,:) = ratesmn(k,:)-ratesmn(k-1,:)    
delratem(k,:) = ratesm(k,:)-ratesm(k-1,:)
delratesd(k,:) = ratesd(k,:)-ratesd(k-1,:)
delvolmn(k,:) = voldmn(k,:)-voldmn(k-1,:)
delvolm(k,:) = voldm(k,:)-voldm(k-1,:)
delvolsd(k,:) = voldsd(k,:)-voldsd(k-1,:)
end

%{
Check delratemed
[75	85	85	87	75;
46	51	52	50	46;
-228	-228	-230	-231	-230;
-2	-4	-3	-2	1;
151	145	145	145	144]
%}

% Annual median rate changes barchart
year ={'2017';'2018';'2019';'2020';'2021';'2022'}
%year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
bar(delratemn(2:7,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 6);
xticklabels(year);
hYLabel=ylabel('basis points');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarrates.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarrates.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\stackedbarrates.tex')

%Annual median volume changes barchart
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
bar(delvolmn(2:7,:),'stacked')
legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Northwest' )
xticklabels(year);
hYLabel=ylabel('$ billion');
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Northwest')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 6);
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarvol.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarvol.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\stackedbarvol.tex')

% Annual median rate changes barchart
year ={'2017';'2018';'2019';'2020';'2021';'2022'}
%year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
bar(delratesd(2:7,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 6);
xticklabels(year);
hYLabel=ylabel('basis points');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarratesd.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarratesd.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\stackedbarratesd.tex')

%Annual stdev rate changes barchart
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
bar(delvolsd(2:7,:),'stacked')
legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Northwest' )
xticklabels(year);
hYLabel=ylabel('$ billion');
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Northwest')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 6);
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarvolsd.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/stackedbarvolsd.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\stackedbarvolsd.tex')

%% box plots for median and stdev annual
year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
Rate={'EFFR', 'OBFR', 'TGCR', 'BGCR','SOFR'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
% daily rates
subplot(2,1,1)
boxplot(ratesmn(1:7,:))
%boxplot(spread(4:1714,1:8:33)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('basis points');
% daily volumes
subplot(2,1,2)
boxplot(voldmn(1:7,:))
%boxplot(spread(4:1714,2:8:34)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('$ billions');
%bar(delratemed(2:6,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
%set([hLegend, gca] ,'FontSize', 8);

savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratevolmnboxplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratevolmnboxplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\dailyratevolmnboxplot.tex')

%% box plots for median and stdev annual
year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
Rate={'EFFR', 'OBFR', 'TGCR', 'BGCR','SOFR'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
% daily rates
subplot(2,1,1)
boxplot(ratesd(1:7,:)) %,'PlotStyle','compact')
%boxplot(spread(4:1714,1:8:33)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('basis points');
% daily volumes
subplot(2,1,2)
boxplot(voldsd(1:7,:)) %,'PlotStyle','compact')
%boxplot(spread(4:1714,2:8:34)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('$ billions');
%bar(delratemed(2:6,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
%set([hLegend, gca] ,'FontSize', 8);

savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratevolsdboxplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratevolsdboxplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\dailyratevolsdboxplot.tex')



% daily bos plot years
% short 2016 7/28/2016 106 212
begn = [4   213 464 713  964 1215 1466];
endn = [212 463 712 963 1214 1465 1714];
begn-endn %-101  -106  -250  -248  -250  -250  -250  -248

rrbpy=zeros(250,7);
voldy=zeros(250,7);
% Do 5 subplots for each rate type?
for k=1:7
rrbpy(begn(k):endn(k),k)=rrbp(begn(k):endn(k),:)
voldy(begn(k):endn(k),k)=vold(begn(k):endn(k),:)
end

year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
Rate={'EFFR', 'OBFR', 'TGCR', 'BGCR','SOFR'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
% daily rates
subplot(2,1,1)
boxplot(spread(4:1714,1:8:33)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('basis points');
% daily volumes
subplot(2,1,2)
boxplot(spread(4:1714,2:8:34)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('$ billions');
%bar(delratemed(2:6,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 8);
%{ 
Annual rates boxplpot
https://www.mathworks.com/help/stats/boxplot.html
figure

subplot(2,1,1)
boxplot(x)

subplot(2,1,2)
boxplot(x,'PlotStyle','compact')

rng default  % For reproducibility
x1 = normrnd(5,1,100,1);
x2 = normrnd(6,1,100,1);
Create notched box plots of x1 and x2. Label each box with its corresponding mu value.

figure
boxplot([x1,x2],'Notch','on','Labels',{'mu = 5','mu = 6'})
title('Compare Random Data from Different Distributions')
%}
year ={'2016';'2017';'2018';'2019';'2020';'2021';'2022'}
Rate={'EFFR', 'OBFR', 'TGCR', 'BGCR','SOFR'}
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
% daily rates
subplot(2,1,1)
boxplot(spread(4:1714,1:8:33)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('basis points');
% daily volumes
subplot(2,1,2)
boxplot(spread(4:1714,2:8:34)) %,'PlotStyle','compact')
xticklabels(Rate);
hYLabel=ylabel('$ billions');
%bar(delratemed(2:6,:),'stacked')
hLegend =legend('EFFR','OBFR','TGCR','BGCR','SOHR','location', 'Southeast')
legend('boxoff')
set([hLegend, gca] ,'FontSize', 8);

savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratesboxplot.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratesboxplot.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality3\dailyratesboxplot.tex')


% Annual volumes barchart
%{
delvolmed =[-4600	4200	3700	4800	-600;
-8800	-20700	3600	-34800	96800;
40700	-2700	-8000	-11500	-68200;
-21600	19100	1400	53800	-29200;
-16400	-5700	-1100	-51100	87800]
%}


%{
NOT NOW  STACKED BARCHARTS ARE BETTER DELETE LATER
% time series A FIGURE FOR EACH SECURITY FOR ALL YEARS, 5 FIGURES, 6
% LINES , THE YEARS, ON ONE FIGURE
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hE = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),1)); %,'LineStyle', 'none');
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hO = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),2));
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hT = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),3)); %,'LineStyle', 'none');
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hB = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),4));
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hS = plot(sdate(begn(k):endn(k)),drates(begn(k):endn(k),5));
hold on
end
%}

% -------------------- time series rates -----------------------------
%{
% STACKED BAR CHART PREFERRED time series figures THINK ABOUT THIS, A FIGURE FOR EACH YEAR OR ALL YEARS
% ON ONE FIGURE
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hE = plot(sdate(begn(k):endn(k)),voldbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hO = plot(sdate(begn(k):endn(k)),voldbp(begn(k):endn(k),2));
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hT = plot(sdate(begn(k):endn(k)),voldbp(begn(k):endn(k),3)); %,'LineStyle', 'none');
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hB = plot(sdate(begn(k):endn(k)),voldbp(begn(k):endn(k),4));
hold on
end

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
ytick=[min(drates(begn(k):endn(k),1)*100):25:max(drates(begn(k):endn(k),1)*100)];
for k=1:6
hS = plot(sdate(begn(k):endn(k)),voldbp(begn(k):endn(k),5));
hold on
end
%%% ABOVE USELESS?
%}

% Time series rates  select sample 
% ( preferred 1 3/04/2016 - 12/29/2022 2 7/28/2016 to 12/29/2022)
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
hE = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hS = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),33)*100) %,'LineStyle', 'none');
hold on
hO = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),9)*100);
hold on
hT = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),17)*100);
hold on
hB = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),25)*100);
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]); % Gold

h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
ylim([0 350]) % brush outlier at (x,y) 737695 5.25
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
  'YTick'       , 0:25:350, ...
  'LineWidth'   , 1         );
%set(gca, 'YTick', 0:25:350) % Break 1
%set(gca, 'YTick', 0:5:55) % Break 2
set(gca,'YGrid', 'on', 'YTick', 50:25:550) % Break 3
%close;
% Export to EPS relable for each chart
%set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratessample1brush.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratessample1brush.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyratessample1brush.fig')

%print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratesample2brush.eps')
%matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratesample2brush.tex')
%savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratesample2brush.fig')

% ------------ Daily time series volumes -------------------------
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
hE = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),2)) %,'LineStyle', 'none');
hold on
hS = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),34)) %,'LineStyle', 'none');
hold on
hO = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),10));
hold on
hT = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),18));
hold on
hB = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),26));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);  % gold

h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('$ billions');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
ylim([0 350]) % brush outlier at (x,y) 737695 5.25
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
  'YTick'       , 0:25:350, ...
  'LineWidth'   , 1         );
%set(gca, 'YTick', 0:25:350) % Break 1
%set(gca, 'YTick', 0:5:55) % Break 2
set(gca,'YGrid', 'on', 'YTick', 50:25:550) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyvolumesample1brush.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyvolumesample1brush.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dailyvolumesample1brush.fig')



% -------------------- spreads ------------------
%{
ADD
 ONRRP-IORB spread in our sample; the rationale behind this choice is that the
ONRRP rate is the safe outside option for FHLBs and MMFs, the main lenders to banks in the
wholesale overnight funding market. The upper bound changes across periods and is equal to the
average realized federal funds-IORB spread in the period;
EFFR-IOR
%}
% IORR 42	SOFR 44	DATE	T10Y2Y 46	T10Y3M 47
endind = size(spread,1);
fig_n1= fig_n1+1;
miny1 =  min(spread(:,46:47)); 
maxy1 = max(spread(:,46:47));
miny2 = min(min(spread(:,42:43)));
maxy2 = max(max(spread(:,42:43)));
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %,''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%''FontName'',''Times-Roman'',''FontSize'',10;']);
%March 2 2016 to Nov 9 2023
%{
ax=gca
yyaxis right
ax.YAxis(2) = [1 0 0];
ylabel('basis points') 
hsof = plot(sdate(1:endind), spread(1:endind,42),'-b','LineWidth',1) % IOR
hold on 
hior=plot(sdate(1:endind), spread(1:endind,43),':b','LineWidth',1) % SOFR
hold on 
yyaxis left
%}
ax=gca;
yyaxis right
hsof_ior=plot(sdate(1:endind),spread(1:endind,43)-spread(1:endind,42),'b','LineWidth',1) % SOFR-IOR
ax.YAxis(2).Color = [0 1 0];
hold on 
yyaxis left
ax.YAxis(1).Color = [0 0 1];
hT10Y2Y=plot(sdate(1:endind),spread(1:endind,46),'g','LineWidth',1) % T10Y2Y
hold on 
hT10Y3M=plot(sdate(1:endind),spread(1:endind,47)-spread(1:endind,42),'m','LineWidth',1) % T10Y3M 47
hold on 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hsof_ior,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hT10Y2Y,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hT10Y3M,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
%set(hsofr,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
%set(hior,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  

%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   

h=[hsof_ior hT10Y2Y hT10Y3M];
%h=[hsofr hior hsofr_ior hT10Y2Y hT10Y3M];
% 'EFFR','OBFR','TGCR','BGCR',
hLegend = legend(h,'SOFR-IOR','T10Y2Y','T10Y3M','location', 'NorthWest');
hTitle=title({'SOHR-IOR and UST spreads (percent)'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreads.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreads.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreads.fig')

fig_n1= fig_n1+1;
%miny1 =  min(spread(:,46:47)); 
si = spread(1:endind,43)-spread(1:endind,42);
maxy1 = max(si);
miny1 = min(si);
miny2 = min(min(spread(:,42:43)));
maxy2 = max(max(spread(:,42:43)));
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %,''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%''FontName'',''Times-Roman'',''FontSize'',10;']);
%March 2 2016 to Nov 9 2023
%{
ax=gca
yyaxis right
ax.YAxis(2) = [1 0 0];
ylabel('basis points') 
hsof = plot(sdate(1:endind), spread(1:endind,42),'-b','LineWidth',1) % IOR
hold on 
hior=plot(sdate(1:endind), spread(1:endind,43),':b','LineWidth',1) % SOFR
hold on 
yyaxis left
%}
ax=gca;
yyaxis right
hsof_ior=plot(sdate(1:endind),spread(1:endind,43)-spread(1:endind,42),'b','LineWidth',1) % SOFR-IOR
ax.YAxis(2).Color = [0 1 0];
hold on 
yyaxis left
ax.YAxis(1).Color = [0 0 1];
hsofr=plot(sdate(1:endind),spread(1:endind,43),'g','LineWidth',1) % T10Y2Y
hold on 
hior=plot(sdate(1:endind),spread(1:endind,42),'m','LineWidth',1) % T10Y3M 47
hold on 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
annotation('textarrow',92,y,'Repo 9/17/2019','y = x ') % SOFR 5.25
hold on 
% 9/17/2019 repo hike  SOFR 5.25
annotation('textarrow',115,y,'Mar 10-18, 2020','y = x ') 
hold on 
%115 (3/8/2020) to 117 (3/15/2020)
% both covid and QE (3/15/2020)?
annotation('textarrow',118,y,'QE','y = x ') % SOFR 5.25
hold on 
%3/23/2020 QE
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hsof_ior,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hT10Y2Y,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
%set(hT10Y3M,'LineStyle', 'none','Marker', 'v','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hsofr,'LineStyle', 'none','Marker', '<','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hior,'LineStyle', 'none','Marker', '>','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  

%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
h=[hsof_ior, hsof, hior] ;
%h=[hsofr hior hsofr_ior hT10Y2Y hT10Y3M];
% 'EFFR','OBFR','TGCR','BGCR',
hLegend = legend(h,'SOFR-IOR','SOFR', 'IOR' ,'location', 'NorthWest');
hTitle=title({'SOHR-IOR spread (percent)'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set(hTitle,'FontName','AvantGarde','Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.fig')
%{
The lower bound is the same for all periods and is equal
to the minimum ONRRP-IORB spread in our sample; the rationale behind this choice is that the
ONRRP rate is the safe outside option for FHLBs and MMFs, the main lenders to banks in the
wholesale overnight funding market. The upper bound changes across periods and is equal to the
average realized federal funds-IORB spread in the period;
\url{https://www.dtcc.com/charts/
dtcc-gcf-repo-index}.
Date	"MBS GCF Repo® 
Weighted Average Rate"	"Treasury GCF Repo® 
Weighted 
Average Rate"	"Agency GCF Repo® 
Weighted 
Average Rate"
%}

%EFFR - IOR, SOFR - IOR, ONRPP - IOR
endind=size(spread,1)
fig_n1= fig_n1+1;
%{
annotation('textarrow',x,y,'String','y = x ')
If X and Y are your data arrays and Xq are your query points, use
Yq = interp1(X,Y,Xq);
96 9/16/2019 Repo spike SOHR 2.42 +13 over 9/15, EFFR 2.23 +11
   97 9/17/2019 Repo spike    SOFR 5+                  EFFR 2.3   
\url{https://www.federalreserve.gov/econres/notes/feds-notes/what-happened-in-money-markets-in-september-2019-20200227.html}
On Monday, September 16, SOFR printed at 2.43 percent, 13 basis points higher than the previous business day. With pressures in the repo market spilling over into the fed funds market, the EFFR printed at 2.25 percent, 11 basis points above the Friday print and at the top of the FOMC's target range. On September 17, the EFFR moved above the top of the target range to 2.3 percent and the SOFR increased to above 5 percent.
annotation('textarrow',91,y,'String','y = x ') 
annotation('textarrow',92,y,'String','y = x ') % SOFR 5.25


2) Mar 10-18 2020  Dash for cash 
121 3/8/2020 0:00 subtract 5 from coordinate
122 3/15/2020 0:00
The COVID-19 Pandemic Caused Market Disruptions across Sovereign Bond Markets
At the start of the COVID-19 pandemic in late February 2020, and in response to the economic repercussions of impending lockdown measures, investors began to demand higher-quality, safe assets. In particular, they shifted their portfolios toward sovereign bonds, and the resulting buying pressure drove sovereign yields to decline broadly. As the crisis intensified in March 2020, however, investors’ demand for cash surged, leading to selling pressure on sovereign bonds and therefore increases in their yields. This down-and-up pattern in yields is illustrated for ten-year U.S., German, U.K., and Japanese bonds in the chart below.
\url{https://libertystreeteconomics.newyorkfed.org/2022/07/the-global-dash-for-cash-in-march-2020/#:~:text=The$\%$20economic$\%$20disruptions$\%$20associated$\%$20with,number$\%$20of$\%$20central$\%$20bank$\%$20actions.}
annotation('textarrow',115,y,'String','y = x ') 
115 (3/8/2020) to 117 (3/15/2020)
% both covid and QE (3/15/2020)?
annotation('textarrow',118,y,'String','y = x ') % SOFR 5.25
3/23/2020 QE
-122 March 15, 2020 On March 15, 2020, the Fed shifted the objective of QE to supporting the economy. It said that it would buy at least $\$$500 billion in Treasury securities and  $\$$200 billion in government-guaranteed mortgage-backed securities over “the coming months.” 
- 123 3/22/2020  March 23, 2020, it made the purchases open-ended, saying it would buy securities “in the amounts needed to support smooth market functioning and effective transmission of monetary policy to broader financial conditions,” expanding the stated purpose of the bond buying to include bolstering the economy. 
annotation('textarrow',118,y,'String','y = x ') % SOFR 5.25

outliers1 = ~excludedata(xdata,ydata,'box',[-1 1 -1 1]);
outliers2 = excludedata(xdata,ydata,'domain',[-2 2]);
outliers = outliers1|outliers2;
Plot the data that is not excluded. The white area corresponds to regions that are excluded.

plot(xdata(~outliers),ydata(~outliers),'.')
axis([-3 3 -3 3])
%}
% Drop outlier
[sdate,maxs] =max(spread(:,42))  % (449,5.2500)
[sdate,maxe] =max(spread(:,1))   % 4.3300
[sdate,maxr] =max(spread(:,42))  % (449,6.0070)
mins=min(spread(:,43)) %  0.0100
mine=min(spread(:,1))  %  0.0100
minr=min(spread(:,45)) % -0.0080 
%[r,c] = min(S);
si =(spread(:,42)-spread(:,41))*100  % 3.1500
ei =(spread(:,1)-spread(:,41))*100  %  0.7000
ri =(spread(:,44)-spread(:,41))*100
[sdate,maxsi] =max(spread(:,42)-spread(:,41))  % (449,315.00)
[sdate,maxei] =max(spread(:,1)-spread(:,41))   %  (270.0000, 70)
[sdate,maxri] =max(spread(:,41)-spread(:,41))*100  % (449,390.7000)
ranges = [maxsi-.5 maxsi]
ranger = [maxri-.5 maxri]
%{
outliers
spread(449,33) spread(449,43) 5.2500 max SOHR
spread(449,45)  6.0070 Max ONRPP

% 'excludedata' requires Curve Fitting Toolbox.
outlierss = excludedata(sdate,si,'range',[maxsi-.5 maxsi]);
outliersr = excludedata(sdate,ri,'range',[maxri-.5 maxri]);
outliers = outlierss|outliersr;
%}
% Break in TS 
% break 1 spread(570:571,1) 1.1000 0.2500 spread(1:570,:)
% break 2 spread(571:1137,:)  .25 - .83
% break 3 spread(1137:1271,:)) 1.58 - ?

% Extreme values   
d=737685 %  09/17/2019 Tuesday
datetime(d, 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yyyy')  %recommended, although I'd recomend using yyyy instead of yy
d=737425 % 12/31/2018  Monday12/31/2018
Yqs = interp1(sdate,spread(:,42),737685);  %maxs Sohr = 5.25
Yq = interp1(sdate,spread(:,42),737425);   % SOHR = 2.45
Yqr = interp1(sdate,spread(:,44),737425);   % SOHR = 5.149
Yqe = interp1(sdate,spread(:,1),737425)  % 2.9500    
%  out(j) = interp1(sdate, spread, 0.5);  % 315 
%{
% Set two outliers
TF = isoutlier(A) 
y(20) = 50;
y(60) = -40;
% Remove outliers
idx = isoutlier(y);
x2 = x(~idx);
y2 = y(~idx);
sdate2 = sdate(~idx);
spread2 = spread(~idx);
% Visualize the result
figure
plot(x,y)
hold on
plot(x2,y2)
legend({'Original','After removing outliers'},'FontSize',12)
%}

fig_n1=fig_n1+1
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %,''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
hsof_ior=plot(sdate(1:endind),(spread(1:endind,43)-spread(1:endind,42))*100,'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
%hsof_ior=plot(sdate(~outliers),si(~outliers),'b','LineWidth',1) % SOFR-IOR , spread(1:endind,43)<maxs
hold on 
he_ior=plot(sdate(1:endind),(spread(1:endind,1)-spread(1:endind,41))*100,'r','LineWidth',1) % EFFR-IOR
hold on 
honrpp_ior=plot(sdate(1:endind),(spread(1:endind,41)-spread(1:endind,41))*100,'g','LineWidth',1) % ONRPP-IOR
hold on 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
% Graph culture
h=[hsof_ior, he_ior, honrpp_ior ]
hLegend = legend(h,'SOFR-IOR','EFFR-IOR', 'ONRPP-IOR' ,'location', 'NorthWest');
hTitle=title({'Overnight rates-IOR spreads (basis points)'});
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(hsof_ior,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
set(he_ior,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);
set(honrpp_ior,'Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0]);
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsIOR.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsIOR.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsIOR.fig')

% IGNORE FOR NOW
% ONRPP - IOR
% % Col C "Treasury GCF Repo® Weighted Average Rate"
fig_n1= fig_n1+1;
%miny1 =  min(spread(:,46:47)); 
%maxy1 = max(spread(:,46:47));
miny2 = min(min(repo(:,2),spread(:,42)));
maxy2 = max(max(repo(:,2),spread(:,42)));
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %,''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
honrpp_ior=plot(sdate(1:endind),repo(1:endind,2)-spread(1:endind,42)*100,'b','LineWidth',1) % SOFR-IOR
%ax.YAxis(2).Color = [0 1 0];
hold on 
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/spreadsSOFR_IOR.fig')

% ---------------- subplots for target, and percentiles -------------------
% EDIT integrate under sample ts
%{fill() function takes as input the x and y coordinates of the corners 
% (vertices) of the region (polygon) to fill the color into in either the 
% clockwise or the anti-clockwise fashion (polygon need not be closed 
% (fill can close it for you)).
h1 = fill([x1 x1 x2 x2], [y2 fliplr(y2)], 'b','EdgeColor','none');
hshade= fill([sdate(begn(k):endn(k))], [target(begn(k):endn(k),2) target(begn(k):endn(k),1) ], 'b','EdgeColor','none');

%}
k=1;
begn = [4 106 213];
endn = [1714 1714 1714];
target = spread(:,3:4); % NaN until 4/19/2019 obs 789	2.44	59	2.25	2.5
target(isnan(target))=0;
begintarget = 789-447+1;
quantileeffr=spread(:,5:8);
% EFFR
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(rrbp(begn(k):endn(k),1)):25:max(rrbp(begn(k):endn(k),1))];
a1 = subplot( 1, 2, 1 );
hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
%hS = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),5)) %,'LineStyle', 'none');
%hold on
ylim ([0 450])
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h1=[hE hL hU];
hLegend = legend(h1,'EFFR','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
%set(hU,'LineStyle', '--', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hL,'LineStyle', '--', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
set(hU,'LineStyle', '--','Color',[0 0 1]);
set(hL,'LineStyle', '--','Color',[0 0 1]);

%set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
%set(gcf, 'PaperPositionMode', 'auto');
% save plot

a2 = subplot( 1, 2, 2 );
hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
%hS = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),5)) %,'LineStyle', 'none');
hold on
hD1 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),2)*100); % 25 pct
hold on
hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
hold on
%yline(meaneffr,'--b','Median') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h2=[hE  hD1 hD2];
hLegend = legend(h2,'EFFR','25 percentile','75 percentile','location', 'NorthWest' );
%hLegend = legend(h2,'EFFR','SOFR','25 percentile','75 percentile','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
%set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hD1,'LineStyle', '--','Color',[0 0 1]);
set(hD2,'LineStyle', '--','Color',[0 0 1]);
%set(hD1,'LineStyle', '--', 'Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hD2,'LineStyle', '--', 'Marker','o', 'MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
%set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffr.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffr.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffr.fig');

% SOFR
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(rrbp(begn(k):endn(k),1)):25:max(rrbp(begn(k):endn(k),1))];
a1 = subplot( 1, 2, 1 );
%hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
%hold on
hS = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),5)) %,'LineStyle', 'none');
hold on
ylim ([0 450])
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h1=[hS hL hU];
hLegend = legend(h1,'SOFR','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
%set(hU,'LineStyle', '--', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hL,'LineStyle', '--', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
set(hU,'LineStyle', '--','Color',[0 0 1]);
set(hL,'LineStyle', '--','Color',[0 0 1]);

%set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
%set(gcf, 'PaperPositionMode', 'auto');
% save plot

a2 = subplot( 1, 2, 2 );
%hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
%hold on
hS = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),5)) %,'LineStyle', 'none');
hold on
ylim ([0 450])
hD1 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),2)*100); % 25 pct
hold on
hD2 = plot(sdate(begn(k):endn(k)),quantileeffr(begn(k):endn(k),3)*100); % 75 pct
hold on
%yline(meaneffr,'--b','Median') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h2=[ hS hD1 hD2];
hLegend = legend(h2,'SOFR','25 percentile','75 percentile','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hD1,'LineStyle', '--','Color',[0 0 1]);
set(hD2,'LineStyle', '--','Color',[0 0 1]);
%set(hD1,'LineStyle', '--', 'Marker', 'o','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hD2,'LineStyle', '--', 'Marker','o', 'MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
%set(gca,'YGrid', 'off', 'YTick', ytick) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
% save plot
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionSofr.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionSofr.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionSofr.fig');

krates=kurtosis(rrbp(begn(k):begn(k),:)) % 1.2728
krates=kurtosis(vold(begn(k):begn(k),:)) % 2.5651

for j=1:5
 krates(j)=kurtosis(rrbp(begn(k):begn(k),j))
end

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

end % if nf~=0  major edit needed

% -------------- Gara dispersion from target rates -----------------
%{
The daily value of $D_t$ is the deviations between the value weighted daily 
fed funds rate and the FOMC target, for 2017-2022.
% FF > upper target TU
\begin{equation*}
D_t = \overline{\rho}_t  -\rho_{max,t}
\end{equation*}
if $\rho_{max,t}<\overline{\rho}_t$

% FF < lower target TD
\begin{equation*}
D_t = \overline{\rho}_t - \rho_{min,t} 
\end{equation*}
if $\overline{\rho}_t <\rho_{min,t}$

$D_t=0$ if $\rho_{min,t}<\overline{\rho}_t <\rho_{max,t} $
%}
T = size(rrbp(begn(k):endn(k),:),1)
dgara = zeros(T,1);
% targets start at line 525 3/29/2018 0:00	1.68	102	1.75	1.5
% t= 524
targetbp = target*100;
for t =524:size(dgara,1)
    if rrbp(t,1)>targetbp(t,1) % greater than TU
        dgara(t) = rrbp(t,1)-targetbp(t,1);
    elseif rrbp(t,1)<targetbp(t,2) % less than TD
        dgara(t) = rrbp(t,1)-targetbp(t,2)*100;
    end
end
% Test
chk = [dgara(620:850) rrbp(620:850,1) targetbp(620:850,1) targetbp(620:850,2)];
% EFFR
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%ytick=[min(rrbp(begn(k):endn(k),1)):25:max(rrbp(begn(k):endn(k),1))];
%a1 = subplot( 1, 2, 1 );
yyaxis left
hE = plot(sdate(begn(k):endn(k)),rrbp(begn(k):endn(k),1)) %,'LineStyle', 'none');
hold on
ylim ([0 450])
hL = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),2)*100);
hold on
hU = plot(sdate(begn(k):endn(k)),target(begn(k):endn(k),1)*100);
hold on
hYLabel=ylabel('basis points');
yyaxis right
hG = plot(sdate(begn(k):endn(k)),dgara(:,1)) %,'LineStyle', 'none');
hold on
%yline(meaneffr,'--b','Mean') 
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
h1=[hE hG hL hU];
hLegend = legend(h1,'EFFR','Index','Lower target','Upper target','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hG,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
%set(hU,'LineStyle', '--', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1]);
%set(hL,'LineStyle', '--', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
set(hU,'LineStyle', '--','Color',[0 0 1]);
set(hL,'LineStyle', '--','Color',[0 0 1]);

set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffrGara.eps','-bestfit' );
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffrGara.tex');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality3/dispersionEffrGara.fig');


%{ 
% ============ Disaggregate unsecured, secured rates, volumes===============
% Use this code to 
% === Group rates by unsecured EFFR, OBFR, and secured TGCR, BGCR, SOFR ===
% -------------------------- rates -----------------------------------
%{
switch rate d
    case 1 % all
    case 2
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
hS = plot(sdate(1:endind),spread(1:endind,33)*100);
hold on
hT = plot(sdate(1:endind),spread(1:endind,17)*100);
hold on
hB = plot(sdate(1:endind),spread(1:endind,25)*100);
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
Remove outliers https://medium.com/analytics-vidhya/removing-outliers-understanding-how-and-what-behind-the-magic-18a78ab480ff#:~:text=Removing%20Outliers%20using%20Standard%20Deviation,is%20Normally%2FGaussian%20distributed).
https://www.mathworks.com/help/matlab/creating_plots/interactively-explore-plotted-data.html;jsessionid=d9eb49344c735f8fbd96a86e52da
%}

h=[hS hT hB];
hLegend = legend(h,'SOFR','TGCR','BGCR','location', 'NorthWest' );
hTitle=title({'US overnight rates'});
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
% print -depsc2 finalPlot1.eps
print -depsc2 onrate_pctchangev2.eps
save('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_all.eps')
save('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_all.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_all.eps')
exportgraphics(gcf,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrate_all.eps','ContentType','vector')

    case 3
    hE = plot(sdate(1:endind),spread(1:endind,1)*100) %,'LineStyle', 'none');
    hold on
    hO = plot(sdate(1:endind),spread(1:endind,9)*100) %,'LineStyle', 'none');
    hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none','Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );

h=[hE hO];
hLegend = legend(h,'EFFR','OBFR','location', 'NorthWest' );
hTitle=title({'US overnight rates'});
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
    otherwise
end

% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
% print -depsc2 finalPlot1.eps
print -depsc2 onrate_pctchangev2.eps

% Export to EPS
if k==1
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateES_.tex');
elseif k==2 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateSTB.tex');
elseif k==3 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateEO.tex');
elseif k==4 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onratedailyAll.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onratedailyAll.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onratedailyAll.tex');
otherwise
end
%}


% --------- Secured rates TGCR, BGCR, SOHRdaily volumes -------------------
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]), ''FontName'',''Times-Roman'',''FontSize'',10;']);
hS = plot(sdate(1:endind),spread(1:endind,34));
hold on
hT = plot(sdate(1:endind),spread(1:endind,19));
hold on
hB = plot(sdate(1:endind),spread(1:endind,26));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hO,'LineStyle', 'none','Marker', 'v','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );  
set(hT,'LineStyle', 'none','Marker', '<','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', '>','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hS hT hB];
hLegend = legend(h,'SOFR','TGCR','BGCR','location', 'NorthWest');
legend('boxoff')
hTitle=title({'US overnight volumes'}) %,{'OBFR','TGCR','BGCR'});
hXLabel=xlabel('daily');
hYLabel=ylabel('$ billions');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','Fontsize',10);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateOTB_.tex');

% --------- Unsecured rates EFFR,OBFRdaily volumes -------------------
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);        
%eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]), ''FontName'',''Times-Roman'',''FontSize'',10;']);
hE = plot(sdate(1:endind),spread(1:endind,2)) %,'LineStyle', 'none');
hold on
hO = plot(sdate(1:endind),spread(1:endind,10)) %,'LineStyle', 'none');
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none','Marker', 'o','LineStyle', 'none', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hO,'LineStyle', 'none', 'Marker','diamond', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );

h=[hE hO];
hLegend = legend(h,'EFFR','OBFR','location', 'NorthWest');
legend('boxoff')
hTitle=title({'US overnight volumes'}) %,{'EFFR','SOFR'});
hXLabel=xlabel('daily');
hYLabel=ylabel('$ billions');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','Fontsize',10);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS
if k==1
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateES_.tex');
elseif k==2 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateSTB.tex');
elseif k==3 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateEO.tex');
elseif k==4 
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateAll.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateAll.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\onrateAll.tex');
otherwise
end
%}

% ============== Demand: Scatter plots of daily rates versus volumes ==============
%{ 
scatter(x,y,sz) specifies the circle sizes. To use the same size for all the circles, specify sz as a scalar. To plot each circle with a different size, specify sz as a vector or a matrix.
example
scatter(x,y,sz,c) specifies the circle colors. You can specify one color for all the circles, or you can vary the color. For example, you can plot all red circles by specifying c as "red".
example
scatter(___,"filled") fills in the circles. Use the "filled" option with any of the input argument combinations in the previous syntaxes.
example
scatter(___,mkr) specifies the marker type.
%}

%{
a=annotatation('textarrow',x,y,'string','y=x');
a.color = 'red
a.fontszie=9
xticks=(0:10:maxx);
%}

% -------------- bin plots daily rates versus volumes full sample
% PUT THIS UNDER THE SAMPLE nf~=0 option?? Create more options
begn = [4 106 213 463];  % 3/4/2016, 7/28/2016 (Start IOR), 1/2/2017, 1/2/2018
endn = [1714 1714 1714 1714];   
switch nf
   case 1 % 03/04/2016 - 12/29/2022
       k=1  
   case 2  % 07/28/2016 - 12/29/2022 IOR starts
       k=2
   case 3 % 01/02/2017
       k=3
end
endind= size(spread,1) 

% check dates
raws(begn)
raws(endn)


drates =spread(begn(k):endn(k),1:8:33);
vold =spread(begn(k):endn(k),2:8:34);
dratesbp = drates*100;
voldbp = vold*100;
maxx = max(vold);
maxy = max(drates*100);

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);

t = tiledlayout('flow');
t = tiledlayout(3,2);
nexttile
hE=binscatter(vold(:,1),drates(:,1)*100)
hE.NumBins = [round(maxx(1)/5) round(maxy(1)/5)];
colormap(gca,'parula')
title('EFFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hO=binscatter(vold(:,2),drates(:,2)*100)
hO.NumBins = [round(maxx(2)/5) round(maxy(2)/5)];
colormap(gca,'parula')
title('OBFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hT=binscatter(vold(:,3),drates(:,3)*100)
hT.NumBins = [round(maxx(3)/15) round(maxy(3)/15)];
colormap(gca,'parula')
title('TGCR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hB=binscatter(vold(:,4),drates(:,4)*100)
hB.NumBins = [round(maxx(4)/5) round(maxy(4)/5)];
colormap(gca,'parula')
title('BGCR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hold on
hS=binscatter(vold(:,5),drates(:,5)*100)
colormap(gca,'parula')
hS.NumBins = [round(maxx(5)/15) round(maxy(5)/15)];
title('SOFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
%hold off

%unsecured rates
t = tiledlayout(2,1);
nexttile
hE=binscatter(vold(:,1),drates(:,1)*100)
hE.NumBins = [round(maxx(1)/5) round(maxy(1)/5)];
colormap(gca,'parula')
title('EFFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hO=binscatter(vold(:,2),drates(:,2)*100)
hO.NumBins = [round(maxx(2)/5) round(maxy(2)/5)];
colormap(gca,'parula')
title('OBFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on

%secured repo rates
t = tiledlayout(3,1);
nexttile
hT=binscatter(vold(:,3),drates(:,3)*100)
hT.NumBins = [round(maxx(3)/15) round(maxy(3)/15)];
colormap(gca,'parula')
title('TGCR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hB=binscatter(vold(:,4),drates(:,4)*100)
hB.NumBins = [round(maxx(4)/5) round(maxy(4)/5)];
colormap(gca,'parula')
title('BGCR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
nexttile
hold on
hS=binscatter(vold(:,5),drates(:,5)*100)
colormap(gca,'parula')
hS.NumBins = [round(maxx(5)/15) round(maxy(5)/15)];
title('SOFR')
hXLabel=xlabel('$ billions');
hYLabel=ylabel('basis points');
hold on
%hold off

maxx = max(vold);
maxy = max(drates*100);

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hE=binscatter(vold(:,1),drates(:,1)*100) %'FaceAlpha',2)
colormap(gca,'parula')
hE.NumBins = [round(maxx(1)/5) round(maxy(1)/5)];

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hO=binscatter(vold(:,2),drates(:,2)*100)
hO.NumBins = [round(maxx(2)/5) round(maxy(2)/5)];

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hT=binscatter(vold(:,3),drates(:,3)*100)
hT.NumBins = [round(maxx(3)/5) round(maxy(3)/5)];

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hB=binscatter(vold(:,4),drates(:,4)*100)
hB.NumBins = [round(maxx(4)/5) round(maxy(4)/5)];

fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
hS=binscatter(vold(:,5),drates(:,5)*100)
hS.NumBins = [round(maxx(4)/5) round(maxy(4)/5)];

set(h,'LineStyle', 'none','Marker', '.','MarkerSize', 1,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 0]);  %yellow
h=[hE hO hL hU hD1 hD2];
hLegend = legend(h,'EFFR','OBFR','Lower target','Upper target','25 percentile','75 percentile','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
endind= size(spread,1)  



% ===================== Shocks ======================
[shocks, txt2, raws2] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv7.xlsx', 'Shockdata', 'A455:P1716');
sdate2 = datenum(raws2(:,1),'mm/dd/yyyy');
shocks(isnan(shocks))=0;
shock=zeros(size(shocks,1),9);
shock(:,1:2)= shocks(:,2:3);  % FOMC from to
shock(:,3:4)= shocks(:,5:6);  % IOR from to
shock(:,5:6)= shocks(:,9:10);  % ONRRP from to
shock(:,7:9)= shocks(:,11:13);  % SOHR-IOR, TGCR-IOR, GCF-IOR
rshock(:,1:3)=shock(:,1:2:5)-shock(:,2:2:6);
endind=size(shocks,1);
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]), ''FontName'',''Times-Roman'',''FontSize'',10;']);
yyaxis right
ax.YAxis(2).Color = [1 0  0];
hE = plot(sdate2(1:endind),rshock(1:endind,1));
hold on
hI = plot(sdate2(1:endind),rshock(1:endind,2));
hold on
hO = plot(sdate2(1:endind),rshock(1:endind,3));
hold on
yyaxis right
ax.YAxis(2).Color = [ 0 1 0];
hS = plot(sdate2(1:endind),shock(1:endind,7));
hold on
hT = plot(sdate2(1:endind),shock(1:endind,8));
hold on
hG = plot(sdate2(1:endind),shock(1:endind,9));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );  
set(hI,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
set(hS,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
set(hG,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] ); % Gold% 

%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hE hI hO hS hT hG];
hLegend = legend(h,'FOMC','IOR','ON RPP','SOHR-IOR','TGCR-IOR','GCF-IOR','location', 'NorthWest');
%h=[hE hI hO];
%hLegend = legend(h,'FOMC','IOR','ON RPP','location', 'NorthWest');
legend('boxoff')
%hTitle=title({'US overnight volumes'}) %,{'OBFR','TGCR','BGCR'});
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','Fontsize',10);
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
  'YTick'       , 0:500:2500, ...
  'LineWidth'   , 1         );
%close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/shocks.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/shocks.eps')
matlab2tikz('C:\Users\Owner\Documents\Research\MonetaryPolicy\Figures\PublicationQuality\shocks.tex');

%{
if ne~=0
if ne~=0  % divide into MP regime epochs
%{
REDO FOR MP EPOCHS IF DESIRES
MAY NOT USE ANYMORE
for full sample daily rates
Daily breaks:
begn = [1 418 1109]; excel [6 90 234] (-5 for weekly)
endn = [417 1108 1271]; excel [89 233 267]
1. 12/4/2017 - 8/01/2019  1 -   417
Normalcy,  mid cycle adjstment
2.  8/02/2019 - 05/04/2022  418-1108
Coping with covid
3. 05/05/2022 - 12/29/2022 1109 1271
Taming inflation


%Daily breaks: ratevw
begn = [1 418 1109]; %excel [6 90 234] (-5 for weekly)
endn = [417 1108 1271]; %excel [89 233 267]


fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
hE = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),1)*100) %,'LineStyle', 'none');
hold on
hS = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),33)*100) %,'LineStyle', 'none');
hold on
hO = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),9)*100);
hold on
hT = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),17)*100);
hold on
hB = plot(sdate(begn(k):endn(k)),spread(begn(k):endn(k),25)*100);
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1 ] );  
set(hT,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0 ] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1]);  

h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')
hXLabel=xlabel('daily');
hYLabel=ylabel('basis points');
%hTitle=title({'US overnight rates'; 'FOMC 2018 Returning to normalcy, 2019 mid cycle adjustment, coping with covid'});
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','Fontsize',10);
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
set(hTitle,'FontName','AvantGarde','Fontsize',10);
ylim([0 350]) % brush outlier at (x,y) 737695 5.25
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
  'YTick'       , 0:25:350, ...
  'LineWidth'   , 1         );
%set(gca, 'YTick', 0:25:350) % Break 1
%set(gca, 'YTick', 0:5:55) % Break 2
set(gca,'YGrid', 'on', 'YTick', 50:25:550) % Break 3
%close;
% Export to EPS relable for each chart
set(gcf, 'PaperPositionMode', 'auto');
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onratesample2brush.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onratesample2brush.tex')
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onratesample2brush.fig')
%}
end %for conditional if ne
% ================  Volatility ==========================

% ================ Daily Rate Volatility historic ==================
volres1 = log(res(2:endind,1))-log(res(1:endind-1,1));
% ------------------------------- RATES ------------------------------
%{ Volatility is calculated using publicly released weekly snapshots for 
52-week trailing windows, as the standard deviation of the first difference
M = movstd(A,k) returns an array of local k-point standard deviation values. 
Each standard deviation is calculated over a sliding window of length k 
across neighboring elements of A. When k is odd, the window is centered 
about the element in the current position. When k is even, the window is 
centered about the current and previous elements. The window size is 
automatically truncated at the endpoints when there are not enough elements
to fill the window. When the window is truncated, the standard deviation is
taken over only the elements that fill the window. M is the same size as A.
%}
% Log first differnce
endind = size(spread,1)
vol1= log(spread(begn(k)+1:endn(k),1:8:33))-log(spread(begn(k):endn(k)-1,1:8:33));
% evolrates = estim_egarch(vol1,1,1)% std dev of vol1, first difference for trailing window of 244 days?
vol2= movstd(vol1,244);
vol3=std(vol1);
% evolrates = estim_egarch(vol3,1,1)
% evolrates = estim_egarch(vol2,1,1)
%log(spread(2:endind,1:8:33))-log(spread(1:endind-1,1:8:33));
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
endind= size(spread,1) 
n=1
switch n
    case 1  % vol1 log percent difference all rates
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
maxy = max(vol1)
maxy1 = max(maxy)
%endind = 200
hE = line(sdate(1:endind-1),vol1(1:endind-1,1)*.01) %,'LineStyle', 'none');
hold on
hS = line(sdate(1:endind-1),vol1(1:endind-1,5)) %,'LineStyle', 'none');
hold on
hO = plot(sdate(1:endind-1),vol1(1:endind-1,2));
hold on
hT = plot(sdate(1:endind-1),vol1(1:endind-1,3));
hold on
hB = plot(sdate(1:endind-1),vol1(1:endind-1,4));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});

set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
set(hO,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );  
set(hT,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0.9290 0.6940 0.1250] );  % Gold
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hE hO hT hB hS]; 
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')   
%hTitle=title({'US overnight rates, percent change'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set(hTitle,'FontName','AvantGarde','FontSize', 10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','FontSize', 10);
set([hLegend, gca],'FontName','AvantGarde','FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:.05:maxy1, ...
  'LineWidth'   , 1         );
%close;

% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratePctchange.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratePctchange.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onratePctchange.tex')

    case 2 % Secured rates
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
maxy = max(vol1(:,2:4))
maxy1 = max(maxy)
hS = line(sdate(1:endind-1),vol1(1:endind-1,2));
hold on
hT = line(sdate(1:endind-1),vol1(1:endind-1,3));
hold on
hB = line(sdate(1:endind-1),vol1(1:endind-1,4));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
set(hS,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );  
set(hT, 'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] );  
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}
h=[hS hT hB];
hLegend = legend(h,'SOFR','TGCR','BGCR','location', 'NorthWest' );

hTitle=title({'US overnight rates, percent change'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hYLabel=ylabel({'basis points';'(semilog)'});
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde', 'Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:.05:maxy1, ...
  'LineWidth'   , 1         );
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchangev2.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchange.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchange.tex')


    case 3 Unsecured rates
% ------------------------------- EFFR, OBFR ------------------------------
maxy = max(vol1(:,1),vol1(:,5))
maxy1 = max(maxy)
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); 
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
yyaxis right
ax.YAxis(2).Color = [1 0  0];
hO = semilogy(sdate(1:endind-1),vol1(1:endind-1,2));
%hO = plot(sdate(1:endind-1),vol1(1:endind-1,5));
%hE= semilogy(X1,Y1,'o',X2,Y2) 
hold on
YLabel=ylabel('percent (semilog)')
hold on
yyaxis left
ax.YAxis(1).Color = [0 0  0];
hE= semilogy(sdate(1:endind-1),vol1(1:endind-1,1));
%hE = plot(sdate(1:endind-1),vol1(1:endind-1,1));
hold on
YLabel=ylabel('percent (semilog)')
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor', [0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);

h=[hE hO];
hLegend = legend(h,'EFFR','OBFR','location', 'NorthWest' );
hTitle=title({'US overnight rates - EFFR, OBFR, percent change'});
hXLabel=xlabel('daily');
%hYLabel=ylabel({'percent (semilog)'});
%hYLabel=ylabel('basis points');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','FontSize', 10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
save('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.tex')

    otherwise
end

% vol2 rolling standard deviation
% evolrates = estim_egarch(vol2,1,1)
n=1
switch n
    case 1  % all rates
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
maxy = max(vol1)
maxy1 = max(maxy)
%endind = 200
hE = line(sdate(1:endind-1),vol2(1:endind-1,1)*.01) %,'LineStyle', 'none');
hold on
hS = line(sdate(1:endind-1),vol2(1:endind-1,5)) %,'LineStyle', 'none');
hold on
hO = plot(sdate(1:endind-1),vol2(1:endind-1,2));
hold on
hT = plot(sdate(1:endind-1),vol2(1:endind-1,3));
hold on
hB = plot(sdate(1:endind-1),vol2(1:endind-1,4));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 0 1] );
set(hO,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );  
set(hT,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none', 'Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1] );  
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}

h=[hE hO hT hB hS];
hLegend = legend(h,'EFFR','OBFR','TGCR','BGCR','SOFR','location', 'NorthWest' );
legend('boxoff')
%hTitle=title({'US overnight rates, percent change'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
%set(hTitle,'FontName','AvantGarde','FontSize', 10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde','FontSize', 10);
set([hLegend, gca],'FontName','AvantGarde','FontSize', 6);
set([hXLabel, hYLabel],'FontName','AvantGarde','FontSize',8);

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:.05:maxy1, ...
  'LineWidth'   , 1         );
%close;

% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onrateStdchange.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onrateStdchange2.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality2/onrateStdchange.tex')

    case 2 % Secured rates
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); %''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
maxy = max(vol1(:,2:4))
maxy1 = max(maxy)
hS = line(sdate(1:endind-1),vol2(1:endind-1,5));
hold on
hT = line(sdate(1:endind-1),vol2(1:endind-1,3));
hold on
hB = line(sdate(1:endind-1),vol2(1:endind-1,4));
hold on
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
set(hO,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0] );  
set(hT, 'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[0 1 0] );  
set(hB,'LineStyle', 'none','Marker', 'o','MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 1 ] );  
%{
Use one of these values: '+' | 'o' | '*' | '.' | 'x' | 'square' |
'diamond' | 'v' | '^' | '>' | '<' | 'pentagram' | 'hexagram' | '|' | '_' | 'none'.
%}
h=[hS hT hB];
hLegend = legend(h,'SOFR','TGCR','BGCR','location', 'NorthWest' );

hTitle=title({'US overnight rates, percent change'});
hXLabel=xlabel('daily');
hYLabel=ylabel('percent');
%hYLabel=ylabel({'basis points';'(semilog)'});
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde', 'Fontsize',10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:.05:maxy1, ...
  'LineWidth'   , 1         );
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
savefig('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchangev2.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchange.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateSTB_pctchange.tex')


    case 3 % Unsecured rates EFFR, OBFR
maxy = max(vol1(:,1),vol1(:,5))
maxy1 = max(maxy)
fig_n1=fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']); 
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
yyaxis right
ax.YAxis(2).Color = [1 0  0];
hO = semilogy(sdate(1:endind-1),vol2(1:endind-1,2));
%hS = plot(sdate(1:endind-1),vol1(1:endind-1,5));
%hE= semilogy(X1,Y1,'o',X2,Y2) 
hold on
YLabel=ylabel('percent (semilog)')
hold on
yyaxis left
ax.YAxis(1).Color = [0 0  0];
hE= semilogy(sdate(1:endind-1),vol2(1:endind-1,1));
%hE = plot(sdate(1:endind-1),vol1(1:endind-1,1));
hold on
YLabel=ylabel('percent (semilog)')
datetick('x', 'mm/dd/yyyy','keepticks')
xtickangle(45)
[tb,btns] = axtoolbar({'zoomin','zoomout','restoreview','datacursor','brush'});
%set(hReserves,'Marker','o','MarkerSize', 2,'MarkerEdgeColor','none','MarkerFaceColor', [.5 .5 .5] );
set(hE,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor', [0 0 0]);
set(hS,'LineStyle', 'none', 'Marker','o', 'MarkerSize', 3,'MarkerEdgeColor','none','MarkerFaceColor',[1 0 0]);

h=[hE hO];
hLegend = legend(h,'EFFR','OBFR','location', 'NorthWest' );
hTitle=title({'US overnight rates - EFFR, OBFR, percent change'});
hXLabel=xlabel('daily');
%hYLabel=ylabel({'percent (semilog)'});
%hYLabel=ylabel('basis points');
%hText=text(1,2,'\leftarrow sin(\pi)')

% Adjust Font and Axes Properties
set( gca,'FontName','Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName','AvantGarde','FontSize', 10);
%set([hTitle, hXLabel, hYLabel, hText],'FontName','AvantGarde');
set([hLegend, gca] ,'FontSize', 6);
set([hXLabel, hYLabel],'FontSize',8);
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
  'YTick'       , 0:.5:maxy1, ...
  'LineWidth'   , 1         );
close;
% Export to EPS
set(gcf, 'PaperPositionMode', 'auto');
save('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.fig')
print('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.eps')
matlab2tikz('C:/Users/Owner/Documents/Research/MonetaryPolicy/Figures/PublicationQuality/onrateEO_pctchange.tex')
    otherwise
end

% ================ Volatility implied ==================
% SIMPLE MODELS
%{
https://www.cmegroup.com/education/articles-and-reports/cme-sofr-futures-and-sofr-volatility.html
The implied volatility rates are averages of mid-level rates for bid and ask "at-money-quotations" 
on selected currencies at 11:00 a.m. on the last business day of the month.
Suzanne Elio at (212) 720-6449 or suzanne.elio@ny.frb.org.
https://seekingalpha.com/article/4501215-implied-volatility
%}

     
drates=spread(213:end,1:8:33);

% Simple AR(1) model levels

A= drates(2:end,:)./drates(1:end-1,:)
for t = 2:endind
     yt(t,:) = A*yt(t-1,:)';
end

%[theta,sec,R2,R2adj,vcv,F] = olsgmm(yy,xx,nlag,nw);  % constant
%param = [theta sec]
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
%ONRRP_IOR= (spread(213:endind,43)-spread(213:endind,41))*100; % ONRPP-IOR
%xx1=[ones(size(drates,1)-1) drates(2:endind,:)];
%xx2=[ones(size(drates,1)-1)  drates(2:end,:) SOFR_IOR(1:end-1) EFFR_IOR(1:end-1) ONRRP_IOR(1:end-1)]
xx1=[rrbp(begn(k)-1:endn(k),:)];
xx2=[rrbp(begn(k)-1:endn(k),:) SOFR_IOR(begn(k)-1:endn(k)) EFFR_IOR(begn(k)-1:begn(k)) ONRRP_IOR(begn(k)-1:begn(k))]
xx3=[rrbp(begn(k)-1:endn(k),:) IOR(begn(k)-1:endn(k)) ONRRP(begn(k)-1:endn(k))]
be=rrbp(begn(k):begn(k)-1,1)/rrbp(begn(k)-1:begn(k),1)
%
% Rates
[theta1,sec1,R2,R2adj,vcv,F1] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx1,nlag,nw);  % constant
param1 = [theta1 sec1,R2,R2adj,vcv,F1]

[theta2,sec2,R2,R2adj,vcv,F2] = olsgmm(rrbp(begn(k):endn(k)-1,:),xx2,nlag,nw);  % constant
param2 = [theta2 sec2,R2,R2adj,vcv,F2]

[theta3,sec3,R2,R2adj,vcv,F3] = olsgmm(rrbp(begn(k):endn(k)-1,:), xx2,nlag,nw)
param3 = [theta3 sec3 R2,R2adj,vcv,F3]



% Volatility
xx4 = [SOFR_IOR(1:end-1) EFFR_IOR(1:end-1) ONRRP_IOR(1:end-1)]
[theta,sec,R2,R2adj,vcv,F] = olsgmm(volrate(2:endind,4),volrates(1:endind-1,3),nlag,nw);  % constant
param = [theta sec,R2,R2adj,vcv,F]
% log pct change and std models


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




% ================== volatility of weekly reserves,  rates ================
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%, ''FontName'',''Times-Roman'',''FontSize'',10;']);
%Times-Roman
ax=gca;
ax.FontSize = 6
%March 2 2016 to Nov 9 2023
plot(reservesn(1:endind-1,1), vol1(1:endind-1,1)*.01,'LineWidth',1) % EFFR
hold on
plot(reservesn(1:endind-1,1), vol1(1:endind-1,2),'LineWidth',1) % OBFR
hold on
plot(reservesn(1:endind-1,1), vol1(1:endind-1,3),'LineWidth',1) % TGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,4),'LineWidth',1) % BGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,5) ,'LineWidth',1) % SOHR
hold on
%plot(mdate(1:endind-1), volres1(1:endind-1,1),'LineWidth',1) % reserves_n
%hold on  % 
%datetick('x', 'mm/dd/yyyy','keepticks')
%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
%axis([datenum(2016,03,03)  datenum(2022,11,09) miny maxy])
%axis([datenum(1963,01,01)  datenum(2022,01,01) NBRy(1) NBRy(2)])
xtickangle(45)
legend('EFFR','OBFR','TGCR','BGCR','SOHR')
title({'Volatility (percent change) of US overnight rates and level of reserves'});
ax.FontSize = 8

legend('EFFR','OBFR','TGCR','BGCR','SOHR','Reserves') ,
title({'US overnight rates and reserves, percent change'});
volres1 = log(res(2:endind,1))-log(res(1:endind-1,1));
minx =min(reservesn)  %0.1079
maxx = max(reservesn) %  0.2429
%}

% Breakdown missing for EO, STB
%{
DUPLICATE?
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'',''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]);']);
%, ''FontName'',''Times-Roman'',''FontSize'',10;']);
%Times-Roman
ax=gca;
ax.FontSize = 6
%March 2 2016 to Nov 9 2023
plot(reservesn(1:endind-1,1), vol1(1:endind-1,1)*.01,'LineWidth',1) % EFFR
hold on
plot(reservesn(1:endind-1,1), vol1(1:endind-1,2),'LineWidth',1) % OBFR
hold on
plot(reservesn(1:endind-1,1), vol1(1:endind-1,3),'LineWidth',1) % TGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,4),'LineWidth',1) % BGCR
hold on
plot(reservesn(1:endind-1,1),vol1(1:endind-1,5) ,'LineWidth',1) % SOHR
hold on
%plot(mdate(1:endind-1), volres1(1:endind-1,1),'LineWidth',1) % reserves_n
%hold on  % 
%datetick('x', 'mm/dd/yyyy','keepticks')
%fill(NBRx', NBRy3',grcolor,'FaceAlpha',.2,'EdgeColor',[1 1 1]) %CORRECT!!
%size( NBRx') %1    36
%size(NBRy3) %18     2   
%axis([datenum(2016,03,03)  datenum(2022,11,09) miny maxy])
%axis([datenum(1963,01,01)  datenum(2022,01,01) NBRy(1) NBRy(2)])
ylabel({'Overnight rates';'pct change'});
xlabel({'Reserves/commercial deposits';'$ billions' });
xtickangle(45)
legend('EFFR','OBFR','TGCR','BGCR','SOHR')
title({'Volatility (percent change) of US overnight rates'});
%title({'Volatility (percent change) of US overnight rates and level of reserves'});
ax.FontSize = 8
print -depsc2 onrate_levels.eps

%y (percent change): US overnight rates and reserves'});
ax.FontSize = 8
print -depsc2 onrate_levels.eps
%}




function yt=simple_model(alph,rhos,rho,b_s,H);
A = [ 0 alph rhos ;
    0 rho^(-1)*(1-alph) -rho^(-1)*rhos ;
    0   0                 rhos];
B = -[ 1;
    rho^(-1)*(b_s-1);
    1];

yt = zeros(H,3);
yt(2,:) = B';
for t = 3:H;
    yt(t,:) = A*yt(t-1,:)';
end;
end


function [N,Nb,nb,Q,ze,Lb] = solvemodel(sig,kap,bet,omeg,rho,t_ix,t_ipi,rhoi,rhos,b_i,b_s)
% matrices
show_results = 0; % use for debugging
A = eye(5);
N = size(A,1);

% x pi q ui us

B = [...
    (1+sig*t_ix+sig*kap/bet) sig*t_ipi-sig/bet    0       sig    0 ;
    -kap/bet                 1/bet                0        0     0 ;
    t_ix/omeg                t_ipi/omeg           1/omeg 1/omeg  0 ;
    0                        0                    0       rhoi   0 ;
    0                        0                    0        0    rhos];



C = [...
    0 0 ;
    %b_i b_s ;
    -b_i -b_s;
    0 0 ;
    1 0 ;
    0 1 ];
% Size(C) 5 2  structural shock
D = [...
    1  0 ;
    0 0;
    0  1 ;
    0  0 ;
    0  0 ];
% size(D) 5 2 expectation error
% Solve by eigenvalues

A1 = inv(A); 
F = A1*B; % A =eye() just returns (gets) B
[Q L] = eig(F); 
Q1 = inv(Q); 
if show_results;
    disp('Eigenvalues');
    disp(abs(diag(L)'));
end
% produce Ef, Eb, that select forward and backward
% eigvenvalues. If L>=1 in position 1, 3, 
% produce
% 1 0 0 0 
% 0 0 1 0 ...
% for example

nf = find(abs(diag(L))>=1); % nf is the index of eigenvalues greater than one
if show_results
    disp('number of eigenvalues >=1');
    disp(size(nf,1))
end
if (size(nf,1) < size(D,2)); 
    disp('not enough eigenvalues greater than 1');
end;
Ef = zeros(size(nf,1),size(A,2));
Efstar = zeros(size(A,2),size(A,2));
for indx = 1:size(nf,1);
    Ef(indx,nf(indx))=1; 
    Efstar(nf(indx),nf(indx)) = 1; 
end;

nb = find(abs(diag(L))<1);
Eb = zeros(size(nb,1),size(A,2));
for indx = 1:size(nb,1);
    Eb(indx,nb(indx))=1;
end;

ze = Eb*Q1*A1*(C-D*inv(Ef*Q1*A1*D)*Ef*Q1*A1*C);
% how epsilon shocks map to z.
% in principle the forward z are zero. In practice they are 1E-16 and then
% grow. So I go through the trouble of simulating forward only the nonzero
% z and eigenvalues less than one.

Nb = size(Eb,1); % number of stable z's
Lb = (Eb*L*Eb'); % diagonal with only stable Ls
end

% evolrates = estim_egarch(vol1,1,1)
function [coefs, forecast] = estim_egarch(y, p, q)
l = @(a) builtin('_paren', -likelihood_egarch(y, a, p, q), 1);
coefs = fminunc(l, [log(var(y)), zeros(1,p+q)]);
[~, f] = likelihood_egarch(y, coefs, p, q);
forecast = f';
end
function [coefs, forecast] = estim_egarch(y, p, q)
l = @(a) builtin('_paren', -likelihood_egarch(y, a, p, q), 1);
coefs = fminunc(l, [log(var(y)), zeros(1,p+q)]);
[~, f] = likelihood_egarch(y, coefs, p, q);
forecast = f';
end
