function cleanManyCompiledRecords()

%Just a lazy looping wrapper for cleanCompiledRecords

[filename,folder]  = uigetfile({'*.mat'},'u got a file fr me or u call me 4 nothin','MultiSelect','on');

for i = 1:length(filename)
    filen = char(strcat(folder,filename(i)));
    cleanCompiledRecords(filen);
end