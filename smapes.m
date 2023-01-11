
runningIndependently = true;

if(runningIndependently)
    clear variables
    load fabBaseIL.mat;
    load multipliersIL.mat
    number_of_sectors = size(CombinedFABRandomSimulation,1);
    number_of_industries = size(true_output_multiplier.multiplier,2);
    number_of_random_steps_per_sector = size(CombinedFABRandomSimulation,2);
    parents = [1 2 5 6 7 9 12 13 14 15 16 17 18 20];
end

%% Multiplier SMAPE -- all parents at once

smapeCombinedMultipliers = zeros(number_of_industries,1);
RMSECombinedMultipliers = zeros(number_of_industries,1);
RMSPECombinedMultipliers = zeros(number_of_industries,1);
for j = 1:number_of_industries
    f = output_multiplier_Combined_Random_Simulation.multiplier(:,j)-1;
    y = true_output_multiplier.multiplier(1,j)-1;
    smapeCombinedMultipliers(j) = 100 * 2.0 * mean(abs(y-f)./(abs(y)+abs(f)));
    RMSECombinedMultipliers(j) = sqrt(mean((y - f).^2));
    RMSPECombinedMultipliers(j) = 100 * sqrt( mean(  ((y - f) / y).^2 ));
end

%% Multiplier SMAPE -- one parents at a time

smapeMultipliers = zeros(number_of_sectors,number_of_industries);
RMSEMultipliers = zeros(number_of_sectors,number_of_industries);
RMSPEMultipliers = zeros(number_of_sectors,number_of_industries);
for k = parents
    for j = 1:number_of_industries
        f = output_multiplier_Random_Simulation(k).multiplier(:,j)-1;
        y = true_output_multiplier.multiplier(1,j)-1;
        smapeMultipliers(k,j) = 100*2.0*mean(abs(y-f)./(abs(y)+abs(f)));
        RMSEMultipliers(k,j) = sqrt(mean((y - f).^2));
        RMSPEMultipliers(k,j) = 100 * sqrt( mean(  ((y - f) / y).^2 ));
                                   
    end
end

%% FAB

%% FAB Smape -- All parents at once

smapeCombinedFAB = zeros(number_of_sectors,1); 
RMSECombinedFAB = zeros(number_of_sectors,1);
RMSPECombinedFAB = zeros(number_of_sectors,1);
for j = 1:number_of_sectors
    f = CombinedFABRandomSimulation(j,:);
    y = benchmark_FAB(j,1);
    smapeCombinedFAB(j) = 100 * 2.0 * mean(abs(y-f)./(abs(y)+abs(f)));
    RMSECombinedFAB(j) = sqrt(mean((y - f).^2));
    RMSPECombinedFAB(j) = 100 * sqrt( mean(  ((y - f) / y).^2 ));
end

%% FAB Smape -- one parent at a time

smapeFAB = zeros(number_of_sectors,number_of_industries);
RMSEFAB = zeros(number_of_sectors,number_of_industries);
RMSPEFAB = zeros(number_of_sectors,number_of_industries);
for k = parents
    for j = 1:number_of_sectors
        f = FABRandomSimulation(k).steps(j,:);
        y = benchmark_FAB(j,1);
        smapeFAB(k,j) = 100 * 2.0 * mean(abs(y-f)./(abs(y) + abs(f)));
        RMSEFAB(k,j) = sqrt(mean((y - f).^2));
        RMSPEFAB(k,j) = 100 * sqrt( mean(  ((y - f) / y).^2 ));

    end
end
%%

save('smapes', 'smapeFAB',"smapeCombinedFAB",...
    "smapeMultipliers","smapeCombinedMultipliers")

save('RMSEs',"RMSEFAB","RMSECombinedFAB","RMSPECombinedFAB",...
    "RMSEMultipliers",...
    "RMSECombinedMultipliers","RMSPECombinedMultipliers")
