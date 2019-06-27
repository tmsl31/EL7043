%Tarea 6: DIDO.
%Redes de Acceso Banda Ancha
%Tomás Lara A.
clc
clear all
close all

%% Script

%0.- Generar antenas y personas
global fs f c lambda dt dAntenaskm

%Parametros.
%Velocidad de la luz
c = 3e8;
%Frecuencia de muestreo
fs = 10e9;
%Tiempo entre muestras.
dt = 1/fs;
%Frecuencia de portadora.
f = 700e6;
%Longitud de onda.
lambda = c/f;
%10 metros como distancia minima.
dMin = 1; 
%3 usuarios.
usuarios = 3; 
%km
dAntenaskm = .1;

%0.- Generacion de las matrices de posiciones.
[matAntenas,matPersonas] = escenario(dAntenaskm,dMin,usuarios);
 
%1.- Calculo de las respuestas al impulso.
[mathXY,mathXYF] = matRespuestasImpulso(matPersonas,matAntenas);

%2.- Generacion de las funciones en las personas.
[funcionCuadrada, rectF] = funcionRect();
[funcionTriangular, triangF] = funcionTriangulo();
[funcionSinusoide, sinusoideF] = funcionSin();

figure()
hold on
plot(funcionCuadrada)
plot(funcionTriangular)
plot(funcionSinusoide)
hold off

%3.- Obtencion de la matriz de senales de antena.
[b1,b2,b3,b4] = obtencionB(mathXYF,rectF,triangF,sinusoideF);

%Plot de las senales
plotSenalesAntenas(b1,b2,b3,b4)

%4.- Obtencion de las funciones originales.
[s1,s2,s3] = obtencionOriginales(b1,b2,b3,b4,mathXY);
plotOriginales(s1,s2,s3);
%% Funciones.

%0.- Generar antenas y personas.
function[matAntenas,matPersonas] = escenario(distanciaAntenaskm,dMin,usuarios)
    %Funcion que entregue las coordenadas de las antenas y personas en
    %metros. Se consideran cuatroa antenas por instruccion del profesor.
    
    %Params:
    %distanciaAntenaskm -> Distancia entre las antenas en kilometros.
    
    %Distancia en metros.
    dAntenasm = distanciaAntenaskm * 1000;
    %Matriz de posiciones de las antenas.
    matAntenas = [0,0;0,dAntenasm;dAntenasm,dAntenasm;dAntenasm,0];
    %Posicion de las personas en el arreglo
    matPersonas = randi([dMin,dAntenasm-dMin],usuarios,2);
    %Plot.
    figure()
    hold on
    %Antenas
    plot(matAntenas(:,1)',matAntenas(:,2)','*k')
    %Personas.
    plot(matPersonas(:,1)',matPersonas(:,2)','+r')
    title('Distribucion de antenas y receptores.')
    xlabel('X [m]')
    ylabel('Y [m]')
    legend('Antenas','Receptores')
    
end

%1.- Calculo de las respuestas al impulso.
%2.- Generacion de las respuestas la impulso.
function hXY = respuestaXY(X,Y,X0,Y0,tDiagonal)
    %Funcion que calcule la respuesta al impulso para la persona ubicada en
    %las coordenadas X,Y a la antena X0, Y0-
    
    global lambda c dt 
    %Distancia
    Rxy = sqrt((X-X0)^2+(Y-Y0)^2);
    %Factor de perdidas.
    factor = ((lambda)/(4*pi*Rxy))^2;
    %tau XY (retardo al receptor)
    tauXY = round(Rxy /(c*dt));
    %Generar la respuesta al impulso.
    hXY = zeros(1,tDiagonal);
    %Agregar el impulso.
    hXY(tauXY) = factor;
end

%Generacion de todas las respuestas al impulso.
function [mathXY,mathXYF] = matRespuestasUnaPersona(posPersona,matAntenas)
    %Funcion que calcule las matrices de respuesta al impulso para una
    %persona.
    
    %Variables globales.
    global dAntenaskm c dt
    %Posicion de la persona.
    xPersona = posPersona(1);
    yPersona = posPersona(2);
    %Numero de antenas
    nAntenas = size(matAntenas,1);
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Matrices de resultados
    mathXY = zeros(nAntenas,tDiagonal);
    mathXYF = zeros(nAntenas,tDiagonal);
    %Matriz de respuesta para las distintas antenas.
    count = 1;
    while count <= nAntenas
        %Coordenadas antena.
        X0 = matAntenas(count,1);
        Y0 = matAntenas(count,2);
        %Respuesta al impulso.
        res = respuestaXY(xPersona,yPersona,X0,Y0,tDiagonal);
        %Agregar
        mathXY(count,:) = res;
        mathXYF(count,:) = fft(res);
        %c
        count = count + 1;
    end
end

function [mathXY,mathXYF] = matRespuestasImpulso(matPersonas,matAntenas)
    %Funcion que entregue la matriz de respuestas al impulso por cada
    %persona a cada antena.
    
    %Variables globales.
    global dAntenaskm c dt
    
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Dimensiones
    filsP = size(matPersonas,1);
    filsA = size(matAntenas,1);
    %Creacion del arreglo que almacene las respuestas.
    %Una matriz por persona, donde cada fila es una antena.
    mathXY = zeros(filsA,tDiagonal,filsP);
    mathXYF = zeros(filsA,tDiagonal,filsP);
    %Calculo de las respuesta al impulso.
    count1 = 1;
    while count1 <= filsP
        %Posicion de la persona
        posPersona = matPersonas(count1,:);
        %Matriz con respecto a las antenas.
        [mat,matF] = matRespuestasUnaPersona(posPersona,matAntenas);
        %Agregar.
        mathXY(:,:,count1) = mat;
        mathXYF(:,:,count1) = matF;
        count1 = count1 + 1;
    end
end

%3.- Generacion de las senales en las personas.
function [cuadrado,cuadradoF] = funcionRect()
    %Funcion que genera una senal cuadrada para uno de los usuarios.
    
    %Variables globales.
    global dAntenaskm c dt
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Generacion de la senal.
    cuadrado = zeros(1,tDiagonal);
    %Altura del cuadrado.
    alturaCuadrado = 1;
    %Numero de muestras cuadrado.
    numCuadrado = 512;
    %Agregar cuadrado.
    cuadrado(1,257:numCuadrado+256) = alturaCuadrado;
    %Calcular la funcion en Fourier.
    cuadradoF = fft(cuadrado);
end

function [triangulo,trianguloF] = funcionTriangulo()
    %Funcion que genera una senal Triangular para uno de los usuarios.
    
    
    %Variables globales.
    global dAntenaskm c dt
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Generacion de la senal.
    triangulo = zeros(1,tDiagonal);
    %Altura del cuadrado.
    alturaTriangulo = 1;
    %Pendientes.
    m1 = alturaTriangulo / 255;
    m2 = -1*alturaTriangulo/256;
    %Subida.
    count = 257;
    while count <=512
        %Evaluar.
        valorY = m1 * (count-257);
        triangulo(1,count) = valorY;
        count = count + 1;
    end
    %Bajada
    count1 = 512;
    while count1 <= 768
        %Evaluar.
        valorY = m2 * (count1-512) + alturaTriangulo;
        triangulo(1,count1) = valorY;
        count1 = count1 + 1;
    end
    %Calcular en el espectro de Fourier.
    trianguloF = fft(triangulo);
end

function [sinusoide,sinusoideF] = funcionSin()
    %Funcion que genera una senal Triangular para uno de los usuarios.
    
    
    %Variables globales.
    global dAntenaskm c dt
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Generacion de la senal.
    sinusoide = zeros(1,tDiagonal);
    %Altura del cuadrado.
    count = 256;
    while count <= 768
        sinusoide(count) = sin((count-256)/512*pi);
        count = count + 1;
    end
    %Calculo en el espectro de Fourier.
    sinusoideF = fft(sinusoide);
end

%3.- Obtencion de las senales originales.
function [B1,B2,B3,B4] = obtencionB(matH,SF1,SF2,SF3)
    %Obtencion de las matrices originales.
    
    %Params.
    %mathH -> Matrices de H.
    %SF1,SF2,SF3 -> Senales en cada persona en Fourier.
    
    %Variables globales.
    global dAntenaskm c dt
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Generacion de arreglos de B.
    B1 = zeros(1,tDiagonal);
    B2 = zeros(1,tDiagonal);
    B3 = zeros(1,tDiagonal);
    B4 = zeros(1,tDiagonal);
    
    %Extraer Cada B.
    count = 1;
    while count<=tDiagonal
        %Obtencion de los valores de la senal.
        SF = [SF1(count);SF2(count);SF3(count)];
        %Obtencion de la matriz H.
        H = [matH(1,count,1),matH(2,count,1),matH(3,count,1),matH(4,count,1);
             matH(1,count,2),matH(2,count,2),matH(3,count,2),matH(4,count,2);
             matH(1,count,3),matH(2,count,3),matH(3,count,3),matH(4,count,3)];
        %Calculo de la pseudoinversa.
        Hinv = pinv(H);
        %Calculo de los valores de B.
        B = Hinv * SF;
        %Obtencion de los valores de cada B.
        B1(count) = B(1);
        B2(count) = B(2);
        B3(count) = B(3);
        B4(count) = B(4);
        %
        count = count + 1;
    end
    %Obtener las antitransformadas.
    B1 = ifft(B1);
    B2 = ifft(B2);
    B3 = ifft(B3);
    B4 = ifft(B4);
end

function [] = plotSenalesAntenas(B1,B2,B3,B4)
    %Funcion que realiza grafico de las funciones en 
    
        figure()
        subplot(2,2,1);
        plot(B1)
        xlabel('Numero Muestra')
        ylabel('Amplitud')
        title('Señal B1')

        subplot(2,2,2);
        plot(B2)
        xlabel('Numero Muestra')
        ylabel('Amplitud')
        title('Señal B2')
        
        subplot(2,2,3);
        plot(B3)
        xlabel('Numero Muestra')
        ylabel('Amplitud')
        title('Señal B3')
        
        subplot(2,2,4);
        plot(B4)
        xlabel('Numero Muestra')
        ylabel('Amplitud')
        title('Señal B4')
end

%4.- Obtencion de las funciones originales en las personas.
function [s1,s2,s3] = obtencionOriginales(b1,b2,b3,b4,mathxy)
    %Funcion que obtenga las senales originales en las personas a partir de
    %la matriz de funciones de transferencia y las senales que salen de las
    %estaciones base.
    
    %Obtencion de S1.
    s1 = conv(b1,mathxy(1,:,1)) + conv(b2,mathxy(2,:,1)) + conv(b3,mathxy(3,:,1)) + conv(b4,mathxy(4,:,1));
    s2 = conv(b1,mathxy(1,:,2)) + conv(b2,mathxy(2,:,2)) + conv(b3,mathxy(3,:,2)) + conv(b4,mathxy(4,:,2));
    s3 = conv(b1,mathxy(1,:,3)) + conv(b2,mathxy(2,:,3)) + conv(b3,mathxy(3,:,3)) + conv(b4,mathxy(4,:,3));
end

function [] = plotOriginales(s1,s2,s3)
    %Funcion que realiza una grafica de las senales originales.
    
    
    %Variables globales.
    global dAntenaskm c dt
    %Tiempo total de la diagonal.
    tDiagonal = ceil(sqrt(2) * dAntenaskm * 1000/(c*dt));
    %Punto a fijar la linea.
    SP=tDiagonal;
    
    figure()
    subplot(2,2,1)
    plot(s1)
    line([SP SP],[-1 2],'Color',[1 0 0])   
    
    subplot(2,2,2)
    plot(s2)
    line([SP SP],[-1 2],'Color',[1 0 0])   
    
    subplot(2,2,3)
    plot(s3)
    line([SP SP],[-1 2],'Color',[1 0 0])   
    
end

