function  BigTable = generatetables(T)
% T = struct2table(summary_decfab)

% Inputs:
% T = Table in MATLAB Table format
% Outputs:
% BigTable = Table with structured Data.
for i = 1:size(T,1)
    for j = 1:size(T.steps{1,1},1)
        
        mean_t(i,j) = mean(T.steps{i,:}(j,:));
        std_t(i,j) = std(T.steps{i,:}(j,:));
        min_t(i,j) = min(T.steps{i,:}(j,:));
        max_t(i,j) = max(T.steps{i,:}(j,:));
    end
end
% This line puts together in table format all calculations above
BigTable = table(mean_t,std_t,min_t,max_t);
% This line puts the headers in fancy format
BigTable.Properties.VariableNames = {'Mean', 'SD', 'Minimum', ...
    'Maximum'};

end
