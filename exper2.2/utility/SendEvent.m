function SendEvent(event, param, sender, recipients)
% sends event to all open modules (control module plus modules in its
% sequence parameter)
%
% event - the event itself
% param - possible additional parameter of the event (usually empty:-)
% sender - module sending the event
% recipients - modules to receive the event: 'all' every open module will
% receive the event, anything else: only modules dependent on sender wil
% receive the event

global exper pref

if nargin<4
    recipients='';
end

if nargin<3
    sender='';
end

if strcmpi(recipients,'all')                            % event goes to all modules
    modules=GetParam('control','dependents','list');    % get the list of open modules
    if ~strcmpi(sender,'control')                       % if control is not the sender
        modules={'control' modules{:}};                 % add control to the list
    end
else
    modules=GetParam(sender,'dependents','list');    % even goes only to those modules which depend on sender
end

idx=find(strcmpi(modules,sender));
if ~isempty(idx)
    modules(idx)='';
end

for n=1:length(modules) % event goes first, because each module works according to varargin{1}
    fcn=[modules{n} '(''' event ''',''' param ''',''' sender ''');'];
	eval(fcn);	
end