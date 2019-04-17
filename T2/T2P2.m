%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte 2. Grabación de sonido.

%% SCRIPT.

%1.- Generacion de senal sin ruido.
%Frecuencia tono (Hz).
f = 300;
%Potencia de senal original.
Ps0 = 12; %dB
%Tiempo signal (s) 
tiempoSignal = 3;
%Generacion de la senal
disp('<<Envío de audio>>')
[signal,tSignal,fs] = signalGeneration(f,Ps0,tiempoSignal);

%2.- Envio y recepcion de signal por el parlante.
%Enviar senal por parlante.
sound(signal,fs)
%% FUNCIONES.

%1.- Generación de la senal de sonido.
%1.-
function [signal,t,fs] = signalGeneration(f,PdB,tTotal)
    % Funcion que genere las muestras de una senal sinusoidal con
    % frecuencia f y amplitud A
    
    %Frecuencia de muestreo.
    fs = 15*f;
    %Periodo de muestreo
    ts = 1/fs;
    %Vector de tiempo
    t = 0:ts:tTotal;
    %Potencia en unidades.
    P = 10^(PdB/10);
    %Generacion de la senal
    signal = sin(2*pi*t*f);
    k = sqrt(P/var(signal));
    signal = k*signal;
end
