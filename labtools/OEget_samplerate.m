function samplerate=OEget_samplerate(oepathname)
% usage: samplerate=OEget_samplerate(oepathname)

cd(oepathname)
d=dir('*.continuous');
filename=d(1).name;
fid = fopen(filename);
NUM_HEADER_BYTES = 1024;

hdr = fread(fid, NUM_HEADER_BYTES, 'char*1');
eval(char(hdr'));
fclose(fid);
samplerate=header.sampleRate;