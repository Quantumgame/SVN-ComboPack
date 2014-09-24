function first_sample_timestamp=OEget_first_sample_timestamp(oepathname)
% usage: first_sample_timestamp=OEget_first_sample_timestamp(oepathname)
%
% returns the time, in seconds, of the first sample for an OE data folder
%
%with the OE GUI, when you click record, the timestamp of the first sample
%recorded does not always start at zero. It depends on whether the GUI was
%playing previously and/or whether the GUI has been cleared or a new
%directory created. Not sure about the details but this function returns
%the time, in seconds, of the first sample. By subtracting this value all
%data (events, spikes, continuous data, etc) will start at zero at the
%begining of the file.

cd(oepathname)
d=dir('*.continuous');
filename=d(1).name;
fid = fopen(filename);
NUM_HEADER_BYTES = 1024;

hdr = fread(fid, NUM_HEADER_BYTES, 'char*1');
eval(char(hdr'));

timestamp = fread(fid, 1, 'int64', 0, 'l');
fclose(fid);
first_sample_timestamp=timestamp/header.sampleRate;