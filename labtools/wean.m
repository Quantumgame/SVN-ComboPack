function wean

%prints out a range of dates, and the dates 21 days after them. 
%useful for figuring out when you need to wean a litter.

 fprintf('\n--------------')
 fprintf('\n dob   ... p21')
 fprintf('\n--------------')
 for d=1:30
    fprintf('\n%s ... %s', datestr(datenum(date)-30+d, 'mmm dd'), datestr(datenum(date)-30+21+d, 'mmm dd'))
end