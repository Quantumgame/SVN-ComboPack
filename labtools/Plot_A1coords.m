%xyz
A1=[0 0 0];
B=[-8588, -3650, -792];
L=[-9040, 3424, 1076];
BL=[-8588, -3650-1000, -792 + -554];
BR=[-8588, -3650+1000, -792 + -1430];

M=[A1; B; L; BL; BR];
X=M(:, 1);
Y=M(:, 2);
Z=M(:, 3);

figure
%hold on
r=plot3(X, Y, Z, 'o');

text(X(1), Y(1), Z(1), 'A1')
text(X(2), Y(2), Z(2), 'B')
text(X(3), Y(3), Z(3), 'L')
text(X(4), Y(4), Z(4), 'BL')
text(X(5), Y(5), Z(5), 'BR')
grid on
shg

set(gca, 'zdir', 'reverse')
xlabel('x')
ylabel('y')
zlabel('z')

get(gca, 'view')