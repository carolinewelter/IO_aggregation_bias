simBase.mat - original database used as input for the simulations in output.

Sequence of operations:
01: FabAggBias.m - script file that generates the First Order Aggregation Bias (FAB) results and the Output simulations results
02: detail_multipliers.m - script file that generates the IO multipliers for the 67 industries (detail level).
03: oddsRatio.m - script file that generates the FAB and Output Multipliers Odds Ratio results.
04: tstats.m - script file that generates the FAB and Output Multipliers T-statistics results.
05: smapes.m
06: runStats.m

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

