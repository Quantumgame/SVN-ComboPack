function cleanCompiledRecords(varargin)
%Clean compiled records and save as xls. variable names specific to
%speechDiscrim, but can easily be changed - JLS052416

if nargin>0
    filen = varargin{1};
    [~,filename,ext] = fileparts(filen);
    filename = [filename,'.',ext];
else
    [filename,folder]  = uigetfile({'*.mat'},'u got a file fr me or u call me 4 nothin','~/Dropbox/School/','MultiSelect','on');
    if iscell(filename)
       filen = char(strcat(folder,filename(1)));
    else
       filen = char(strcat(folder,filename));
    end
end

load(filen);

if length(compiledDetails)>1
    if strcmp(compiledDetails(1).className,'speechDiscrim')
        compiledDetails = compiledDetails(1);
    elseif strcmp(compiledDetails(2).className,'speechDiscrim')
        compiledDetails=compiledDetails(2);
    end
    get = compiledDetails.trialNums(:);
else
    get = compiledDetails.trialNums(:);
end

%Extract to variables
consonant = compiledDetails.records.toneFreq(1,:); %toneFreq in SpeechDiscrim is a vector w/ 4 values, first is consonant
speaker = compiledDetails.records.toneFreq(2,:);
if size(compiledDetails.records.toneFreq,1)==3;
    vowel = compiledDetails.records.toneFreq(3,:);
elseif size(compiledDetails.records.toneFreq,1)==4;
    vowel = compiledDetails.records.toneFreq(3,:);
    token = compiledDetails.records.toneFreq(4,:);
end
%if size(compiledDetails.records.toneFreq,1)>4
%    gentype = compiledDetails.records.toneFreq(5,:);
%end
correctionTrials = compiledDetails.records.correctionTrial(:);
correct = compiledTrialRecords.correct(get);
response = compiledTrialRecords.response(get);
session=compiledTrialRecords.sessionNumber(get);
dates = compiledTrialRecords.date(get);
steps = compiledTrialRecords.step(get);
targets = compiledTrialRecords.targetPorts(get);

%Clean NaN trials if quit before mouse answered
nansI = find(isnan(correct));
correct(nansI) = []; %need to do this due to interruptions from erroring
consonant(nansI)= [];
speaker(nansI) = [];
if size(compiledDetails.records.toneFreq,1)==3;
    vowel(nansI) = [];
elseif size(compiledDetails.records.toneFreq,1)==4;
    vowel(nansI) = [];
    token(nansI) = [];
end
%if size(compiledDetails.records.toneFreq,1)>4
%    gentype(nansI) = [];
%end
response(nansI)= [];
steps(nansI)= [];
session(nansI)=[];
correctionTrials(nansI)=[];
dates(nansI)=[];
targets(nansI)=[];

trialNumbers = 1:length(correct);


%If multiple files, concatenate
if iscell(filename)
    for i = 2:length(filename)
       filen = char(strcat(folder,filename(i)));
       load(filen);
       
       if length(compiledDetails)>1
           if strcmp(compiledDetails(1).className,'speechDiscrim')
               compiledDetails = compiledDetails(1);
           elseif strcmp(compiledDetails(2).className,'speechDiscrim')
               compiledDetails=compiledDetails(2);
           end
           get = compiledDetails.trialNums(:);
       else
           get = compiledDetails.trialNums(:);
       end
       
       %Extract to variables
       tempconsonant = compiledDetails.records.toneFreq(1,:); %toneFreq in SpeechDiscrim is a vector w/ 4 values, first is consonant
       tempspeaker = compiledDetails.records.toneFreq(2,:);
       tempvowel = compiledDetails.records.toneFreq(3,:);
       temptoken = compiledDetails.records.toneFreq(4,:);
       %f size(compiledDetails.records.toneFreq,1)>4
        %   tempgentype = compiledDetails.records.toneFreq(5,:);
        %   nansgen = find(isnan(tempgentype));
        %   tempgentype(nansgen) = 1;
       %end
       tempcorrectionTrials = compiledDetails.records.correctionTrial(:);
       tempcorrect = compiledTrialRecords.correct(get);
       tempresponse = compiledTrialRecords.response(get);
       tempsession=compiledTrialRecords.sessionNumber(get);
       tempsession = tempsession+(max(session));
       tempdates = compiledTrialRecords.date(get);
       tempsteps = compiledTrialRecords.step(get);
       temptargets = compiledTrialRecords.targetPorts(get);
       
       %Clean NaN trials if quit before mouse answered
       nansI = find(isnan(correct));
       tempcorrect(nansI) = []; %need to do this due to interruptions from erroring
       tempconsonant(nansI)= [];
       tempspeaker(nansI) = [];
       tempvowel(nansI) = [];
       temptoken(nansI) = [];
       %if size(compiledDetails.records.toneFreq,1)>4
       %    tempgentype(nansI) = [];
       %end
       tempresponse(nansI)= [];
       tempsteps(nansI)= [];
       tempsession(nansI)=[];
       tempcorrectionTrials(nansI)=[];
       tempdates(nansI)=[];
       temptargets(nansI)=[];
       
       temptrialNumbers = (trialNumbers(end)+1):(trialNumbers(end)+length(tempcorrect));
       
       %concatenate
       correct = [correct, tempcorrect]; %need to do this due to interruptions from erroring
       consonant = [consonant, tempconsonant];
       speaker = [speaker, tempspeaker];
       vowel = [vowel, tempvowel];
       token = [token, temptoken];
       %if size(compiledDetails.records.toneFreq,1)>4
       %    if exist('gentype')
       %        gentype = [gentype, tempgentype];
       %    else
       %        gentype = [ones(length(response),1)', tempgentype];
       %    end
       %end
       response= [response, tempresponse];
       steps= [steps,tempsteps];
       session=[session,tempsession];
       correctionTrials=[correctionTrials;tempcorrectionTrials];
       dates=[dates,tempdates];
       targets=[targets,temptargets];
       trialNumbers = [trialNumbers,temptrialNumbers];
    end
end
       
%write to xls
%if size(compiledDetails.records.toneFreq,1)>4
%    header = {'trialNumber','date','session','step','consonant','speaker','vowel','token','gentype','response','target','correct','correctiontrial'};
%    datamat = [trialNumbers',uint32(dates'),session',steps',consonant',speaker',vowel',token',gentype',response',targets',correct',correctionTrials];
%    datacell = mat2cell(datamat,ones(size(datamat,1),1),ones(size(datamat,2),1));
%    compcell = [header;datacell]; 
%else
if size(compiledDetails.records.toneFreq,1)==2;
    header = {'trialNumber','date','session','step','consonant','speaker','response','target','correct','correctiontrial'};
    datamat = [trialNumbers',uint32(dates'),session',steps',consonant',speaker',response',targets',correct',correctionTrials];
elseif size(compiledDetails.records.toneFreq,1)==3;
    header = {'trialNumber','date','session','step','consonant','speaker','vowel','response','target','correct','correctiontrial'};
    datamat = [trialNumbers',uint32(dates'),session',steps',consonant',speaker',vowel',response',targets',correct',correctionTrials];
elseif size(compiledDetails.records.toneFreq,1)==4;
    header = {'trialNumber','date','session','step','consonant','speaker','vowel','token','response','target','correct','correctiontrial'};
    datamat = [trialNumbers',uint32(dates'),session',steps',consonant',speaker',vowel',token',response',targets',correct',correctionTrials];

end
%end

if iscell(filename)
    xlsfile = char(strcat(folder,filename{1}(1:end-4),'csvout.csv'));
else
    xlsfile = char(strcat(folder,filename(1:end-4),'csvout.csv'));
end

fid = fopen(xlsfile,'w');
fprintf(fid,'%s,',header{1:end-1});
fprintf(fid,'%s\n',header{end});
dlmwrite(xlsfile,datamat,'-append');

