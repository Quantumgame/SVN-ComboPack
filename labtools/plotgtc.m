function [getc, gitc]=plotgtc(varargin)
%plots tuning curve of ge and gi
% inputs: data structure
% optional: linestyle string
% if you pass a linestyle string, data is overplotted in same figure,
% otherwise it generates a new figure
in=varargin{1};
if nargin==2
    ls=varargin{2};
    figure(13)
    hold on
else
    ls='-';
    figure
end

M1=in.M1;
mM1=in.mM1;
expdate=in.expdate;
session=in.session;
filenum=in.filenum;
freqs=in.freqs;
amps=in.amps;
durs=in.durs;
potentials=in.potentials;
samprate=in.samprate;
numamps=length(amps);
numfreqs=length(freqs);
numpotentials=length(potentials);
numdurs=length(durs);
fs=24;

%plot the mean tuning curve
hold on
p=0;
gitc=zeros( numfreqs,numamps, numdurs);
getc=gitc;
for dindex=1:numdurs
    for aindex=[numamps:-1:1]
        for findex=2:numfreqs
            ge=squeeze(in.GE(findex, aindex, dindex, :));
            gi=squeeze(in.GI(findex, aindex, dindex,  :));
            gsyn=squeeze(in.GSYN(findex, aindex, dindex, 1, :));
            getc(findex, aindex, dindex)=max(ge);
            gitc(findex, aindex, dindex)=max(gi);
            region=50*samprate/1000:250*samprate/1000; %from stimulus onset to 50ms after stimulus offset
            %          getc(findex, aindex)=sum(ge(region));
            %          gitc(findex, aindex)=sum(gi(region));
%             getc(findex, aindex, dindex)=max(ge);
%             gitc(findex, aindex, dindex)=max(gi);

        end
    end
end

for aindex=1:numamps
    for dindex=1:numdurs
        figure

        p1=plot(1:numfreqs-1, getc(2:numfreqs,aindex, dindex), 'g');
        hold on
        p2=plot(1:numfreqs-1, gitc(2:numfreqs,aindex, dindex), 'r');
        title(sprintf('%s-%s-%s ON %ddB', expdate,session, filenum, amps(aindex)))
        set([p1 p2], 'linestyle', ls)
        set([p1 p2], 'linewidth', 3)
        set(gca, 'xtick', [2:4:18])
        try
            set(gca, 'xticklabel', round(freqs(1+[2:4:18])./1000))
        catch
            set(gca, 'xticklabel', round(freqs(1+[2:4:length(freqs)-1])./1000))
        end
        xl=xlabel('frequency, kHz');
        set(xl, 'fontsize', fs, 'fontweight', 'bold')

        set(gca, 'ytick', [0:5:15])
        yl=ylabel('g_p_e_a_k, nS');
        set(yl, 'fontsize', fs, 'fontweight', 'bold')
        set(gca, 'fontsize', fs)

        figure
        hold on
        p3=plot(gitc(:,2)./getc(:,2), 'k');
        set([ p3], 'linestyle', ls)
        set([ p3], 'linewidth', 2)
        ylabel('gi/ge')
        h=title(sprintf('%s-%s-%s', expdate,session, filenum));
        set(h, 'fontsize', fs)

    end
end
%keyboard