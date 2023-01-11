function outputPerm = getOutputPermutationResult(varargin)

ip = inputParser;

    addParameter(ip, 'inUS', []);
    addParameter(ip, 'inReg', 'IL');
    addParameter(ip, 'newReg_g', 1);
    addParameter(ip, 'desired_trial_count', 100);

parse(ip, varargin{:});

if isempty(ip.UsingDefaults)
   disp('Using defaults: ')
   disp(ip.UsingDefaults)
end

load simBase.mat

%%

if ismember('inUS', ip.UsingDefaults) 
    inUS = US;
else
    inUS = ip.Results.inUS;
end

% Default regions in simBase include CA, KY, and IL.  Any of these can be
% used two lines below to see results from other regions.
if ismember('inReg', ip.UsingDefaults) 
    inReg = IL;   % names the default region
else
    inReg = ip.Results.inReg;
end


if ~ismember('newReg_g', ip.UsingDefaults)
    inReg(:,5)= ip.Results.newReg_g;
end

% Default permutation steps
if ismember('desired_trial_count', ip.UsingDefaults) 
    desired_trial_count = 100;   
else
    desired_trial_count = ip.Results.desired_trial_count;
end

if ~ismember('desired_trial_count', ip.UsingDefaults)
    desired_trial_count = ip.Results.desired_trial_count;
end


%% 


number_of_commodities = (size(inReg,1)); 
number_of_industries = number_of_commodities - 2; 
commodity_aggregation_scheme = aggC; 
industry_aggregation_scheme = aggC(1:number_of_industries);

true_industry_output = inReg(1:number_of_industries,5); 

%% Permutation

number_of_accepted_vectors = 0;
PermutationResult = zeros(size(true_industry_output,1),desired_trial_count+1)';
PermutationResult(1,:) = true_industry_output';

number_of_candidate_vectors = 0;

while (number_of_accepted_vectors < desired_trial_count)
    trial_industry_output = true_industry_output;

    for i = 1:max(industry_aggregation_scheme)
        sector_industry_indexes = find(industry_aggregation_scheme==i);
        industry_index_permutations = perms(sector_industry_indexes);
        index_permutation_in_use = industry_index_permutations(randi(size(industry_index_permutations,1)),:);
        trial_industry_output(industry_aggregation_scheme==i) = true_industry_output(index_permutation_in_use);
    end
    
    number_of_candidate_vectors = number_of_candidate_vectors+1;
    
    if (~ismember(trial_industry_output',PermutationResult,'rows')) % this trial is not already used
        number_of_accepted_vectors = number_of_accepted_vectors + 1;
        PermutationResult(number_of_accepted_vectors+1,:) = trial_industry_output';
    end
end

number_of_discarded_duplicates = number_of_candidate_vectors - number_of_accepted_vectors;

%%

outputPerm = PermutationResult;

end