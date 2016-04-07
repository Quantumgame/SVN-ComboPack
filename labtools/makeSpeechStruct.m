function sstx = makeSpeechStruct(dirName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Makes structure as .mat file for SpeechSearch that contains
%   -Basic stim information (speaker/consonant/vowel/etc.)
%   -Spectrogram for each phoneme
%   -Graph with similarity weights to other phonemes
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get filenames
fileList = getPhoPhiles(dirName);
numFiles = length(fileList);
sstx = struct;

%Build structure
%Folder/file structure of input dir should be:
%   <dir>/Speaker/Phoneme Class (eg. CV for consonant
%   Vowel)/Phoneme/Phoneme#.wav
%   eg: '/Jonny/CV/bI/bI3.wav'
%ProcPhoPhiles should be able to build that for you if you're starting with
%raw audio
prevCharCnt = 0;
fprintf('\n\n')
M = zeros(.5*96000,numFiles);
for i = 1:numFiles
    fprintf([repmat('\b',1,(21+length(num2str(i-1))+length(num2str(numFiles)))),'Processing file %d of %d '],i,numFiles)
    sstx(i).file = fileList{i};
    pathParts = strsplit(fileList{i},'/');
    sstx(i).speaker = pathParts(end-3); %Speaker should always be 3 steps up from the file
    sstx(i).phonClass = pathParts(end-2); %CV, CVC, etc.
    sstx(i).phoneme = pathParts(end-1);
    sstx(i).recnum = fileList{i}(end-4); %Since extensions should be 4 chars, number of recording should be here
    
    %Feature extraction fo clustering
    [a,fs] = audioread(fileList{i});
    sstx(i).features = stFeatureExtraction(a,fs,.010,.010);
    lt = size(a,1);
    if lt < (fs*.5)
        a(lt:(fs*.5),1) = 0;
    elseif lt > (fs*.5)
        a = a(1:fs*.5);
    end
    M(:,i) = a;
end
fprintf(' \n')
fprintf('Simple processing completed, beginning spectral clustering\n')

%Spectral clustering
%Inspired by http://www.mathworks.com/matlabcentral/fileexchange/34412-fast-and-efficient-spectral-clustering
%Normalize
minData = min(M, [], 2);
maxData = max(M, [], 2);

r = (0-1) ./ (minData - maxData);
s = 0 - r .* minData;
M = repmat(r, 1, size(M, 2)) .* M + repmat(s, 1, size(M, 2));


% Compute distance matrix
W = squareform(pdist(M'));

% Apply Gaussian similarity function
sigma = 1;
W = simGaussian(W, sigma);
for i = 1:numFiles
    sstx(i).simGraph = W(:,i);
end
cd(dirName)
cd ..
saveDir = pwd;
matPath = [pwd,'/phoMat.mat'];
save(matPath,'sstx');

fprintf('Spectral clustering completed, saving struct as %s and plotting results... \n',matPath)
%have to actually put the plot in...



   
    
    
    
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin local functions
function fileList = getFilenamez(dirName)
  excludes = {'.DS_Store'};
  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  validFiles = ~ismember(fileList,excludes);
  fileList = fileList(validFiles);
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..','Unprocessed','Unsorted'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getFilenames(nextDir)];  %# Recursively call getAllFiles
  end
end



end

