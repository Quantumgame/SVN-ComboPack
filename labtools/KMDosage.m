function KMDosage(mass)
%usage: KMDosage(mass)
%prints out maintenance and knockdown dosage

knockdown=.004*mass;
maintenance=.003*mass;
fprintf('\nfor a %d gram rat:\n%.2f cc knockdown dose \n%.2f cc maintenance dose', mass, knockdown,maintenance )
fprintf('\n(using KM cocktail that is 10 mg/ml ketamine, .0835 medetomidine)')
fprintf('\n(the resulting dosage is 30 mg/kg ketamine, .24 mg/kg medetomidine)') 