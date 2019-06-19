%Tarea 6: DIDO.
%Redes de Acceso Banda Ancha
%Tomás Lara A.
clc
clear all
close all

%% Script

%0.- Generar antenas y personas
global fs f c lambda dt

%Parametros.
%Velocidad de la luz
c = 3e8;
%Tiempo entre muestras (1 nanoSegundo).
dt = 1e-9; 
%Frecuencia de muestreo
fs = 1e9;
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
% %Generacion de las matrices.
 [matAntenas,matPersonas] = escenario(dAntenaskm,dMin,usuarios);
 
%1.- Generar las funciones en cada persona.
[funcionCuadrada, rectF] = funcionRect();
[funcionTriangular, triangF] = funcionTriangulo();
[funcionSinusoide, sinusoideF] = funcionSin();
 
%2.- Generacion de las respuestas al impulso.
[mathXY,mathXYF] = matRespuestasImpulso(matPersonas,matAntenas);

%3.- Obtencion de la matriz de senales de antena.
[B1,B2,B3,B4] = obtencionB(mathXYF,rectF,triangF,sinusoideF);
%Plot de las senales
plotSenalesAntenas(B1,B2,B3,B4)

%4.- Obtencion de las funciones originales.


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
end

%1.-
function [cuadrado,cuadradoF] = funcionRect()
    %Funcion que genera una senal cuadrada para uno de los usuarios.
    
    %Generacion de la senal.
    cuadrado = zeros(1,1024);
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
    
    %Generacion de la senal.
    triangulo = zeros(1,1024);
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
    
    %Generacion de la senal.
    sinusoide = zeros(1,1024);
    %Altura del cuadrado.
    count = 256;
    while count <= 768
        sinusoide(count) = sin((count-256)/512*pi);
        count = count + 1;
    end
    %Calculo en el espectro de Fourier.
    sinusoideF = fft(sinusoide);
end

%2.- Generacion de las respuestas la impulso.
function hXY = respuestaXY(X,Y,X0,Y0)
    %Funcion que calcule la respuesta al impulso para la persona ubicada en
    %las coordenadas X,Y a la antena X0, Y0-
    
    global lambda c dt
    %Distancia
    Rxy = sqrt((X-X0)^2+(Y-Y0)^2);
    %Factor de perdidas.
    factor = ((lambda)/(4*pi*Rxy))^2;
    %tau XY
    tauXY = round(Rxy /(c*dt));
    %Generar la respuesta al impulso.
    hXY = zeros(1,1024);
    %Agregar el impulso.
    hXY(tauXY) = factor;
end

%Generacion de todas las respuestas al impulso.
function [mathXY,mathXYF] = matRespuestasImpulso(matPersonas,matAntenas)
    %Funcion que entregue la matriz de respuestas al impulso por cada
    %persona a cada antena.
    
    %Dimensiones
    filsP = size(matPersonas,1);
    filsA = size(matAntenas,1);
    %Creacion del arreglo que almacene las respuestas.
    %Una matriz por persona, donde cada fila es una antena.
    mathXY = zeros(filsA,1024,filsP);
    mathXYF = zeros(filsA,1024,filsP);
    %Calculo de las respuesta al impulso.
    count1 = 1;
    while (count1 <= filsP)
        count2 = 1;
        while (count2 <= filsA)
            mathXY(count2,:,count1) = respuestaXY(matPersonas(count1,1),matPersonas(count1,2),matAntenas(count2,1),matAntenas(count2,1));
            mathXYF(count2,:,count1) = fft(mathXY(count2,:,count1));
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
    

end

%3.- Obtencion de las senales originales.
function [B1,B2,B3,B4] = obtencionB(matH,SF1,SF2,SF3)
    %Obtencion de las matrices originales.
    
    %Params.
    %mathH -> Matrices de H.
    %SF1,SF2,SF3 -> Senales en cada persona en Fourier.
    
    %Generacion de arreglos de B.
    B1 = zeros(1,1024);
    B2 = zeros(1,1024);
    B3 = zeros(1,1024);
    B4 = zeros(1,1024);
    
    %Extraer Cada B.
    count = 1;
    while count<=1024
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