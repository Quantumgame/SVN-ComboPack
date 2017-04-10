function varargout=Plot_many_NBASRs(varargin)
%usage Plot_many_NBASRs(expdate1, session1, filenum1, expdate2, session2, filenum2, ...)
%assumes you have already run PlotNB_ASR
%mw 09.17.10
%
%optional outputs:
%[Ppeak, Parea, Psqarea, percentPPI, time]=Plot_many_NBASRs(expdate1, session1, filenum1, ...
% Ppeak = p-values of PPI based on peak startle response 
% Parea = p-values of PPI based on area under startle response
% Psqarea = p-values of PPI based on squared area under startle response
%time=timevecs of each file
%09.17.10 mw: added support for multiple expdates


if nargin==0 fprintf('\nno input');return;
elseif mod(nargin, 3)
    help Plot_many_NBASRs
    error('wrong number of input arguments.');
end

global pref
if isempty(pref) Prefs; end
username=pref.username;

%color sequence
c='kgrmby';
    figure;hold on
for i=1:(nargin)/3
    expdate=varargin{3*i-2};
    session=varargin{3*i-1};
    filenum=varargin{3*i};
    outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

    fprintf('\ntrying to load %s...', outfilename)
    try
        godatadir(expdate,session, filenum)
        load(outfilename)
    catch
        fprintf('failed to load outfile')
        return
    end

    fprintf('done\n');


%  P(i,:)=out.P;
  %  percentGPIAS(i,:)=out.percentGPIAS;
    time(i,:)=getexpertime(expdate,session, filenum);

   

    %Plot the mean of the peaks for each ppa

     numprepulseamps=out.numprepulseamps;
     prepulseamps=out.prepulseamps;
     samprate=1e4;
     nreps1=out.nreps;
%     for ppaindex=1:numprepulseamps;
%         for k=1:nreps1(ppaindex);
%             trace1=squeeze(out.M1(ppaindex, k, :));
%             peak(ppaindex, k)=(max(abs(trace1(125*samprate/1000:275*samprate/1000))));
%             %Only peaks between 125ms--275ms are used for this calculation
% 
%             h=plot(ppaindex, peak(ppaindex, k), 'o');
%             set(h, 'color', c(i));
%         end
%         m(ppaindex)=mean(peak(ppaindex, 1:nreps1(ppaindex)));
%         s(ppaindex)=(std(peak(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak(ppaindex, 1:nreps1(ppaindex))));
%         %Displays the rat's mean peak response for each pre-pulse amplitude in the MATLAB Command Window
%         %     fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
%         %     fprintf(' the mean peak response was %.1f.', (m(ppaindex)));
%     end

    %Displays the rat's mean percent Noise Burst Pre-pulse Inhibition for the Acoustic Startle...
    %...  (NBPIAS) for each gap duration in the MATLAB Command Window

    %sanity check that first ppa is -1000 (i.e. control condition)
    if prepulseamps(1)~=-1000
        error('first ppa is not 0, what is wrong?')
    end

    peak=out.peak;
    area=out.area;
    sq_area=out.sq_area;
    m=mean(peak,2);
    s=std(peak, [], 2);
    
    for p=2:numprepulseamps;
        m1=m(1);
        m2=m(p);
        [H, Ppeak(i,p-1)]=ttest( peak(1, 1:nreps1(1)), peak(p, 1:nreps1(1)), [], 'right');
        [H, Parea(i,p-1)]=ttest( area(1, 1:nreps1(1)), area(p, 1:nreps1(1)), [], 'right');
        [H, Psq_area(i,p-1)]=ttest( sq_area(1, 1:nreps1(1)), sq_area(p, 1:nreps1(1)), [], 'right');
        
         percentNBPIAS(i,p-1)=((m1-m2)/m1)*100;
%         fprintf('\n  For the pre-pulse amplitude of %ddB, the percent NBPIAS was %.1f%%,H=%d, p=%.3f)', prepulseamps(p),percentNBPIAS,  H, P);
        if H
            T=text(p+.1, 1.1*m(p), sprintf('*%.3f', Ppeak(i,p-1)));
        else
            T=text(p+.1, 1.1*m(p), sprintf('%.3f', Ppeak(i,p-1)));
        end
        set(T, 'color', c(i));
    end
    h=plot(1:numprepulseamps, m, '.-');
    set(h, 'color', c(i), 'markersize', 20);
    h=errorbar(1:numprepulseamps, m, s, 'b')
    set(h, 'color', c(i));
    set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
    title(sprintf('Average Peak Response for Each Pre-pulse Amplitude \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Amplitude (dB)')

    
end

for i=1:size(time, 1)
t(i)=etime(time(i,:), time(1,:));
end
t=t/60;%->minutes

for i=1:nargin
    if mod(i,3)==0
    h=text(.9, 1-.01*i, varargin{i}, 'units', 'normal');
    set(h, 'color', c(i/3));
    end
end
pos=get(gcf, 'pos');
pos(1)=pos(1)-pos(3);
set(gcf, 'pos', pos);



figure
plot(Ppeak, '-o')
xlabel('file number')
ylabel('p-value of NB pre-pulse inhibition (peak)')
set(gca, 'xtick', [1:(nargin)/3])
xlim( [0 1+(nargin)/3])
title(sprintf('P(NBASR) %s-%s', expdate, sprintf('%s-%s, ',varargin{:})))
for p=2:numprepulseamps
    T=text(nargin/3+.1, Ppeak(end, p-1), sprintf('%ddB',prepulseamps(p)));
end
ylim([0 1])
line(xlim, [.05 .05], 'linestyle', '--')

figure
plot(Parea, '-o')
xlabel('file number')
ylabel('p-value of NB pre-pulse inhibition (area under curve)')
set(gca, 'xtick', [1:(nargin)/3])
xlim( [0 1+(nargin)/3])
title(sprintf('P(NBASR) %s-%s', expdate, sprintf('%s-%s, ',varargin{:})))
for p=2:numprepulseamps
    T=text(nargin/3+.1, Ppeak(end, p-1), sprintf('%ddB',prepulseamps(p)));
end
ylim([0 1])
line(xlim, [.05 .05], 'linestyle', '--')
pos=get(gcf, 'pos');
pos(2)=pos(2)-pos(4);
set(gcf, 'pos', pos);

figure
plot(Psq_area, '-o')
xlabel('file number')
ylabel('p-value of NB pre-pulse inhibition (squared area under curve)')
set(gca, 'xtick', [1:(nargin)/3])
xlim( [0 1+(nargin)/3])
title(sprintf('P(NBASR) %s-%s', expdate, sprintf('%s-%s, ',varargin{:})))
for p=2:numprepulseamps
    T=text(nargin/3+.1, Ppeak(end, p-1), sprintf('%ddB',prepulseamps(p)));
end
ylim([0 1])
line(xlim, [.05 .05], 'linestyle', '--')
pos=get(gcf, 'pos');
pos(1)=pos(1)+pos(3);
pos(2)=pos(2)-pos(4);
set(gcf, 'pos', pos);


figure
plot(percentNBPIAS, '-o')
xlabel('file number')
ylabel('percent NB pre-pulse inhibition')
set(gca, 'xtick', [1:(nargin)/3])
xlim( [0 1+(nargin)/3])
title(sprintf('%% NBASR %s-%s', expdate, sprintf('%s-%s, ',varargin{:})))
pos=get(gcf, 'pos');
pos(1)=pos(1)+pos(3);
set(gcf, 'pos', pos);
for p=2:numprepulseamps
    T=text(nargin/3+.1, percentNBPIAS(end, p-1), sprintf('%ddB',prepulseamps(p)));
end

if nargout>0
    varargout{1}=Ppeak;
    varargout{2}=Parea;
    varargout{3}=Psq_area;
    varargout{4}=percentNBPIAS;
    varargout{5}=time;
end    


