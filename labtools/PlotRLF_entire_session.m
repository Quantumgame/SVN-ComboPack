function PlotRLF_entire_session(expdate, session, varargin)
%usage PlotTC_spikes_entire_session(expdate, session, [thresh], [xlimits])
%runs PlotTC_spikes on all files in a session

if nargin==0; fprintf('\nno input'); return; end
cells=cell_list_AlstR;
for i=1:length(cells)
    if strcmp(cells(i).expdate, expdate) & strcmp(cells(i).session,session)
        cellnum=i;
    end
end %assumes only one match exists in the cell list



for i=1:length(cells(cellnum).filenum)
    filenum=cells(cellnum).filenum(i, :);
    if nargin==2
        PlotRLF(expdate, session, filenum)
    elseif nargin==3
        PlotRLF(expdate, session, filenum, varargin{1})
    elseif nargin==4
        PlotRLF(expdate, session, filenum, varargin{1}, varargin{2})
    end
    
    
    close all
    
end


