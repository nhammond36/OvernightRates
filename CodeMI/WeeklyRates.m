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
[spread,txts,raws]=xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table_weekdayv7.xlsx','A445:AS1715');
size(spread) %    1244          47
sdate = datenum(raws(:,1),'mm/dd/yyyy');

rates=zeros(size(spread,1),13);
%vmrates=zeros(size(spread,1),55);
rates(:,1:2:9) = spread(:,1:8:33); % EFFR, OBFR, TGFR, BGSR, SOHR
rates(:,2:2:10) = spread(:,2:8:34); % EFFR, OBFR, TGFR, BGSR, SOHR
% Percentiles 1 25 75 99
ptiles = [.01 .25 .75 .99];
pctiles(:,9:12)  = spread(:,5:8);   %EFFR
pctiles(:,17:20) = spread(:,13:16); %OBFR
pctiles(:,25:28) = spread(:,21:24); %TGCR
pctiles(:,33:36) = spread(:,29:32); %BGCR
pctiles(:,41:44) = spread(:,37:40); %SOHR
%{
pctilese(:,9:12)  = spread(:,5:8);
pctileso(:,17:20) = spread(:,13:16);
pctilest(:,25:28) = spread(:,21:24);
pctilesb(:,33:36) = spread(:,29:32);
pctiless(:,41:44) = spread(:,37:40);
%}
rates(:,11) = spread(:,41); %IOR
rates(:,12) = spread(:,44); %ONRPP Treasuries "Treasury GCF Repo® Weighted Average Rate"
rates(:,13) = spread(:,43); %ONRPP "MBS GCF Repo® Weighted Average Rate"

% Compute volume weighted means and percentiles
% ERROR the benchmarks are already volume weigthed median rates
wrates1(:,1:2:9) = rates(:,1:5).*vol(:,1:5); % Rates
wrates1(:,2:2:10) = vol(:,1:5);               % Volume, each rate
vsum=sum(wrates1(:,2:2:10),2);                % Total volume
vmrates(:,1:2:9) = wrates1(:,1:2:9)./vsum(:); % Rates
vmrates(:,2:2:10) =wrates1(:,2:2:10);         % Volumes &billion
vmrates(:,11:13) = rates(:,6:8);        % IOR, RRPust, RRPmbs
chk = sum(vmrates(:,1:2:10),2);
% Percentiles, not right magnitude
vmrates(:,13:8:52) =  ptiles(1).*(pctiles(:,9:8:41).*vol(:,1:5)./vsum(:));
vmrates(:,14:8:53) = ptiles(2).*(pctiles(:,10:8:42).*vol(:,1:5)./vsum(:));
vmrates(:,15:8:54) = ptiles(3).*(pctiles(:,11:8:43).*vol(:,1:5)./vsum(:));
vmrates(:,16:8:55) = ptiles(4).*(pctiles(:,12:8:44).*vol(:,1:5)./vsum(:));
%{
 Change frequency from daily to average weekly
a) simple average
b) volume weighted averge
VWAP is calculated using the following formula:
VWAP=∑p(j)q(j)/sum(q(j))
P_{{{\mathrm  {VWAP}}}}={\frac  {\sum _{{j}}{P_{j}\cdot Q_{j}}}{\sum _{j}{Q_{j}}}}\,
where:
VWAP = P_{{{\mathrm  {VWAP}}}} is Volume Weighted Average Price;
P_{j} is price of trade 
Q_{j} is quantity of trade j;
j is each individual trade that takes place over the defined period of time, excluding cross trades and basket cross trades.[4]

Using
Time = seconds(1:5);
TT = array2timetable(X,'RowTimes',Time)
TT2 = retime(TT1,newTimeStep) 
adjusts timetable data using the 'fillwithmissing' method. TT2 has missing data indicators wherever TT2 has a row time that does not match any row time in TT1.
%}
%a) simple average 
date1=datetime(txts,'InputFormat','MM/dd/yyyy'); 
rateT = array2timetable(rates,'RowTimes',date1);
rateT1 = retime(rateT,'weekly','median'); 

rateTmatrix = rows2vars(rateT);
writetimetable(rateT,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_table4.xlsx');
writetimetable(rateT1,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onrates_weekly4.xlsx');

%b) volume weighted average 
%date1=datetime(sdate,'InputFormat','MM/dd/yyyy'); 
ratew1 = array2timetable(rates(:,1:13),'RowTimes',date1);
ratew = retime(ratew1,'weekly','median'); 

rateTmatrix = rows2vars(ratew);
writetimetable(ratew,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onratesw_tablev3.xlsx');
%writetimetable(ratevw1,'C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/onratesvmw_weeklyv2.xlsx');

% ========================================================
%{ Plot TS of rates and reserves
3/2/2016	2481.508	15707.4483	11064.7498	3/2/2016	2461152	0.36	3/6/2016 0:00		
DATE	WRESBAL	TLAACBW027SBOG	DPSACBW027SBOG	DATE	TREAST
size(ratevw1) 266     8
size(ratevw)  1271     8
size(ratevw1)  266     8
size(res) 357     6
Error using tabular/plot (line 220)
Tables and timetables do not have a plot method. To plot a table or a timetable, use the
stackedplot function. As an alternative, extract table or timetable variables using dot or brace
subscripting, and then pass the variables as input arguments to the plot function.

thefield = 'snowstorm';
data = ratevw1 ;
structOfTables = struct(thefield, data)
structOfTables2.(thefield) = data

A = TestTable{:,{'REST'}}
Or
A = TestTable.REST

ratesp = T{:, 'ratevw1'}
ratesp = T{:, {'ratevw1'}}

%}
[res,txtr,rawr] = xlsread('C:/Users/Owner/Documents/Research/MonetaryPolicy/Data/WRESBAL_BankAssetsv7.xlsx','A2346:G2610');
wdate = datenum(rawr(:,1),'mm/dd/yyyy')
size(wdate) % 265     1
size(res) %  265     6
%
%ratesp = ratevw1(2:end,:);
T = Table(ratevw1(2:end,1:7)); %' % EFFR	OBFR	TGCR	BGCR	SOHR	IOR	RPPust	RPPmbs
ratesp = T(2:end,:);

thefield = 'weeklyrates';
data = magic(4);
structOfTables = struct(thefield, data)
structOfTables2.(thefield) = data
fig_n1= fig_n1+1;
eval(['Figure',num2str(fig_n1),' = figure(''PaperOrientation'',''portrait'',''color'', ''white'');']);
%''PaperPosition'',[0.7 2.5 7 6],''PaperSize'',[11 8.5]
%, ''FontName'',''Times-Roman'',''FontSize'',10;']);
%Times-Roman
ax=gca;
ax.FontSize = 6
%March 2 2016 to Nov 9 2023
plot(wdate,ratevw1(:,1),'LineWidth',1) % EFFR
hold on
plot(wdate,ratevw1(:,2),'LineWidth',1) % OBFR
hold on
plot(wdate,ratevw1(2:end,3),'LineWidth',1) % TGCR
hold on
plot(wdate,ratevw1(2:end,4),'LineWidth',1) % BGCR
hold on
plot(wdate,ratevw1(2:end,5),'LineWidth',1) % SOHR
hold on
plot(wdate,res(:,1),'LineWidth',1) % TOTRESN
hold on
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
legend('EFFR','OBFR','TGCR','BGCR','SOHR','Reserves') ,
title({'US overnight rates and reserves, percent change'});
volres1 = log(res(2:endind,1))-log(res(1:endind-1,1));
minx =min(reservesn)  %0.1079
maxx = max(reservesn) %  0.2429


%averagee values per month
[am,~,cm] = unique(data(:,1:2),'rows');
out_month = [am,accumarray(cm,data(:,5),[],@nanmean)];

% Sample data
data     = [datenum(2012,10:13,1)',(1:4)'];
% Retrieve all days
dates    = (data(1):data(end,1))';
% Remove weekends and holidays
dates    = dates(isbusday(dates));

https://www.mathworks.com/help/finance/fints.toweekly.html
toweekly()
newfts = toweekly(oldfts,'ParameterName',ParameterValue, ...)
BusDays (ParameterName)
0 (Parametervalue)
Generates a financial time series that ranges from (or between) the first date to the last date in oldfts (includes NYSE nonbusiness days and holidays).
	
1
(Default) Generates a financial time series that ranges from the first date to the last date in oldfts (excludes NYSE nonbusiness days and holidays and weekends based on AltHolidays and Weekend). If an end-of-quarter date falls on a nonbusiness day or NYSE holiday, returns the last business day of the quarter.
NYSE market closures, holidays, and weekends are observed if AltHolidays and Weekend are not supplied or empty ([]).


AltHolidays
Vector of dates specifying an alternate set of market closure dates
	
-1 Excludes all holidays.

Weekend	
Vector of length 7 containing 0's and 1's. The value 1 indicates a weekend day. The first element of this vector corresponds to Sunday. For example, when Saturday and Sunday are weekend days (default) then Weekend = [1 0 0 0 0 0 1].

case 

US holidays federal https://en.wikipedia.org/wiki/Federal_holidays_in_the_United_States
New Year's Day
Birthday of Martin Luther King, Jr.
Washington's Birthday
Memorial Day
Juneteenth National Independence Day
Independence Day
Labor Day
Columbus Day
Veterans Day
Thanksgiving Day
Christmas Dayl
%}