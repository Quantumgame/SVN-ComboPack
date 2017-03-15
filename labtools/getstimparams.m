function stimparams=getstimparams(expdate, session, filename)
% usage: stimparams=getstimparams(expdate, session, filename)
%
%returns structure with stimulus paramsfor stimuli that were presented for
%that file
%
%
global pref
if isempty(pref) Prefs; end
username=pref.username;
if nargin~=3
    help stimparams
    error('stimparams: wrong number of arguments')
end

if pref.usebak
    godatadirbak(expdate, session, filename)
else
    godatadir(expdate, session, filename)
end
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filename);
if exist(eventsfile)~=2
    fprintf('no events file found')
    stimparams=[];
    return
end

load(eventsfile)


allevents=[];
alldurs=[];
allfreqs=[];
allcarrierfreqs=[];
allamps=[];
allpotentials=[];
allSOAs=[];
allISIs=[];
allprepulseamps=[];
allprepulsefreqs=[];
allprepulsebandwidths=[];
allpulsedurs=[];
allpulseamps=[];
allfilter_operations={};
allcenter_frequencies=[];
alllower_frequencies=[];
allupper_frequencies=[];
alldescriptions=[];
allfiles=[];
allfields={};

for i=1:length(event)
    allevents{i}=event(i).Type;
    fields=fieldnames(event(i).Param);
    allfields={allfields{:}, fields{:}};

    if strcmp(event(i).Type, 'holdcmd')
        allpotentials=[allpotentials event(i).Param.holdcmd_to];
    else
        if isfield(event(i).Param, 'duration')
            alldurs=[alldurs event(i).Param.duration];
        end
        if isfield(event(i).Param, 'frequency')
            allfreqs=[allfreqs event(i).Param.frequency];
        end
        if isfield(event(i).Param, 'carrier_frequency')
            allcarrierfreqs=[allcarrierfreqs event(i).Param.carrier_frequency];
        end
        if strcmp(event(i).Type, 'whitenoise')
            allfreqs=[allfreqs -1];
        end
        if isfield(event(i).Param, 'amplitude')
            allamps=[allamps event(i).Param.amplitude];
        end
        if isfield(event(i).Param, 'prepulseamp')
            allprepulseamps=[allprepulseamps event(i).Param.prepulseamp];
        end
        if isfield(event(i).Param, 'prepulsefreq')
            allprepulsefreqs=[allprepulsefreqs event(i).Param.prepulsefreq];
        end
        if isfield(event(i).Param, 'prepulsebandwidth')
            allprepulsebandwidths=[allprepulsebandwidths event(i).Param.prepulsebandwidth];
        end
        if isfield(event(i).Param, 'pulsedur')
            allpulsedurs=[allpulsedurs event(i).Param.pulsedur];
        end
        if isfield(event(i).Param, 'pulseamp')
            allpulseamps=[allpulseamps event(i).Param.pulseamp];
        end
        if isfield(event(i).Param, 'filter_operation')
            allfilter_operations={allfilter_operations{:} event(i).Param.filter_operation};
        end
        if isfield(event(i).Param, 'upper_frequency')
            allupper_frequencies=[allupper_frequencies event(i).Param.upper_frequency];
        end
        if isfield(event(i).Param, 'lower_frequency')
            alllower_frequencies=[alllower_frequencies event(i).Param.lower_frequency];
        end
        if isfield(event(i).Param, 'center_frequency')
            allcenter_frequencies=[allcenter_frequencies event(i).Param.center_frequency];
        end
        if isfield(event(i).Param, 'SOA')
            allSOAs=[allSOAs event(i).Param.SOA];
        end
        if isfield(event(i).Param, 'next')
            allISIs=[allISIs event(i).Param.next];
        end
        if isfield(event(i).Param, 'description')
            
            alldescriptions{i}=event(i).Param.description;
        end
        if isfield(event(i).Param, 'file')
            allfiles{i}= event(i).Param.file;
        end
        
    end
end

stimparams.stimtypes=unique(allevents);
stimparams.durs=unique(alldurs);
stimparams.amps=unique(allamps);
stimparams.freqs=unique(allfreqs);
stimparams.carrier_freqs=unique(allcarrierfreqs);
stimparams.potentials=unique(allpotentials);
stimparams.SOAs=unique(allSOAs);
stimparams.ISIs=unique(allISIs);

stimparams.prepulseamps=unique(allprepulseamps);
stimparams.prepulsefreqs=unique(allprepulsefreqs);
stimparams.prepulsebandwidths=unique(allprepulsebandwidths);
stimparams.pulsedurs=unique(allpulsedurs);
stimparams.pulseamps=unique(allpulseamps);
stimparams.filter_operations=unique(allfilter_operations);
stimparams.center_frequencies=unique(allcenter_frequencies);
stimparams.lower_frequencies=unique(alllower_frequencies);
stimparams.upper_frequencies=unique(allupper_frequencies);
stimparams.allfields=unique(allfields);
%stimparams.descriptions=unique(alldescriptions);
%stimparams.files=unique(allfiles);


