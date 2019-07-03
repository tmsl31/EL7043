% Proyecto final
% Tomas Lara A.
% Redes de Acceso Banda Ancha.

clear;
clc
close all;

%% Datos.
%0.- Datos de la situacion analizada.
global a nClad nCore alpha distanciaRecorrida c;
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

%% Script.

%1.- Prueba de la forma original
disp('Grafico de variacion de n(r)...')
variacionN();

%2.- Determinacion del angulo maximo.
disp('Determinación del ángulo critico...')
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0)
%Display de informacion.
disp('El Angulo maximo se encuentra entre 14 y 15 grados desde la horizontal')
disp('Para las proximas actividades se utiliza 14.5 grados desde la horizontal')

%3.- Variacion de Dispersion en funcion de la distancia.
thetaInitGrados = 14.5;
vectorD = linspace(1, 1000,1000);
%Obtencion de las dispersiones.
disp('Calculo de las dispersiones...')
[dispersiones,T,T0] = variacionDispersion(vectorD,thetaInitGrados);

%4.- Ajuste de una recta al promedio del movimiento.
disp('Aproximación de recta...')
dispAprox = aproxRecta(vectorD,dispersiones);

%Grafico de movimiento de la dispersion.
disp('Graficos de variacion...')
figure()
hold on
plot(vectorD,dispAprox)
plot(vectorD,dispersiones);
xlabel('Posicion X [\mu m]');
ylabel('Dispersion [ms]')
hold off

figure()
hold on
plot(vectorD,dispersiones - dispAprox)
xlabel('Posicion X [\mu m]');
ylabel('Oscilacion dispersion [ms]')
xlabel('Oscilacion de la dispersión')
hold off

%% Funciones 