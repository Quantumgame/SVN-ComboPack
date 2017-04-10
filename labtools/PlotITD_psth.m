function PlotITD_psth(expdate1, session1, filenum1, varargin)
% extracts spikes and plots spike rasters with a single psth tuning curve
%
% usage: PlotITD_psth('expdate', 'session', 'filenum', [thresh], [xlimits], [ylimits], [binwidth])
% (thresh, xlimits, ylimits, binwidth are optional)
%
% defaults: thresh=7sd, binwidth=5ms, axes autoscaled
% thresh is in number of standard deviations
% to use an absolute threshold (in mV) pass [-1 mV] as the thresh
% argument, where mV is the desired threshold
% modified from PlotTC_psth by mak 29dec2010

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref)
     Prefs;
end
username=pref.username;

monitor=1; % monitor on=1, off=0
fs=10; % font size for figure

if nargin==0
     fprintf('\nno input');
     return;
elseif nargin==3
     nstd=7;
     ylimits=-1;
     durs=getdurs(expdate1, session1, filenum1);
     dur=max(durs);
     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
     binwidth=5;
elseif nargin==4
     nstd=varargin{1};
     if isempty(nstd) nstd=7;end
     ylimits=-1;
     durs=getdurs(expdate1, session1, filenum1);
     dur=max(durs);
     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
     binwidth=5;
elseif nargin==5
     nstd=varargin{1};
     if isempty(nstd) nstd=7;end
     xlimits=varargin{2};
     if isempty(xlimits)
          durs=getdurs(expdate1, session1, filenum1);
          dur=max(durs);
          xlimits=[-.5*dur 1.5*dur]; %x limits for axis
     end
     ylimits=-1;
     binwidth=5;
elseif nargin==6
     nstd=varargin{1};
     if isempty(nstd) nstd=7;end
     xlimits=varargin{2};
     if isempty(xlimits)
          durs=getdurs(expdate1, session1, filenum1);
          dur=max(durs);
          xlimits=[-.5*dur 1.5*dur]; %x limits for axis
     end
     ylimits=varargin{3};
     if isempty(ylimits)
          ylimits=-1;
     end
     binwidth=5;
elseif nargin==7
     nstd=varargin{1};
     if isempty(nstd) nstd=7;end
     xlimits=varargin{2};
     if isempty(xlimits)
          durs=getdurs(expdate1, session1, filenum1);
          dur=max(durs);
          xlimits=[-.5*dur 1.5*dur]; %x limits for axis
     end
     ylimits=varargin{3};
     if isempty(ylimits)
          ylimits=-1;
     end
     binwidth=varargin{4};
     if isempty(binwidth)
          binwidth=50;
     end
else
     error('wrong number of arguments');
end

tracelength=diff(xlimits); %in ms
if xlimits(1)<0
     baseline=abs(xlimits(1));
else
     baseline=0;
end

lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

[D E ~]=gogetdata(expdate1, session1, filenum1);
event1=E.event;
if isempty(event1); fprintf('\nno tones\n'); return; end
trace1=D.trace;
nativeOffset1=D.nativeOffset;
nativeScaling1=D.nativeScaling;
clear D E

fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
if lostat1==-1; lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;
fprintf('\nresponse window: %d before to %d ms after tone onset',round(baseline), round(tracelength));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high'); %this sets the high pass
filteredtrace1=filtfilt(b,a,scaledtrace1);
if length(nstd)==2 %for filtering in absolute threshold (mV)
     if nstd(1)==-1
          thresh=nstd(2);
          fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, thresh/std(filteredtrace1));
     end
else %for filtering by nstd
     thresh=nstd*std(filteredtrace1);
     fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
end
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace1)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try dspikes=[spikes(1) dspikes'];
catch
     error('No spikes detected; either decrease nstd or there are simply no spikes');
end
if (monitor)
     figure
     plot(filteredtrace1, 'b')
     hold on
     plot(thresh+zeros(size(filteredtrace1)), 'm--')
     plot(spikes, thresh*ones(size(spikes)), 'g*')
     plot(dspikes, thresh*ones(size(dspikes)), 'r*')
     L1=line(xlim, thresh*[1 1]);
     L2=line(xlim, thresh*[-1 -1]);
     set([L1 L2], 'color', 'g');
     %pause(.5)
     %close
end
if monitor
     figure
     ylim([min(filteredtrace1) max(filteredtrace1)]);
     for ds=dspikes(1:20)
          xlim([ds-100 ds+100])
          t=1:length(filteredtrace1);
          region=[ds-100:ds+100];
          if min(region)<1
               region=[1:ds+100];
          end
          hold on
          plot(t(region), filteredtrace1(region), 'b')
          plot(spikes, thresh*ones(size(spikes)), 'g*')
          plot(dspikes, thresh*ones(size(dspikes)), 'r*')
          line(xlim, thresh*[1 1])
          line(xlim, thresh*[-1 -1])
          pause(.05)
          hold off
     end
     pause(.5)
     close
end

%get itds/amps
j=0;
for i=1:length(event1)
     if strcmp(event1(i).Type, 'itdwhitenoise')
          j=j+1;
          allitds(j)=event1(i).Param.itd;
          allamps(j)=event1(i).Param.amplitude;
          alldurs(j)=event1(i).Param.duration;
     end
end
itds=unique(allitds);
amps=unique(allamps);
durs=unique(alldurs);
numitds=length(itds);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allitds)/(numitds*numamps*numdurs));
%M1=zeros(numitds, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numitds, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
     if strcmp(event1(i).Type, 'itdwhitenoise')
          if isfield(event1(i), 'soundcardtriggerPos')
               pos=event1(i).soundcardtriggerPos;
               if isempty(pos) && ~isempty(event1(i).Position_rising)
                    pos=event1(i).Position_rising;
               end
          else
               pos=event1(i).Position_rising;
          end
          
          start=(pos-baseline*1e-3*samprate);
          stop=(start+tracelength*1e-3*samprate)-1;
          region=start:stop;
          if isempty(find(region<0)) %(disallow negative start times)
               if stop>lostat1
                    fprintf('\ndiscarding trace')
               else
                    if strcmp(event1(i).Type, 'itdwhitenoise')
                         itd=event1(i).Param.itd;
                         dur=event1(i).Param.duration;
                    end
                    try
                         amp=event1(i).Param.amplitude;
                    catch
                         amp=event1(i).Param.spatialfrequency;
                    end
%                     dur=event1(i).Param.duration;
                    iindex= find(itds==itd);
                    aindex= find(amps==amp);
                    dindex= find(durs==dur);
                    nreps1(iindex, aindex, dindex)=nreps1(iindex, aindex, dindex)+1;
                    spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                    spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                    M1(iindex,aindex,dindex, nreps1(iindex, aindex, dindex)).spiketimes=spiketimes1;
               end
          end
     end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps1))), max(max(max(nreps1))))
fprintf('\ntotal num spikes: %d', length(dspikes))

%accumulate across trials
for dindex=1:numdurs
     for aindex=numamps:-1:1
          for iindex=1:numitds
               spiketimes1=[];
               for rep=1:nreps1(iindex, aindex, dindex)
                    spiketimes1=[spiketimes1 M1(iindex, aindex, dindex, rep).spiketimes];
               end
               mM1(iindex, aindex, dindex).spiketimes=spiketimes1;
          end
     end
end

numbins=tracelength/binwidth;

dindex=1;

%find axis limits
if ylimits==-1
     ylimits=[-2 -2];
     for aindex=numamps:-1:1
          for iindex=1:numitds
               spiketimes=mM1(iindex, aindex, dindex).spiketimes;
               N=hist(spiketimes, numbins);
               ylimits(2)=max(ylimits(2), max(N));
          end
     end
end

%find axis limits
if ylimits==-1
     ylimits=0;
     for aindex=numamps:-1:1
          for iindex=1:numitds
               spiketimes=mM1(iindex, aindex, dindex).spiketimes;
               X=-baseline:binwidth:tracelength; %specify bin centers
               [N, x]=hist(spiketimes, X);
               ylimits(2)=max(ylimits(2), max(N));
          end
     end
end

%plot ch1
for dindex=1:numdurs
     figure
     p=0;
     subplot1(numamps,numitds)
     for aindex=numamps:-1:1
          for iindex=1:numitds
               p=p+1;
               subplot1(p)
               hold on
               spiketimes1=mM1(iindex, aindex, dindex).spiketimes;
               %         %use this code to plot curves
               %         [n, x]=hist(spiketimes1, numbins);
               %         r=plot(x, n);
               %         set(r, 'linewidth', 2)
               %use this code to plot histograms
               X=-baseline:binwidth:tracelength; %specify bin centers
               hist(spiketimes1, X);
               line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
               line(xlimits, [0 0], 'color', 'k')
               ylim(ylimits)
               %xlim([0-baseline tracelength])
               
               xlim(xlimits)
               %xlim([-10 500])
               %axis off
               %set(gca, 'xtick', [0:20:tracelength])
               %grid on
               set(gca, 'fontsize', fs)
               
          end
     end
     
     %label amps and itds
     p=0;
     for aindex=numamps:-1:1
          for iindex=1:numitds
               p=p+1;
               subplot1(p)
               if iindex==1
                    T=text(xlimits(1)-diff(xlimits)/2, mean(ylimits), int2str(amps(aindex)));
                    set(T, 'HorizontalAlignment', 'right')
               else
                    set(gca, 'xticklabel', '')
               end
               set(gca, 'xtickmode', 'auto')
               grid on
               if aindex==1
                    %             if mod(iindex,2) %odd itd
                    %                 vpos=axmax(1);
                    %  %           else
                    vpos=ylimits(1)-diff(ylimits)/10;
                    %            end
                    text(mean(xlimits), vpos, sprintf('%.1f', itds(iindex)))
               else
                    set(gca, 'yticklabel', '')
               end
          end
     end
     subplot1(ceil(numitds/3))
     title(sprintf('%s-%s-%s dur=%d, nstd=%g, %d bins, %d total spikes',expdate1,session1, filenum1, durs(dindex), nstd,numbins,length(dspikes)))
     
end %for dindex


% Make a simple outfile for data analysis
% MAK 11Jul09, 1551Hrs
outfilename=sprintf('outPlotTC_psth:%s-%s-%s',expdate1,session1, filenum1);
out.spikes=length(dspikes);
out.nstd=nstd;
out.numbins=numbins;
out.thresh=thresh;
save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)




%check if the on response is the same size as the off response
% A=ON response (0:win)
% B=OFF response (dur-:dur+win)
if(0)
     fprintf('\n\ntest whether OFF=ON (p->0 means different, p->1 means same)\n\n')
     win=50;
     p=0;
     for dindex=[1:numdurs]
          for aindex=[1:numamps]
               for iindex=1:numitds
                    start=0;
                    stop=start+win;
                    for rep=1:nreps1(iindex,aindex,dindex)
                         A1=find(M1(iindex,aindex,dindex, rep).spiketimes>start);
                         A2=find(M1(iindex,aindex,dindex, rep).spiketimes<stop);
                         A(rep)=length(intersect(A1, A2));
                    end
                    
                    start=durs(dindex);
                    stop=start+win;
                    for rep=1:nreps1(iindex,aindex,dindex)
                         B1=find(M1(iindex,aindex,dindex, rep).spiketimes>start);
                         B2=find(M1(iindex,aindex,dindex, rep).spiketimes<stop);
                         B(rep)=length(intersect(B1, B2));
                    end
                    [h, p]=ttest2(A, B, .001);
                    sd={'same', 'different'};
                    fprintf('\n%.2f kHz: p=%.4f (%s) ', itds(iindex)/1000, p, sd{h+1})
               end
          end
     end
end

fprintf('\n\n')

