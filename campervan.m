%to solve pde with a time derivative
clear
close all

numberOfPDE = 1;
pdem = createpde(numberOfPDE);

%create geometry
P1 = [2;6;4.1;4.5;4.5;3.6;3.6;4.1;0.65;0.65;0.9;0.9;0.87;0.87]; %pot
C1 = [3;4;1;5;5;1;0;0;2.5;2.5]; %campervan
C1 = [C1;zeros(length(P1)-length(C1),1)];
T1 = [3;4;4;5;5;4;0;0;0.5;0.5];
T1 = [T1;zeros(length(P1)-length(T1),1)]; %table
H1 = [4;4.3;0.575;0.05;0.07;0]; %heat source
H1 = [H1;zeros(length(P1)-length(H1),1)];

gd=[P1,C1,T1,H1]; %includes goemetries
sf='(C1+P1)-(T1+H1)'; %doesn't include table of heat source
ns = char('P1','C1','T1','H1')';
g = decsg(gd,sf,ns); %creates geometry
geometryFromEdges(pdem,g);
figure %figure of geometry
pdegplot(pdem,'edgeLabels','on','subdomainLabels','on') 
axis equal

applyBoundaryCondition(pdem,'Edge',[4,7,6,5,9,10],'u',5);  % outside temp
applyBoundaryCondition(pdem,'Edge',[16,15,13,14],'u',400); %heat source temp
specifyCoefficients(pdem,'m',0,'d',1,'c',1,'a',0,'f',0,'face',1); %set conductivity of air
specifyCoefficients(pdem,'m',0,'d',1,'c',10,'a',0,'f',0,'face',2); %set conductivity of pot
setInitialConditions(pdem,20); %initial room temp
msh = generateMesh(pdem,'Hgrad',1.05);
figure
pdemesh(pdem);
axis equal 
nframes = 200;
tlist = linspace(0,0.1,nframes);
pdem.SolverOptions.ReportStatistics ='on'; 
result = solvepde(pdem,tlist);
u1 = result.NodalSolution;

%points to follow temp change at - in pot, handle, standing pos for person
xx = [4.25,3.7,3.25];
yy = [0.7,0.88,1.25];
uintrp = interpolateSolution(result,xx,yy,1:length(tlist));

figure
for j= 1:3
    hold on
plot(tlist,uintrp(j,:))
hold off
end
title('Change of T over time at three points')
xlabel('time')
ylabel('temperature')
legend('pot','handle','person')

figure 
for j = 1:nframes, pdeplot(pdem,'xydata',u1(:,j),'colormap','hot');
hold on 
pdegplot(pdem);
hold off 
Mv(j) = getframe;
end
movie(Mv,1);