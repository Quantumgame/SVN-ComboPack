% Change to the location of these files on your computer....
wn      = load('/Volumes/BIG_VIRUS/CELLS.mat');
gap     = load('/Volumes/BIG_VIRUS/cells1.mat');
tones   = load('/Volumes/BIG_VIRUS/cells2.mat');
tc      = load('/Volumes/BIG_VIRUS/cells3.mat');
onon    = load('/Volumes/BIG_VIRUS/cells4.mat');
offon   = load('/Volumes/BIG_VIRUS/cells5.mat');
wntrain = load('/Volumes/BIG_VIRUS/cells6.mat');

cells         = struct;
cells.wn      = wn.cells;
cells.gap     = gap.cells1;
cells.tones   = tones.cells2;
cells.tc      = tc.cells3;
cells.onon    = onon.cells4;
cells.offon   = offon.cells5;
cells.wntrain = wntrain.cells6;

IDsub = cat(2,extractfield(cells.wn,'expdate')',extractfield(cells.wn,'session')',...
    extractfield(cells.wn,'username')',extractfield(cells.wn,'cell')',extractfield(cells.wn,'tetrode')');
isvector(str2num([cells.wn.expdate]))

join(cells.wn,cells.gap,'key','expdate','key','session','key','username','key','cell','key','tetrode','type','outer')


