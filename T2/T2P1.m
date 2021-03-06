%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte I. Validacion de la ecuacion de Friis.
clear
clc
%% SCRIPT
%Frecuencia tono (Hz).
f = 100;
%Potencia de senal original.
Ps0 = 10; %dB
%Tiempo signal (s) 
tiempoSignal = 5;

%% PRUEBAS
%Prueba 1.
disp('.')
disp('<<Prueba 1>>')
%Noise Figure.
NF1 = 1;
%Ganancia
G1 = 10;
pruebaFriis(f,Ps0,tiempoSignal,NF1,G1)

%Prueba 2.
disp('.')
disp('<<Prueba 2>>')
%Noise Figure.
NF2 = 1;
%Ganancia
G2 = 100;
pruebaFriis(f,Ps0,tiempoSignal,NF2,G2)

%Prueba 3.
disp('.')
disp('<<Prueba 3>>')
%Noise Figure.
NF3 = 5;
%Ganancia
G3 = 1;
pruebaFriis(f,Ps0,tiempoSignal,NF3,G3)

disp('Se observa una concordancia aproximada para valores no muy altos de ganancia')
disp('En caso de alta ganancia la ecuacion de Friis pierde validez pues los terminos asociados a los ultimos amplificadores son despreciables')
disp('Lo mismo ocurre para alto NF')
%% FUNCIONES.
%1.-
function [signal,t] = signalGeneration(f,PdB,tTotal)
    % Funcion que genere las muestras de una senal sinusoidal con
    % frecuencia f y amplitud A
    
    %Frecuencia de muestreo.
    fs = 10*f;
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
    G = GdB;
%     G = 10^(GdB/10);
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
%     if nAmplificadores ==1
%         [signal,ruido] = amplificador(signalIn,ruidoIn,GdB, NF);
%     else
%         [s,n] = cadenaAmplificacion(signalIn,ruidoIn,GdB,NF,nAmplificadores-1);
%         [signal,ruido] = amplificador(s,n,GdB,NF);
%     end
      count = 1;
      signal = 0;
      ruido = 0;
      while count<=nAmplificadores
          if count == 1
              [signal,ruido] = amplificador(signalIn,ruidoIn,GdB,NF);
          else
              [signal,ruido] = amplificador(signal,ruido,GdB,NF);
          end
          count = count + 1;
      end
end

%6.-
function[Feq,NFeq] = calculadoraFriis(vectorGananciasdB,vectorFdB)
    %Funcion que dadas las caracter�sticas de n amplificadores calcula la
    %figura de ruido equivalente de acuerdo a la ecuaci�n de Friis.
    
    %Paso a razon.
    vectorGanancias = 10.^(vectorGananciasdB./10);
    vectorF = 10.^(vectorFdB./10);
    %Numero de amplificadores
    nAmplificadores = length(vectorGanancias);
    %Calculo
    count = 1;
    Feq = 0;
    while count <= nAmplificadores
        if count==1
            %Caso de primer termino
            Feq = Feq + vectorF(count);
        else
        %Terminos con division
        termino = (vectorF(count)-1)/(prod(vectorGanancias(1:count-1)));
        Feq = Feq + termino;
        end
        count = count + 1;
    end
    %Figura de ruido.
    NFeq = 10*log10(Feq);
end

%7.- Funcion que realiza todos los calculos para un conjunto de parametros.
function [] = pruebaFriis(f,Ps0,tiempoSignal,NF,G)
    %1.- Generacion de senal.
    disp('<<Estado Inicial>>')
    [signal,tSignal] = signalGeneration(f,Ps0,tiempoSignal);
    %2.- Generacion del ruido original.
    %Para esta parte, se utiliza como SNR inicial el utilizado en el ejemplo de
    %la clase.
    ruido = generarRuidoInicial(signal,40);
    % %Calculo de Input SNR.
    SNRInputdB = SNRSignal(signal,ruido,1);
    SNRInput = SNRSignal(signal,ruido,0);

    %3.- Paso por el amplificador.
    %Ejemplo con un amplificador
    disp('<<Paso por un amplificador>>')
    [sOut1Amplificador,nOut1Amplificador] = amplificador(signal,ruido, G, NF);
    %Calculo de SNR.
    SNROut1Amplificador = SNRSignal(sOut1Amplificador,nOut1Amplificador,1);
    %Display.
    disp(strcat('Potencia Salida un Amplificador [dB] = ',string(10*log10(var(sOut1Amplificador)))))
    disp(strcat('Potencia Ruido Salida un Amplificador [dB] = ',string(10*log10(var(nOut1Amplificador)))))
    disp(strcat('SNR Salida un Amplificador [dB] = ',string(SNROut1Amplificador)))

    %4.- Paso por la cadena de amplificadores.
    nAmplificadores = 10;
    %Paso por la cadena de amplificacion
    [sOut10, nOut10] = cadenaAmplificacion(signal, ruido, G, NF, nAmplificadores);
    %Calculo de Output SNR.
    SNROut10dB = SNRSignal(sOut10,nOut10,1);
    SNROut10 = SNRSignal(sOut10,nOut10,0);
    %Display de la informaci�n.
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

    %6.- C�lculo mediante la ecuaci�n de Friis.
    %Ganancias
    vectorGananciasdB = 20 * ones(1,nAmplificadores); 
    %Figuras de ruido.
    vectorNF = 8 * ones(1,nAmplificadores);
    %Calculo de la figura de ruido equivalente.
    [FeqFriis,NFeqFriis] = calculadoraFriis(vectorGananciasdB,vectorNF);
    %Impresion en pantalla.
    disp('<<F y NF con ecuaci�n de Friis>>')
    disp(strcat('Factor de ruido = ',string(FeqFriis)))
    disp(strcat('Figura de ruido [dB] = ',string(NFeqFriis)))
    %7.- Ploteo de senales.
    %Senal original.
    hold on
    figure()
    plot(tSignal,signal+ruido)
    title('Senal ruidosa original')
    xlabel('Tiempo[s]')
    ylabel('Amplitud [.]')
    xlim([1.0,1.5])
    hold off
    %Senal final.
    hold on
    figure()
    plot(tSignal,sOut10+nOut10)
    title('Senal ruidosa final(10 amplificadores')
    xlabel('Tiempo[s]')
    ylabel('Amplitud [.]')
    xlim([1.0,1.1])
    hold off

    %Gr�fico de evoluci�n
    [sOut2, nOut2] = cadenaAmplificacion(signal, ruido, G, NF, 2);
    [sOut5, nOut5] = cadenaAmplificacion(signal, ruido, G, NF, 5);
    [sOut8, nOut8] = cadenaAmplificacion(signal, ruido, G, NF, 8);

    hold on
    figure()
    subplot(2,2,1)
    plot(tSignal,sOut2+nOut2)
    title('Senal ruidos, 2 amplificadores')
    xlim([1.0,1.04])

    subplot(2,2,2)
    plot(tSignal,sOut5+nOut5)
    title('Senal ruidos, 5 amplificadores')
    xlim([1.0,1.04])

    subplot(2,2,3)
    plot(tSignal,sOut8+nOut8)
    title('Senal ruidos, 8 amplificadores')
    xlim([1.0,1.04])

    subplot(2,2,4)
    plot(tSignal,sOut10+nOut10)
    title('Senal ruidos, 10 amplificadores')
    xlim([1.0,1.04])
end