%Redes de Acceso Banda Ancha.
%Tarea 5. Parte 2
%Tomas Lara A.


%% SCRIPT
%1.- Importar los datos.
[~,lat,long] = importarDatos();
%2.- Generar Grilla.
precision = input('Precision: ')
[X,Y,matPotencias] = generarGrilla(long,lat,precision);
%3.- Calcular potencias para todas las antenas.
Pt = 1;
f = 700e6;
[matRadiacion] = propagacionRadiacion(lat,long,X,Y,matPotencias,Pt,f);
%Grafico.
graficar(X,Y,matRadiacion)
%% FUNCTIONS.
%1.- Importar los datos.
function [empresa,lat,long] = importarDatos()
    %Funcion que realice la importacion de los datos, y los separa entre
    %empresa, latitud y longitud.
    
    %Importar datos.
    datosBS = readtable('autorizacionBS2.xlsx');
    %Separar datos.
    empresa = datosBS.Empresa;
    empresa = string(empresa);
    lat = datosBS.Lat;
    lat = -1*lat;
    long = datosBS.Long;
    long = -1*long;
end

%2.- Generar grillas de coordenadas.
function [X,Y,matPotencias] = generarGrilla(long,lat,precision)
    %Funcion que genere los valores X e Y de una grilla con dimensiones de
    
    %Longitudes, ejeX
    %Limites.
    minLong = min(long);
    maxLong = max(long);
    %Vector.
    X = minLong:precision:maxLong;
    %Latitudes
    %Limites.
    minLat = min(lat);
    maxLat = max(lat);
    %Vector.
    Y = minLat:precision:maxLat;
    %Dimensiones de X e Y.
    dimX = length(X);
    dimY = length(Y);
    %Construcción de la matrizVacia
    matPotencias = zeros(dimX,dimY);
end

%3.- Calcular potencias
%
function [matRadiacion] = propagacionRadiacion(lat,long,X,Y,matRadiacion,Pt,f)
    %Funcion que calcule la propagacion de potencias utilizando la ecuacion
    %de Friis
    
    %Numero de BS.
    nBS = size(lat,1);
    %Ciclo
    count = 1;
    while count<=nBS
        %Coordenadas de la BS count-esima
        coordBS = [long(count),lat(count)];
        %Radiacion generada por la matriz
        mat = potenciasUnaBS(coordBS,X,Y,Pt,f);
        %Sumar la radiacion de la antena count-esima
        matRadiacion = matRadiacion + mat;
        %
        count = count + 1;
    end
end

function [mat] = potenciasUnaBS(coordBS,X,Y,Pt,f)
    %Funcion que calcule las potencias reducidas para una estacion base.
    
    %Coordenadas en X.
    nX = length(X);
    %Coordenadas en Y.
    nY = length(Y);
    %mat
    mat = zeros(nX,nY);
    %Ciclo.
    count1 = 1;
    while count1 <= nX
        %Movimiento horizontal.
        count2 = 1;
        while count2<=nY
            %Movimiento vertical
            %Coordenadas del punto a evaluar.
            coord = [X(count1),Y(count2)];
            %Distancia del punto a la estación base.
            d = distanciaEuclideana(coord,coordBS);
            %Calculo de la potencia en el punto a evaluar.
            mat(count1,count2) = friis(Pt,d,f);
            %
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
end

function [power] = friis(Pt, d, f)
    %Funcion que calcule las potencia en un punto dada por la ecuación de
    %Friis.
    
    %Velocidad de la luz.
    c = 3e8;
    %Longitud de onda
    lambda = c/f;
    %Factor de reduccion
    factor = ((lambda/(4*pi))^2)*(1/d.^2);
    %Calculo de la potencia.
    power = Pt*factor;
end

function [dist] = distanciaEuclideana(coord1,coord2)
    %Funcion que calcule la distancia euclideana entre dos coordenadas.
    
    %Coordenadas
    x1 = coord1(1);
    y1 = coord1(2);
    x2 = coord2(1);
    y2 = coord2(2);
    %Distancia
    difX = (x1-x2)^2;
    difY = (y1-y2)^2;
    %
    dist = sqrt(difX+difY);
end

%4.- Graficar.
function [] = graficar(X,Y,mat)
    %Funcion que realice un grafico de calor con el mapa de santiago.


end