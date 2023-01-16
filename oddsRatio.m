% Odds ratio results

%Inputs:
    %mcs: a MC sample - this is the monte carlo draws: FAB perturbations
    %v: degrees of freedom (n-k): 0
    %h0: value under the null hypothesis : benchmark_FAB(k,1)
    %form: leave blank for T-distribution, for kernal density enter 1
tic
clear;
clc;
load fabBase.mat;
load multipliers.mat;
number_of_sectors = size(CombinedFABRandomSimulation,1);
number_of_industries = size(true_output_multiplier.multiplier,2);
number_of_random_steps_per_sector = size(CombinedFABRandomSimulation,2);
parents = [1 2 5 6 7 9 12 13 14 15 16 17 18 20];

%% Aggregation Bias Odds ratio

% all parents at once

oddsratio_CombinedFABRandomSimulation = zeros(number_of_sectors,2);
for k = 1:number_of_sectors
   [odds,bpval] = obfpval(CombinedFABRandomSimulation(k,:),0,benchmark_FAB(k,1),1); 
   oddsratio_CombinedFABRandomSimulation(k,:) = [odds,bpval];   
end

% one parent at a time
oddsratio_FABRandomSimulation = struct([]);
for k = parents
    oddsratio_random_sim = zeros(number_of_sectors,2);
    for j = 1:number_of_sectors
    [odds,bpval] = obfpval(FABRandomSimulation(j).steps(k,:),0,benchmark_FAB(k,1),1); 
    oddsratio_random_sim(j,:) = [odds,bpval];  
    end
    oddsratio_FABRandomSimulation(k).steps = oddsratio_random_sim; 
end
% oddsratio_FABRandomSimulation(19).steps = [];
% oddsratio_FABRandomSimulation(20).steps = [];

%% Output Multipliers Odds ratio

% all at once
oddsratio_multiplier_CombinedRandomSimulation = zeros(2,number_of_industries);
interpretation_multiplier_CombinedRandomSimulation = zeros(1,number_of_industries);
for i = 1:number_of_industries
   [odds,bpval] = obfpval(output_multiplier_Combined_Random_Simulation.multiplier(:,i),0,true_output_multiplier.multiplier(1,i),1); 
   oddsratio_multiplier_CombinedRandomSimulation(:,i) = [odds,bpval];
        if (oddsratio_multiplier_CombinedRandomSimulation(2,i)) < 0.05
            interpretation_multiplier_CombinedRandomSimulation(1,i) = 1;
        else
            interpretation_multiplier_CombinedRandomSimulation(1,i) = 0;
        end
end

% each at a time
oddsratio_multiplier_RandomSimulation = struct('oddsratio',{}, 'interpretation', {});
%interpretation = zeros(1,number_of_industries);
for k = parents
    interpretation = zeros(1,number_of_industries);
    oddsratio_multiplier = zeros(2,number_of_industries);
    for i = 1:number_of_industries
    [odds,bpval] = obfpval(output_multiplier_Random_Simulation(k).multiplier(:,i),0,true_output_multiplier.multiplier(1,i),1);
    oddsratio_multiplier(:,i) = [odds,bpval];
        if (oddsratio_multiplier(2,i)) < 0.05
            interpretation(1,i) = 1;
        else
            interpretation(1,i) = 0;
        end
    end
    oddsratio_multiplier_RandomSimulation(k).oddsratio = oddsratio_multiplier;
    oddsratio_multiplier_RandomSimulation(k).interpretation = interpretation;
end
%     oddsratio_multiplier_RandomSimulation(19).oddsratio = [];
%     oddsratio_multiplier_RandomSimulation(20).oddsratio = [];
%     oddsratio_multiplier_RandomSimulation(19).interpretation = 0;
%     oddsratio_multiplier_RandomSimulation(20).interpretation = 0;

%% Collect FAB odds ratios for one parent at a time
FABOddsRatios = zeros(number_of_sectors,number_of_sectors);
for i = parents 
    FABOddsRatios(i,:) = ...
        oddsratio_FABRandomSimulation(i).steps(:,1);
end


%% Collect Multiplier odds ratios for one parent at a time

multiplierOddsRatios = zeros(number_of_sectors,number_of_industries);
for i = parents 
    multiplierOddsRatios(i,:) = ...
        oddsratio_multiplier_RandomSimulation(i).oddsratio(1,:);
end


%%
save('oddsratio', "oddsratio_multiplier_RandomSimulation", ...
    "oddsratio_multiplier_CombinedRandomSimulation", ...
    "interpretation_multiplier_CombinedRandomSimulation",...
    "oddsratio_FABRandomSimulation", ...
    "oddsratio_CombinedFABRandomSimulation","FABOddsRatios",...
    "multiplierOddsRatios", "parents")
toc