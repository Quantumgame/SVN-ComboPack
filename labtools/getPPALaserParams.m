function [on, start, width, numpulses, isi]=getPPALaserParams(expdate, session, filenum)
%loads PPAlaser module settings from the exper structure
%usage
%       [on, start, width, numpulses, isi]=getPPALaserParams(expdate, session, filenum)
%
%mw 01.28.2014

on=[];
start=[];
width=[];
numpulses=[];
isi=[];
username=whoami;

global pref
if isempty(pref) Prefs; end

try
    raw_data_dir=sprintf('%s\\Data-%s-backup\\%s-%s', pref.home, username, expdate, username);
    sessdir=sprintf('%s-%s-%s',expdate, username, session);
    
    cd(raw_data_dir)
    cd(sessdir)
    experfile=sprintf('%s-%s-%s-%s.mat', expdate, username, session, filenum);
    exp=load(experfile);
    names=fieldnames(exp);
    exper=getfield(exp,names{1});
    
    on=exper.ppalaser.param.on.value;
    start=exper.ppalaser.param.start.value;
    width=exper.ppalaser.param.width.value;
    numpulses=exper.ppalaser.param.numpulses.value;
    isi=exper.ppalaser.param.isi.value;
    
catch
    warning('getPPALaserParams: Could not get PPA laser params')
end

