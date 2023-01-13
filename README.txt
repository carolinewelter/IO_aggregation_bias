simBase.mat - original database used as input for the simulations in output.

Sequence of operations:
01: fab.m - script file that generates the First Order Aggregation Bias results and the Output simulations results
02: detail_multipliers.m - 
03: odds_ratio.m
04: tstats.m
05: smapes.m
06: runStats.m

DATABASES:
fabBase.mat - store FAB results from fab.m
gsimBase.mat - store output simulation results from fab.m
odds_ratio.mat - store results from odds_ratio.m
tstats.mat - store results from tstats.m
smapes.mat - store results from smapes.m
allStats.mat - store results from runStats.m 

FUNCTIONS:
aggF.m - Aggregation scheme function
getOutputSimulationResults.m - Output simulation function
getRegionalA.m - Input-Output Regionalization funcion
obfpval - Odds Ratio function

