function RecurrentEIModel(I1, I2)
% recurrent E-I firing rate based model
% (no spikes, no conductances)
% loosely based on Ahmadian et al 2013 http://www.ncbi.nlm.nih.gov/pubmed/23663149
% usage: RecurrentEIModel(I1, I2)
% inputs: 
%     I1, I2: two current injection input vectors (same length). 
% I1 goes to both E and I cells, but I2 only goes to the I cell.
% the length of these vectors  will be used as tmax*dt
% example usage:
% I1=zeros(1, 1000);
% Iopto=I1;
% I1(50:800)=1; %positive input
% Iopto(200:600)=-.05;
% RecurrentEIModel(I1, Iopto)
    
tau=10; %membrane time constant
dt=.1;
tmax=length(I1); %ms
t=(1:tmax)*dt;

Ve=0;Vi=0; %initial conditions
Vme=[];
Vmi=[];

Wee=1; %exc-exc weights, Wxy are weights from y to x
Wei=1; %inh-to-exc weights
Wie=1; %exc-to-inh weights
Wii=1; %inh-to-inh weights

i=0;
for tt=t
    i=i+1;
    Ve=Ve+dt*(-Ve/tau +g(Wee*Ve - Wei*Vi + I1(i))/tau);
    Vi=Vi+dt*(-Vi/tau +g(Wie*Ve - Wii*Vi + I1(i)+ I2(i))/tau);
    
    
    Vme=[Vme Ve];
    Vmi=[Vmi Vi];
end

h=plot(t, Vme, 'go', t, Vmi, 'r', t, -5*I2, 'c', t, .5*I1, 'k');
set(h(2), 'linew', 2)
%ylim([-50 100])
grid on

function y=g(x)
%power law (no saturation)
k=3;
n=3;
% k and n define the input-output function (Vm to FR)
% g(x)=kx.^n
y=k*x.^n;
%optionally add saturation to power law
%y(y>100)=100;
%y(y<0)=0;

% function y=g(x)
% %sigmoid with threshold th and slope k
% th=10;
% k=1;
% y=1./(1+exp(-k*(x-th)));

% function y=g(x)
% threshold linear with thresh th and slope k
% th=1;
% k=5;
% y=k*(x-th);
% y(y<0)=0;

