%Redes de Acceso Banda Ancha
%Tarea 2.
%Tomas Lara Aravena.
%Parte 2. Grabación de sonido y calculo de figuras.
clear
clc
disp('Se comentan las partes del codigo asociadas a sonido puesto que esto se realizo previamente')
disp('Se adjuntan las muestras de audio realizadas')
%% Generacion de senal inicial.
load('workspaceT2.mat')
%0.- Generacion de senal inicial.
disp('<<Generacion de la senal Original>>')
%Globales grabacion
global fs nBits NumChannels
%Bits de grabacion
nBits = 24;
%Numero de canales.
NumChannels = 1;
%Frecuencia tono (Hz).
f = 500;
%Frecuencia de muestreo.
fs = 44100;
%Potencia de senal original.
amplitud = 0.5;
%Tiempo signal (s) 
tiempoSignal = 5;
%SNR Inicial (dB)
SNRInicial = 40;
%Generacion de la senal
[senalInicial] = generarSenalInicial(f,amplitud,tiempoSignal,SNRInicial);
%Display de informacion
disp(strcat('Inicialmente la senal tienen una amplitud de: ',string(amplitud)))
disp(strcat('Inicialmente la senal tiene un SNR de: ', string(SNRInicial),'dB')) 
%Guardar signal en un achivo .mp4.
filename = 'sonido1.mp4';
audiowrite(filename,senalInicial,fs);

%% Paso de información a telefono.
disp('Archivo se pasa a un telefono móvil a través de Google Drive')
disp('Se emite la muestra de sonido a través de un parlante conectado al celular')

%% Grabación.
disp('Con esta seccion del codigo se realizan las grabaciones.')
%Tiempo de grabacion (8).
tGrab = 8;
% grabarSonidos(tGrab);

%% Procesamiento de las muestras.
disp('Procesamiento del sonido...');
%Lectura de las muestras de sonido capturadas.
[matMuestras] = leerMuestras(5);

%Resultados Experimentales.
[F, NF] = nfExperimental(matMuestras);
disp('<<Resultados Experimentales>>')
disp(strcat('Factor de ruido experimental:',string(F)))
disp(strcat('Noise Figure experimental:',string(NF)))

%Resultados por formula de Friis.
%Obtencion de F y ganancias.
%[vectorGanancias,vectorF] = obtencionGananciasyF(matMuestras);
%Calculo de F y NF equivalentes
[FFriis,NFFriis] = calculadoraFriis(vectorGanancias, vectorF);
%Displays.
disp('<<Resultados por Formula de Friis>>')
disp(strcat('Factor de ruido Friis:',string(FFriis)))
disp(strcat('Noise Figure Friis:',string(NFFriis)))
disp('Se observa una notoria diferencia entre el calculo por Friis y el calculo a traves de experimentacion')
%% Funciones.
% 0.- Generacion de la senal original.
function [senalInicial] = generarSenalInicial(f,amplitud,tTotal,SNR)
    %Funcion que genere la senal inicial a enviar.
    
    %Generacion de la senal.
    [signal,t] = signalGeneration(f,amplitud,tTotal);
    %Generacion del ruido.
    [ruido] = generarRuidoInicial(signal,SNR);
    %Generacion de la senal total.
    senalInicial = ruido + signal;
    %Plot de la senal original.
    figure(1)
    hold on
    plot(t,senalInicial)
    title('Senal ruidosa original')
    xlabel('Tiempo[s]')
    ylabel('Amplitud [.]')
    xlim([0.5,0.55])
    hold off
    
end

function [signal,t] = signalGeneration(f,amplitud,tTotal)
    % Funcion que genere las muestras de una senal sinusoidal con
    % frecuencia f y amplitud A
    
    %Globales
    global fs
    %Periodo de muestreo
    ts = 1/fs;
    %Vector de tiempo
    t = 0:ts:tTotal;
    %Generacion de la senal
    signal = sin(2*pi*t*f);
    signal = amplitud*signal;
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
    %SNR en veces.
    SNR = 10^SNRdB;
    %Ajustar potencia de ruido
    factorAjuste = sqrt(energiaSignal/(SNR*var(ruido)));
    ruido = factorAjuste*ruido;
end

%1.- Grabacion de muestras.
function [] = grabarSonidos(tGrab)
    %Funcion que se utilizo para la grabacion de los sonidos.
    cond = 0;
    while cond == 0
        grabarSonido(tGrab);
        cond = input('Parar(0->NO;else->si?');
    end
end

function [] = grabarSonido(tGrab)
    %Emisiion del sonido para un determinado archivo.
    
    %Globales
    global fs NumChannels nBits
    %Ingresar numero de muestra.
    numeroMuestra = input('Numero de grabacion:');
    %Nombre del archivo.
    filename = char(strcat('sonido',string(numeroMuestra),'.mp4'));
    %Creacion
    recorder = audiorecorder(fs,nBits,NumChannels);
    %Grabacion del sonido
    disp('Inicio Escucha.'); 
    recordblocking(recorder, tGrab);
    senalGrabada = getaudiodata(recorder);
    disp('Fin Escucha.'); 
    %Guardar nuevo archivo con el nombre correspondiente.
    audiowrite(filename,senalGrabada,fs);
end

%2.- Calculo de F y NF experiemntal
function [F, NF] = nfExperimental(matSonido)
    %Funcion que calcule la figura de ruido asociado a n amplificadores
    
    %Global. Frecuencia de muestreo
    global fs
    %Dimensiones de la matriz.
    fils = size(matSonido,2);
    %Obtencion de las senales.
    signal1 = matSonido{1};
    signal2 = matSonido{fils};
    %Calculos de los SNR
    snrInicial = snr(signal1,fs);
    snrFinal = snr(signal2,fs);
    %Factor de Ruido
    F = snrInicial/snrFinal;
    %Figura de Ruido
    NF = 10*log10(F);
end

function [matMuestras] = leerMuestras(numMuestras)
    %Funcion que lea las muestras de sonido grabadas previamente.
    
    %Lectura.
    count = 1;
    %Matriz que almacene los valores.
    matMuestras = {};
    while count <= numMuestras
        sonido = leerSonido(count);
        matMuestras{count} = sonido;
        count = count + 1;
    end

end

function [sonido] = leerSonido(numMuestra)
        %Nombre de archivo.
        filename = char(strcat('sonido',string(numMuestra),'.mp4'));
        %Lectura del archivo
        [sonido,~] = audioread(filename);
end


%3.- Calculo segun Friis.
%Busqueda de parametros.

function[Feq,NFeq] = calculadoraFriis(vectorG, vectorF)
    %Funcion que dadas las características de n amplificadores calcula la
    %figura de ruido equivalente de acuerdo a la ecuación de Friis.
    
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

function [vectorGanancias,vectorF] = obtencionGananciasyF(matSonido)
    %Obtencion de las ganacias de los amplificadores.
    
    %Obtencion de potencias y SNR.
    [vectorPotencias,vectorSNR] = obtencionPotencias(matSonido);
    %Numero de elementos.
    numeroPotencias = length(vectorPotencias);
    numeroGanancias = numeroPotencias - 1;
    %Vector de ganancias
    vectorGanancias = zeros(numeroGanancias,1);
    %Vector de factores de ruido.
    vectorF = zeros(numeroGanancias,1);
    %Ciclo de calculo
    count = 1;
    while count <= numeroGanancias
        GdB = vectorPotencias(count+1)-vectorPotencias(count);
        F = vectorSNR(count)/vectorSNR(count + 1);
        G = 10^(GdB/10);
        vectorGanancias(count) = G;
        vectorF(count) = F;
        count = count + 1;
    end
end


function [vectorPotencias,vectorSNR] = obtencionPotencias(matSonido)
    %Funcion que muestre los gráficos de modo de poder anotar las ganancias
    %obtenidas mediante la funcion snr.
    
    %Numero de muestras.
    nMuestras = size(matSonido,2);
    %Vector que almacene los valores de potencia.
    vectorPotencias = zeros(nMuestras,1);
    %Vector que almacene los SNR.
    vectorSNR = zeros(nMuestras,1);    
    %Calcular las potencias.
    count = 1;
    while count <= nMuestras
        %Valor de SNR asociado a cada senal.
        snrMuestra = snr(matSonido{count});
        %Agregar al vector de SNR.
        vectorSNR(count) = snrMuestra;
        %Obtencion del grafico de SNR para encontrar la potencia.
        snr(matSonido{count});
        %Obtener la potencia en dB
        potenciadB = input('Incluir potencia');
        %Agregar valor de la potencia.
        vectorPotencias(count) = potenciadB;
        count = count + 1;
    end
end
