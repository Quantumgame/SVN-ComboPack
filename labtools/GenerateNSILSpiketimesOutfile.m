function GenerateNSILSpiketimesOutfile(varargin)

% Generates an outfile with spiketimes, etc. for a light-interleaved 
% natural sound (NS) protocol. To plot, use the separate plotting funtion:
% PlotNSIL_rasters().
% Usage: GenerateNSILSpiketimesOutfile(expdate, session, filename, [xlimits], [ylimits], [thresh],[binwidth]) 
% Defaults to xlimits=[-1s +11s], assumes laser duration = [-.1s 10.1s].
% Pass whatever you want for ylimits & binwidth -- they're ignored for
% now...
% AKH 3/27/14

out.laserduration=[-100 10100]; % Hard coded for now.

%% Process up through dspikes

global pref
if isempty(pref) Prefs; end
username=pref.username;
   
% Defaults--
nstd=[];
binwidth=[];
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
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
elseif nargin==7
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
    binwidth=varargin{7};
    if isempty(binwidth);binwidth=5;end
elseif nargin==8
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
    binwidth=varargin{7};
    if isempty(binwidth);binwidth=5;end
else
    error('wrong number of arguments');
end

if isempty(xlimits)
    xlimits=[-1000 11000]; 
end

lostat1=[];% getlostat(expdate, session, filenum);
[D E S D2]=gogetdata(expdate,session,filenum);
event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
scaledtrace2=[];

try 
    scaledtrace2=D2.nativeScaling*double(D2.trace)+D2.nativeOffset;
end
clear D E S D2

samprate=1e4;
if isempty(lostat1) lostat1=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;

% Get dspikes

high_pass_cutoff=300; %Hz
fprintf('\nHigh-pass filtering at %d Hz...', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace);
        fprintf('\nUsing absolute spike detection threshold of %.1f mV (%.1f sd).', thresh, nstd);
    end
else
    thresh=nstd*std(filteredtrace);
    if thresh>1
        fprintf('\nUsing spike detection threshold of %.1f mV (%g sd).', thresh, nstd);
    elseif thresh<=1
        fprintf('\nUsing spike detection threshold of %.4f mV (%g sd).', thresh, nstd);
    end
end
refract=5;
fprintf('\nUsing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try
    dspikes=[spikes(1) dspikes'];
catch
    fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high.\n');
    return
end


monitor=1;

if (monitor)
    figure
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
end



%% Sort events
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'naturalsound')
        j=j+1;
        alldurs(j)=event(i).Param.duration;
        allisis(j)=event(i).Param.next;
        allfilenames{j}=event(i).Param.file;
    end
end
numepochs=length(unique(allfilenames));
epochfilenames=(unique(allfilenames));
dur=unique(alldurs);
isi=unique(allisis);
if length(dur)~=1 error('cannot handle multiple durs');end

%% Extract the traces into a big matrix M.

nrepsON=zeros(numepochs,1);
nrepsOFF=zeros(numepochs,1);
M1ON=[];
M1OFF=[];
M1stimON=[];
M1stimOFF=[];

j=0;

for i=1:length(event)
    
    
    if strcmp(event(i).Type, 'naturalsound')
        
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        
        if isempty(find(region<0)) %(disallow negative start times)
            
            dur=event(i).Param.duration;
            epochfile=event(i).Param.file;
            epochnum=find(strcmp(epochfilenames, epochfile));
            
            % Gather evoked spike times
            spiketimes1=dspikes(dspikes>start & dspikes<stop); % Spiketimes in region
            spiketimes1=(spiketimes1-pos)*1000/samprate;% Covert to ms after sound onset
            
            if event(i).Param.AOPulseOn
                nrepsON(epochnum)=nrepsON(epochnum)+1;
                M1ON(epochnum, nrepsON(epochnum)).spiketimes=spiketimes1;
                M1stimON(epochnum, nrepsON(epochnum),:)=stim(region);
            else
                nrepsOFF(epochnum)=nrepsOFF(epochnum)+1;
                M1OFF(epochnum, nrepsOFF(epochnum),:).spiketimes=spiketimes1;
                M1stimOFF(epochnum, nrepsOFF(epochnum),:)=stim(region);
            end

        end
        
    end
    
end
%% Save it.
out.nrepsON=nrepsON;
out.nrepsOFF=nrepsOFF;
out.M1ON=M1ON;
out.M1OFF=M1OFF;
out.M1stimON=M1stimON;
out.M1stimOFF=M1stimOFF;

out.numepochs=numepochs;
out.epochfilenames=epochfilenames;
out.durs=dur;
out.xlimits=xlimits;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.laserduration=laserduration;


godatadir(expdate,session,filenum);
outfilename=sprintf('out_NSspiketimes _%s-%s-%s',expdate,session, filenum);
save(outfilename, 'out');
fprintf('\n Saved to %s.\n', outfilename)
PlotNSIL_rasters(outfilename,cd) % 

end



