function outputArg = getRegionalA(varargin)
% Purpose:  getRegionalA it receives regional and national economic data 
% and returns a regionalized IO coefficients matrix
%
% Input data in the US variable includes five (column) variables for
% the US and the same five variables for the region that is the
% focus of the regionalization. The five key variables for each place are  
%
 % Column 1: exogenously given (fixed) final demands - these are a function
 %           of column control totals that do not change from simulation to 
 %           simulation. These final demand activities include PCE,
 %           Investment, and all government sectors
 % Column 2: exports
 % Column 3: imports
 % Column 4: non-trade final demands that vary by sector as a function of 
 %           commodity output.  For our set of FD activities, 
 %           inventory adjustments are the only such activity
 % Column 5: industry output
%
%  When there are only default variables, the function will draw from
%  simBase.mat, where US is the five-variable set for the US, an data are
%  available for IL, KY, and CA.
%
%  detailed = 1 for disaggregated tables, 0 for aggregated tables
%  
%  for simulations where the estimates of regional g are varied, the
%  function call would look like this, where perturbed_g is a user-supplied 
%  variable containing the perturbed industry output values:
%
%   outputArg = getRegionalA('newReg_g', perturbed_g);
% 
%  To also explicitly name the region to be processed, the function call
%  will look like this:
%
%   newResult = getRegionalA('inReg', statevbls, 'newReg_g', perturbed_g);
%   newResult = getRegionalA('inReg', statevbls,...
%  , 'detailed',0,'newReg_g', perturbed_g);
%
%   where statevbls would be a 5-column variable with the structure of CA,
%   IL, or KY in simBase.mat, and where newResult is a user-supplied
%   variable name
%
%--------
%   Written by: Randy Jackson and finalized by Peter Jarosi
%   November 3, 2021.
%
%%
ip = inputParser;

    addParameter(ip, 'inUS', []);
    addParameter(ip, 'inReg', 'IL');
    addParameter(ip, 'detailed', 1);
    addParameter(ip, 'newReg_g', 1);
    addParameter(ip, 'ScrapColumns', 68:69);
    addParameter(ip, 'IsScrapAdjusted', true);
    
parse(ip, varargin{:});

if isempty(ip.UsingDefaults)
   disp('Using defaults: ')
   disp(ip.UsingDefaults)
end

load simBase.mat

%%
if ismember('inUS', ip.UsingDefaults) % 
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

detailed = ip.Results.detailed;


if ~ismember('newReg_g', ip.UsingDefaults)
    inReg(:,5)= ip.Results.newReg_g;
end

ScrapColumns = ip.Results.ScrapColumns;
IsScrapAdjusted = ip.Results.IsScrapAdjusted;

number_of_commodities = (size(inReg,1)); %number of commodities
number_of_industries = number_of_commodities - 2; % number of industries

if(detailed == 0) % we want an aggregated table
   
    Sc = aggF(aggC);
    Si = aggF(aggC(1:number_of_industries));
    
    inUS = Sc * inUS;
    inReg = Sc * inReg;

%     ScrapColumns = [16,17];
    
    number_of_commodities = (size(inReg,1)); 
    number_of_industries = number_of_commodities - 2;
    
    Use = Sc * Use * Si';
    Make = Si * Make * Sc';
    
end
%%
industry_output = inReg(1:number_of_industries,5);
ishares = industry_output ./ inUS(1:number_of_industries,5); % regional share of industry output
use = Use * diag(ishares);
make = diag(ishares) * Make;
q = sum(make,1)';
qUS = sum(Make,1)';

cshares = q ./ qUS; % regional share of commodity output

% The next two final demand activities vary by commodity output levels
exports = cshares .* inUS(:,2); 
FixedFD = inReg(:,1);
varFD = cshares .* inUS(:,4); 

dFD = sum(use,2) + exports + varFD + FixedFD; % regional domestic demand
DFD = sum(Use,2) + inUS(:,1) + inUS(:,4); % national domestic demand

mshares = dFD./DFD; % "expected" shares of national commodity imports

%% 
% The initial regional shares of commodity imports are a function of regional 
% demands, not regions supply (as with exports, e.g.), and mshares is the set 
% of expected values used.

imports = mshares .* inUS(:,3);

%% 
% We can now compute total regional demand and compare to total regional commodity 
% output and proceed with the Supply - Demand Pooling method.

demand = dFD + exports + imports;
supply = q;
balance = supply - demand;

%% 
% Now we add surpluses to exports and add (-) deficits to imports.

surplus = balance .* (balance > 0);
deficit = balance .* (balance <= 0);
exports = exports + surplus;
imports = imports + deficit;

%% 
% Now we estimate the cross-hauling value that will augment exports and trade

chratio = 0.2; % global default constant
ch = chratio * (0.1 * q + 0.9 .* exports);
exports = exports + ch;
imports = imports - ch;

%% 
% We now have what we need to estimate Q and D-tilde.

denom = q - exports - imports;
num = (q - exports);
num(num<0) = .0001;
denom(denom==0) = 0.001;
Q = num ./ denom;
q (q==0) = .001;
dtilde = make / diag(q) * diag(Q);

%%
% Considering Scrap
Scrap = make(:, ScrapColumns);
h = sum(Scrap, 2);
V = make;
V(:, ScrapColumns) = 0;
if all(industry_output>0, 'all') % In order to prevent singularity
    p = h ./ industry_output; % Scrap percentages
else
    p = pinv(diag(industry_output)) * h; % In the case of singularity use pseudo inverse
end
I_i = eye(size(industry_output, 1)); % Identity matrix, industry by industry size
% I_c = eye(size(q, 1)); % Identity matrix, commodity by commodity size
% D is the transformation matrix from commodity space to industry space (not considering scrap)
q(q==0)= 0.001;
d = make / diag(q);
% W is the transformation matrix from commodity space to industry space (considering scrap)
w = (I_i - diag(p)) \ V / diag(q);
wtilde = w * diag(Q);

%% 
% For purposes of computing the aggregation bias measure, we need the industry 
% x industry coefficients matrix.

industry_output(industry_output==0) = 0.1;
b = use / diag(industry_output);
if IsScrapAdjusted
    a = wtilde * b;
else    
    a = dtilde * b;
end
%%
% Computing the final demand
if IsScrapAdjusted
    f = wtilde * (FixedFD + varFD) + w * exports;
else    
    f = dtilde * (FixedFD + varFD) + d * exports;
end
%%
% Computing output multipliers = total backward linkage
L = inv(eye(number_of_industries) - a);
output_multiplier = sum(L,1);

backward_linkage = output_multiplier; 
backward_linkage_normalized = zeros(1,number_of_industries);
for i = 1:number_of_industries
backward_linkage_normalized(:,i) = backward_linkage(:,i) / (sum(backward_linkage)/number_of_industries);
end

% Total Forward linkage
forward_linkage = sum(L,2);

forward_linkage_normalized = zeros(number_of_industries,1);
for i = 1:number_of_industries
forward_linkage_normalized(i,:) = forward_linkage(i,:) / (sum(forward_linkage)/number_of_industries);
end


%%
outputArg = struct();
outputArg.a = a;
outputArg.f = f;
outputArg.m = output_multiplier;
outputArg.back = backward_linkage;
outputArg.backward_normalized = backward_linkage_normalized;
outputArg.forward = forward_linkage;
outputArg.forward_normalized = forward_linkage_normalized;

end
