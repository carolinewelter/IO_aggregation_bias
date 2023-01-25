function  outputSim = getOutputSimulationResults(varargin)
% Purpose:  getOutputSimulationResults it receives regional and national economic data 
% and returns simulated regional outputs
%
% Input data in the US variable includes five (column) variables for
% the US and the same five variables for the region that is the
% focus of the regionalization. The five key variables for each place are  
%
 % Column 1: exogenously given (fixed) final demands - these are a function
 %           of column control totals that do not change from simulation to 
 %           simulation. These final demand activities include PCE,
 %           Investment, and all government sectors
 % Column 2: exports
 % Column 3: imports
 % Column 4: non-trade final demands that vary by sector as a function of 
 %           commodity output.  For our set of FD activities, 
 %           inventory adjustments are the only such activity
 % Column 5: industry output
%
%  When there are only default variables, the function will draw from
%  simBase.mat, where US is the five-variable set for the US, an data are
%  available for IL, KY, and CA.
% 
%  
%--------
%   Written by: Caroline Welter and finalized by Randy Jackson
%   November 3, 2022.
%


% Notation:
% k = index for use over aggregate sectors 
% i = index for use over detailed industries 
% j = index for use over simulation steps

% terminology:  

% industries are children and the sectors they belong to are
% parents: industry = child, sector = parent 
% true means "known and accurate"

%%
ip = inputParser;

    addParameter(ip, 'inUS', []);
    addParameter(ip, 'inReg', 'IL');
    addParameter(ip, 'newReg_g', 1);
    addParameter(ip, 'NumberOfRandomSteps', 20000);

parse(ip, varargin{:});

if isempty(ip.UsingDefaults)
   disp('Using defaults: ')
   disp(ip.UsingDefaults)
end

load simBase.mat

%%

if ismember('inUS', ip.UsingDefaults) 
    inUS = US;
else
    inUS = ip.Results.inUS;
end

% Default region in simBase is Illinois (IL).  
if ismember('inReg', ip.UsingDefaults) 
    inReg = IL;   % names the default region
else
    inReg = ip.Results.inReg;
end


if ~ismember('newReg_g', ip.UsingDefaults)
    inReg(:,5)= ip.Results.newReg_g;
end

% Default simulations steps
if ismember('NumberOfRandomSteps', ip.UsingDefaults) 
    NumberOfRandomSteps = 20000;  
else
    NumberOfRandomSteps = ip.Results.NumberOfRandomSteps;
end

if ~ismember('NumberOfRandomSteps', ip.UsingDefaults)
    NumberOfRandomSteps = ip.Results.NumberOfRandomSteps;
end


%% 

commodity_aggregation_scheme = aggC; 

number_of_sectors = max(commodity_aggregation_scheme) - 2;
number_of_commodities = (size(inReg,1)); 
number_of_industries = number_of_commodities - 2; 

industry_aggregation_scheme = commodity_aggregation_scheme(1:number_of_industries);

true_industry_output = inReg(1:number_of_industries,5); 
number_of_random_steps_per_sector = NumberOfRandomSteps;


%% 
% Store the aggregate sector output totals in a vector:

true_sector_output = zeros(number_of_sectors:1);
for i = 1:number_of_sectors
    true_sector_output(i) = sum(true_industry_output(industry_aggregation_scheme == i));
end
true_sector_output = true_sector_output';

% Data check:

total_regional_output = sum(true_industry_output,1);

%% 
% Counts of the number of industries in each sector and identify 
% the index of the max-valued industry for each sector       

number_of_children_per_parent = zeros(number_of_sectors,1);
for k = 1:number_of_sectors
    number_of_children_per_parent(k) = size(true_industry_output(industry_aggregation_scheme==k),1);
end

biggest_child_for_parent = zeros(number_of_sectors,1);
biggest_child_output_value = zeros(number_of_sectors,1);
for i = 1:number_of_industries  
   if(true_industry_output(i) > ...
           biggest_child_output_value(industry_aggregation_scheme(i)))

       biggest_child_for_parent(industry_aggregation_scheme(i)) = i;
       biggest_child_output_value(industry_aggregation_scheme(i)) = ...
           true_industry_output(i);
   end
end

%% Random Simulation Design

allresultsrand = struct([]); 

for k = 1:number_of_sectors 
    
    for j = 1:number_of_random_steps_per_sector
        for i = 1:number_of_industries
            if (industry_aggregation_scheme(i) == k)
                %rng(1, 'twister')
                shock = (true_industry_output(i)/4) * randn(1,1);  % Find a shock centered on zero 
                                                                   % with a range that is a function
                                                                   % of the initial estimate
                if (abs(shock) < true_industry_output(i))   % these conditional (if) statements 
                                                            % ensure positive simg values
                    simulated_industry_output(i,j) = true_industry_output(i) + shock;
                else
                    shock = shock/2;
                    
                    if (abs(shock) < true_industry_output(i))
                        simulated_industry_output(i,j) = true_industry_output(i) + shock;
                    else
                        shock = shock/2;
                        
                        if (abs(shock) < true_industry_output(i))
                            simulated_industry_output(i,j) = true_industry_output(i) + shock;
                        else 
                            simulated_industry_output(i,j) = true_industry_output(i);                                
                        end
                    end
                end
            else % if i is not in k
                 simulated_industry_output(i,j) = true_industry_output(i);
            end
        end
        num = sum(true_industry_output(industry_aggregation_scheme == k),1);
        denom = sum(simulated_industry_output(industry_aggregation_scheme == k,j));
        adjustment = num / denom;
        simulated_industry_output(industry_aggregation_scheme == k,j) = simulated_industry_output(industry_aggregation_scheme == k,j) * adjustment;
        constraint_check = sum(true_industry_output(industry_aggregation_scheme == k)) - sum(simulated_industry_output(industry_aggregation_scheme == k));
            if(constraint_check > .001)
                disp("Adding up constraint not met");
            end
        allresultsrand(k).steps = simulated_industry_output;            
    end
end

% All at once - Combining results from multiple single-sector runs.  

resultAllrand = zeros(number_of_industries,number_of_random_steps_per_sector);

for k = 1:number_of_sectors
     tmp = allresultsrand(k).steps;
    for i = 1:number_of_industries
        if (industry_aggregation_scheme(i) == k)
            resultAllrand(i,:) = resultAllrand(i,:) + tmp(i,:);
        end
    end
end
resultAllrand;

%%

outputSim = struct();
outputSim.RandomSimulationResults = allresultsrand;
outputSim.CombinedRandomSimulationResults = resultAllrand;
end
