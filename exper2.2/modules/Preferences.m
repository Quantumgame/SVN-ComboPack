function varargout = Preferences(varargin) 

% Simple module for changing the user preferences, both from Matlab and
% pref.m.
% It's really annoying when you first start exper, answer THOSE questions
% about your module and data directories, then you happily use exper for
% some time, then you become adventurous (=stupid) and put exper to another
% computer (user, directory,...) only to find out that exper uses Matlab's
% internal preferences which remain the same...:-)))
% foma 10/2002

global exper pref

varargout{1} = lower(mfilename); 

if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
case 'init'

    
case 'reset'
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);
% me
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
