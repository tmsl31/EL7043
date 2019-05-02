%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.

%Parte 2. Grabaci�n de sonido. Envio primero.

%% SCRIPT.
%0.- Definicion del modo en que se utilizara el script
modo = input('Ingresar modo (Inicial(0);Emisor(1);Receptor(2);Procesamiento(3);Evaluacion(4)): ');
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
    tiempoSignal = 5;
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
        emitirMuestra = input('Emitir Muestra(1):');
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
    tGrab = 8; %segundos
    %Ciclo de grabacion
    numeroMuestra = 2;
    %Numero de amplificadores
    nAmplificadores = 10;
    while numeroMuestra <= 10
        disp(strcat('Inicio de Grabacion',string(numeroMuestra)))
        grabarSonido(numeroMuestra,Fs,nBits,NumChannels,tGrab)  
        numeroMuestra = numeroMuestra + 1;
        grabarMuestra = input('Grabar Muestra(1):');
    end
elseif modo == 3   
    %Calculo de la figura de ruido total experimental.
    nAmplificadores = 10;
    disp('<<Calculo de NF Experimental>>')
    [FExperimental, NFExperimental] = nfExperimental(nAmplificadores);
    disp(strcat('F Experimental: ',string(FExperimental)))
    disp(strcat('NF Experimental: ',string(NFExperimental),'dB'))

    %Calculo de la figura de ruido total por Friis
    disp('<<Calculo de NF por ecuaci�n de Friis>>')
    %Obtencion del vector de potencias.
    disp('Obtencion de las potencias')
    disp('Las potencias se deben obtener a mano, envio adjunto a este archivo el workspace donde se encuentran')
    [vectorPotencias] = obtencionPotencias(nAmplificadores);
    %Obtencion de las ganancias de los amplificadores.
    disp('Vector Potencias')
    disp(vectorPotencias)
    disp('Obtencio de las ganacias de los amplificadores')
    [vectorGanancias] = obtencionGanancias(vectorPotencias);
    disp('Vector Ganancias')
    disp(vectorGanancias)
    %Calculo de las figuras de ruido.
    [vectorF, vectorNF] = figurasRuido(nAmplificadores);
    %Calculo de la ecuacion de Friis.
    [FeqFriis,NFeqFriis] = calculadoraFriis(vectorGanancias, vectorF);
    disp(strcat('F Friis: ',string(FeqFriis)))
    disp(strcat('NF Friis: ',string(NFeqFriis),'dB'))
elseif modo == 4
    %Modo evaluacion para no tener que volver a obtener las ganancias y
    %cargar el workspace.
    %Limpiar el workspace actual.
    clear
    %Cargar el workspace
    load('workspaceEvaluacion.mat')

    %Calculo de la figura de ruido total experimental.
    nAmplificadores = 10;
    disp('<<Calculo de NF Experimental>>')
    [FExperimental, NFExperimental] = nfExperimental(nAmplificadores);
    disp(strcat('F Experimental: ',string(FExperimental)))
    disp(strcat('NF Experimental: ',string(NFExperimental),'dB'))

    %Calculo de la figura de ruido total por Friis
    disp('<<Calculo de NF por ecuaci�n de Friis>>')
    [FeqFriis,NFeqFriis] = calculadoraFriis(vectorGanancias, vectorF);
    disp(strcat('F Friis: ',string(FeqFriis)))
    disp(strcat('NF Friis: ',string(NFeqFriis),'dB')) 
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
    %Emision del sonido a trav�s del parlante
    disp(strcat('Inicio Emision:',string(numeroMuestra)));
    sound(signal,fs)
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
    %Funcion que muestre los gr�ficos de modo de poder anotar las ganancias
    %obtenidas mediante la funcion snr.
    
    count = 1;
    vectorPotencias = zeros(nAmplificadores,1);
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
        GdB = vectorPotencias(count+1)-vectorPotencias(count);
        G = 10^(GdB/10);
        vectorGanancias(count) = G;
        count = count + 1;
    end
end

function [vectorF, vectorNF] = figurasRuido(nAmplificadores)
    %Funcion que calcule la figura de ruido asociado a n amplificadores
    
    %Vector de numeros de amplificador.
    vectorIndices = 2:1:nAmplificadores;
    %Calculo de figuras de ruido.
    vectorF = zeros(nAmplificadores-1,1);
    vectorNF = zeros(nAmplificadores-1,1);
    %Calculo de las figuras de ruido.
    for i = vectorIndices
        %Nombres de los archivos.
        filename1 = char(strcat('sonido',string(i-1),'.wav'));
        filename2 = char(strcat('sonido',string(i),'.wav'));
        %LecturaArchivos
        [signal1,fs1] = audioread(filename1);
        [signal2,fs2] = audioread(filename2);
        %Calculo de snr
        snr1 = snr(signal1,fs1);
        snr2 = snr(signal2,fs2);
        %Factor de ruido 
        F = snr1/snr2;
        %Figura de ruido
        NF = 10*log10(F);
        %Agregar a los vectores
        vectorF(i-1) = F;
        vectorNF(i-1) = NF;
    end    
end

function[Feq,NFeq] = calculadoraFriis(vectorG, vectorF)
    %Funcion que dadas las caracter�sticas de n amplificadores calcula la
    %figura de ruido equivalente de acuerdo a la ecuaci�n de Friis.
    
    %Numero de amplificadores
    nAmplificadores = length(vectorG);
    %Calculo
    count = 1;
    Feq = 0;
    while count <= nAmplificadores
        if count==1
            %Caso de primer termino
            Feq = Feq + vectorF(count);
        else
        %Terminos con division
        termino = (vectorF(count)-1)/(prod(vectorG(1:count-1)));
        Feq = Feq + termino;
        end
        count = count + 1;
    end
    %Figura de ruido.
    NFeq = 10*log10(Feq);
end