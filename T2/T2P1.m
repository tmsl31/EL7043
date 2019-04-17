%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte I. Validacion de la ecuacion de Friis.
clear
%% SCRIPT
%1.- Generacion de senal.
%Frecuencia tono (Hz).
f = 500;
%Potencia de senal original.
Ps0 = 12; %dB
%Tiempo signal (s) 
tiempoSignal = 100;
%Generacion de la senal
disp('<<Estado Inicial>>')
[signal,tSignal] = signalGeneration(f,Ps0,tiempoSignal);
%2.- Generacion del ruido original.
%Para esta parte, se utiliza como SNR inicial el utilizado en el ejemplo de
%la clase.
ruido = generarRuidoInicial(signal,71);
% %Calculo de Input SNR.
SNRInputdB = SNRSignal(signal,ruido,1);
SNRInput = SNRSignal(signal,ruido,0);

%3.- Paso por el amplificador.
%Valores de parametros de los amplificadores
NF = 8;       %dB
GdB = 20;     %dB
%Ejemplo con un amplificador
disp('<<Paso por un amplificador>>')
[sOut1Amplificador,nOut1Amplificador] = amplificador(signal,ruido, GdB, NF);
%Calculo de SNR.
SNROut1Amplificador = SNRSignal(sOut1Amplificador,nOut1Amplificador,1);
%Display.
disp(strcat('Potencia Salida un Amplificador [dB] = ',string(10*log10(var(sOut1Amplificador)))))
disp(strcat('Potencia Ruido Salida un Amplificador [dB] = ',string(10*log10(var(nOut1Amplificador)))))
disp(strcat('SNR Salida un Amplificador [dB] = ',string(SNROut1Amplificador)))

%4.- Paso por la cadena de amplificadores.
nAmplificadores = 10;
%Paso por la cadena de amplificacion
[sOut10, nOut10] = cadenaAmplificacion(signal, ruido, GdB, NF, nAmplificadores);
%Calculo de Output SNR.
SNROut10dB = SNRSignal(sOut10,nOut10,1);
SNROut10 = SNRSignal(sOut10,nOut10,0);
%Display de la información.
disp('<<Paso por cadena de 10 amplificadores>>')
disp(strcat('Potencia Senal Salida [dB]',string(10*log10(var(sOut10)))))
disp(strcat('Potencia Ruido Salida [dB]',string(10*log10(var(nOut10)))))
disp(strcat('SNR Salida [dB]',string(SNROut10dB)))

%5.- Calculo de F equivalente, forma experimental.
%Factor de ruido.
Feq = SNRInput/SNROut10;
%Figura de ruido.
NFeq = 10*log10(Feq);
%Displays.
disp('<<F y NF experimental>>')
disp(strcat('Factor de ruido = ',string(Feq)))
disp(strcat('Figura de ruido [dB] = ',string(NFeq)))

%6.- Cálculo mediante la ecuación de Friis.


%% FUNCIONES.
%1.-
function [signal,t] = signalGeneration(f,PdB,tTotal)
    % Funcion que genere las muestras de una senal sinusoidal con
    % frecuencia f y amplitud A
    
    %Frecuencia de muestreo.
    fs = 5*f;
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

%2.-
function [ruido] = generarRuidoInicial(signal,SNRdB)
    %Funcion que genere ruido AWGN con el fin de poder calcular el SNR
    %inicial. Se entrega el valor de SNR para el inicio
    
    %Largo signal
    lSignal = length(signal);
    %Generacion de ruido
    ruido = randn(1,lSignal);
    %SNR inicial [dB]
    SNRInicial = SNRSignal(signal,ruido,1);
    %Energia senal
    energiaSignal = var(signal);
    energiaSignaldB = 10*log10(energiaSignal);
    %Ajustar potencia de ruido
    factorAjuste = sqrt(energiaSignal/(var(ruido)*10^(SNRdB/10)));
    ruido = factorAjuste*ruido;
    %Energia del ruido
    energiaRuido = var(ruido);
    energiaRuidodB = 10*log10(energiaRuido);
    %Nuevo SNR
    SNR = SNRSignal(signal,ruido,1);
    %Display de la informacion inicial.
    %signal.
    disp(strcat('Signal Power [dB] = ',string(energiaSignaldB)))
    %Noise.
    disp(strcat('Noise Power [dB] = ',string(energiaRuidodB)))
    %Valor del SNR.
    disp(strcat('Input SNR [dB] = ',string(SNR)))
end

function [SNR] = SNRSignal(signal,noise,dB)
    %Funcion que calcule el SNR dada la signal y la senal de ruido, es
    %posible escoger entre razon y decibeles.
    
    %Energia de las signales.
    energiaSignal = var(signal);
    energiaRuido = var(noise);
    %SNR en razon.
    SNR = energiaSignal/energiaRuido;
    %Caso en que se quiere en dBmV
    if dB == 1
        SNR = 10 * log10(SNR);
    end
    
end

%3.- 
function [signal,ruido] = amplificador(sIn,nIn, GdB, NF)
    %Funcion que modele un amplificador con una cierta ganancia y una
    %cierta figura de ruido.
    
    %Factor de ruido 
    F = 10^(NF/10);
    %Potencias
    PSin = var(sIn);
    PNin = var(nIn);
    %Ganancia.
    G = 10^(GdB/10);
    %Potencia del output referred noise
    PNa = G*PNin*(F-1);
    %Generacion del ruido de salida del amplificador
    Na = sqrt(PNa) * randn(1,length(sIn));
    %Output Signal
    signal = sIn * sqrt(G);
    ruido = nIn*sqrt(G) + Na;
end

%4.- 
function [signal,ruido] = cadenaAmplificacion(signalIn, ruidoIn, GdB, NF, nAmplificadores)
    %Funcion que modele una cadena de nAmplificadores, amplificadores, como
    %retorno se entrega la senal y el ruido. en la salida de la cadena.
    if nAmplificadores ==1
        [signal,ruido] = amplificador(signalIn,ruidoIn,GdB, NF);
    else
        [s,n] = cadenaAmplificacion(signalIn,ruidoIn,GdB,NF,nAmplificadores-1);
        [signal,ruido] = amplificador(s,n,GdB,NF);
    end  
end
