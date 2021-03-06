function [imagelist] =PriyaImageSets;  
%TMP version enforced Erik's naming scheme, all images
% have to have same prefix and number, where lower number
% defines which is target.
%
%function [imagelist] =PriyaImageSets; 
% defines image sets for each training step in priya's experiment
% imagelist.ts3 contains training step 3 images etc
% where rats are randomly assigned to target, there are A and B versions

% first filename in list is target, other(s) is(are) distractor(s)

%ts3 contains nike and blank, nike is target
imagelist.ts3 ={ { {'nike_blank01' 'nike_blank02'} 1.0} };

%ts4 contains nike and shuttle, nike is target
imagelist.ts4 ={ { {'nike_shuttle01' 'nike_shuttle02'} 1.0} };

%ts5A contains paintbrush flashlight; paintbrush is target
imagelist.ts5A={  {  {'paintbrush_flashlight01'  'paintbrush_flashlight30'} 1} };
%ts5B contains flashlight paintbrush, flashlight is target
imagelist.ts5B={  {  {'paintbrush_flashlight30'  'paintbrush_flashlight01'} 1} };

%ts6A contains paintbrush morph to flashlight; paintbrush is target
% for 20% probe trials, set extreme to 56, probes 1 
imagelist.ts6A={...
   {  {'paintbrush_flashlight01'  'paintbrush_flashlight30'} 56} ... % pure exemplars
   {  {'paintbrush_flashlight02'  'paintbrush_flashlight29'} 1} ...
   {  {'paintbrush_flashlight03'  'paintbrush_flashlight28'} 1} ...
   {  {'paintbrush_flashlight04'  'paintbrush_flashlight27'} 1} ...
   {  {'paintbrush_flashlight05'  'paintbrush_flashlight26'} 1} ...
   {  {'paintbrush_flashlight06'  'paintbrush_flashlight25'} 1} ...
   {  {'paintbrush_flashlight07'  'paintbrush_flashlight24'} 1} ...
   {  {'paintbrush_flashlight08'  'paintbrush_flashlight23'} 1} ...
   {  {'paintbrush_flashlight09'  'paintbrush_flashlight22'} 1} ...
   {  {'paintbrush_flashlight10'  'paintbrush_flashlight21'} 1} ...
   {  {'paintbrush_flashlight11'  'paintbrush_flashlight20'} 1} ...
   {  {'paintbrush_flashlight12'  'paintbrush_flashlight19'} 1} ...
   {  {'paintbrush_flashlight13'  'paintbrush_flashlight18'} 1} ...
   {  {'paintbrush_flashlight14'  'paintbrush_flashlight17'} 1} ...
   {  {'paintbrush_flashlight15'  'paintbrush_flashlight16'} 1} ... % nearly identical
};

%ts6B contains flashlight morph to paintbrush, flashlight is target
for i=1:length(imagelist.ts6A), % for each image pair, switch order
    imagelist.ts6B{i}{1}{1} = imagelist.ts6A{i}{1}{2}; % target is now distractor
    imagelist.ts6B{i}{1}{2} = imagelist.ts6A{i}{1}{1}; % distractor is now target
    imagelist.ts6B{i}{2} = imagelist.ts6A{i}{2}; % probability is same
end
