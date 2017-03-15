function cleanPermanentRecords(mouse,foldir,datadir)

%Because compiled records are an absolute clusterfuck we have to go back
%and rebuild our data from scratch if we actually want to use it. what a
%great piece of software this is.

%Scratchy help b/c writing quickly -JLS052516
%inputs: foldir - folder we're looking for permanent records in
%datadir: place to save the .csv

cd(foldir)

excludes = {'.DS_Store','.','..'};
header = {'trialNumber','date','session','step','gapDur','response','target','correct'};

%make csv and write header
csvfile = char(strcat(datadir,'/',mouse,'.csv'));
fid = fopen(csvfile,'w');
fprintf(fid,'%s,',header{1:end-1});
fprintf(fid,'%s\n',header{end});
fclose(fid);

datamat = [];
fileData = dir(foldir);
fileList = {fileData(:).name}';
validFiles = ~ismember(fileList,excludes);
fileData = fileData(validFiles);
fileDates = [fileData(:).datenum].';
[fileDates,fileDates] = sort(fileDates);
fileList = {fileData(fileDates).name};

trialNumber = 0;

for j = 1:length(fileList)
    fprintf('file %d of %d\n',j,length(fileList));
    load(strcat(foldir,'/',fileList{j}))
    l = length(trialRecords);


    %Extract Data
    trialNumber = (trialNumber(end)+1):(trialNumber(end)+l);
    session = repmat(j,l,1);
    step = [trialRecords(:).trainingStepNum];

    %Stuff that needs to be looped
    dates = [];
    correct = [];
    gapDur = [];
    response = [];
    target = [];
    for k = 1:l
        dates(k) = datenum(trialRecords(k).date);
        try
            correct(k) = trialRecords(k).trialDetails.correct;
        catch
            correct(k) = NaN(1);
        end
        gapDur(k) = trialRecords(k).stimDetails.toneFreq;
 

        try
            responsevec = trialRecords(k).phaseRecords(2).responseDetails.tries{end};
            if responsevec(1) == 1
                response(k) = 1;
            elseif responsevec(3) == 1
                response(k) = 3;
            else
                response(k) = NaN(1);
            end
        catch
            response(k) = NaN(1);

        end

        if length(trialRecords(k).targetPorts) == 1
            target(k) = trialRecords(k).targetPorts;
        else
            target(k) = NaN(1);
        end



    end
    datamat = [trialNumber',double(dates'),session,double(step'),gapDur',response',target',correct'];
    dlmwrite(csvfile,datamat,'-append','precision','%.6f');
end

            
            
            
            
            
                
              
        
        
        

    
    
