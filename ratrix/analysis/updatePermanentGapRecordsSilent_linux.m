function updatePermanentGapRecordsSilent_linux()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update cleaned permanent records for the mouselist, and if they haven't
% been gathered yet build them.

mouseList = {'6957','6973','6971','6972'};
         
rigNums = [4,5,1,2];

         
datadir = '~/Documents/gapData';
recordsdir = '1';


%Get list of files to compare against
fileList = getFilenames(datadir);
dates = getFileDates(datadir);

for i = 1:length(mouseList)
    if ~all(cellfun('isempty',strfind(fileList,mouseList{i})))
        fprintf('\nFound existing file for %s, updating...',mouseList{i});
        csvfile = char(fileList(~cellfun('isempty',strfind(fileList,mouseList{i}))));
        date = datenum(dates{~cellfun('isempty',strfind(fileList,mouseList{i}))});
        if strcmp(recordsdir,'1')
            updatePermRec(mouseList{i},date,csvfile,rigNums(i));
        else
            updatePermRec(mouseList{i},date,csvfile);
        end
    else
        fprintf('\nCompiling %s fresh',mouseList{i});
        if strcmp(recordsdir,'1')
            cleanPermanentRecords_Gap(mouseList{i},['/mnt/rat',num2str(rigNums(i)),'/nlab/Desktop/laserData/PermanentTrialRecordStore/',mouseList{i}],datadir);
        else
            cleanPermanentRecords_Gap(mouseList{i},recordsdir,datadir);
        end
    end
end
fprintf('\nGenerating Figure...\n');
CheckPerformanceGap_Silent

end

function updatePermRec(varargin)
mouse = varargin{1};
date = varargin{2};
csvfile = varargin{3};
switch nargin
    case 3
        foldir = [recordsdir,'\',mouse];
    case 4
        foldir = ['/mnt/rat',num2str(varargin{4}),'/nlab/Desktop/laserData/PermanentTrialRecordStore/',mouse];
end

%Get and sort file list
excludes = {'.DS_Store','.','..'};
fileData = dir(foldir);
fileList = {fileData(:).name}';
validFiles = ~ismember(fileList,excludes);
fileData = fileData(validFiles);
fileDates = [fileData(:).datenum].';
[fileDates,fileDates] = sort(fileDates);
subfileList = {fileData(fileDates).name};
subfileList = cellfun(@(x) fullfile(foldir,x),...  %# Prepend path to files
                       subfileList,'UniformOutput',false);
subdates = {fileData(fileDates).datenum};


csvimport = csvread(csvfile,1);
lastsesh = csvimport(end,3);
lastdate = csvimport(end,2);

datamat = [];
trialNumber = csvimport(end,1);
indint = 0;
for j = 1:length(subfileList)
    
    sessiondate = datenum(str2num(subfileList{j}(end-18:end-15)),str2num(subfileList{j}(end-14:end-13)),str2num(subfileList{j}(end-12:end-11)),str2num(subfileList{j}(end-9:end-8)),str2num(subfileList{j}(end-7:end-6)),str2num(subfileList{j}(end-5:end-4)));
    if sessiondate > lastdate
        load(subfileList{j})
        indint = indint+1;
        fprintf('\n Processing file %d of %d',j,length(subfileList));
    else
        continue
    end
    l = length(trialRecords);


    %Extract Data
    trialNumber = (trialNumber(end)+1):(trialNumber(end)+l);
    session = repmat(lastsesh+indint,l,1);
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
    fileattrib(csvfile,'+w');
    datamat = [trialNumber',double(dates'),session,double(step'),gapDur',response',target',correct'];
    dlmwrite(csvfile,datamat,'-append','precision','%.6f');
end    






end

    
     
        
    
    