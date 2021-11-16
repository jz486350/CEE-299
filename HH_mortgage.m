% Stanford University               CEE299 Indepedent Studies - Jimmy Zhang 
% jzhang01@stanford.edu                                           7/21/2021                   
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Household Income Assignment based on Mortgage Eligibility              
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This script matches transaction prices and dates to applicable interest 
% rates to evaluate the minimum level of household income required
% to secure mortgage financing to purchase a property at the time of
% purchase. 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:                                                
%
% input_bldg.xlsx     - Nx4 Matrix containing property transaction date,
%                       transaction price, census tract, # of units at
%                       address
%
% input_interest.xlsx - 2597x3 Vectors containing 30-year & 15-year amorti-
%                       zation period interest rates from 1971 and 1991
%                       respectively based off of Freddie Mac Prime Mortgage
%                       Market Survey at http://www.freddiemac.com/pmms/
%
% Notes: 
% All dates from input files to be numerical; i.e. 44006 vs. 6/24/2020 and
%   in Excel format
% FreddieMac PMMS updates on a weekly basis, the file retrieved was last
%   updated on 6/17/2021.
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
% init_income.txt     - Text file containing vector of household income at
%                       time of last property purchase in order of input
%                     - 06/28/2021 Addendum: Columns increase to 3, Col2 to
%                       delineate # of units per address(row), Col3 to 
%                       outline transaction date for further processing,
%                       and Col4 to display census tract index
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Assumptions:
%
% Assume Total Debt Service Ratio of 36%; Gross Debt Service Ratio of 28%
% Assume all building owners met 500 credit score and qualified for mortgages
% Assume all buildings in input_bldg file are owner-occupied (previously
%   sampled to randomly assign tenants vs. owners via Rodrigo Costa)
% Assume every building sold was on a primary mortgage basis, and has no
%   other restrictive covenants, liens, or other charges that would otherwise
%   affect the housing price and mortgage eligibility of the property
% Assume that if building last sold after Dec 2020, the interest rate will
%   be that of the last week of Dec 2020
% Assume that if no transaction information is available, randomly assign
%   household income by Census tract HH income distribution
% Assume most conservative lending measures will be observed due to lack of
%   information surrounding HH savings and credit scores, such that all
%   purchases of property will neglect down-payment requirements and
%   mortgages of 30-year amortization periods will be financed
% Assume 20% downpayment for conservative measure
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Import Inputs of BLDG and INTEREST
INTR = readmatrix('input_interest.xlsx');
BLDG = readmatrix('input_bldg.xlsx');
idx_NaN = find(isnan(BLDG(:,1)));
idx_Val = find(~isnan(BLDG(:,1)));

%% Establish Lending Parameters and Initial Income
GDSR = 0.28;
INCOME = zeros(length(BLDG(:,1)),1);
INCOME(idx_NaN) = NaN;

for i = 1:length(idx_Val)
    % Match purchase date to closest known weekly interest rate
    [~,t] = min(abs(INTR(:,1)-BLDG(idx_Val(i),1)));
    % Evaluate minimum income required to clear payment requirements
    INCOME(idx_Val(i)) = 12/GDSR*payper(INTR(t,2)/100/12,30*12,0.8*BLDG(idx_Val(i),2)/BLDG(idx_Val(i),4),0,0);
    
    % For debugging
    if rem(i,10) == 0
        disp(i)
    end
end

%% Export Income at Time of Purchase
INCOME = [INCOME,BLDG(:,4),BLDG(:,1)];
save('init_income.txt','INCOME','-ascii')