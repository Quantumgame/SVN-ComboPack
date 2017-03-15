daqfilename='expdate-user-session-filenum.daq';
rawdata=daqread(daqfilename); %this is the file from the DataBackup folder
a=rawdata(:,1); %recorded trace from axopatch or am-systems
b=rawdata(:,2); %stimulus monitor trace: tones, clicks etc
c=rawdata(:,5); %soundcard trigger trace
figure
hold on
plot(a,'b');
plot(b*1e4,'m');
plot(c*10,'g')

