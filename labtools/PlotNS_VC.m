function PlotNS_VC(varargin)
%Plot voltage clamp responses to natural sound stimuli (speech, etc.)
%usage: PlotNS_VC(expdate, session, filename)
%PlotNS_VC(expdate, session, filename, [xlimits], [ylimits], [Vout])
%note: [] indicates optional arguments

Vout=[];
xlimits=[];
ylimits=[];
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    Vout=varargin{6};
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
username=whoami;

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
      ProcessNS_VC(expdate, session, filenum)
        godatadir(expdate, session, filenum)
        load(outfilename);
    
    try godatadirbak(expdate, session, filenum)
        load(outfilename);
    catch
        ProcessNS_VC(expdate, session, filenum)
        godatadir(expdate, session, filenum)
        load(outfilename);
    end
end

if ~isfield(out,'potentials')
    ProcessNS_VC(expdate, session, filenum, Vout)
    load(outfilename);
end
%extract variables from outfile
M1=out.M1; %matrix of Vm traces, trial-by-trial
mM1=out.mM1; %matrix of mean Vm traces across trials
dur=out.dur;
isi=out.isi;
nreps=out.nreps;
numepochs=out.numepochs;
mM1stim=out.mM1stim;
M1stim=out.M1stim;
samprate=out.samprate;
sequences=out.sequences;
potentials=out.potentials;
numpotentials=length(potentials);
scaledtrace=out.scaledtrace;
lostat=out.lostat(2);

%plot entire trace and lostat to check for recording quality and stability,
%edited by ira 09-25-2013
figure; hold on
k1=1:lostat;
k2=1:length(scaledtrace);
scaledtracefixed=scaledtrace(k1);
if lostat~=length(scaledtrace);
plot(decimate(scaledtrace,20), 'r')
plot(decimate(scaledtracefixed,20),'b')
legend('lost trace due to poor quality','remaining trace')
else
    plot(decimate(scaledtrace, 20))
legend('membrane potential trace')
end
title(sprintf('entire trace for %s-%s-%s', expdate, session, filenum));

%plot series pulse
figure
plot(squeeze(mean(mean(out.Rs_pulses))))
yl=ylim;
text(100, yl(1)+.8*diff(ylim), sprintf('Rs: %.1f\nRt: %.1f\nRin: %.1f', median(median(out.Rs)),median(median(out.Rt)),median(median(out.Rin)) ))

%find optimal axis limits

if isempty(ylimits)
    ylimits=[0 0];
    for eindex=1:numepochs
        for pindex=1:numpotentials
            trace1=squeeze(mM1(eindex, pindex, :));
            trace1=trace1-mean(trace1(1:100));
            if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
        end
    end
end
if isempty(xlimits)
    xlimits=out.xlimits;
end


%plot the mean Isyn traces
figure
p=0;
c='bgrycm';
subplot1(numepochs, 1)
%add 10% ylim space for stimulus
ylimits(1)=ylimits(1)-.1*diff(ylimits);
for eindex=1:numepochs
    p=p+1;
    subplot1( p)
    for pindex=1:numpotentials
        trace1=squeeze(mM1(eindex, pindex, :));
        trace1=trace1-mean(trace1(1:100));
        stimtrace=squeeze(mM1stim(eindex, pindex,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
        
        t=1:length(trace1);
        t=t/(.001*samprate);
        t=t+out.xlimits(1);
        plot(t, trace1, c(pindex), t, stimtrace, 'm');
        ylim(ylimits)
        xlim(xlimits)
        axis off
    end
end
set(gca, 'xticklabel', get(gca, 'xtick')/1000)
xlabel('time, s')

subplot1(1)
if length(unique(nreps))==1
    nrepsstr=sprintf('Mean of %d reps', unique(nreps));
else
    nrepsstr=sprintf('Mean of %d-%d reps', min(nreps), max(nreps));
end
h=title(sprintf('%s-%s-%s %s', expdate,session, filenum, nrepsstr));
set(h, 'HorizontalAlignment', 'left')


%label epochs
p=0;
for eindex=1:numepochs
    p=p+1;
    subplot1(p)
    text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('epoch%d', eindex))
end
subplot1(numepochs)
axis on
orient landscape

%plot all trials of Isyn response
figure
p=0;
subplot1(numepochs, 1)
%add 10% ylim space for stimulus
ylimits(1)=ylimits(1)-.1*diff(ylimits);
offset=diff(ylimits);
for eindex=1:numepochs
    p=p+1;
    stimtrace=squeeze(mM1stim(eindex, 1, :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*.5*diff(ylimits);
    stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
    t=1:length(stimtrace);
    t=t/(.001*samprate);
    t=t+out.xlimits(1);
    
    subplot1( p)
    hold on
    for pindex=1:numpotentials
        for rep=1:nreps(eindex, pindex)
            trace1=squeeze(M1(eindex, pindex, rep,:));
            trace1=trace1-mean(trace1(1:100));
            %offset=rep*range(trace1);
            offset2=rep*offset;
            plot(t, trace1+offset, c(pindex))
        end
    end
    plot( t, stimtrace, 'm');
    ylim([-offset max(nreps(:))*offset])
    xlim(xlimits)
    axis off
end
set(gca, 'xticklabel', get(gca, 'xtick')/1000)
xlabel('time, s')

subplot1(numepochs)
axis on

subplot1(1)
h=title(sprintf('%s-%s-%s all trials', expdate,session, filenum));
set(h, 'HorizontalAlignment', 'left')


%label epochs
p=0;
for eindex=1:numepochs
    p=p+1;
    subplot1(p)
    text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('epoch%d', eindex))
end
orient landscape


%plot all reps of high-rep stimuli
figure
hold on
offset=0;
start=100;
rep2=0;

%pulls useful information from cell list and adds it to the graph in a
%textbox; ira 09-23-2013
i=0;
j=0;
k=0;
cells = cell_list_ira;
    for i=1:length(cells)
    if strcmp(cells(i).expdate, expdate)& strcmp(cells(i).session, session)
expdate=cells(i).expdate;
session=cells(i).session;
filenum1=cells(i).filenum;
        for j=1:size(filenum1,1)
            depth= cells(i).depth;
            CF= cells(i).CF;
            A1= cells(i).A1;
            Stim00=cells(i).description;
        if strcmp(cells(i).filenum(j,:), filenum)== 1;
            k=j;
            StimUsed= char(Stim00(k));
        end
        end
    end
end

try
    infoTextBox={'depth=' depth 'CF (Hz)=' CF 'A1=' A1 'Stimulus=' StimUsed};
    annotation('textbox', [.8 .7 .1 .1], 'String',  infoTextBox, 'background', [1 1 1]);
end

%highrepper=mode(sequences(:)); %the most frequent set member
highrepper=1;
for rep=1:max(max(nreps))
    for eindex=1:numepochs
        seq=squeeze(sequences(eindex,pindex, rep,:));
        for sent=1:length(seq)
            if sent==1
                start=100;
                stimtrace=squeeze(M1stim(eindex,pindex, rep,  :));
                stimtrace=stimtrace(-xlimits(1)*samprate*.001+1:end);
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                stimtrace=.025*diff(ylimits)*stimtrace;
            end
            
            stop=start+3000;
            regionms=start:stop;
            startsamp=round(start*.001*samprate+1);
            stopsamp=round(stop*.001*samprate);
            %             fprintf('\n%d-%d', start, stop)
            %             fprintf('\t%d %d %d %d ', sent, seq(sent), eindex, rep)
            %
            start=stop+2*out.isi;
            if seq(sent)==highrepper
                %             if seq(sent)~=highrepper
                offset=offset+.05*diff(ylimits);
                stimseg=stimtrace(startsamp:stopsamp+1000);
                t=1:length(stimseg);
                t=1000*t/samprate;
                %                     p=plot(t, stimseg+offset,'m');
                for pindex=1:numpotentials
                    
                    trace1=squeeze(M1(eindex, pindex, rep,startsamp:stopsamp+1000));
                    %sum(trace1)
                    %if sum(trace1)~=0
                    trace1=trace1-mean(trace1(1:100));
                    plot( t, trace1+offset+.1*diff(ylimits), c(pindex))
                    rep2=rep2+1;
                    M2(pindex, rep2,:)=trace1;
                    %end
                end
            end
        end
    end
end
for pindex=1:numpotentials
    plot(t, stimseg-.1*diff(ylimits), 'm', t, squeeze(mean(M2(pindex, :,:), 2)),  c(pindex), 'linewidth', 2)
end

xlabel('time, ms')
title(sprintf('%s-%s-%s, one 3s sentence segment, %d reps',expdate,session, filenum, sum(squeeze(sequences(:)==highrepper))));

orient portrait


