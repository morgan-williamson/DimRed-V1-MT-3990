% generate semedo-style subpopulations
% INPUT: rateMats -- cell array of nCh x nTrials spike counts
%        edges    -- bin edges for the histogram used for matching
%                 -- finer histogram = better matching, fewer matches
%        maxPopSize -- the maximum number of channels to include
% OUTPUT: subpop -- the channels that should be included in each subpop
% this should work for an arbitrary number of populations, but I only
% tested it on 2 (i.e. V1 + MT).
% if the number of matchable channels is more than maxPopSize, the matching
% histogram is rescaled, and then subsampled.
% if maxPopSize is 0 or omitted, the number of matchable channels will be
% used.
function [subpop] = getRateMatchedSubpops(rateMats, edges, maxPopSize)

nBins = length(edges)-1;
nPops = length(rateMats); 

nP = zeros(nPops, nBins);

% get the rate histograms
for iPop = 1:length(rateMats)
    [nP(iPop, :), ~, binP{iPop}] = ...
        histcounts(mean(rateMats{iPop}, 2), edges);
end; clear iPop

% find the intersecting regions
matchedDist = min(nP);

% rescale to include approximately the correct number of channels;
% inclRatio = maxPopSize/sum(matchedDist);
% matchedDist = ceil(matchedDist*inclRatio); % include too many, not too few

% randomly sample cells for matching
for iPop = 1:length(rateMats)
    subpop{iPop} = []; 
    nCh = size(rateMats{iPop}, 1);
    for bin = 1:nBins
        if matchedDist(bin) > 0
            
            if nP(iPop, bin) == 1 % in this case, randsample() treats find(binP{iPop} == bin) as a number, not a population vector from which to sample, which is problematic  
                subpop{iPop} = [subpop{iPop} ...
                    find(binP{iPop} == bin)' ]; % instead of randsampling, since there is only one to sample, just take it 
            else 
                subpop{iPop} = [subpop{iPop} ...
                      randsample(find(binP{iPop} == bin),...
                                 matchedDist(bin))'];
            end 
            
        end
    end
    
    % if we included too many, cut the excess at random.
    if length(subpop{iPop}) > maxPopSize
       subpop{iPop} = randsample(subpop{iPop}, maxPopSize); 
    end
end
