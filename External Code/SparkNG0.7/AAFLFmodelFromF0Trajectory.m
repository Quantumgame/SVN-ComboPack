function outStr = AAFLFmodelFromF0Trajectory(f0In,timeAxis,fs,tp,te,ta,tc)
%   outStr = AAFLFmodelFromF0Trajectory(f0In,timeAxis,fs,tp,te,ta,tc)
%   tp,te,ta,tc are L-F model parameters

startTime = tic;
tt = (timeAxis(1):1/fs:timeAxis(end))';
f0 = exp(interp1(timeAxis,log(f0In),tt,'linear','extrap'));
theta = cumsum(2*pi*f0.*ones(length(tt),1)/fs);

pvPhase = angle(exp(1i*theta));
indexList = 1:length(theta)-1;
startPointList = indexList(diff(pvPhase)<-5);

lastPoint = 1;
outSignal = tt*0;
directOut = tt*0;
directVV = tt*0;
nyqFreq = fs/2;
for ii = 1:length(startPointList)-2;
    segment = [pvPhase(lastPoint+1:startPointList(ii))-2*pi; ...
        pvPhase(startPointList(ii)+1:startPointList(ii+1));
        pvPhase(startPointList(ii+1)+1:startPointList(ii+2))+2*pi]+pi;
    normalizedTime = segment/2/pi;
    averageF0 = mean(f0(startPointList(ii)+1:startPointList(ii+1)));
    Tw = 2/nyqFreq;
    Tworg = Tw*averageF0;
    modelOut = sourceByLFmodelAAF(normalizedTime,tp,te,ta,tc,Tworg);
    outSignal(lastPoint+1:startPointList(ii+2)) = ...
        outSignal(lastPoint+1:startPointList(ii+2))+modelOut.antiAliasedSource;
    directOut(lastPoint+1:startPointList(ii+2)) = ...
        directOut(lastPoint+1:startPointList(ii+2))+modelOut.source;
    directVV(lastPoint+1:startPointList(ii+2)) = ...
        directVV(lastPoint+1:startPointList(ii+2))+modelOut.volumeVerocity;
    lastPoint = startPointList(ii);
end;
outStr.antiAliasedSignal = outSignal;
outStr.LFmodelOut = directOut;
outStr.LFvolumeVelocity = directVV;
outStr.samplingFrequency = fs;
outStr.f0Interpolated = f0;
outStr.temporalPosition = tt;
outStr.startPointList = startPointList;
outStr.pvPhase = pvPhase;
outStr.elapsedTime = toc(startTime);



