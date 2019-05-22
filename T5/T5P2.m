%Redes de Acceso Banda Ancha.
%Tarea 5. Parte 2
%Tomas Lara A.


%% SCRIPT

disp('hola')


%% FUNCTIONS.

%
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
%
function [mat] = potenciasUnaBS(coordBS,matCoord,matPotencias,Pt,f)
    %Funcion que calcule las potencias reducidas para una estacion base.
    
    %Numero de coordenadas 
    [nCoord,~] = size(matCoord);
    %Matriz auxiliar transpuesta
    matAux = matPotencias';
    
    %Ciclo de evaluaciones
    count = 1;
    while count<=nCoord
       distancia = distanciaEuclideana(matCoord(count,:),coordBS);
       pot = friis(Pt, distancia, f);
       matAux(count) = matAux(count) + pot;
       count = count + 1;
    end
    mat = matAux';
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