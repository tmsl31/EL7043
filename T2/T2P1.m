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
%3.- Paso por el amplificador.



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
function [signal,ruido] = amplificador(sIn,nIn, G, F)
    %Funcion que modele un amplificador con una cierta ganancia y una
    %cierta figura de ruido.

end

function [signal,ruido] = cadenaAmplificacion(signalIn, ruidoIn, G, F, nAmplificadores)
    %Funcion que modele una cadena de nAmplificadores, amplificadores, como
    %retorno se entrega la senal y el ruido. en la salida de la cadena.
    if nAmplificadores ==1
        [signal,ruido] = amplificador(signalIn,ruidoIn,G,F);
    else
        [s,n] = cadenaAmplificacion(signalIn,ruidoIn,G,F,nAmplificadores-1);
        [signal,ruido] = amplificador(s,n,G,F);
    end  
end
