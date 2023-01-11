%% Mean Absolute Percent Value symmetric - MAPE for IL

% Symmetric MAPE calculated by row wise evaluation, which gives us the
% mean-based accuracy measure across simulation steps and not across number
% of sectors.

% Interpretation: The lower the Symmetric MAPE value of a forecast, the higher its accuracy.

clear;
clc;
load fabBaseIL.mat;
number_of_sectors = size(CombinedFABRandomSimulation,1);
number_of_random_steps_per_sector = size(CombinedFABRandomSimulation,2);
number_of_permutations = size(FABPermutation,2);


%% MAPE Results - Permutation FAB

difference = zeros(number_of_sectors,number_of_permutations);
mape = zeros(number_of_sectors,number_of_permutations); 
mape_sum = zeros(number_of_sectors,1);
    for j = 1:number_of_sectors
    difference(j,:) = abs(FABPermutation(j,:) - benchmark_FAB(j,1));
    mape(j,:) = difference(j,:) ./ ((abs(benchmark_FAB(j,1)) + abs(FABPermutation(j,:)))/2);
    mape_sum(j,1) = sum(mape(j,:));
    end
    smape_FABPermutation = (mape_sum/number_of_permutations) * 100; 

%% MAPE Results - Random Simulation FAB

% Multiple single-industry perturbation (each sector at a time):

smape_FABRandomSimulation = struct([]);
difference = zeros(number_of_sectors,number_of_random_steps_per_sector);
mape = zeros(number_of_sectors,number_of_random_steps_per_sector); 

for k = 1:number_of_sectors
    for j = 1:number_of_sectors
    difference(j,:) = abs(FABRandomSimulation(k).steps(j,:) - benchmark_FAB(j,1));
    mape(j,:) = difference(j,:) ./ ((abs(benchmark_FAB(j,1)) + abs(FABRandomSimulation(k).steps(j,:)))/2);
    mape_sum(j,1) = sum(mape(j,:));
    end
    smape_FABRandomSimulation(k).steps = (mape_sum/number_of_random_steps_per_sector) * 100;  
end

% Combination of the multiple single-industry perturbation (all at once):

difference = zeros(number_of_sectors,number_of_random_steps_per_sector);
mape = zeros(number_of_sectors,number_of_random_steps_per_sector); 
    for j = 1:number_of_sectors
    difference(j,:) = abs(CombinedFABRandomSimulation(j,:) - benchmark_FAB(j,1));
    mape(j,:) = difference(j,:) ./ ((abs(benchmark_FAB(j,1)) + abs(CombinedFABRandomSimulation(j,:)))/2);
    mape_sum(j,1) = sum(mape(j,:));
    end
    smape_CombinedFABRandomSimulation = (mape_sum/number_of_random_steps_per_sector) * 100; 

%% Plots - Permutation MAPE

bar(smape_FABPermutation, 'r')
%title('Symmetric MAPE, Permutation','FontSize',10);                                  
xlabel('Aggregated Industries','FontSize', 12);                                        
ylabel('Symmetric MAPE','FontSize',12);
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\smape_FABPermutationIL.png','Resolution',300)

% HISTOGRAM 
skewness_smape_FABPermutation = skewness(smape_FABPermutation);
mean_smape_FABPermutation = mean(smape_FABPermutation);
nbins = 12;
histfit(smape_FABPermutation, nbins);
%title('Symmetric MAPE, Permutation','FontSize',14);
xlabel('Symmetric MAPE', 'FontSize',12);
ylabel('Frequency', 'FontSize', 12); 
legend( 'Mean: 131.3', 'Skewness: -1.09', 'Location','NorthEast');
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\hist.smape_FABPermutationIL.png','Resolution',300)

save ('smape_fabIL', "smape_CombinedFABRandomSimulation", "smape_FABRandomSimulation", "smape_FABPermutation" )

%% Plots - Random Simulation MAPE
% SYSTEM-WIDE EFFECTS (All at once results)

bar(smape_CombinedFABRandomSimulation)
%title('Symmetric MAPE - System-Wyde Effects, Random Simulation','FontSize',14);                                  
xlabel('Aggregated Industries','FontSize', 12);                                        
ylabel('Symmetric MAPE', 'FontSize', 12);
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\smape_CombinedFABRandomSimulationIL.png','Resolution',300)

% HISTOGRAM 
skewness_smape_CombinedFABRandomSimulation = skewness(smape_CombinedFABRandomSimulation);
mean_smape_CombinedFABRandomSimulation = mean(smape_CombinedFABRandomSimulation);
nbins = 9;
histfit(smape_CombinedFABRandomSimulation, nbins);
%title('Symmetric MAPE - System-Wyde Effects, Random Simulation','FontSize',14);
xlabel('Symmetric MAPE', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);   
legend( 'Mean: 60.73', 'Skewness: 0.74', 'Location','NorthEast');
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\hist.smape_CombinedFABRandomSimulationIL.png','Resolution',300)

%% Plots - Random Simulation MAPE
% Each at a time results

x = 1:1:20;
y = [smape_FABRandomSimulation(6).steps'; smape_FABRandomSimulation(9).steps'; smape_FABRandomSimulation(15).steps'];
bar(x,y,1)
xlabel('Aggregated Industries', 'FontSize', 12);
ylabel('Symmetric MAPE', 'FontSize', 12);
lgd = legend({' 6 - Mineral and Metal products',' 9 - Chemical products',' 15 - Finance, insurance, real estate, rental, and leasing'},'Location','southoutside', 'FontSize', 10);
title(lgd,'Perturbed Industry:', 'FontSize', 10);
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\smape_FABRandomSimulation.png','Resolution',300)


%% MAPE Results - Permutation Multipliers

load multipliersIL.mat;
number_of_industries = size(true_output_multiplier.multiplier,2);

difference = zeros(number_of_permutations,number_of_industries);
mape = zeros(number_of_permutations,number_of_industries); 
mape_sum = zeros(1,number_of_industries);
    for j = 1:number_of_industries
    difference(:,j) = abs(output_multiplier_Permutation.multiplier(:,j) - true_output_multiplier.multiplier(1,j));
    mape(:,j) = difference(:,j) ./ ((abs(true_output_multiplier.multiplier(1,j)) + abs(output_multiplier_Permutation.multiplier(:,j)))/2);
    mape_sum(1,j) = sum(mape(:,j));
    end
    smape_output_multiplier_Permutation = (mape_sum/number_of_permutations) * 100; 


%% MAPE Results - Random Simulation Multipliers

% Multiple single-industry perturbation (each sector at a time):

smape_output_multiplier_RandomSimulation = struct([]);
difference = zeros(number_of_random_steps_per_sector,number_of_industries);
mape = zeros(number_of_random_steps_per_sector,number_of_industries); 

for k = 1:number_of_sectors
    for j = 1:number_of_industries
    difference(:,j) = abs(output_multiplier_Random_Simulation(k).multiplier(:,j) - true_output_multiplier.multiplier(1,j));
    mape(:,j) = difference(:,j) ./ ((abs(true_output_multiplier.multiplier(1,j)) + abs(output_multiplier_Random_Simulation(k).multiplier(:,j)))/2);
    mape_sum(1,j) = sum(mape(:,j));
    end
    smape_output_multiplier_RandomSimulation(k).steps = (mape_sum/number_of_random_steps_per_sector) * 100;  
end

% Combination of the multiple single-industry perturbation (all at once):
difference = zeros(number_of_random_steps_per_sector, number_of_industries);
mape = zeros(number_of_random_steps_per_sector,number_of_industries);
for j = 1:number_of_industries
    difference(:,j) = abs(output_multiplier_Combined_Random_Simulation.multiplier(:,j) - true_output_multiplier.multiplier(1,j));
    mape(:,j) = difference(:,j) ./ ((abs(true_output_multiplier.multiplier(1,j)) + abs(output_multiplier_Combined_Random_Simulation.multiplier(:,j)))/2);
    mape_sum(1,j) = sum(mape(:,j));
end
smape_output_multiplier_CombinedRandomSimulation = (mape_sum/number_of_permutations) * 100; 

%% Store the results into a .mat file
save ('smape_multiplierIL', "smape_output_multiplier_Permutation", "smape_output_multiplier_RandomSimulation", "smape_output_multiplier_CombinedRandomSimulation" )


%% Plots MAPE Multiplier 

bar(smape_output_multiplier_CombinedRandomSimulation);
xlabel('Industries','FontSize', 12);                                        
ylabel('Symmetric MAPE', 'FontSize', 12);
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\smape_output_multiplier_CombinedRandomSimulationIL.png','Resolution',300)

x = 1:1:67;
y = [smape_output_multiplier_RandomSimulation(6).steps; smape_output_multiplier_RandomSimulation(15).steps; smape_output_multiplier_RandomSimulation(16).steps];
bar(x,y,1)
xlabel('Industries', 'FontSize', 12);
ylabel('Symmetric MAPE', 'FontSize', 12);
lgd = legend({' 6 - Mineral and Metal products',' 15 - Finance, insurance, real estate, rental, and leasing', ' 16 - Professional and business services',},'Location','southoutside', 'FontSize', 10);
title(lgd,'Perturbed Industry:', 'FontSize', 10);
figure = gca; % command for the export function to work
exportgraphics(figure,'mapeIL\smape_output_multiplier_RandomSimulationIL.png','Resolution',300)

