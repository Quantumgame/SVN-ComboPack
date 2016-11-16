function [fullfilename]=MakeTCHoldCmdProtocol(start, ramp, reps_per_step, ...
    potentials, initial_potential, nrepeats, varargin)
% NOTES: 
% - holdduration was changed to reps_per_step. MAK, 23 JUN 2011.
% - changed the fieldname for reps_per_step back to holdduration,
% otherwise protocols are broken. mw 04.06.2012 
% - Added varagin option for path to TC file. akh 6/19/13
%
% Specify a Voltage Clamp command protocol and incorporate a previously
% created tuning curve protocol.
% usage: MakeTCHoldCmdProtocol(start, ramp, reps_per_step,...
% potentials, initial_potential, nrepeats, [tcfilename], [tcPath])
% 
% inputs:
%           start    - delay to the start of the ramp after the trigger (ms)
%           ramp     - ramp duration (ms)
%           reps_per_step    - Number repeats per voltage step. Must be an
%                      interger multiple of nrepeats. e.g. If nrepeats = 10,
%                      reps_per_step must equal -1, -2, -5, or -10. 
%                      NOTE:
%                      Low values translate to a lot of stepping between
%                      potentials; high values, fewer steps.
%           potentials - holding potentials 
%           initial_potential - where you want to start the first ramp FROM   (usually -70)
%           nrepeats - Number of total repeats per potential (e.g. 10 reps for -90mV; 10 reps for +70mV)
%               In other words this needs to be half of the nreps on the
%               tuning curve. In more words. If you want 10 reps at -90 and
%               10 reps at +20, you need to make a TC with 20 reps and in
%               this field you need to put 10.
%           NOTE: You must make a tuning curve with this number
%           of reps*num potentials. For example, you must make a tuning curve with 30 reps if
%           you want a TCHoldCmd tuning curve with 10 reps for 3 potentials.
%   
%           If tuning curve filename and path are not provided, a dialog
%           box opens the tuning curve you want to incorporate.
% outputs:
%           Creates a suitably named stimulus protocol in
%           exper2.2\protocols.
%
% Example call:
% MakeTCHoldCmdProtocol(100, 1000, -1, [-90 -50 20], -70, 10)
% For binaural:
% MakeTCHoldCmdProtocol(100, 1000, -5, [-90 20], -70, 10)

tcpathname=[];
if nargin==0 fprintf('\nno input');return;end
if nargin==8 % If a protocol path was passed...
    tcfilename=varargin{1}; 
    tcpathname=varargin{2};
end
    
global pref
Prefs
cd(pref.stimuli)
% cd ('Tuning Curve protocols')
% cd ('SoundPlayer Protocols')

if isempty(tcpathname)
    [tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Voltage Clamp protocol:');
    if isequal(tcfilename,0) || isequal(tcpathname,0)
        disp('User pressed cancel')
        return
    else
        disp(['User selected ', fullfile(tcpathname, tcfilename)])
    end
    tc=load(fullfile(tcpathname, tcfilename));
else
    tc=load(fullfile(tcpathname, tcfilename));
end

%get repeatlength by tabulating freqs/amps
j=0;
bintc=0; %is this a binaural TC?
for i=2:length(tc.stimuli)
    if strcmp(tc.stimuli(i).type, '2tone') | strcmp(tc.stimuli(i).type, 'tone')
        j=j+1;
        allfreqs(j)=tc.stimuli(i).param.frequency;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
        allbws(j)=0;
    elseif strcmp(tc.stimuli(i).type, 'bintone')
        bintc=1;
        j=j+1;
        allfreqs(j)=tc.stimuli(i).param.frequency;
        allamps(j)=tc.stimuli(i).param.Ramplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
    elseif strcmp(tc.stimuli(i).type, 'fmtone')
        j=j+1;
        allfreqs(j)=tc.stimuli(i).param.carrier_frequency;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
    elseif strcmp(tc.stimuli(i).type, 'noise')
        j=j+1;
        allfreqs(j)=tc.stimuli(i).param.center_frequency;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allbws(j)=tc.stimuli(i).param.bandwidthOct;
        allisis(j)=tc.stimuli(i).param.next;
    elseif strcmp(tc.stimuli(i).type, 'whitenoise') 
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
        allbws(j)=inf;
    elseif strcmp(tc.stimuli(i).type, 'clicktrain')  | strcmp(tc.stimuli(i).type, 'pulsetrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
        allicis(j)=tc.stimuli(i).param.isi;
        allbws(j)=inf;
    elseif  strcmp(tc.stimuli(i).type, 'binwhitenoise')
        bintc=1;
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=tc.stimuli(i).param.Ramplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
    elseif  strcmp(tc.stimuli(i).type, 'naturalsound') % added 31aug2012 by mak for ira
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=tc.stimuli(i).param.amplitude;
        alldurs(j)=tc.stimuli(i).param.duration;
        allisis(j)=tc.stimuli(i).param.next;
    elseif  strcmp(tc.stimuli(i).type, 'aopulse')
        bintc=0;
        j=j+1; 
        allfreqs(j)=-2; %using -2 as a flag for an aopulse
    end
end
% if ~strcmp(tc.stimuli(i).type, 'naturalsound')
    freqs=unique(allfreqs);
% end
amps=unique(allamps);
durs=unique(alldurs);
isi=unique(allisis);
if exist('allbws')
    bws=unique(allbws);
    numbws=length(bws);
else
    numbws=1;
end
if numbws==2 && sum(bws==inf)==1 && sum(bws==0)==1
    numbws=1;
end
if exist('allicis')
    icis=unique(allicis);
    numicis=length(icis);
else
    numicis=1;
end
% if ~strcmp(tc.stimuli(i).type, 'naturalsound')
    numfreqs=length(freqs);
% end
numamps=length(amps);
numdurs=length(durs);
numisis=length(isi);
if bintc; numamps=numamps^2;end
if numbws>2;
    if ~strcmp(tc.stimuli(i).type, 'naturalsound') 
        numfreqs=numfreqs-1;
    end
end
%if numisis>1 error('help. cannot handle multiple ISIs.');end
if strcmp(tc.stimuli(i).type, 'naturalsound')
    tonesperrepeat=numamps*numdurs*numisis*numbws*numicis; %added numdurs mw 012808
else 
    tonesperrepeat=numfreqs*numamps*numdurs*numisis*numbws*numicis; %added numdurs mw 012808
end
%added numicis mw 110810
%added numisis mw 031108
%added numbws mw 032410
%repeatlength=numfreqs*numamps*numdurs*(isi+500);
%if reps_per_step<0 reps_per_step=-reps_per_step*repeatlength;end

if reps_per_step<0 %use tonesperrepeat
    if nrepeats*length(potentials) ~= (length(tc.stimuli)-1)/tonesperrepeat
        fprintf('\n\n\n')
        fprintf('!!!!!!!!!!!!!!!!!!!!!!')
        warning('number of repeats in tuning curve does not match nrepeats*numpotentials')
        fprintf('\n\n\n')
    end
end

neworder=randperm( length(potentials) );
cmdsequence=zeros(1,length(potentials)*nrepeats);

for nn=1:nrepeats
    neworder=randperm( length(potentials) );
    cmdsequence( prod(size(potentials))*(nn-1) + (1:prod(size(potentials))) ) = potentials( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('TCHoldCmd, ramp%dms/reps_per_step%dms/%s/%s', ramp, reps_per_step, int2str(potentials), tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('HoldCmd, start: %dms, nrepeats: %d, ramp: %dms, reps_per_step: %dms, potentials: %s, init_potential: %d, %s',start, nrepeats, ramp, reps_per_step, int2str(potentials), initial_potential,tc.stimuli(1).param.description);
filename=sprintf('TCholdcmd-%dms-hd%d-%s-%s.mat', ramp, -reps_per_step, int2str(potentials),tcfilename);


jj=0;kk=0;
out_of_tones=0;
for nn=2:(length(cmdsequence)+1)
    if ~out_of_tones
        stimuli(nn+jj+kk).type='holdcmd';
        stimuli(nn+jj+kk).param.start=start;
        stimuli(nn+jj+kk).param.ramp=ramp;
        stimuli(nn+jj+kk).param.holdduration=2000; %this acts as a equilibration pause before presenting tones. actual hold duration is controlled by elapsed_tc comparison
        stimuli(nn+jj+kk).param.duration=2000+ramp+start;
        if nn==2 stimuli(nn+jj+kk).param.holdcmd_from=initial_potential;
        else
            stimuli(nn+jj+kk).param.holdcmd_from=cmdsequence(nn-2);
        end
        stimuli(nn+jj+kk).param.holdcmd_to=cmdsequence(nn-1);
        %hard coding params for series pulses.
        stimuli(nn+jj+kk).param.pulse_start= 10;
        stimuli(nn+jj+kk).param.pulse_width= 50;
        stimuli(nn+jj+kk).param.pulse_height= -10;
        stimuli(nn+jj+kk).param.npulses= 10;
        stimuli(nn+jj+kk).param.pulse_isi= 50;
        stimuli(nn+jj+kk).param.pulseduration= 970;

        %insert tones
        %         if reps_per_step=-1 %use tonesperrepeat
        %             for n=1:tonesperrepeat
        %                 jj=jj+1;
        %                 if (jj+1)>length(tc.stimuli)
        %                     out_of_tones=1;
        %                     fprintf('\nran out of tones after %d potentials (%d reps)', nn, floor(nn/length(potentials)))
        %                     break
        %                 else
        %                     tone=tc.stimuli(jj+1);
        %                     stimuli(nn+jj+kk)=tone;
        %                 end
        %             end
        if reps_per_step<0 %use tonesperrepeat
            for n=1:(-reps_per_step)*tonesperrepeat
                jj=jj+1;
                if (jj+1)>length(tc.stimuli)
                    out_of_tones=1;
                    fprintf('\nran out of tones on hold command %d  (%d reps)', nn-1, -reps_per_step*floor((nn-1)/length(potentials)))
                    fprintf('\nNOTE: This is not an error and is expected behavior when reps_per_step is < -1\nmak 3nov2012');
                    break
                else
                    tone=tc.stimuli(jj+1);
                    if isfield(tone, 'description')
                        tone=rmfield(tone, 'description');
                    end
                    stimuli(nn+jj+kk)=tone;
                end
            end
        else %use specified reps_per_step
            elapsed_tc=0;
            while elapsed_tc<reps_per_step
                jj=jj+1;
                if (jj+1)>length(tc.stimuli)
                    out_of_tones=1;
                    fprintf('\nran out of tones after %d potentials (%d reps)', nn, floor(nn/length(potentials)))
                    break
                else
                    tone=tc.stimuli(jj+1);
                    stimuli(nn+jj+kk)=tone;
                    elapsed_tc=elapsed_tc+tone.param.duration+tone.param.next+500; %this mysterious 500
                end
            end
        end
    end
end


% These 3 lines added by mak 5jan2011 to ensure that the VCstimuli protocol
% ends at the most negative value to avoid needlessly stressing the cell.
nnn=length(stimuli);
lowest_potential=sort(potentials); % in case the user doesn't put the lowest holdcmd first in the list
stimuli(nnn).param.holdcmd_to=lowest_potential(1);


cd(pref.stimuli) %where stimulus protocols are saved
cd('Voltage Clamp protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s in directory %s\n', filename, pwd)
fprintf('\n\nFull path:\n\n%s\n\n',fullfile(pwd,filename));
fullfilename=fullfile(pwd,filename);


