function S = aggF(r)
% This function is used to produce an aggregation matrix S according to 
% the row aggregation scheme r 
% r is an aggregation vector like r = [1 1 2 2 3 3 ... n n] 
% 
% Input Variables:
% r: the row aggregation scheme.
% 
% Output Variables:
% S: the aggregation matrix given by the aggregation scheme r.
% (S is stored as a sparse matrix)
lr=length(r);
S=sparse(max(r),lr);
for i=1:lr
S(r(i),i)=1;
end


