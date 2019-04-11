%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomás Lara Aravena.

%Parte I. Validación de la ecuación de Friis.

%% SCRIPT
%1.- Generación de señal.
%Frecuencia tono (Hz).
f = 500;
%Amplitud
A = 1;
%Tiempo signal (s) 
tiempoSignal = 5;
[signal,tSignal] = signalGeneration(f,A,tiempoSignal);
%2.- Generacion del ruido original.
%Para esta parte, se utiliza como SNR inicial el utilizado en el ejemplo de
%la clase.
ruido = generarRuidoInicial(signal,71);
%Calculo de Input SNR.
SNRInput = SNRSignal(signal,ruido,0);
%3.- Paso por el amplificador.
%Valor de Noise Figure (dB)
NF = 8;
G = 100;
nAmplificadores = 10;
%Paso por la cadena de amplificación
[outSignal,outNoise] = cadenaAmplificacion(signal, ruido, G, NF, nAmplificadores);
%Calculo de Output SNR.
SNROutput = SNRSignal(outSignal,outNoise,0);
%4.- Calculo de F equivalente.
Feq = SNRInput/SNROutput;
NFeq = 10*log10(Feq);
disp(Feq)
disp(NFeq)
%% FUNCIONES.
%1.-
function [signal,t] = signalGeneration(f,A,tTotal)
    % Funcion que genere las muestras de una señal sinusoidal con
    % frecuencia f y amplitud A
    
    %Frecuencia de muestreo.
    fs = 5*f;
    %Periodo de muestreo
    ts = 1/fs;
    %Vector de tiempo
    t = 0:ts:tTotal;
    %Generacion de la señal
    signal = A*sin(2*pi*t*f);
end

%2.-
function [ruido] = generarRuidoInicial(signal,SNRdB)
    %Funcion que genere ruido AWGN con el fin de poder calcular el SNR
    %inicial. Se entrega el valor de SNR para el inicio
    
    %Largo signal
    lSignal = length(signal);
    %Generacion de ruido
    ruido = randn(1,lSignal);
    %SNR inicial 
    SNRInicial = SNRSignal(signal,ruido,1);
    disp(SNRInicial)
    %Ajustar potencia de ruido
    factorAjuste = sqrt(var(signal)/(var(ruido)*10^(SNRdB/10)));
    ruido = factorAjuste*ruido;
    %Nuevo SNR
    SNR = SNRSignal(signal,ruido,1);
    disp(SNR)
    
end

function [en] = energia(signal)
    %Funcion que calcule la energia de una signal.
    en = var(signal);
end

function [SNR] = SNRSignal(signal,noise,dB)
    %Funcion que calcule el SNR dada la signal y la senal de ruido, es
    %posible escoger entre razon y decibeles.
    
    %Energia de las signales.
    energiaSignal = energia(signal);
    energiaRuido = energia(noise);
    %SNR en razon.
    SNR = energiaSignal/energiaRuido;
    %Caso en que se quiere en dBmV
    if dB == 1
        SNR = 10 * log10(SNR);
    end
    
end

%3.- 
function [signal,ruido] = amplificador(sIn,nIn, G, NF)
    %Funcion que modele un amplificador con una cierta ganancia y una
    %cierta figura de ruido.
    
    %Factor de ruido 
    F = 10^(NF/10);
    %Potencias
    PSin = var(sIn);
    PNin = var(nIn);
    %Potencia del output referred noise
    PNa = G^2.*PNin.*(F-1);
    %Generacion del ruido de salida del amplificador
    Na = sqrt(PNa) * randn(1,length(sIn));
    %Output Signal
    signal = sIn * G;
    ruido = nIn*G + Na;
end

function [signal,ruido] = cadenaAmplificacion(signalIn, ruidoIn, G, NF, nAmplificadores)
    %Funcion que modele una cadena de nAmplificadores, amplificadores, como
    %retorno se entrega la senal y el ruido. en la salida de la cadena.
    if nAmplificadores ==1
        [signal,ruido] = amplificador(signalIn,ruidoIn,G, NF);
    else
        [s,n] = cadenaAmplificacion(signalIn,ruidoIn,G,NF,nAmplificadores-1);
        [signal,ruido] = amplificador(s,n,G,NF);
    end  
end
