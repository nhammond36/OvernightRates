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
