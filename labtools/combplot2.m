function Onefig = combplot2(figs,layout)
%COMBPLOT Combines existing axes into one new window.
%   COMBPLOT(FIGS,LAYOUT) copies the axes in the existing figure windows
%   given in vector FIGS into a single new figure. The axes (only one per
%   figure) will be laid out, in order, in a grid specified by LAYOUT (as in
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
%trying to add multiple axes support

m = length(figs);
numchildren= length( get(figs(1),'ch'));

if any( ~ishandle(figs) ) || any( ~strcmp( get(figs,'type'), 'figure' ))
  error('Specified figure(s) do not exist')
elseif prod(layout)~=m*numchildren
  error('Layout does not match the specified number of figures')
end

if nargin == 1,  layout = [m 1];  end

onefig = figure;
 
% check for number of axes per fig
% assumes that it is identical for all figs

k=0;
for j = 1:m
  c = get(figs(j),'ch'); 
  for cindex= length(c):-1:1
      k=k+1;
  % Get the proper position in the layout.
  Lh = subplot(layout(1),layout(2),k);
  pos = get(Lh,'pos');  delete(Lh)

  h = copyobj(c(cindex),onefig); 
    set(h,'unit',get(onefig,'defaultaxesunits'),'pos',pos)
  end
end

if nargout > 0
  Onefig = onefig;
end
