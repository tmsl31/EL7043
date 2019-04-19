%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte 2. Grabación de sonido. Recepcion primero.

%% SCRIPT.
clear
%1.- Generacion de senal inicial.
%Frecuencia tono (Hz).
f = 300;
%Potencia de senal original.
Ps0 = 12; %dB
%Tiempo signal (s) 
tiempoSignal = 3;
%SNR Inicial [dB] 
SNRInicial = 60;
%Numero Muestras
fs = 44100;
instantes = 0:1/(fs):tiempoSignal;
numMuestras = length(instantes);
%2.- Envio y recepcion de signal por el parlante.
%Enviar senal por parlante.
%Veces
veces = [4,6,8,10];
%Matriz que almacene las senales.
matSenales = zeros(10,numMuestras);
%Primera recepcion
grabacion = recepcion(6,fs);
cortada = cortarSilencio(grabacion,numMuestras);
matSenales(2,:) = cortada;
%Ciclo
for i = veces
    %Envio
    disp('envio')
    envio(cortada,fs);
    %Espera
    pause(1.5)
    %Recepcion
    grabacion = recepcion(6,fs);
    cortada = cortarSilencio(grabacion,numMuestras);
    matSenales(i,:) = cortada;
    %Espera
end
%% FUNCIONES.

%1.- Generación de la senal de sonido.
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
%     NumChannels = 1;
    %Creacion
    recorder = audiorecorder(Fs,nBits,1);
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