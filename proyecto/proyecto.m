%Proyecto final de curso.
%Tomás Lara A.
%Redes de Acceso Banda Ancha.

close all;
clear all;
clc;

%% Datos de la fibra a utilizar.
global a nClad nCore alpha distanciaRecorrida c ajuste3;
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
%modo
modo = input('modo');

%Si esta en modo uno, calcular los coeficientes del polyfit.
if(modo == 1)
    ajuste3 = polyfit([0,10,13.7186,20],[1.5,1.47,1.5,1.4],3);
end
%% Script.

%1.- Prueba de la forma original
disp('Grafico de variacion de n(r)...')
variacionN(modo);

%2.- Determinacion del angulo maximo.
disp('Determinación del ángulo critico...')
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0,modo)
%Display de informacion.
disp('El Angulo maximo se encuentra entre 14 y 15 grados desde la horizontal')
disp('Para las proximas actividades se utiliza 14.5 grados desde la horizontal')
thetaInitGrados = input('Angulo de inicio');
%3.- Variacion de Dispersion en funcion de la distancia.
disp('Calculo de las dispersiones...')
vectorD = linspace(1, 1000,1000);
%Obtencion de las dispersiones.
[dispersiones,T,T0,X,X0,Y,Y0] = variacionDispersion(vectorD,thetaInitGrados,modo);

%4.- Ajuste de una recta al promedio del movimiento.
disp('Aproximación de recta...')
dispAprox = aproxRecta(vectorD,dispersiones);

%5.- Calculo de variaciones.
disp('Graficos de variacion...')
[variacion] = calculoVariaciones(vectorD,dispersiones,dispAprox);

%6.- Variacion en función de la distancia Y.
figure()
hold on
plot(variacion,Y)
xlabel('Variacion de dispersion [ms]')
ylabel('Y[\mu m]')
title('Valor de Y asociado a cada variación de dispersión')
hold off