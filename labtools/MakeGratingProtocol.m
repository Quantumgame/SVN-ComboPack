function MakeGratingProtocol(numorientations, cyclespersecond, spatialfreqs, durations, isi, nrepeats)
%usage: MakeGratingProtocol(numorientations, cyclespersecond, spatialfreqs)
%mw072108
%creates an exper2 stimulus protocol file for an orientation tuning curve
%stimulus for use with psychophysics toolbox (PTB)
% inputs:
% numorientations: number of orientations (0 to 360, i.e. directions)  
% cyclespersecond: drift frequency
% spatialfreqs: vector of spatial frequencies in cycles per pixel
% durations: vector of stim durations (in ms) (can be a single duration)
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example call: MakeGratingProtocol(8, 2, .005, 2000, 2000, 10)
%
%example call with multiple spatial freqs and durations: 
%example call: MakeGratingProtocol(8, 2, [.005 .010], [1000 2000], 2000, 10)

numdurations=length(durations);
numspatialfreqs=length(spatialfreqs);
linspacedorientations = 360/numorientations:360/numorientations:360;


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
sfstring=sprintf('%.3f-', spatialfreqs);sfstring=sfstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

    stimuli(1).param.name= sprintf('orientation tuning curve, %do/%dcps/%dsf(%scpd)/%dd(%sms)/%dmsisi', ...
        numorientations, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);
    stimuli(1).param.description= sprintf('orientation tuning curve, %dorientations/%d cycles per second / %d spatial freqs(%s cpd)/%d durations(%s ms)/%d ms isi', ...
        numorientations, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);
    filename= sprintf('ori-tuning-curve-%do-%dcps-%dsf_%scpd-%dd_%sms-%dmsisi.mat', ...
        numorientations, cyclespersecond, numspatialfreqs,sfstring, numdurations, durstring,isi);

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