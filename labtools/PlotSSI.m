function [ISSI, mM1]=PlotSSI(expdate, session, filename)
%calculates and plots stimulus-specific information
%for each amplitude separately
%(treats each amp as a separate iso-intensity tuning curve)
%based on Butts and Goldman 2006
%
%usage:
%PlotSSI(expdate, session, filename)
%
%looks for an outfile generated (I think) by PlotTC_spikes

if nargin==0 fprintf('\nno input\n'); return; end

outfile=sprintf('out%s-%s-%s', expdate, session, filename);
fprintf('\nloading... ')
godatadir(expdate, session, filename);
load(outfile);
numfreqs=length(out.freqs);
numamps=length(out.amps);
freqs1=out.freqs;
amps=out.amps;
M1=out.M1;
mM1=out.mM1;
sM1=out.sM1;
fprintf('done\n')
fprintf('\nanalyzing... ')

if round(freqs1(end))==80000 %strip top 3 freqs due to harmonic distortion in Tannoy
    numfreqs=numfreqs-3;
    freqs1=freqs1(1:numfreqs);
    M1=M1(1:numfreqs,:,:,:);
    mM1=mM1(1:numfreqs,:);
    sM1=sM1(1:numfreqs,:);
end

fig=figure;
ylimits1=[0 0];
ylimits2=[0 0];
for aindex=1:numamps; %choose  a single amplitude
    
    minnreps=min(out.nreps(:,aindex));
    nrepsa=squeeze(out.nreps(:,aindex));
    
    Ma=squeeze(M1(:,aindex,:,:));
    [iSSI, isp]=Compute_SSI_bias(Ma');
    
    Bs=bootstrp(10, @Compute_SSI, Ma');
    
    %     Plot SSI
    ylimits1=[min(min(min(mM1)), ylimits1(1)), max(max(max(mM1)), ylimits1(2))];
    ylimits2=[min(min(iSSI), ylimits2(1)), max(max(iSSI), ylimits2(2))];
    
    figure(fig)
    %    subplot(numamps, 1, numamps-aindex+1)
    subplot(ceil(numamps/2), 2, numamps-aindex+1)
    %     errorbar(1:length(freqs1), mM1(:, aindex), sM1(:, aindex))
    [AX,H1,H2]= plotyy(1:length(freqs1), mM1(:, aindex), 1:length(freqs1), [mean(Bs); mean(Bs)+std(Bs); mean(Bs)-std(Bs)]);
    hold all
    
    set([H2], 'color', 'r')
    set(AX(2), 'ycolor', 'r')
    xlim(AX(1),[1 numfreqs])
    xlim(AX(2),[1 numfreqs])
    ylabel(AX(1), 'spike count')
    ylabel(AX(2), 'SSI, bits')
    yl=ylim;
    set(H2([2 3]), 'linestyle', ':')
    set(H2(1), 'linew', 2)
    
    MI= sprintf('MI: %.2f bits', mean(isp));
    if aindex==numamps
%         title(sprintf('%d dB \n%s-%s-%s \nch 1,  %d evoked spikes, %d reps %s', amps(aindex), expdate,session, filename, sum(sum(sum(sum(M1)))), minnreps, MI))
        title(sprintf('%d dB', round(amps(aindex))))
    else
%         title(sprintf('%d dB          %s', round(amps(aindex)), MI))
        title(sprintf('%d dB', round(amps(aindex))))
    end
    if aindex==1
        xlabel('frequency, kHz')
    end
    grid on
    set(AX(1), 'xticklabel', round(freqs1(get(gca, 'xtick'))/1000))
    set(AX(2), 'xticklabel', '')
    %     store axis handles
    AXX(aindex,:)=AX;
    ISSI(:, aindex)=iSSI; %accumulate into a big matrix
end %for aindex

ylimits1(1)=floor(ylimits1(1));
ylimits1(2)=ceil(ylimits1(2));
ylimits2(1)=floor(ylimits2(1));
ylimits2(2)=ceil(ylimits2(2));

for aindex=1:numamps; %choose  a single amplitude
    ylim(AXX(aindex, 1),ylimits1);
    set(AXX(aindex, 1), 'ytick', [ylimits1(1), mean(ylimits1), ylimits1(2)])
%     ylim(AXX(aindex, 2),ylimits2);
%     set(AXX(aindex, 2), 'ytick', sort([0  ylimits2(2)/2, ylimits2(2)]))
end
set(gcf, 'pos', [1116          82         554         868])
subplot1(1)
% suptitle(sprintf('%s-%s-%s', expdate,session, filename))
% figure

% subplot(211)
% imagesc(mM1')
% set(gca, 'ydir', 'normal')
% cb=colorbar;
% cbl=get(cb, 'ylabel');
% set(cbl, 'string', 'mean spikecount');
% title(sprintf('%s-%s-%s ch 1,  %d evoked spikes', expdate,session, filename, sum(sum(sum(sum(M1))))))
% set(gca, 'ytick', [1:numamps], 'yticklabel', round(amps))
% set(gca, 'xticklabel', round(freqs1(get(gca, 'xtick'))/1000))
% ylabel('level, dB')
% 
% subplot(212)
% imagesc(ISSI')
% set(gca, 'ydir', 'normal')
% cb=colorbar;
% cbl=get(cb, 'ylabel');
% set(cbl, 'string', 'iSSI, bits');
% set(gca, 'ytick', [1:numamps], 'yticklabel', round(amps))
% set(gca, 'xticklabel', round(freqs1(get(gca, 'xtick'))/1000))
% ylabel('level, dB')
% xlabel('frequency, kHz')