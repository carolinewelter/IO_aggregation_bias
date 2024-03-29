%% Run all the statistics and results
% script file that combine and save all the results in one allStats.mat file.

tic

runningIndependently = false;
clear variables
load fabBase.mat;
load oddsratio.mat
load multipliers.mat
number_of_sectors = size(CombinedFABRandomSimulation,1);
number_of_industries = size(true_output_multiplier.multiplier,2);
number_of_random_steps_per_sector = size(CombinedFABRandomSimulation,2);
parents = [1 2 5 6 7 9 12 13 14 15 16 17 18];
toc

clear variables
load oddsratio.mat
load tstats.mat
load smapes.mat
load RMSEs.mat
load('fabBase.mat', 'benchmark_FAB')
load('multipliers.mat', 'true_output_multiplier')
benchmarkMultipliers = true_output_multiplier.multiplier;
clear true_output_multiplier
allFABCombinedStats = [benchmark_FAB tstat_CombinedFABRandomSimulation ...
    oddsratio_CombinedFABRandomSimulation smapeCombinedFAB RMSECombinedFAB ...
    (RMSPECombinedFAB)];
allMultiplierCombinedStats = [benchmarkMultipliers' ...
    tstat_CombinedMultipliers oddsratio_multiplier_CombinedRandomSimulation' ...
    smapeCombinedMultipliers RMSECombinedMultipliers ...
    RMSPECombinedMultipliers];

save('allStats')

toc