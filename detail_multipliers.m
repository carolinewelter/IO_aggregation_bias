%%  Output multiplier Type I at the Disaggregated Level 

% Output multiplier is equal to the total backward linkage because it is
% the sum of columns in L

tic
clc;
clear variables;
load simBase.mat;
load gsimBaseIL;

industry_output = IL(1:69,5);   % Illinois
number_of_sectors = size(RandomSimulationResults,2);
number_of_industries = size(industry_output,1) - 2;
number_of_random_steps_per_sector = size(CombinedRandomSimulationResults,2);

%% Benchmark Output Multipliers

true_output_multiplier = struct('multiplier',{}, 'back_link', {}, 'back_link_norm', {}, 'for_link', {}, 'for_link_norm', {} );
outputArg = getRegionalA('inReg',IL);                                                                     
true_output_multiplier(1).multiplier = outputArg.m;
true_output_multiplier(1).back_link = outputArg.back;
true_output_multiplier(1).back_link_norm = outputArg.backward_normalized;
true_output_multiplier(1).for_link = outputArg.forward;
true_output_multiplier(1).for_link_norm = outputArg.forward_normalized;

key_industries = zeros(number_of_industries,1);
for i = 1:number_of_industries
if (true_output_multiplier(1).back_link_norm(1,i) > 1)
if (true_output_multiplier(1).for_link_norm (i,1) > 1 )
 key_industries(i,1) = 1; % key industry == 1
else
 key_industries(i,1) = 0; 
end
end
end

%% Random Simulation Multipliers

% for each sector at a time
output_multiplier_Random_Simulation = struct('multiplier',{}, 'back_link', {}, 'back_link_norm', {}, 'for_link', {}, 'for_link_norm', {} );
simulated_output_multiplier = zeros(number_of_random_steps_per_sector,number_of_industries);
simulated_backward_linkage = zeros(number_of_random_steps_per_sector,number_of_industries);
simulated_backward_linkage_normalized = zeros(number_of_random_steps_per_sector,number_of_industries);
simulated_forward_linkage = zeros(number_of_industries, number_of_random_steps_per_sector);
simulated_forward_linkage_normalized = zeros(number_of_industries, number_of_random_steps_per_sector);


for k = 1:number_of_sectors 

    for j = 1:number_of_random_steps_per_sector
        simulated_output = [RandomSimulationResults(k).steps(:,j);0;0];                   

        outputArg = getRegionalA('inReg',IL,'newReg_g',simulated_output); 
        simulated_output_multiplier(j,:) = outputArg.m;
        simulated_backward_linkage(j,:) = outputArg.back;
        simulated_backward_linkage_normalized(j,:) = outputArg.backward_normalized;
        simulated_forward_linkage(:,j) = outputArg.forward;
        simulated_forward_linkage_normalized(:,j) = outputArg.forward_normalized;
    end
    output_multiplier_Random_Simulation(k).multiplier = simulated_output_multiplier;   
    output_multiplier_Random_Simulation(k).back_link = simulated_backward_linkage;
    output_multiplier_Random_Simulation(k).back_link_norm = simulated_backward_linkage_normalized;
    output_multiplier_Random_Simulation(k).for_link = simulated_forward_linkage;
    output_multiplier_Random_Simulation(k).for_link_norm = simulated_forward_linkage_normalized;
end

% all results at once:
output_multiplier_Combined_Random_Simulation = struct('multiplier',{}, 'back_link', {}, 'back_link_norm', {}, 'for_link', {}, 'for_link_norm', {} );
sim_output_multiplier = zeros(number_of_random_steps_per_sector,number_of_industries);
sim_backward_linkage = zeros(number_of_random_steps_per_sector,number_of_industries);
sim_backward_linkage_normalized = zeros(number_of_random_steps_per_sector,number_of_industries);
sim_forward_linkage = zeros(number_of_industries, number_of_random_steps_per_sector);
sim_forward_linkage_normalized = zeros(number_of_industries, number_of_random_steps_per_sector);

for j = 1:number_of_random_steps_per_sector
    simulated_output = [CombinedRandomSimulationResults(:,j);0;0];

    outputArg = getRegionalA('inReg',IL,'newReg_g',simulated_output); 
    sim_output_multiplier(j,:) = outputArg.m;
    sim_backward_linkage(j,:) = outputArg.back;
    sim_backward_linkage_normalized(j,:) = outputArg.backward_normalized;
    sim_forward_linkage(:,j) = outputArg.forward;
    sim_forward_linkage_normalized(:,j) = outputArg.forward_normalized;
    
end  
output_multiplier_Combined_Random_Simulation(1).multiplier = sim_output_multiplier; 
output_multiplier_Combined_Random_Simulation(1).back_link = sim_backward_linkage;
output_multiplier_Combined_Random_Simulation(1).back_link_norm = sim_backward_linkage_normalized;
output_multiplier_Combined_Random_Simulation(1).for_link = sim_forward_linkage;
output_multiplier_Combined_Random_Simulation(1).for_link_norm = sim_forward_linkage_normalized;

%% Store the results into a .mat file

save ('multipliersIL', "true_output_multiplier", "key_industries", ...
    "output_multiplier_Random_Simulation", ...
    "output_multiplier_Combined_Random_Simulation");
toc
