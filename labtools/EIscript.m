% Script for calling RecurrentEIModel

% I=0*t; I(50:800)=1; %input
% Iopto=0*t; Iopto(200:600)=-.05; %input

I1=zeros(1, 1000);
Iopto=I1;
I1(50:800)=1; %positive input
Iopto(200:600)=-.05;
RecurrentEIModel(I1, Iopto)