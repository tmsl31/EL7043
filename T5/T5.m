%Redes de Acceso Banda Ancha.
%Tarea 5.
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
K = 4;
[matLimites] = contornos(puntosBS,K);

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

function [superMatLimites] = dibujarLimites(vecLat,vecLong,empresa,nPuntos) 
    %Funcion que obtenga los limites de las celdas y las dibuje en un
    %gráfico.
    
    %nPuntos -> parametros segun el numero de estaciones base que se elige
    %para definir el contorno.
    
    %Graficar el las estaciones base de acuerdo a operador.
    graficarBS(vecLat,vecLong,empresa);
    
    %Numero de estaciones base
    [nBS,~] = size(vecLat);
    %matLimites. Dimensiones.
    superMatLimites = zeros(nPuntos,2,nBS);
    
    %Ciclo.
    count = 1;
    while count <= nBS
        %Obtener los limites y graficar los contornos.
        matLimites = graficarBS(vecLat,vecLong,empresa);
        %Agregar a la super matriz
        superMatLimites(:,:,nBS) = matLimites;
        %Contador.
        count = count + 1;
    end
    

end

function[matLimites] = contornos(coordenadas,K)
    %Funcion que encuentre todos los contornos.
    matLimites = {};
    
    %Numero de coordenadas.
    [nCoord,~] = size(coordenadas);
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
        matUnaCoord = contornoUnaBS(coordenadas(count,:),coord2,K);
        %Agregar a matLimites.
        matLimites = {matLimites,matUnaCoord};
        %
        count = count + 1;
    end
    

end

function [matLimites] = contornoUnaBS(coord0,coord,K)
    %Funcion que dibuje el contorno y obtenga los puntos que definen este.
    %Encontrar los vecinos más cercanos
    indices = knnsearch(coord,coord0,'K',K);
    %Obtener los valores de los mas cercanos
    valoresCercanos = coord(indices,:);
    %Encontrar los puntos medios entre las coordenadas y los puntos
    %cercanos
    puntosMedios = (valoresCercanos + coord0)./2;
    %Dibujar el contorno con los puntos medios.
    matLimites = puntosMedios;
    %Plot
    plot(puntosMedios(:,1),puntosMedios(:,2),'-k')
end

