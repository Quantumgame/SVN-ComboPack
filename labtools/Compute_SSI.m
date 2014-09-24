function [iSSI, isp]=Compute_SSI(M1)
% usage:
%     [iSSI, isp]=Compute_SSI(M1)
%
%note: pass M1 as the transpose of the M1 generated e.g. by PlotTC_Spikes
%we transpose it back here. The reason for this wierdness is to make this
%function compatible with bootstrapping which requires repetitions be
%matrix rows rather than columns.
%
%also, this function expects only a single intensity!!!
%
%thus M1 locally is only nreps X nfreqs  (isointensity)

M1=M1';
nresponses=length(unique(M1)); %number of binned response magnitudes
responses=unique(M1);
numfreqs=size(M1, 1);
minnreps=size(M1, 2);

% entropy of stimulus ensemble
HS=0;
for f=1:numfreqs
    %p0 = 1/numfreqs
    ps=1/numfreqs;
    HS=HS+ps*log2(ps);
end
HS = -HS;

% psr : jpint prob p(s, r)
psr=zeros(numfreqs, nresponses);
for findex=1:numfreqs
    for i=1:minnreps
        r=M1(findex,i);
        rindex=find(r==responses);
        psr(findex, rindex)=psr(findex, rindex)+1;
    end
end
%normalize
psr=psr/sum(sum(psr));

% prgs : p(r|s)
for s=1:numfreqs
    for r=1:nresponses
        prgs(s, r)=length(find(M1(s, 1:minnreps)==responses(r)))/minnreps;
    end
end

% pr : p(r) prior prob of a given response
for r=1:nresponses
    pr(r)=length(find(M1==responses(r)));
end
pr=pr/sum(pr);

% ps : p(s) prior prob of a given stimulus
for s=1:numfreqs
    ps(s)=1/numfreqs;
end

% bayes rule: p(a|b)=p(b|a)*p(a)/p(b)
% psgr : conditional prob. p(s|r)
% get it from bayes rule
% p(s|r)=p(r|s)*p(s)/p(r)
for s=1:numfreqs
    for r=1:nresponses
        psgr(s, r)=prgs(s, r)*ps(s)/pr(r);
    end
end

% entropy of the stimulus ensemble conditional on the measurement r.
HSgr = zeros(size(responses));
for r=1:nresponses
    for s=1:numfreqs
        if psgr(s, r) %only try if nonzero, otherwise log(0) returns a NaN
            HSgr(r)=HSgr(r) + psgr(s, r)*log2(psgr(s, r));
        end
    end
end
HSgr=-HSgr;

% specific information
for r=1:nresponses
    isp(r)=HS- HSgr(r);
end

% stimulus-specific information (SSI)
%   iSSI(s)=sum over r (p(r|s)*isp(r)
iSSI=zeros(size(1:numfreqs));
for s=1:numfreqs
    for r=1:nresponses
        iSSI(s)=iSSI(s)+prgs(s, r)*isp(r);
    end
end