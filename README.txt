simBase.mat - original database used as input for the simulations. Besides Illinois (IL) data, California (CA) and Kentucky (KY) data are available 
for experimentation. For you to do that, you will need to change the IL in the scripts for CA or KY.

Sequence of operations:
01: FabAggBias.m - script file that generates the First Order Aggregation Bias (FAB) results and the Output simulations results
02: detail_multipliers.m - script file that generates the IO multipliers for the 67 industries (detail level).
03: oddsRatio.m - script file that generates the FAB and Output Multipliers Odds Ratio results.
04: tstats.m - script file that generates the FAB and Output Multipliers T-statistics results.
05: smapes.m - script file that generates the Symmetric Mean Absolute Percentage Error (SMAPE), the aRoot Mean Squared Error (RMSE) and 
the Root Mean Squared Percentage Error (RMSPE) results for both FAB and Output Multipliers.
06: runStats.m - script file that combine and save all the results in one allStats.mat file.

DATABASES:
fabBase.mat - store FAB results from FabAggBias.m
gsimBase.mat - store output simulation results from fab.m
oddsratio.mat - store results from odds_ratio.m
tstats.mat - store results from tstats.m
smapes.mat - store results from smapes.m
allStats.mat - store results from runStats.m 

FUNCTIONS:
aggF.m - Aggregation scheme function
getOutputSimulationResults.m - Output simulation function
getRegionalA.m - Input-Output Regionalization function
obfpval - Odds Ratio function

FOLDER:
original_results_IL - This folder contain the original results from the random simulation that are analysed in the 
paper "Aggregation Bias and Input-Output Regionalization. Detail or Accuracy?". When you run these public available scripts to replicate our paper, 
you will face different results because there is a random component in FabAggBias.m that most likely will change the perturbation on the regional output. 