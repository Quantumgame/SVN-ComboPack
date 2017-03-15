function Make_OGratingProtocol(orientations, cyclespersecond, spatialfreqs, durations, isi, nrepeats)
%usage: Make_OGratingProtocol(orientations, cyclespersecond, spatialfreqs, durations, isi, nrepeats)
%mw072108
%similar to MakeGratingProtocol but you specify the orientations
%creates an exper2 stimulus protocol file for an orientation tuning curve
%stimulus for use with psychophysics toolbox (PTB)
% inputs:
% orientations:  orientations (in degrees, 0 to 360, i.e. directions)  
% cyclespersecond: drift frequency
% spatialfreqs: vector of spatial frequencies in cycles per pixel
% durations: vector of stim durations (in ms) (can be a single duration)
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example call: Make_OGratingProtocol(0, 2, .005, 2000, 2000, 10)
%
%example call with multiple spatial freqs and durations: 
%example call: Make_OGratingProtocol([0 30 60 90 120 150 180 210 240 270 300 330], 2, [.000589 .0011787 .002357 .0047146 .009429 .0188585], [1500], 2000, 10)

numdurations=length(durations);
numorientations=length(orientations);
numspatialfreqs=length(spatialfreqs);
linspacedorientations = orientations;


[Orientations,SpatialFreqs, Durations]=meshgrid( linspacedorientations , spatialfreqs, durations );
neworder=randperm( numspatialfreqs * numorientations * numdurations);
orientations=zeros(size(neworder*nrepeats));
spatfreqs=zeros(size(neworder*nrepeats));
durs=zeros(size(neworder*nrepeats));

tdur=numspatialfreqs * numorientations*numdurations *(mean(durations)+isi)/1000;%approx. duration per repeat

for nn=1:nrepeats
    neworder=randperm( numspatialfreqs * numorientations * numdurations);
    orientations( prod(size(Orientations))*(nn-1) + (1:prod(size(Orientations))) ) = Orientations( neworder );
    spatfreqs( prod(size(SpatialFreqs))*(nn-1) + (1:prod(size(SpatialFreqs))) ) = SpatialFreqs( neworder );
    durs( prod(size(Durations))*(nn-1) + (1:prod(size(Durations))) ) = Durations( neworder );
end

durstring=sprintf('%d-', durations);durstring=durstring(1:end-1);
orientationstring=sprintf('%d-', unique(orientations));orientationstring=orientationstring(1:end-1);
sfstring=sprintf('%.3f-', spatialfreqs);sfstring=sfstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

    stimuli(1).param.name= sprintf('orientation tuning curve, %so/%dcps/%dsf(%scpd)/%dd(%sms)/%dmsisi', ...
        orientationstring, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);
    stimuli(1).param.description= sprintf('orientation tuning curve, %sorientations/%d cycles per second / %d spatial freqs(%s cpd)/%d durations(%s ms)/%d ms isi', ...
        orientationstring, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);
    filename= sprintf('ori-tuning-curve-o%s-%dcps-%dsf_%scpd-%dd_%sms-%dmsisi.mat', ...
        orientationstring, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);

for nn=1:length(orientations)
    

        stimuli(nn+1).type='grating';
        stimuli(nn+1).param.angle=orientations(nn);
        stimuli(nn+1).param.spatialfrequency=spatfreqs(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.cyclespersecond=cyclespersecond;
        stimuli(nn+1).param.next=isi;
    
end

global pref
cd(pref.stimuli)
cd('Visual Protocols')
save(filename, 'stimuli')


% keyboard