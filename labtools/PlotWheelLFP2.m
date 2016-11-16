function PlotWheelLFP2(varargin)

%plots evoked LFP traces and wheel velocity
%
%extracts wheel velocity from a photodiode signal
%pointed at a rat running wheel
%assumes the wheel has a disk with black and white wedges
%assumes diode data is in AxopatchData2
%usage:
% PlotWheelLFP2(expdate, session, filename)
% PlotWheelLFP2(expdate, session, filename, [level])
%
%assumes photodiode stripes are 1 cm wide
%
%optional inputs
%level: plot only a single RLF level
%
%example calls:
%PlotWheelLFP2('060311', '001', '005')
%PlotWheelLFP2('060311', '001', '005', 60)

level=[];
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
    level=varargin{4};
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stripe_width=1; %cm
velocity=PlotWheelVelocity(expdate, session, filenum, stripe_width);
figure
t=1:length(velocity);t=t/1e4;
plot(t, velocity)

global pref
if isempty(pref) Prefs; end
username=pref.username;
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
datafile2=strrep(datafile, 'AxopatchData1', 'AxopatchData2');
[D E S]=gogetdata(expdate,session,filenum);
godatadir(expdate, session, filenum)
%D2=load(datafile2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function PlotRLF_timecourse_LFP(varargin)
%plots time course of responses for each tone frequency and level
%(useful for observing time course before/during/after drug application)
%usage:
%   PlotRLF_timecourse_LFP(expdate, session, filenum, [xlimits], [ylimits] [stepsize])
%     xlimits, and stepsize are optional
%     default xlimits are 0:300
%     stepsize (in minutes) is the time interval to plot each point in the time course (default: 2 minute)
%
%example call: PlotRLF_timecourse_LFP('071509', '001', '001', [0 100], [], 2)


event=E.event;
%stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;

%low-pass filter
low_pass_cutoff=200; %Hz
samprate=10000;
fprintf('\nlow-pass filtering at %.2f Hz', low_pass_cutoff);
[b,a]=butter(3, low_pass_cutoff/(samprate/2));
scaledtrace=filtfilt(b,a,scaledtrace);

clear D E S
xlimits=[-50 150];
tracelength=diff(xlimits); %in ms

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);
samprate=1e4;
%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') |strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop<=length(scaledtrace)
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                end
                amp=event(i).Param.amplitude;
                findex= find(freqs1==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=scaledtrace(region);
                T1(findex,aindex,dindex, nreps(findex, aindex, dindex))=pos/samprate; %position in seconds
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
else
    for aindex=1:numamps
        for findex=1:numfreqs
            for dindex=1:numdurs
                mM1(findex, aindex, dindex,:)=mean(M1(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
                %                 mM1stim(findex, aindex, dindex,:)=mean(M1stim(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
            end
        end
    end
end

% try to load exper structure
user=whoami;
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, user, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    timemarks=exp.timemark.param.timemarks.value;
    notes=exp.timemark.param.notes.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        if isfield(exp, 'timemark')
            timemarks=exp.timemark.param.timemarks.value;
            notes=exp.timemark.param.notes.value;
        else
            timemarks=[];
            notes=[];
            fprintf('\nno timemarks in exper structure.')
        end
    else
        timemarks=[];
        notes=[];
        fprintf('\ncould not find exper structure. Cannot plot timemarks.')
    end
end
timemarks=timemarks/60;

%find optimal axis limits
ylimits=[0 0];
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        trace1=squeeze(mM1(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
        if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot

%get numsteps
tend=max(max(max(T1)));
cmap=colormap;

for findex=1:numfreqs
    figure
    hold on
    p=0;
    for aindex=numamps:-1:1
        clear d t
        for rep=1:nreps(findex, aindex, dindex)
            %d(rep,:)=M1(findex,aindex,dindex, rep,:); % traces
            trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % trace
            d(rep)=range(trace1);
            t(rep)=T1(findex,aindex,dindex, rep);     %times
        end
        c=cmap(round(size(cmap,1)*aindex/numamps),:);
        
        plot(t, d, '.-', 'color', c)
    end
    title(sprintf('RLF LFP timecourse for %s-%s-%s', expdate, session, filenum))
    legend(int2str(amps'))
end
yl=ylim;
ylf=yl;
t_vel=1:length(velocity); t_vel=t_vel/samprate;
nmean_vel=velocity./max(abs(velocity));
nmean_vel=yl(1)+.5*range(yl)*nmean_vel;
plot(t_vel, nmean_vel, 'k', 'linewidth', 2)
grid on
xlabel('time, s')
close


% combined plot
navg=8; %number of reps to average, use 1 to plot single traces
magfactor=10*navg;

if isempty(level)
    for findex=1:numfreqs
        figure
        hold on
        p=0;
        for aindex=1:numamps
            c=cmap(round(size(cmap,1)*aindex/numamps),:);
            plot(0,0, 'color', c) %to assign legend colors colors
        end
        for aindex=1:numamps
            clear d t
            c=cmap(round(size(cmap,1)*aindex/numamps),:);
            for rep=1:navg:nreps(findex, aindex, dindex)-navg
                trace1=mean(squeeze(M1(findex,aindex,dindex, rep:rep+navg,:)), 1); % mean of navg reps
                %                 trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % single trace
                
                trace1=trace1-mean(trace1(1:10));
                trace1=trace1+aindex*.25*range(ylf);
                
                t(rep)=T1(findex,aindex,dindex, round(rep+navg/2));     %times in sec
                tt=1:length(trace1); tt=magfactor*tt/10000;
                plot(tt+t(rep), trace1, 'color', c)
            end
            
        end
        title(sprintf('RLF LFP timecourse for %s-%s-%s, avg of %d reps', expdate, session, filenum, navg))
        set(gca, 'ytick', [])
        legend(int2str(amps'))
    end
    
    yl=ylim;
    t_vel=1:length(velocity); t_vel=t_vel/samprate;
    nmean_vel=velocity./max(abs(velocity));
    nmean_vel=yl(1)+.5*range(yl)*nmean_vel;
    h=plot(t_vel, nmean_vel, 'k', 'linewidth', 2);
    uistack(h, 'bottom');
    grid on
    xlabel('time, s')
    
else %level is specified
    
    for findex=1:numfreqs
        figure
        hold on
        p=0;
        
        aindex=find(amps==level);
        clear d t
        for rep=1:navg:nreps(findex, aindex, dindex)-navg
            trace1=mean(squeeze(M1(findex,aindex,dindex, rep:rep+navg,:)), 1); % mean of 10 reps
            trace1=trace1-mean(trace1(1:10));
            t(rep)=T1(findex,aindex,dindex, rep);     %times in sec
            tt=1:length(trace1); tt=magfactor*tt/10000;
            plot(tt+t(rep), trace1)
        end
        
        
        
        title(sprintf('RLF LFP timecourse for %s-%s-%s, avg of %d reps', expdate, session, filenum, navg))
        legend(int2str(amps'))
    end
    
    yl=ylim;
    t_vel=1:length(velocity); t_vel=t_vel/samprate;
    nmean_vel=velocity./max(abs(velocity));
    nmean_vel=yl(1)+.5*range(yl)*nmean_vel;
    plot(t_vel, nmean_vel, 'k', 'linewidth', 2)
    grid on
    xlabel('time, s')
end


%sort reps into running vs. non-running, then plot each condition in
%separate TC
velocity_thresh=1; %cm/s, arbitrary threshold for "running"

nrepsr=zeros(numfreqs, numamps);
nrepsnr=nrepsr;
Mr=zeros(numfreqs, numamps, nreps(1,1,1), length(trace1));
Mnr=Mr;
for findex=1:numfreqs
    for aindex=1:numamps
        clear d t
        for rep=1:navg:nreps(findex, aindex, dindex)-navg
            trace1=squeeze(M1(findex,aindex,dindex, rep,:)); % single trace
            trace1=trace1-mean(trace1(1:10));
            t=T1(findex,aindex,dindex, rep);     %time of this rep in sec
            tsamp=round(t*samprate); %time in samples
            if velocity(tsamp)>velocity_thresh       %assign trace1 to Mr (run)
                nrepsr(findex, aindex)=nrepsr(findex, aindex)+1;
                Mr(findex, aindex, nrepsr(findex, aindex), :)=trace1;
            else                %assign trace1 to Mnr (non-run)
                
                nrepsnr(findex, aindex)=nrepsnr(findex, aindex)+1;
                Mnr(findex, aindex, nrepsnr(findex, aindex), :)=trace1;
            end
        end
        
    end
end

%plotTC
ylim_scalefactor=1;
ylnr=[min(mean(mean(Mnr))) max(mean(mean(Mnr)))];
ylr=[min(mean(min(Mr))) max(mean(max(Mr)))];
yl=ylim_scalefactor*[min([ylnr ylr]), max([ylnr ylr])];

t=1:length(trace1);t=t/10;
for findex=1:numfreqs
    figure
    subplot1(numamps, 2, 'YTickL' , 'None')
    for aindex=1:numamps
        trace1r=mean(squeeze(Mr(findex,aindex, :,:))); % mean trace
        subplot1([numamps-aindex+1 1])
        plot(t, trace1r)
        clear h
        h=get(gca,'ylim');
        repstring=sprintf('n=%d',nrepsr(aindex));
        text(25,mean(h),repstring);
        ylim(yl)
        if aindex==1
            set(gca,'xtick',[0:50:200])
            thelabels={'',0,50,100};
            set(gca,'xticklabel',thelabels)
            h=get(gca,'ylim');
            line([50 75],[h(1) h(1)],'color','m','linewidth',5)
        end
        if aindex==numamps title('Run');end
        trace1n=mean(squeeze(Mnr(findex,aindex, :,:))); % mean trace
        subplot1([numamps-aindex+1 2])
        plot(t, trace1n)
        clear h
        h=get(gca,'ylim');
        repstring=sprintf('n=%d',nrepsnr(aindex));
        text(25,mean(h),repstring)
        ylim(yl)
        if aindex==1
            set(gca,'xtick',[0:50:200])
            thelabels={'',0,50,100};
            set(gca,'xticklabel',thelabels)
            h=get(gca,'ylim');
            line([50 75],[h(1) h(1)],'color','m','linewidth',5)
        end
        if aindex==numamps title('Non-Run');end
    end
end
suptitle(sprintf('%s-%s-%s', expdate, session, filenum))
pos=get(gcf,'pos');
pos(2)=100;pos(4)=900;
set(gcf, 'pos', pos);

%can execute this from command line to adjust ylimits
f=1.5;
h=get(gcf, 'children');
for hi=h'
    yl=get(hi, 'ylim');
    ylim(hi,f*yl)
end


