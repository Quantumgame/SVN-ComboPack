function [expertime, duration]=getexpertime(expdate,session, filenum)
%usage:
%  [expertime, duration]==getexpertime(expdate,session, filenum)
%  outputs:
%   expertime: time of day when file was recorded (datevec)
%   duration: duration of file in seconds
%   
%  looks in exper structure
%  use datestr(expertime) to convert expertime into a meaningful string 

godatadirbak(expdate,session, filenum) %get onto backup server
username=whoami;

cd ../../..
raw_data_sessdir=sprintf('Data-%s/%s-%s', username, expdate, username);
cd(raw_data_sessdir)
datadir=sprintf('%s-%s-%s', expdate, username, session);
cd(datadir)
experfile=sprintf('%s-%s-%s-%s.mat', expdate, username, session, filenum);
exp=load(experfile);
names=fieldnames(exp);
exper=getfield(exp,names{1});

expertime=(exper.control.param.expstart.value);
duration=(exper.control.param.exptime.value);


