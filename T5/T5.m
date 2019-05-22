%Redes de Acceso Banda Ancha.
%Tarea 5. Parte 1
%Tomas Lara A.


%% SCRIPT.
%1.- Importar datos.
disp('<<Importar Datos>>')
[empresa,lat,long] = importarDatos();
%Vector de coordenadas.
puntosBS = [long,lat];

%2.- Obtener coodenadas
disp('<<Obtener coordenadas>>')
coordenadas = graficarBS(lat,long,empresa);

%3.- Buscar y graficar los vecinos más cercanos.
disp('<<Dibujar limites.>>')
%Numero de vecinos.
[matLimites] = contornos(puntosBS);

%4.- Realizar el cruce con las antenas en tramite.


%% FUNCIONES.
%1.-
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

%.-
function [arrCoordenadas] = graficarBS(lat,long,empresa)
    %Funcion que grafique las estaciones base.
    
    %Diferentes nombres de empresa.
    difEmpresas = unique(empresa);
    difEmpresas(1) = [];
    %Numero de empresas
    numEmpresas = length(difEmpresas);
    %Arreglo de latitudes.
    arrCoordenadas = {[],[],[],[],[],[],[],[],[]};
    %Ciclo
    count = 1;
    while count <= numEmpresas
        if (empresa(count)~="")
        indices = find(empresa == difEmpresas(count));
        %Elemento a agregar-
        coords = [lat(indices),long(indices)];
        %Agregar
        arrCoordenadas{count} = coords;
        count = count + 1;
        end
    end
    
    %Graficar
    hold on
    count2 = 1;
    while count2 <= numEmpresas
        coordsEmpresa = arrCoordenadas{count2};
        latEmpresa = coordsEmpresa(:,1);
        longEmpresa = coordsEmpresa(:,2);
        plot(longEmpresa,latEmpresa,'*')
        count2 = count2 + 1;
    end
%     legend(difEmpresas)
end

function[matLimites] = contornos(coordenadas)
    %Funcion que encuentre todos los contornos.
    
    
    %Numero de vecinos
    K = 1;
    %Numero de coordenadas.
    [nCoord,~] = size(coordenadas);
    %Matriz de limites de circulos
    matLimites = zeros(nCoord,3);
    %Ciclo.
    count = 1;
    while count <= nCoord
        %Por cada que coordenadas encontrar los K vecinos más cercanos y
        %agregarlos a la matriz
        %Coordenadas 
        if (count == 1)
            coord2 = coordenadas(count+1:end,:);        
        elseif (count ==nCoord)
            coord2 = coordenadas(1:count-1,:);            
        else
            coord2 = [coordenadas(1:count-1,:);coordenadas(count+1:end,:)];            
        end
        vecUnCirculo = contornoUnaBS(coordenadas(count,:),coord2,K);
        %Agregar a matLimites.
        matLimites(count,:) = vecUnCirculo;
        %
        count = count + 1;
    end
    hold off
end

function [vecCirculo] = contornoUnaBS(coord0,coord,K)
    %Funcion que dibuje el contorno y obtenga los puntos que definen este.
    %Encontrar los vecinos más cercanos
    indices = knnsearch(coord,coord0,'K',K);
    %Obtener los valores de los mas cercanos
    valoresCercanos = coord(indices,:);
    %Encontrar los puntos medios entre las coordenadas y los puntos
    %cercanos
    puntosMedios = (valoresCercanos + coord0)./2;
    %Calculo del radio.
    r = sqrt((puntosMedios(1)-coord0(1))^2 + (puntosMedios(2)-coord0(2))^2);
    %Dibujar el contorno con los puntos medios.
    vecCirculo = circulo(coord0(1),coord0(2),r);
end

function [vecCirculo] = circulo(x0,y0,r)
    %Funcion que dibuje un circule de tal manera que x0 e y0 son las
    %coordenadas del centro y r es su radio.
    %Basado en: https://la.mathworks.com/matlabcentral/answers/98665-how-do-i-plot-a-circle-with-a-given-radius-and-center
    
    %Vector de angulos
    theta = 0:pi/50:2*pi;
    %Valores en cartesianas
    xUnit = r * cos(theta) + x0;
    yUnit = r * sin(theta) + y0;
    %Matriz de puntos.
    vecCirculo = [x0,y0,r];
    %Plot de la linea.
    plot(xUnit, yUnit,'-k');
end

function [puntosDentro,puntosFuera] = cruceDatos(matCirculos,coord2)
    %Funcion que realice el cruce entre las celdas existentes y los datos
    %de las antenas solicitadaas.
    
    %Numero de antenas solicitadas.
    [nBSPedidas,~] = size(coord2);
    %
    puntosDentro = 0;
    puntosFuera = 0;
    %
    count = 1;
    while count < nBSPedidas
        in = inCirculo(matCirculos,coord2(count,:));
        if(in == 1)
            puntosDentro = puntosDentro + 1;
        else
            puntosFuera = puntosFuera + 1;
        end
        count = count + 1;
    end
end

function [adentro] = inCirculo(matCirculos,punto)
    %Funcion que verifica si un punto se encuentra dentro de alguno de los
    %circulos de la matriz.
    
    adentro = 0;
    %Numero de circulos.
    [nCirculos,~] = size(matCirculos);
    %Ciclo de evaluacin
    count = 1;
    while count <= nCirculos
        centros = matCirculos(:,[1,2]);
        %Distancias
        d = sqrt((centros(1)-punto(1)).^2+(centros(2)-punto(2))^2);
        cond = sum(d<matCirculos(:,3));
        if(cond > 0)
            adentro = 1;
        end
        count = count + 1;
    end
end