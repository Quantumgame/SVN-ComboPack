 @echo off
rem switch to WC directory and attempt to update and commit changes to repository
rem creates a file in the WC directory called SVNmerge.log with all output from last run
rem in the future this could be modified to be a continuous log, just change the >> symbols to > symbols

rem this section changes to the directory containing the batch file, then moves up a directory
rem this ensures that no matter what machine SVNmerge is run on it will find the working exper copy
rem however this also means that it must be run from the labtools directory of that machine
rem to overcome this make a shortcut to SVNmerge and place it wherever desired

cd "%~dp0"
cd ..

svn update  --username wehrlab --password A1 --accept postpone > SVNmerge.log
svn commit -m "Nightly SVN merge: Committed today's changes to the trunk.  Conflicts postponed, must be resolved manually." >> SVNmerge.log
svn status --quiet >> SVNmerge.log
svn update >> SVNmerge.log

setlocal
set checker=0
rem iteratively checking for "C" at the beginning of lines, which denote conflicts
for /f "tokens=1-2* delims= " %%a in (SVNmerge.log) do if "%%a" == "C" (set checker=1) 
if %checker% == 1 (type SVNmerge.log)
if %checker% == 1 (set /p conflicts="Conflicts found, look for lines marked with a C in SVNmerge.log in D:\lab (hit enter to exit)")
endlocal
echo SVNMerge completed

rem pause for 5 seconds
CHOICE /N /D Y /T 5 

