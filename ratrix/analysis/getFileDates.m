function dateList = getFileDates(dirName)
  excludes = {'.DS_Store','.','..'};
  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  dateList = {dirData(~dirIndex).date}';  %'# Get a list of the files
  validFiles = ~ismember(dateList,excludes);
  dateList = dateList(validFiles);
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..','Unprocessed','Unsorted'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    dateList = [dateList; getFileDates(nextDir)];  %# Recursively call getAllFiles
  end
end