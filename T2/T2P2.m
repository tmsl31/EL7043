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
    
    %Calculo de la figura de ruido total experimental.
    disp('<<Calculo de NF Experimental>>')
    [FExperimental, NFExperimental] = nfExperimental(nAmplificadores);
    disp(strcat('F Experimental: ',string(FExperimental)))
    disp(strcat('NF Experimental: ',string(NFExperimental),'dB'))

    %Calculo de la figura de ruido total por Friis
    disp('<<Calculo de NF por ecuación de Friis>>')
    %Obtencion del vector de potencias.
    disp('Obtencion de las potencias')
    [vectorPotencias] = obtencionPotencias(nAmplificadores);
    %Obtencion de las ganancias de los amplificadores.
    disp('Obtencio de las ganacias de los amplificadores')
    [vectorGanancias] = obtencionGanancias(vectorPotencias);
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

function [F, NF] = nfExperimental(nAmplificadores)
    %Funcion que calcule la figura de ruido asociado a n amplificadores
    
    %Primer SNR
    filenameInicial = 'sonido1.wav';
    [signalInicial,fsInicial] = audioread(filenameInicial);
    %SNR Final.
    filenameInicial = char(strcat('sonido',string(nAmplificadores),'.wav'));
    [signalFinal,fsFinal] = audioread(filenameInicial);
    %SNR Inicial
    snrInicial = snr(signalInicial,fsInicial);
    snrFinal = snr(signalFinal,fsFinal);
    %Factor de Ruido
    F = snrInicial/snrFinal;
    %Figura de Ruido
    NF = 10*log10(F);
end

function [vectorPotencias] = obtencionPotencias(nAmplificadores)
    %Funcion que muestre los gráficos de modo de poder anotar las ganancias
    %obtenidas mediante la funcion snr.
    
    count = 1;
    vectorPotencias = zeros(nAmplifadores,1);
    %Ciclo.
    while count<nAmplificadores
        %Nombre de archivo.
        filename = char(strcat('sonido',string(count),'.wav'));
        %Lectura del archivo
        [signal,~] = audioread(filename);
        %Calculo de SNR. Plot.
        snr(signal)
        %Agregar potencia
        potencia = input('Incluir potencia');
        %Agregar al vector potencias.
        vectorPotencias(count,:) = potencia;
        count = count + 1;
    end
end

function [vectorGanancias] = obtencionGanancias(vectorPotencias)
    %Obtencion de las ganacias de los amplificadores.
    
    %Numero de elementos.
    numeroPotencias = length(vectorPotencias);
    numeroGanancias = numeroPotencias - 1;
    %Vector de ganancias
    vectorGanancias = zeros(numeroGanancias,1);
    %Ciclo de calculo
    count = 1;
    while count < numeroPotencias
        G = vectorGanancias(count+1)/vectorGanancias(count);
        vectorGanancias(count) = G;
        count = count + 1;
    end
end
