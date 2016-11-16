function age_out=age(dob)
%returns age of animal in days
%usage: age(dob)
age_out=datenum(date)-datenum(dob);