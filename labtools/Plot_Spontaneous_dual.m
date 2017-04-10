function Plot_Spontaneous_dual(varargin)
%
% plots spontaneous activity, 2-channels
%
%usage: Plot_Spontaneous_dual(expdate, session, filename)
%Plot_Spontaneous_dual(expdate, session, filename, xlimits)
%
%xlimits are in seconds
%
%you can also (if this works) pass a matrix for xlimits
%e.g. [x1 x2; x3 x4; x5 x6]
%which creates a separate window for each row (with xlimits [x1 x2], etc)
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[]; %x limits for axis
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



[datafile1, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
datafile2=strrep(datafile1, 'AxopatchData1', 'AxopatchData2');
datafile3=strrep(datafile1, 'AxopatchData1', 'EMG');
datafile4=strrep(datafile1, 'AxopatchData1', 'EOG');



fprintf('\nload file 1: ')
try
    fprintf('\ntrying to load %s...', datafile1)
    godatadir(expdate, session, filenum)
    D1=load(datafile1);
    D2=load(datafile2);
    D3=load(datafile3);
    D4=load(datafile4);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
    fprintf('\n\nfailed. Could not find data. Will try to process data...')
    ProcessData_single(expdate, session, filenum)
    try
        fprintf('\ntrying again to load %s...', datafile1)
        godatadir(expdate, session, filenum)
        D1=load(datafile1);
        D2=load(datafile2);
        D3=load(datafile3);
        D4=load(datafile4);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('done.');
    catch
        fprintf('\n\nfailed again. Could not find data. Giving up.')

    end
end
event=E.event;
if isempty(event) fprintf('\nno tones\n');  end


scaledtrace1=D1.nativeScaling*double(D1.trace) +D1.nativeOffset;
scaledtrace2=D2.nativeScaling*double(D2.trace) +D2.nativeOffset;
EMG=D3.nativeScaling*double(D3.trace) +D3.nativeOffset;
EOG=D4.nativeScaling*double(D4.trace) +D4.nativeOffset;
scaledtrace1=detrend(scaledtrace1, 'constant');
scaledtrace2=detrend(scaledtrace2, 'constant');

if (1)
    %low-pass filter the LFP traces (optional)
    cutoff=300;
    [b,a]=butter(3, cutoff/5e3);
    scaledtrace1=filtfilt(b,a,scaledtrace1);
    scaledtrace2=filtfilt(b,a,scaledtrace2);
    fprintf('\nlow-pass filtered at %d Hz', cutoff)
else
    fprintf('\nno low-pass filtering')
end

if (0)
    %hi-pass filter the traces to highlight MUA (optional)
    cutoff=300;
    [b,a]=butter(3, cutoff/5e3, 'high');
    scaledtrace1=filtfilt(b,a,scaledtrace1);
    scaledtrace2=filtfilt(b,a,scaledtrace2);
    fprintf('\nhi-pass filtered at %d Hz', cutoff)
else
    fprintf('\nno hi-pass filtering')
end

if (1)
    %normalizing both channels (optional)
    scaledtrace1=scaledtrace1./std(10*scaledtrace1);
    scaledtrace2=scaledtrace2./std(10*scaledtrace2);
    fprintf('\nfor plotting convenience, normalizing both channels')
else
    fprintf('\nno normalization')
end


stimtrace=S.nativeScalingStim*double(S.stim);
clear D1 D2 D3 D4 E S

t=1:length(scaledtrace1);
    samprate=1e4;
    t=t/samprate;
if isempty(xlimits) xlimits=[1 max(t)];end

for n=1:size(xlimits, 1)

    if xlimits(n,1)==0;
        region=1:xlimits(n,2)*samprate;
    else
        region=xlimits(n,1)*samprate:xlimits(n,2)*samprate;
    end
    if max(region)>length(scaledtrace1)
        region=region(1):length(scaledtrace1);
    end
    if min(region)>length(scaledtrace1)
        fprintf('\nout of bounds');return
    end

    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    offset=5*std(scaledtrace1(region));
    stimtrace=stimtrace*offset/10;
    figure
    plot(t(region), scaledtrace1(region), 'b',t(region),...
        scaledtrace2(region) + offset,'r',  ...
        t(region),.1*EMG(region) + 2*offset,'g',t(region),.1*EOG(region) + 3*offset,'c', ...
        t(region), stimtrace(region)-offset, 'm');
    xlim(xlimits(n,:))
    h=title(sprintf('%s-%s-%s', expdate,session, filenum));
    ylabel('mV')
    xlabel('time, s')
    legend('aud', 'vis', 'EMG', 'EOG', 'stim');
    set(gcf, 'pos', [ 22         678        1561         420])


    fprintf('\ndone')

    tic
if(0)    %locate  regions of EMG/EOG activity
    nstd=5;
    win=1e4; %1 s
    emgth=nstd*std(EMG);
    eogth=nstd*std(EOG);

   a1=(abs(EMG)>emgth)'; %active region in EMG
    a2=(abs(EOG)>eogth)'; %active region in EOG
    a=or(a1, a2); %active in either one
    da=diff(a);
    Jstop=find(da==-1);
    Jstart=find(da==1);
%     a(Jstart-win):a(Jstop+win)=1;
        % still working right here   
    
%         old way:
        a1=find(abs(EMG)>emgth)'; %active region in EMG
    a2=find(abs(EOG)>eogth)'; %active region in EOG
    a=union(a1, a2); %active in either one
    b=zeros(size(EOG)); %expand active region by +- win (1 sec?)
    for k=a
        b(k-win:k+win)=1;
        k=k+win;
    end
    c=find(b); %b is same size as EOG, ones where active and zeroes where quiet. c is the active indices
    hold on
    yl=ylim;
    plot(t(region), yl(1)+.9*diff(yl)*b(region), 'k')

    %plot(t, EOG, 'g', t(c), EOG(c), 'm.', t(a), EOG(a), 'r.')

    % L=line(xlim, (eogth)*[1 1]);
    % set(L, 'color', 'k')
toc
end
end
