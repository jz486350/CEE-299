% Stanford University               CEE299 Indepedent Studies - Jimmy Zhang 
% jzhang01@stanford.edu                                           7/28/2021  
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Supplement to Household Income Assignment based on Mortgage Eligibility 1             
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This script adjusts the output init_income.txt file from HH_mortgage.m to
% interpolate/extrapolate minimum household income values at time of
% purchase to an arbitrary point of time referencing the following:
% 
% [1] Donovan, S. A., Labonte, M., Dalaker, J., & Romero, P. D. (2021, 
%     January 13). The U.S. Income Distribution: Trends and Issues (Rep. 
%     No. R44705). Retrieved https://fas.org/sgp/crs/misc/R44705.pdf
%
% [2] Semega, J., Kollar, M., Shrider, E. A., & Creamer, J. (2020, 
%     September 15). Income and Poverty in the United States: 2019 (Rep. 
%     No. P60-270). Retrieved 
%     https://www.census.gov/library/publications/2020/demo/p60-270.html
%
% [3] Steven Ruggles, Sarah Flood, Sophia Foster, Ronald Goeken, Jose Pacas, 
%     Megan Schouweiler and Matthew Sobek. IPUMS USA: Version 11.0 [dataset]. 
%     Minneapolis, MN: IPUMS, 2021. https://doi.org/10.18128/D010.V11.0
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:                                                
%
% init_income.txt     - Nx3 matrix containing income at time of purchase,
%                       # of units at address, and date of purchase
%
% input_quints.xlsx   - 55x6 matrix containing HH income brackets broken
%                       into quintiles sourced from [3], using methodology 
%                       outlined in [1] and [2] from 1967-2019
%                       (specific to [San Fran-Oakland-Fremont])
%
% input_growth.xlsx   - 55x6 matrix containing midpoint HH income quintile
%                       growth trends processed from [3]
%
% Q(i)_mobility.txt   - Nx5 matrix containing distributions of HH income
%                       mobility as a function of duration and HH income
%                       bracket, output of PSIDprocess.m
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
% adj_income.txt      - Nx1 Vector containing adjusted owner HH income from 
%                       time of purchase to 2020
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Import Income/Mobility Parameters
INCOME = readmatrix('init_income.txt');   
QUINTS = readmatrix('input_quints.xlsx'); 
GROWTH = readmatrix('input_growth.xlsx');
Q1 = readmatrix('Q1_mobility.txt');
MOBILITY = zeros(5,length(Q1),5);
MOBILITY(1,:,:) = Q1;
MOBILITY(2,:,:) = readmatrix('Q2_mobility.txt');
MOBILITY(3,:,:) = readmatrix('Q3_mobility.txt');
MOBILITY(4,:,:) = readmatrix('Q4_mobility.txt');
MOBILITY(5,:,:) = readmatrix('Q5_mobility.txt');

%% Convert Target Date & Indentify Target Date Index
ExDate = m2xdate(datenum(2020,1,1));
[~,x] = min(abs(QUINTS(:,1)-ExDate));

%% Evaluation
idx_Val = find(~isnan(INCOME(:,1)));
idx_NaN = find(isnan(INCOME(:,1)));
ADJUSTED = zeros(length(idx_Val),1);
MOVEMENT = zeros(length(idx_Val),1);
initQ = zeros(length(idx_Val),1);

for i = 1:length(idx_Val)
    % Categorize Income Percentile by Year and Dollar Value
    [~,y] = min(abs(QUINTS(:,1)-INCOME(idx_Val(i),3)));
    
    P = INCOME(idx_Val(i),1)-QUINTS(y,2:end);
    P(P <= 0) = inf;
    [~,z] = min(P(:));
  
    % Account for Income Mobility over Duration of Projection
    % z = randsrc(1,1,[3,4,5;0.1267,0.3818,0.4915]); % For Unknowns
    MOVE = incomeMobility(INCOME(idx_Val(i),3),ExDate,z,MOBILITY);

    % Convert Initial Income & Interpolate Target Value
    ADJUSTED(i) = GROWTH(x,1+z)/GROWTH(y,z+1)*INCOME(idx_Val(i),1);
    MOVEMENT(i) = MOVE-z;
    initQ(i) = z;
    
    % For debugging
    if MOVE > 5 || MOVE < 0
        disp('Impossible Movement Detected')
    end
    if rem(i,10) == 0
        disp(i)
    end
end

FINAL = zeros(length(INCOME(:,1)),1);
FINAL(idx_NaN) = NaN;
FINAL(idx_Val) = ADJUSTED;

%% Check Starting Income Quintile & Track Income Mobility
CHECK = zeros(length(INCOME(:,1)),2);
CHECK(idx_NaN,:) = NaN;
CHECK(idx_Val,2) = MOVEMENT;
CHECK(idx_Val,1) = initQ;
CHECK = [FINAL,CHECK];

%% Export 
save('4pager_income.txt','FINAL','-ascii')

%% Income Mobility Function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function mobility = incomeMobility(INIT,END,Quintile,Movement)
% Establish timing 
duration = (END-INIT)/365;
[~,t] = min(abs([0:51/(length(Movement(Quintile,:,:))-1):51]-duration));
% Determine Destination Based on Origin & Duration
P = [Movement(Quintile,t,1),Movement(Quintile,t,2),Movement(Quintile,t,3),...
        Movement(Quintile,t,4),Movement(Quintile,t,5)];
P = P./sum(P);
mobility = randsrc(1,1,[1:5;P]);
end



