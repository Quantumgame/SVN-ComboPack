function [n1,n2]=binomial_sample_size(p1, p2, r)
% usage:
% [n1,n2]=binomial_sample_size(p1, p2, r)
% 
%computes the sample sizes required to detect a true population difference
%between p1 and p2 %correct, with an alpha (type I error) of 0.05 and a
%beta (type 2 error) of 0.10 (i.e. power=1-beta = 90%). r is the ration of
%sample sizes (r=np2/np1). You can edit the code below to run either a
%one-sided or two-sided test
%
%example: 10% of trials are laser-on trials, so r=9. The mouse gets 75%
% correct on control trials, and 65% correct on laser-on trials.
% r=9
% p2=.75
% p1=.65
% [n1, n2]=binomial_sample_size(.65, .75, 9)
% n1=227, n2=2047
% thus you need 227 laser trials and 2047 control trials to detect the effect with a power of 90%
%
%from Zar Biostatistical Analysis, p. 556-558, example 23.26b, eq 23.76-79

%use this Za for a two-sided test:
%Za=1.96; %Z for alpha=.05, 2 dof (Zar p.App19, t(a(2),inf=1.96)

%use this Za for a one-sided test:
Za=1.6449; %Z for alpha=.05, 1 dof (Zar p.App19, t(a(1),inf=1.6449)


Zb=1.2816; %Z for B=.1, 1 dof
q1=1-p1;
q2=1-p2;
d=abs(p1-p2); 
pbarprime=(p1+r*p2)/(r+1);
qbarprime=1-pbarprime;
n=([Za*sqrt((r+1)*pbarprime*qbarprime) + Zb*sqrt(r*p1*q1+p2*q2)].^2)/(r*d.^2);
n1=(n/4)*[1+sqrt(1+ 2*(r+1)/(r*n*d))].^2;
n2=r*n1;