function [c sampleRate s cacheUpdated]=getClip(s)
global freqDurable;
global stimMap;
global freqCon
if isempty(s.clip)
    %disp(sprintf('caching %s',s.name))

    switch s.type
        case 'binaryWhiteNoise'
            s.clip = rand(1,s.numSamples)>.5;
        case 'gaussianWhiteNoise'
            s.clip = randn(1,s.numSamples);
        case 'uniformWhiteNoise'
            s.clip = rand(1,s.numSamples);
        case 'allOctaves'
            outFreqs=[];
            for i=1:length(s.fundamentalFreqs)
                done=0;
                thisFreq=s.fundamentalFreqs(i);
                while ~done
                    if thisFreq<=s.maxFreq
                        outFreqs=[outFreqs thisFreq];
                        thisFreq=2*thisFreq;
                    else
                        done=1;
                    end
                end
            end
            freqs=unique(outFreqs);
            raw=repmat(2*pi*[0:s.numSamples]/s.numSamples,length(freqs),1);
            s.clip = sum(sin(diag(freqs)*raw));
        case 'tone'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'tone615'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'toneLCycle10'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'toneThenSpeech'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'toneLaser'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;
        case 'CNMToneTrain'
            %train of pure tones, all at start freq, except last one is at
            %end freq. duration and isi specified in setProtocolCNM
            startfreq=s.freq(1);
            endfreq=s.freq(2);
            numtones=s.freq(3);
            isi=s.freq(4);
            toneDuration=s.freq(5);
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            starttone=sin(2*pi*t*startfreq);
            endtone=sin(2*pi*t*endfreq);
            silence=zeros(1, 44.1*isi);
            train=[];
            for i=1:numtones
            train=[train starttone silence];
            end
            train=[train endtone];

            s.clip = train;
        case 'freeCNMToneTrain'
            %train of pure tones, all at start freq
            %duration and isi specified in setProtocolCNM
            startfreq=s.freq(1);
            endfreq=s.freq(2);
            numtones=s.freq(3);
            isi=s.freq(4);
            toneDuration=s.freq(5);
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            starttone=sin(2*pi*t*startfreq);
            %endtone=sin(2*pi*t*endfreq);
            silence=zeros(1, s.sampleRate*isi/1000);
            train=[];
            for i=1:numtones-1
            train=[train starttone silence];
            end
            train=[train starttone];
            s.clip = train;

        case 'gap'
            beginNoise = randn(1,s.sampleRate*.2)./5; % 200ms of WN
            if s.freq == 0
                endNoise = randn(1,s.sampleRate*.3)./5; % 300ms of WN
                s.clip = [beginNoise,endNoise];
            else
                gapSamples = zeros(s.sampleRate*(s.freq/1000),1)';  % zeros for the length of the gap
                endNoise = randn(1,s.sampleRate*(.3-(s.freq/1000)))./5; % noise for whatever time is left
                s.clip = [beginNoise,gapSamples,endNoise]; %
            end

        case 'noise'
            s.numSamples = s.sampleRate*.5;
            sustained = randn(1,s.numSamples)./5;
            s.clip = sustained;

        case 'wmToneWN'
            startsound=s.freq(1); %if 0, tone first, if 1, WN first
            endsound=s.freq(2); %if 0, tone 2nd, if 1, WN 2nd
            freq=s.freq(3);
            isi=s.freq(4);
            toneDuration=s.freq(5);
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*freq);
            WN = randn(1,s.numSamples);
            if startsound
                starttone = tone;
            else
                starttone = WN;
            end
            if endsound
                endtone = tone;
            else
                endtone = WN;
            end
            silence=zeros(1, s.sampleRate*isi/1000);
            train=[];
            train=[train starttone silence];
            train=[train endtone];

            s.clip = train;

        case 'wmReadWav'
            s.clip = s.freq;
            a = s.sampleRate;

        case 'phonemeWav'
            [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right
            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right
            if s.freq
                s.clip = sad.';
            else
                s.clip = dad.';
            end

        case 'phonemeWavLaser'
            [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right
            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right
            if s.freq
                s.clip = sad.';
            else
                s.clip = dad.';
            end

        case 'phonemeWavLaserMulti'
            [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right
            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right
            if s.freq
                s.clip = sad.';
            else
                s.clip = dad.';
            end

        case 'phonemeWavReversedReward'
            [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right
            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            %reversed rewards for this soundType - to test stimulus vs
            %motor effect of laser
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right
            if s.freq
                s.clip = dad.';
            else
                s.clip = sad.';
            end
       case 'pulseAndNoise'
           s.numSamples = s.sampleRate*5;
           pulse = randn(1,s.sampleRate*.025);
           sustained = randn(1,s.numSamples-(s.sampleRate*.025))./4;
           s.clip = horzcat(pulse,sustained);

       case 'phoneTone'
           %Receive stim target from s.freq as described in calcStim
            %freq is [consonant, speaker, vowel, recording]

            map = {'gI', 'go', 'ga'; 'bI', 'bo', 'ba'};
            if stimMap == 1
                names = {'Jonny','Ira','Anna','Dani','Theresa'};
            elseif stimMap == 2
                names = {'Theresa','Dani','Jonny','Ira','Anna'};
            elseif stimMap == 3
                names = {'Anna','Theresa','Dani','Jonny','Ira'};
            elseif stimMap == 4
                names = {'Dani','Anna','Theresa','Jonny','Ira'};
            elseif stimMap == 5
                names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
            elseif stimMap == 6
                names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
            end

            %if ~s.freq
                s.freq = freqDurable;
            %end

            duration = s.freq(2);
            s.numSamples = s.sampleRate*duration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            if s.freq(1) == 1
                tone=sin(2*pi*t*2000);
            elseif s.freq(1) == 2
                tone=sin(2*pi*t*7000);
            end

            filen = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(1),'\CV\',map(s.freq(1),1),'\',map(s.freq(1),1),num2str(3),'.wav'));
            [aud, fs] = wavread(filen);
            expectLength = s.sampleRate *.5;
            if length(aud) < expectLength
                aud(end:expectLength) = 0;
            end

            %Normalize
            toneamp = ((abs(max(aud.'))+abs(min(aud.')))/4); %want half of the average min/max intensity
            tone = tone*toneamp;

            clip = horzcat(tone,aud.');
            s.clip = clip;
            s.numSamples = s.sampleRate*(duration+500)/1000;

        case {'speechWav', 'speechWavLaser', 'speechWavLaserMulti', 'speechWavReversedReward'} %note reversed is not reversed here
            %Receive stim target from s.freq as described in calcStim
            %freq is [consonant, speaker, vowel, recording]

            map = {'gI', 'go', 'ga'; 'bI', 'bo', 'ba'};


            if stimMap == 1
                names = {'Jonny','Ira','Anna','Dani','Theresa'};
            elseif stimMap == 2
                names = {'Theresa','Dani','Jonny','Ira','Anna'};
            elseif stimMap == 3
                names = {'Anna','Theresa','Dani','Jonny','Ira'};
            elseif stimMap == 4
                names = {'Dani','Anna','Theresa','Jonny','Ira'};
            elseif stimMap == 5
                names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
            elseif stimMap == 6
                names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
            end

            %if ~s.freq
                s.freq = freqDurable;
            %end

            filen = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(s.freq(2)),'\CV\',map(s.freq(1),s.freq(3)),'\',map(s.freq(1),s.freq(3)),num2str(s.freq(4)),'.wav'));
            [aud, fs] = wavread(filen);


            %pad end w/ silence if not fully 500ms so doesn't loop
            expectLength = s.sampleRate *.5;
            if length(aud) < expectLength
                aud(end:expectLength) = 0;
            end

            s.clip = aud.';

        case {'speechWavAll'}
            if stimMap == 1
                names = {'Jonny','Ira','Anna','Dani','Theresa'};
            elseif stimMap == 2
                names = {'Theresa','Dani','Jonny','Ira','Anna'};
            elseif stimMap == 3
                names = {'Anna','Theresa','Dani','Jonny','Ira'};
            elseif stimMap == 4
                names = {'Dani','Anna','Theresa','Jonny','Ira'};
            elseif stimMap == 5
                names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
            elseif stimMap == 6
                names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
            end
            map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};

            s.freq = freqDurable;

            filen = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(s.freq(2)),'\CV\',map(s.freq(1),s.freq(3)),'\',map(s.freq(1),s.freq(3)),num2str(s.freq(4)),'.wav'));
            [aud, fs] = wavread(filen);
            expectLength = s.sampleRate *.5; %Pad end with silence
            if length(aud) < expectLength
                aud(end:expectLength) = 0;
            end

            s.clip = aud.';

        case {'speechWavAllUniform'}
            % stimMap doesn't matter for uniform sampling, use the default for simplicity
            names = {'Jonny','Ira','Anna','Dani','Theresa'};
            cons = {'g','b'};
            map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};

            s.freq = freqDurable;

            filen = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\cv_consonant_split\',cons(s.freq(1)),filesep,names(s.freq(2)),filesep,map(s.freq(1),s.freq(3)),filesep,map(s.freq(1),s.freq(3)),num2str(s.freq(4)),'.wav'));
            [aud, fs] = wavread(filen);
            expectLength = s.sampleRate *.5; %Pad end with silence
            if length(aud) < expectLength
                aud(end:expectLength) = 0;
            end

            s.clip = aud.';


        case 'morPhone'
            %not implemented yet...

        case 'speechComponent'
            %not implemented yet...


        case 'toneThenPhoneme'
            toneDuration=500;
            s.numSamples = s.sampleRate*toneDuration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;
            tone=sin(2*pi*t*s.freq);
            s.clip = tone;


        case 'phoneToneConor'
           %Receive stim target from s.freq as described in calcStim
            %freq is [consonant, speaker, vowel, recording


            %if ~s.freq
                s.freq = freqCon;
            %end


            duration = s.freq(2);
            s.numSamples = s.sampleRate*duration/1000;
            t=1:s.numSamples;
            t=t/s.sampleRate;


             [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right
            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right

            if s.freq(1) == 1
                tone=sin(2*pi*t*2000);
                clip = horzcat(tone,sad.');
            elseif s.freq(1) == 0
                tone=sin(2*pi*t*7000);
                clip = horzcat(tone,dad.');

            end
            s.clip = clip;
            s.numSamples = s.sampleRate*(duration+500)/1000;




        case 'phonemeWavGlobal'
            [sad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\sadshifted-allie.wav'); %left
            %[dad, fs] =wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie.wav'); %right

            %old stimulus - not ideally aligned - changed to new file with
            %50ms silence added to beginning of dad
            [dad, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\phonemes\dadshifted-allie-aligned.wav'); %right
            s.freq=freqCon(1);
            if s.freq
                s.clip = sad.';
            else
                s.clip = dad.';
            end


        case 'warblestackWav'
            startsound=s.freq(1); %if 0, warble first, if 1, WN first
            endsound=s.freq(2); %if 0, tone 2nd, if 1, WN 2nd

            isi=s.freq(4);
            [warble, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\WMsounds\warble_stack.wav');
            [harmonic, fs] = wavread('C:\Users\nlab\Desktop\ratrixSounds\WMsounds\harmonic_stack.wav');
            if startsound
                starttone = warble.';
            else
                starttone = harmonic.';
            end
            if endsound
                endtone = warble.';
            else
                endtone = harmonic.';
            end
            silence=zeros(1, s.sampleRate*isi/1000);
            train=[];
            train=[train starttone silence];
            train=[train endtone];
            s.clip = train;
        case 'tritones'
            s.clip = getClip(soundClip('annonymous','allOctaves',[s.fundamentalFreqs tritones(s.fundamentalFreqs)],s.maxFreq));
        case 'dualChannel'
            s.clip(1,:) = getClip(s.leftSoundClip);
            s.clip(2,:) = getClip(s.rightSoundClip);
            s.amplitude(1) = s.leftAmplitude;
            s.amplitude(2) = s.rightAmplitude;
        case 'empty'
            s.clip = []; %zeros(1,s.numSamples);
        otherwise
            s.type
            error('unknown soundClip type')
    end

    %For all channels, normalize
    for i=1:size(s.clip,1)
        s.clip(i,:)=s.clip(i,:)-mean(s.clip(i,:));
        s.clip(i,:)=s.clip(i,:)/max(abs(s.clip(i,:)))*s.amplitude(i);
    end
    s.clip(isnan(s.clip))=0;

    cacheUpdated=1;

else
    %disp(sprintf('already cached %s',s.name))
    cacheUpdated=0;
end
c=s.clip;
sampleRate=s.sampleRate;

function t=tritones(freqs)
t=freqs*2.^(6/12); % to get i halfsteps over freq, use freq*2.^[i/12]

