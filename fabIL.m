
%% 

clc;
clear variables;
load simBase.mat;

industry_output = IL(1:69,5);   % Illinois
commodity_aggregation_scheme = aggF(aggC);
industry_aggregation_scheme = aggF(aggC(1:67));
number_of_sectors = max(aggC) - 2;
number_of_random_steps_per_sector = 20000; 

%% Get True Aggregated A* that will never change
outputArg = getRegionalA('inReg',IL,'detailed',0,'ScrapColumns',[16,17]); 
true_aggregate_A = outputArg.a; % FIXED - never change

outputArg = getRegionalA('inReg',IL);                                                                     
detail_A = outputArg.a;   
final_demand = outputArg.f;         

%% Benchmark First Order Aggregation Bias

fab = (true_aggregate_A * industry_aggregation_scheme - industry_aggregation_scheme * detail_A) * final_demand; % FAB for each perturbed_g on sector k
benchmark_FAB = fab;


%% Get Output Simulation Results

outputSim = getOutputSimulationResults('inReg',IL,'NumberOfRandomSteps',20000); 
RandomSimulationResults  = outputSim.RandomSimulationResults; 
CombinedRandomSimulationResults = outputSim.CombinedRandomSimulationResults;

%% FAB from the Random Simulation

% for each sector at a time
FABRandomSimulation = struct([]);
fab = zeros(number_of_sectors,number_of_random_steps_per_sector);

for k = 1:number_of_sectors 

    for j = 1:number_of_random_steps_per_sector
        simulated_output = [RandomSimulationResults(k).steps(:,j);0;0];                    

        outputArg = getRegionalA('inReg',IL,'newReg_g',simulated_output); 
        detail_A = outputArg.a;   
        f = outputArg.f;         
    
        fab(:,j) = (true_aggregate_A * industry_aggregation_scheme * final_demand) - (industry_aggregation_scheme * detail_A * f); % FAB for each perturbed_g on sector k
        
    end
    FABRandomSimulation(k).steps = fab;        
end
    
% all results at once:
fab = zeros(number_of_sectors,number_of_random_steps_per_sector);

for j = 1:number_of_random_steps_per_sector
    simulated_output = [CombinedRandomSimulationResults(:,j);0;0];

    outputArg = getRegionalA('inReg',IL,'newReg_g',simulated_output); 
    detail_A = outputArg.a;  
    f = outputArg.f;        

    fab(:,j) = (true_aggregate_A * industry_aggregation_scheme * final_demand) - (industry_aggregation_scheme * detail_A * f); % FAB for each perturbed_g where all sectors are perturbed
end  
CombinedFABRandomSimulation = fab; 

%% Get Output Permutation Results

outputPerm = getOutputPermutationResult('inReg',IL); 
PermutationResult = outputPerm'; 

%% FAB from the Permutation
 
fabPerm = zeros(number_of_sectors,size(PermutationResult,2));

for j = 1:size(PermutationResult,2)
    permuted_output = [PermutationResult(:,j);0;0];

    outputArg = getRegionalA('inReg',IL,'newReg_g',permuted_output); 
    detail_A = outputArg.a;  
    f = outputArg.f;        

    fabPerm(:,j) = (true_aggregate_A * industry_aggregation_scheme * final_demand) - (industry_aggregation_scheme * detail_A * f); % FAB for each permuted_output 
end  
FABPermutation = fabPerm; 


%% Store the results into a .mat file

% save Aggregation Bias results:
save ('fabBaseIL', "benchmark_FAB","FABRandomSimulation", "CombinedFABRandomSimulation", "FABPermutation");

% save g simulations results 
save ("gsimBaseIL", "RandomSimulationResults","CombinedRandomSimulationResults","PermutationResult");



