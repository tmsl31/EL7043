%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte 2. Grabación de sonido. Envio primero.

%% SCRIPT.
clear
%0.- Definicion del modo en que se utilizara el script
modo = input('Ingresar modo (0->Inicial;1->Emisor;2->Receptor): ');
if modo == 0
    %0.- Generacion de senal inicial.
    disp('<<Modo Generacion>>')
    disp('<<Generacion de la senal Original>>')
    %Frecuencia tono (Hz).
    f = 500;
    %Frecuencia de muestreso
    fs = 44100;
    %Potencia de senal original.
    Ps0 = 10; %dB
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
    %Display de informacion
    disp(strcat('Inicialmente la senal tienen una potencia de: ',string(Ps0),'dB'))
    disp(strcat('Inicialmente la senal tiene un SNR de: ', string(SNRInicial),'dB')) 
    %Plot de la senal original.
    hold on
    figure(1)
    plot(tSignal,senalTotalInicial)
    title('Senal ruidosa original')
    xlabel('Tiempo[s]')
    ylabel('Amplitud [.]')
    xlim([0.5,0.55])
    hold off
    %Guardar signal en un achivo .mp4.
    filename = 'sonido1.wav';
    audiowrite(filename,senalTotalInicial,fs);
elseif modo == 1
    %Modo Emisor.
    disp('<<Modo Emision>>')
    numeroMuestra = 1;
    while numeroMuestra <= 10
        emisionSonido(numeroMuestra);
        numeroMuestra = numeroMuestra + 1;
    end
    
elseif modo == 2
    disp('<<Modo Recepcion>>')
    %Modo Recepcion
    %Creacion del objeto recorder.
    %Parametros
    Fs = 44100;
    nBits = 24;
    NumChannels = 1;
    %Tiempo de grabacion
    tGrab = 5; %segundos
    %Ciclo de grabacion
    numeroMuestra = 2;
    while numeroMuestra <= 10
        disp(strcat('Inicio de Grabacion',string(numeroMuestra)))
        grabarSonido(numeroMuestra,Fs,nBits,NumChannels,tGrab)  
        numeroMuestra = numeroMuestra + 1;
    end
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

function [] = emisionSonido(numeroMuestra)
    %Emision del sonido para un determinado archivo.
    
    %Nombre del archivo.
    filename = char(strcat('sonido',string(numeroMuestra),'.wav'));
    %Lectura del archivo de sonido almacenado.
    [signal,fs] = audioread(filename);
    %Emision del sonido a través del parlante
    sound(signal,fs)
    pause(6);
    disp(strcat('sonido:',string(numeroMuestra),'emitido'));
end

function [] = grabarSonido(numeroMuestra,Fs,nBits,NumChannels,tGrab)
    %Emisiion del sonido para un determinado archivo.
    
    %Nombre del archivo.
    filename = char(strcat('sonido',string(numeroMuestra),'.wav'));
    %Creacion
    recorder = audiorecorder(Fs,nBits,NumChannels);
    %Grabacion del sonido
    disp('Inicio Escucha.'); 
    recordblocking(recorder, tGrab);
    senalGrabada = getaudiodata(recorder);
    disp('Fin Escucha.'); 
    %Guardar nuevo archivo con el nombre correspondiente.
    audiowrite(filename,senalGrabada,Fs);
end



