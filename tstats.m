%% T-statistics
% script file that generates the FAB and Output Multipliers T-statistics results.

runningIndependently = true;

if(runningIndependently)
    clear variables
    tic
    load fabBase.mat;
    load oddsratio.mat
    load multipliers.mat
    number_of_sectors = size(CombinedFABRandomSimulation,1);
    number_of_industries = size(true_output_multiplier.multiplier,2);
    number_of_random_steps_per_sector = size(CombinedFABRandomSimulation,2);
    parents = [1 2 5 6 7 9 12 13 14 15 16 17 18 20];
end

%% Tstats for FAB - one parent sector at a time 
tstat_FAB = struct([]);
tstat_random_sim = zeros(number_of_sectors,2);
for k = parents
    for j = parents
    [~,p,~,stats] = ttest(FABRandomSimulation(j).steps(k,:),benchmark_FAB(k,1));
    tstat_random_sim(j,:) = [p, stats.tstat];
    end
    tstat_FAB(k).steps = tstat_random_sim; 
end


%% Tstats for FAB - all parent sectors at once

tstat_CombinedFABRandomSimulation = zeros(number_of_sectors,2);
for k = 1:number_of_sectors
   [~,p,~,stats] = ttest(CombinedFABRandomSimulation(k,:),benchmark_FAB(k,1));
   tstat_CombinedFABRandomSimulation(k,:) = [p,stats.tstat];
end


%% Tstats for Multipliers - one parent sector at a time 

tstat_Multipliers = struct([]);
tstat_random_sim = zeros(number_of_sectors,2);
for k = parents
    for j = 1:number_of_industries
        [~,p,~,stats] = ...
        ttest(output_multiplier_Random_Simulation(k).multiplier(:,j),...
        true_output_multiplier.multiplier(1,j));
        tstat_random_sim(j,:) = [p, stats.tstat];
    end
    tstat_Multipliers(k).steps = tstat_random_sim; 
end

%% Tstats for Multipliers - all parent at once

tstat_CombinedMultipliers = zeros(number_of_industries,2);
for k = 1:number_of_industries
   [~,p,~,stats] = ...
       ttest(output_multiplier_Combined_Random_Simulation.multiplier(:,j), ...
       true_output_multiplier.multiplier(1,k));
   tstat_CombinedMultipliers(k,:) = [p,stats.tstat];
end

%%
save('tstats', 'tstat_random_sim', 'tstat_Multipliers', 'tstat_FAB', ...
    "tstat_CombinedMultipliers", 'tstat_CombinedFABRandomSimulation')
