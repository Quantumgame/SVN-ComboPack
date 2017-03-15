function samprate= getsamplerate(expdate,session,filenum)
%gets sample rate from exper file (in Hz)
%usage: samprate= getsamplerate(expdate,session,filenum)

user=whoami;
wd=pwd;
gorawdatadir(expdate,session,filenum);
experfilename=sprintf('%s-%s-%s-%s.mat',expdate,user, session, filenum);
expr=load(experfilename);
f=fieldnames(expr);
exp=getfield(expr, f{:});
samprate=exp.ai.param.samplerate.value;
cd(wd)