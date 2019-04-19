%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte 2. Grabación de sonido. Envio primero.

%% SCRIPT.
clear
%1.- Generacion de senal inicial.
%Frecuencia tono (Hz).
f = 300;
%Frecuencia de muestreso
fs = 44100;
%Potencia de senal original.
Ps0 = 20; %dB
%Tiempo signal (s) 
tiempoSignal = 3;
%SNR Inicial [dB] 
SNRInicial = 60;
%Generacion de la senal
[signal,tSignal] = signalGeneration(f,Ps0,tiempoSignal,fs);
%Generacion del Ruido.
ruido = generarRuidoInicial(signal,SNRInicial);
%senal de salida.
senalTotalInicial = signal + ruido;
%Plot de la senal original.
hold on
figure(1)
plot(tSignal,senalTotalInicial)
title('Senal ruidosa original')
xlabel('Tiempo[s]')
ylabel('Amplitud [.]')
xlim([0.5,0.55])
hold off

%2.- Envio y recepcion de signal por el parlante.
%Enviar senal por parlante.
%Veces
veces = [3,5,7,9];
%Matriz que almacene las senales.
numMuestras = length(tSignal);
matSenales = zeros(10,numMuestras);
%Guardar senal original 
matSenales(1,:) = senalTotalInicial;
%Ciclo envio recepcion.
%Primer envio.
%Envio
envio(senalTotalInicial,fs);
for i = veces
    %Recepcion
    grabacion = recepcion(6,fs);
    cortada = cortarSilencio(grabacion,numMuestras);
    matSenales(i,:) = cortada;
    %Espera
    
    %Envio
    disp('envio')
    envio(cortada,fs);
end
%% FUNCIONES.

%1.-
function [signal,t] = signalGeneration(f,PdB,tTotal,fs)
    % Funcion que genere las muestras de una senal sinusoidal con
    % frecuencia f y amplitud A
    
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

function [ruido] = generarRuidoInicial(signal,SNRdB)
    %Funcion que genere ruido AWGN con el fin de poder calcular el SNR
    %inicial. Se entrega el valor de SNR para el inicio
    
    %Largo signal
    lSignal = length(signal);
    %Generacion de ruido
    ruido = randn(1,lSignal);
    %Energia senal
    energiaSignal = var(signal);
    %Ajustar potencia de ruido
    factorAjuste = sqrt(energiaSignal/(var(ruido)*10^(SNRdB/10)));
    ruido = factorAjuste*ruido;
end

%2.- 
function [signal] = recepcion(tGrab,fs)
    %Funcion que reproduzca el sonido.
    
    %Creacion del objeto recorder.
    %Parametros
    Fs = fs;
    nBits = 24;
    NumChannels = 1;
    %Creacion
    recorder = audiorecorder(Fs,nBits,NumChannels);
    %Grabar.
    disp('Inicio Escucha.'); 
    recordblocking(recorder, tGrab);
    disp('Fin Escucha.');
    signal = getaudiodata(recorder);

end

function [] = envio(signal,fs)
    %Funcion que realiza la emision de sonido
    
    %Reproducir.
    soundsc(signal,fs);
end

function [signalCortada] = cortarSilencio(grabacion,numeroMuestras)
    %Quitar instante inicial y final de silencio en la grabacion.
    
    %Encontrar niveles de senal.
    mayores = (grabacion>=2e-4);
    %Encontrar inicio de senal.
    indices = find(mayores==1);
    inicioSenal = indices(1);
    %Capturar senal desde su inicio
    signalCortada = grabacion(inicioSenal:inicioSenal + numeroMuestras - 1);
end