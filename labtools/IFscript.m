dt=.1; % time step
tmax=200; % xlim(2)
N=tmax/dt;
Gl=.10;  
C=1;
Th=20;
a=.1; % exp. for alpha function
gmax=100;
t=dt:dt:tmax;
alpha=a^2.*t.*exp(-a*t); %alpha function starting at t=0;
unitalpha=alpha./sum(alpha); % norm to area = 1

Ge=zeros(N,1);
Gi=zeros(N,1);
I=zeros(N,1);
%I(500:1000)=1;
onset=25/dt;
delay=3/dt;

numspikes=5;
Spiketimes={};  
for i=1:25    
spiketrain1=zeros(N,1);
spiketrain2=zeros(N,1);

if (0)  %hand-placed
    spiketrain1(onset)=1;
    spiketrain2(onset+delay)=1;
else    %randomly placed
    spiketimes1=find(poissrnd(numspikes/tmax,tmax,1));
    spiketrain1(spiketimes1./dt)=1;
    %spiketimes2=find(poissrnd(numspikes/tmax,tmax,1));
    spiketimes2=spiketimes1+3;
    spiketrain2(spiketimes2./dt)=1;
end

Ge=conv(unitalpha,spiketrain1);
Gi=conv(unitalpha,spiketrain2); % 
conv_offset=10;
Ge=Ge(1+conv_offset:N+conv_offset); 
Gi=Gi(1+conv_offset:N+conv_offset); 

Ge=Ge/sum(Ge);
Gi=Gi/sum(Gi);
Ge=gmax*Ge;
Gi=gmax*Gi;

[V, spiketimes]=Ifg( Ge, Gi, Gl, I, C,dt, Th);
Spiketimes{i}=spiketimes;  
end
figure(1);clf;
subplot(3,1,2)
plot( t, V, 'k');
title(sprintf('%d spikes, Ge area=%g', length(Spiketimes{i}), sum(Ge)))
subplot(3,1,3)
plot(t, Ge, 'g', t, Gi, 'r');
subplot(3,1,1)
for i=1:length(Spiketimes)
    hold on
    plot(Spiketimes{i}, i+ones(size(Spiketimes{i})), '.')
    Spikecount(i)=length(Spiketimes{i});
end
xlim([0 tmax])
shg
title([sprintf('spikecount: %.1f',mean(Spikecount)),' \pm ',sprintf('%.1f (n=%d trials)', std(Spikecount), i)])
