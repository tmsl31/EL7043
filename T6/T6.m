%Tarea 6: DIDO.
%Redes de Acceso Banda Ancha
%Tomás Lara A.

%% SCRIPT.

%1.- Generar antenas y personas
dMin = 10; %10 metros como distancia minima.
usuarios = 3; %3 usuarios.
dAntenaskm = 4; %km
%Generacion de las matrices.
[matAntenas,matPersonas] = escenario(dAntenaskm,dMin,usuarios);

%2.- Calcular matriz de funciones de transferencia
%Parametros.
perdidas1 = 0;
f = 700e6;
%Matriz de funciones de transferencia.
H = matH(matAntenas,matPersonas,f,perdidas1);

%3.- Generacion de las signals en receptor.
inicio = 10;
fin = 11;
amplitud = 1;
%Generar.
[tiempo,triangulo,rect,sinusoide] = generarSenales(inicio,fin,amplitud);

%4.- Pasar señales al dominio de Fourier para utilizar ecuacion
[Ftriangulo,Frect,Fsinusoide] = fourier(triangulo,rect,sinusoide);

%5.- Obtencion de las senales originales.
%Obtencion de las senales originales en el espectro de Fourier.
[B1,B2,B3,B4] = signalOriginalF(Ftriangulo,Frect,Fsinusoide,H);
%Obtencion de las senales originales en tiempo
b1 = ifft(B1);
b2 = ifft(B2);
b3 = ifft(B3);
b4 = ifft(B4);

%6.- Comprobar con traslacion temporal y suma.

%% FUNCIONES.
%1.- Generar antenas y personas.
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

%2.-Funciones de transferencia
function [H] = matH(matAntenas,matPersonas,f,perdidas)
    %Funcion que retorne la matriz de funciones de transferencia H.
    
    %Params:
    %matAntenas-> Posiciones de las antenas dim(X) = [nAntenas,2];
    %matPersonas-> Posiciones de las personas dim(X) = [nPersonas,2];

    %Numero de antenas
    nAntenas = size(matAntenas,1);
    %Numero de personas.
    nPersonas = size(matPersonas,1);
    %Matriz H
    H = zeros(nPersonas,nAntenas);
    %Ciclo de llenado de la matriz H.
    count1 = 1;
    while count1 <= nPersonas
        %Avanzar con la persona
        count2 = 1;
        while count2 <= nAntenas
            %Avanzar con la antena.
            H(count1,count2) = funcionTransferencia(matPersonas(count1,:),matAntenas(count2,:),f,perdidas);
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
end

function [Hxy] = funcionTransferencia(pos1,pos2,f,perdidas)
    %Funcion que calcula la funcion de transferencia entre dos nodos, en
    %este caso Tx,Rx. Se calcula H_{x,y}
    
    %Params: pos1->X
    %        pos2->Y.
    %        perdidas -> Indica si considera o no perdidas de Free Space.
    
    %Velocidad de la luz 
    c = 3e8;
    %Calculo de distancia
    Rxy = distancia(pos1,pos2);
    %Calculo de factor de perdidas.
    if (perdidas == 1)
        %Caso con perdidas
        lambda = c/f;
        factor = (lambda/(4*pi*Rxy))^2;
    else
        factor = 1;
    end
    %Calculo la funcion de transferencia.
    exponente = (-1i * 2 * pi * f * Rxy)/c;
    Hxy = factor * exp(exponente);
end

function [d] = distancia(coord1,coord2)
    %Funcion que calcula la distancia euclideana.
    
    X1 = coord1(1);
    X2 = coord2(1);
    Y1 = coord1(2);
    Y2 = coord2(2);
    
    %Distancias
    d = sqrt((X1-X2)^2 + (Y1-Y2)^2);

end

%3.- Generacion de las signals en el receptor.
function[tiempo,triangulo,rect,sinusoide] = generarSenales(inicio,fin,amplitud)
    %Funcion que genere las tres senales a utilizar.
    
    [tiempo,triangulo] = ondaTriangular(inicio,fin,amplitud);
    [~,rect] = ondaRectangular(inicio,fin,amplitud);
    [~,sinusoide] = ondaSinusoidal(inicio,fin,amplitud);

end
function [tiempos,triangulo] = ondaTriangular(inicio,fin,amplitud)
    %Funcion que genere un cierto numero de muestras de una funcion
    %triangular

    %Vector de valores de muestreo 
    f = 10;
    %Periodos
    ts = 1/f;
    %Vector de tiempos.
    tiempos = 0:ts:20;
    nMuestras = length(tiempos);
    %Vector que almacene la senal triangular.
    triangulo = zeros(nMuestras,1);
    %Ciclo
    count = 1;
    while count < nMuestras
        triangulo(count) = amplitud * triangularPulse(inicio,fin,tiempos(count));
        count = count + 1;
    end

end

function [tiempos,rectangulo] = ondaRectangular(inicio,fin,amplitud)
    %Funcion que genere un cierto numero de muestras de una funcion
    %rectangular

    %Vector de valores de muestreo 
    f = 10;
    %Periodos
    ts = 1/f;
    %Vector de tiempos.
    tiempos = 0:ts:20;
    nMuestras = length(tiempos);
    %Vector que almacene la senal triangular.
    rectangulo = zeros(nMuestras,1);
    %Ciclo
    count = 1;
    while count < nMuestras
        rectangulo(count) = amplitud * rectangularPulse(inicio,fin,tiempos(count));
        count = count + 1;
    end
end

function [tiempos,sinusoide] = ondaSinusoidal(inicio,fin,amplitud)
    %Funcion que genere un cierto numero de muestras de una funcion
    %rectangular
    
    %Vector de valores de muestreo 
    f = 10;
    %Periodos
    ts = 1/f;
    %Vector de tiempos.
    tiempos = 0:ts:20;
    nMuestras = length(tiempos);
    %Vector que almacene la senal triangular.
    sinusoide = zeros(nMuestras,1);
    %Ciclo
    count = 1;
    %Factor para la frecuencia
    while count < nMuestras
        tActual = tiempos(count);
        if ((tActual >= inicio) && (tActual<=fin))
            fact = 2*pi/(fin-inicio);
            sinusoide(count) = amplitud*sin((tActual-inicio)*fact) ;
        else
            sinusoide(count) = 0;
        end
        count = count + 1;
    end    
end

%4.-
function [Ftriangulo,Frect,Fsinusoide] = fourier(triangulo,rect,sinusoide)
    %Funcion que calcule la transformada de fourier de las tres senales
    %utilizadas.
    
    %
    Ftriangulo = fft(triangulo);
    %
    Frect = fft(rect);
    %
    Fsinusoide = fft(sinusoide);
end

%5.- Calculo de senal de  estacion base.
function [B1,B2,B3,B4] = signalOriginalF(S1,S2,S3,H)
    %Funcion que calcule las senales originales enviadas desde las BS.
    
    %Dimensiones de las senales.
    dimSenales = length(S1);
    %Creacion de los vectores de entrada
    B1 = zeros(dimSenales,1);
    B2 = zeros(dimSenales,1);
    B3 = zeros(dimSenales,1);
    B4 = zeros(dimSenales,1);
    
    %Calcular.
    count = 1;
    while count <= dimSenales
        %Calcular la muestra de la senal original.
        [compB1,compB2,compB3,compB4] = componenteOriginal(S1(count),S2(count),S3(count),H);
        %Asignar a las senales.
        B1(count) = compB1;
        B2(count) = compB2;
        B3(count) = compB3;
        B4(count) = compB4;
        count = count + 1;
    end
end

function [compB1,compB2,compB3,compB4] = componenteOriginal(S1,S2,S3,H)
    %Funcion que calcule una componente de la funcion original.
    
    %Vector de senales en receptor.
    vectorS = [S1;S2;S3];
    %Igualdad
    mat = pinv(H) * vectorS;
    %Obtencion de componentes
    compB1 = mat(1);
    compB2 = mat(2);
    compB3 = mat(3);
    compB4 = mat(4);
end