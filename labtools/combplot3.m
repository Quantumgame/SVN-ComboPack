function Onefig = combplot3(fig,layout)
%COMBPLOT3 use to reshape mulitple axes from one figure into a new layout in a new figure.
%   COMBPLOT3(FIG,LAYOUT) copies the axes in the existing figure window
%   given in  FIG into a single new figure. The axes will be laid out, in order, in a grid specified by LAYOUT (as in
%   SUBPLOT).
%
%   This is really a way to do SUBPLOT "after the fact."
%
%   Example:
%      close('all'), ezplot('sin(t)',[-pi pi])
%      figure, ezplot('cos(t)',[-pi pi])
%      figure, ezplot('sin(t)+cos(t)',[-pi pi])
%      combplot(1:3,[3 1])
%
%   See also SUBPLOT, COPYOBJ.
%
% Copyright 2003 by Toby Driscoll (driscoll@math.udel.edu). All rights
% reserved.
%
% combplot3: similar to combplot but takes axes from a single figure and
% reshapes them into a new layout
% mw 042508

m = length(fig);
if m~=1 error ('combplot3: use only one figure'), end
numchildren= length( get(fig,'ch'));

if any( ~ishandle(fig) ) || any( ~strcmp( get(fig,'type'), 'figure' ))
  error('Specified figure(s) do not exist')
elseif prod(layout)<m*numchildren
  error('Layout is too small for the specified number of axes')
end

if nargin == 1,  layout = [m 1];  end


onefig=figure;
subplot1(layout(1), layout(2))
k=0;
c=get(fig, 'ch');
for cindex= length(c):-1:1
    k=k+1;
    % Get the proper position in the layout.
    subplot1(k);
    Lh=gca;
    %  Lh = subplot(11,2,k);
    pos = get(Lh,'pos');  %delete(Lh)

    h = copyobj(c(cindex),onefig);
    set(h,'unit',get(onefig,'defaultaxesunits'),'pos',pos)
end

  
% 
% onefig=figure
% 
% k=0;
% c=get(2, 'ch')
% for cindex= length(c)-1:-1:1
%       k=k+1;
%   % Get the proper position in the layout.
%   Lh = subplot(11,2,k);
%   pos = get(Lh,'pos');  delete(Lh)
% 
%   h = copyobj(c(cindex),onefig); 
%     set(h,'unit',get(onefig,'defaultaxesunits'),'pos',pos)
%   end
