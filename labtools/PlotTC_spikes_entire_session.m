function PlotTC_spikes_entire_session(expdate, session, varargin)
%usage PlotTC_spikes_entire_session(expdate, session, [thresh], [xlimits])
%runs PlotTC_spikes on all files in a session

cellnum=[];
if nargin==0; fprintf('\nno input'); return; end
cells=cell_list_NIHL_xiang;
for i=1:length(cells)
    if strcmp(cells(i).expdate, expdate) & strcmp(cells(i).session,session)
        cellnum=i;
    end
end %assumes only one match exists in the cell list
if isempty(cellnum) error('cell not found in cell list');end


for i=1:size(cells(cellnum).filenum, 1)
    filenum=cells(cellnum).filenum(i, :);
    if nargin==2
        PlotTC_spikes(expdate, session, filenum)
    elseif nargin==3
        PlotTC_spikes(expdate, session, filenum, varargin{1})
    elseif nargin==4
        PlotTC_spikes(expdate, session, filenum, varargin{1}, varargin{2})
    else
        error('wrong number of arguments')
    end
    
    
    close all
    
end


