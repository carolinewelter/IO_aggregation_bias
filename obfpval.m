function [odds,bpval] = obfpval(mcs,v,h0,form)

%This function creates posterior odds and Bayesian p-values using Mills (2010) 
%Inputs:
    %mcs: a MC sample
    %v: degrees of freedom (n-k)
    %h0: value under the null hypothesis
    %form: leave blank for T-distribution, for kernal density enter 1

if nargin == 3    
    that = abs(mean(mcs) - h0)/std(mcs);
    odds = 1/(1+(that^2)/v)^(-(v+1)/2);
elseif nargin == 4 && form == 1
    [f, xi] = ksdensity(mcs,'npoints',1000); %Calculating Density
    if h0<min(xi) || h0>max(xi) 
        denom = min(f);
    else
        tmp = abs(xi-h0);
        [idx idx] = min(tmp);
        denom = f(idx);
    end
    num = max(f);
    odds = num/denom;
end

smcs = sort(mcs);
p = 0;
for i = 1:length(smcs)
    if smcs(i) <= h0
        p = p + 1;
    end
end
if p == 0
    bpval = 0.0001;
elseif p == length(smcs)
    bpval = 0.0001;
else 
    bpval = 2*p/length(smcs);
end

if bpval >= 1.0
    bpval = 2*(1.0-bpval/2);
end

end