%Proyecto final de curso.
%Tomás Lara A.
%Redes de Acceso Banda Ancha.

close all;
clear all;
clc;
%Importar los parametros optimos
load('optParams.mat');

%% Datos de la fibra a utilizar.
global a nClad nCore alpha distanciaRecorrida c
%Velocidad de la luz.
c = 3e8;
%Ancho de la fibra optica (um).
a = 20;
%Indices de refraccion.
nClad = 1.4;
nCore = 1.5;
%Parametro de diseno.
alpha = 2;
%Precision del recorrido (um)
distanciaRecorrida = .5;
%Calcular los coeficientes del polyfit.
ajuste3 = polyfit([0,13.7186/2,13.7186,a],[nCore,(nCore+nClad)/2,1.5,nClad],3);
ajuste4 = polyfit([0,13.7186/2,10,13.7186,a],[nCore,(nCore+nClad)/2,(nCore-nClad)*2/3+nClad,nCore,nClad],4);
%% Script.

% %6.- Variacion en función de la distancia Y.
% figure()
% hold on
% plot(variacion,Y)
% xlabel('Variacion de dispersion [ms]')
% ylabel('Y[\mu m]')
% title('Valor de Y asociado a cada variación de dispersión')
% hold off

%% Comparación de perfiles.
% Base: Calculo de dispersión para el caso base desarrollado en tarea.
%1.- Prueba de la forma original
disp('Grafico de variacion de n(r)...')
%Variacion de n base.
[vecNBase,radios] = variacionN(0,[]);
%Variacion de n para ajuste de grado 3.
[vecN1,~] = variacionN(1,ajuste3);
%Variacion de n para ajuste de grado 4.
[vecN2,~] = variacionN(2,ajuste4);
%Variacion de n para alfa = 3.
[vecN3,~] = variacionN(3,3);
%Variacion de n para alfa = 4.
[vecN4,~] = variacionN(3,4);
%Variacion de n para alfa = 5.
[vecN5,~] = variacionN(3,5);
%Grafico de comparacion de perfiles de  n.
figure()
hold on 
plot(radios,vecNBase)
plot(radios,vecN1)
plot(radios,vecN2)
plot(radios,vecN3)
plot(radios,vecN4)
plot(radios,vecN5)
legend('Perfil Base', 'Ajuste grado 3','ajuste grado 4')
title('Comparación de perfiles de n')
xlabel('Radio [\mu m]')
ylabel('n[]')
hold off

%2.- Busqueda del angulo maximo.
disp('Determinación del ángulo critico para los distintos modos...')
%Modo 0.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,0,[])
%Modo 1.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,1,ajuste3)
%Modo 2.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,2,ajuste4)
%alfa = 3.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,3,3)
%alfa = 4.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,3,4)
%alfa = 5
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,3,5)
%Display de informacion.
disp('El Angulo maximo se encuentra entre 14 y 15 grados desde la horizontal')
disp('Para las proximas actividades se utiliza 14.5 grados desde la horizontal')
thetaInitGrados = input('Angulo de inicio');

%3.- Variacion de Dispersion en funcion de la distancia.
disp('Calculo de las dispersiones...')
vectorD = linspace(1, 1000,1000);
%Obtencion de las dispersiones.
%Modo 0.
[dispersiones0,T0,TBase0,X0,XBase0,Y0,YBase0] = variacionDispersion(vectorD,thetaInitGrados,0,[]);
%Modo 1.
[dispersiones1,T1,TBase1,X1,XBase1,Y1,YBase1] = variacionDispersion(vectorD,thetaInitGrados,1,ajuste3);
%Modo 2.
[dispersiones2,T2,TBase2,X2,XBase2,Y2,YBase2] = variacionDispersion(vectorD,thetaInitGrados,2,ajuste4);
%Modo alfa = 3.
[dispersiones3,T3,TBase3,X3,XBase3,Y3,YBase3] = variacionDispersion(vectorD,thetaInitGrados,3,3);
%Modo alfa = 3.
[dispersiones4,T4,TBase4,X4,XBase4,Y4,YBase4] = variacionDispersion(vectorD,thetaInitGrados,3,4);
%Modo alfa = 3.
[dispersiones5,T5,TBase5,X5,XBase5,Y5,YBase5] = variacionDispersion(vectorD,thetaInitGrados,3,5);
%Grafico comparativo.
figure()
hold on
plot(vectorD,dispersiones0)
plot(vectorD,dispersiones1)
plot(vectorD,dispersiones2)
plot(vectorD,dispersiones3)
plot(vectorD,dispersiones4)
plot(vectorD,dispersiones5)
%plot(vectorD,dispersiones2)
xlabel('Largo fibra (\mu m)')
ylabel('Dispersion (ms)')
title('Dispersion en función de la distancia')
legend('modo 0', 'modo 1', 'modo 2','alfa = 3', 'alfa = 4', 'alfa = 5')
hold off

%4.- Ajuste de una recta al promedio del movimiento.
disp('Aproximación de recta...')
dispAprox0 = aproxRecta(vectorD,dispersiones0);
dispAprox1 = aproxRecta(vectorD,dispersiones1);
dispAprox2 = aproxRecta(vectorD,dispersiones2);
dispAprox3 = aproxRecta(vectorD,dispersiones3);
dispAprox4 = aproxRecta(vectorD,dispersiones4);
dispAprox5 = aproxRecta(vectorD,dispersiones5);

%5.- Calculo de variaciones.
disp('Graficos de variacion...')
[variacion0] = calculoVariaciones(vectorD,dispersiones0,dispAprox0);
[variacion1] = calculoVariaciones(vectorD,dispersiones1,dispAprox1);
[variacion2] = calculoVariaciones(vectorD,dispersiones2,dispAprox2);
[variacion3] = calculoVariaciones(vectorD,dispersiones3,dispAprox3);
[variacion4] = calculoVariaciones(vectorD,dispersiones4,dispAprox4);
[variacion5] = calculoVariaciones(vectorD,dispersiones5,dispAprox5);
%Grafico comparativo de las variaciones.
figure()
hold on
plot(vectorD,variacion0)
plot(vectorD,variacion1)
plot(vectorD,variacion2)
plot(vectorD,variacion3)
plot(vectorD,variacion4)
plot(vectorD,variacion5)
xlabel('Posicion X [\mu m]');
ylabel('Oscilacion dispersion [ms]')
title('Oscilacion de la dispersión')
legend('modo0','modo1','modo2','alfa =3','alfa=4','alfa=5')
hold off
%Calculo de areas encerradas.
disp('Calculo de areas...')
area0 = areaCurva(vectorD,variacion0);
area1 = areaCurva(vectorD,variacion1);
area2 = areaCurva(vectorD,variacion2);
area3 = areaCurva(vectorD,variacion3);
area4 = areaCurva(vectorD,variacion4);
area5 = areaCurva(vectorD,variacion5);
disp('Area 0:')
disp(area0)
disp('Area 1:')
disp(area1)
disp('Area 2:')
disp(area2)
disp('Area 3:')
disp(area3)
disp('Area 4:')
disp(area4)
disp('Area 5:')
disp(area5)

figure()
hold on
plot(variacion0,Y0)
plot(variacion1,Y1)
plot(variacion2,Y2)
plot(variacion3,Y3)
plot(variacion4,Y4)
plot(variacion5,Y5)
xlabel('Variacion de dispersion [ms]')
ylabel('Y[\mu m]')
legend('modo 0', 'modo 1','modo2','alfa=3','alfa=4','alfa=5')
title('Valor de Y asociado a cada variación de dispersión')
hold off

disp('En base a lo anterior se prefiere utilizar un polinomio de grado 4')

%6.- Pruebas de ajuste del polinomio de grado 4.
%Optimizar.
%Se inicia la optimización con los parametros probados.
params0 = [13.7186/2,10,(nCore+nClad)/2,(nCore-nClad)*2/3+nClad];
%Opciones.
options = optimset('Display','iter','PlotFcns',@optimplotfval);
%Busqueda del minimo.
%optParams = fminsearch(@areaMinimizar,params0,options);
%optParams = particleswarm(@areaMinimizar,5);
%Restricciones.
%Lower bound.
lb = [0, 0, nClad, nClad];
%Upper Bound.
ub = [13.7186,13.7186,nCore,nCore];
optParams = fmincon(@areaMinimizar,params0,[],[],[],[],lb,ub);
%7.-Delay con los parametros optimos.
%Variacion de n para los parametros optimos.
disp('Calculo con los valores optimos...')
[vecNOpt,~] = variacionN(4,optParams);
%Modo 2 con parametros optimos.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,4,optParams);
%Calculo de dispersiones con parametros optimos
grado2 = input('Inclinación inicial configuracion optima');
[dispersionesOpt,TOpt,TBaseOpt,XOpt,XBaseOpt,YOpt,YBaseOpt] = variacionDispersion(vectorD,grado2,4,optParams);
%Aproximacion de la recta optima
dispAproxOpt = aproxRecta(vectorD,dispersionesOpt);
%Calculo de las variaciones.
[variacionOpt] = calculoVariaciones(vectorD,dispersionesOpt,dispAproxOpt);
%Calculo del area.
areaOpt = areaCurva(vectorD,variacionOpt);