function PdiodeVelocity(expdate,session,filenum, varargin)

% usage: PdiodeVelocity('expdate','session','filenum', [diameter in cm])
%converts a photodiode signal from a running wheel into velocity
if nargin==0
    return
elseif nargin==4
    diameter=varargin{1};
else
    diameter= 17;%default (in cm)
end

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
fprintf('\nload file: ')
[D E S]=gogetdata(expdate,session,filenum);
scaledtrace=double(D.trace);
scaledtrace=scaledtrace-min(scaledtrace);
scaledtrace=scaledtrace./max(scaledtrace);

clear D E S
t=1:length(scaledtrace);
t=t/10;

%high-pass filter data to remove DC component

figure
plot(t, scaledtrace);