function CallModule(name,action)
% CALLMODULE(NAME,ACTION)
		
	fcn = [name, '(''' action ''');'];
%     	fcn = [name '(''' action ''')'];
	evalc(fcn);
	
