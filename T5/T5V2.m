%Tarea 5.
%Tomas Lara A.
%Redes de Acceso Banda Ancha.
%clear all
%close all
%% Script.
%Variables globales.
global Rkm Rm f c lambda Pt
%Radio de la tierra (km).
Rkm = 6372.795477598;
%Radio de la tierra (m);
Rm = Rkm * 1000;
%Frecuencia de transmision (700 MHz).
f = 700e6;
%Velocidad de la luz en el vacio (m/s).
c = 3e8;
%Longitud de onda
lambda = c/f;
%Potencia de tranmision de la antena.
Pt = 20;
%Precision.
precision = 0.0001;

%1.- Importar los datos.
%[empresa,lat,long] = importarDatos();

%2.- Filtrar los datos segun la zona a estudiar.
%Prints.
disp('La zona a utilizar corresponde a un sector de la comuna de San Miguel')
disp('[-33.4832, -33.4954] Lat; [-70.6509, -70.6639] Long con antenas en tramite')
%Limites de latitud y longitud.
limLat = [-33.4832, -33.4954];
limLong = [-70.6509, -70.6639];
%Filtrado de los datos.
%[empresa,coords] = filtrarDatos(empresa,lat,long,limLat,limLong);

%4.- 
disp('Calculando potencias...')
[X,Y,matRadiacion] = calcularPotencias(limLat,limLong,precision,coords,1);
hold on
contourf(X,Y,matRadiacion)

%3.- Plot de las calles.
disp('Graficando mapa...')
plotCalles('map2.osm',limLat,limLong)

%% Funciones.

%1.- Importar los datos.
function [empresa,lat,long] = importarDatos()
    %Funcion que realice la importacion de los datos, y los separa entre
    %empresa, latitud y longitud.
    
    %Disp
    disp('Importando Datos...')
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

%2.- Filtrado de los datos
function [empresa2,coords] = filtrarDatos(empresa,lat,long,limLat,limLong)
    %Funcion que filtre los datos de acuerdo a la zona que se esta
    %estudiando.
    
    %Disp
    disp('Filtrando Datos...')
    %Numero de datos.
    nDatos = length(empresa);
    %Ciclo de revision de los datos.
    count = 1;
    count1 = 1;
    while count <= nDatos
        %Condicion de latitud.
        if ((lat(count)>=limLat(2)) && (lat(count)<=limLat(1)))
            %Condicion de longitud.
            if ((long(count)>=limLong(2)) && (long(count)<=limLong(1)))
                lat2(count1) = lat(count);
                long2(count1) = long(count);
                empresa2(count1) = empresa(count);
                count1 = count1 + 1;
            end
        end
        count = count + 1;
    end
    nLong = length(lat2);
    long2 = reshape(long2,[nLong,1]);
    lat2 = reshape(lat2,[nLong,1]);
   %Generacion de la estructura de coordenadas.
   coords = [long2,lat2];
    
end

%3.- Plot de las calles. Se utiliza codigo entregado por el profesor en
%material docente del curso.

function [] = plotCalles(filename,limLat,limLong)
    tic

    fileID = fopen(filename,'r','n','UTF-8');
    A = textscan(fileID,'%s', 'delimiter', '\n'); % , 'whitespace', '');
    fclose(fileID);

    R = length(A{1}); % number of rows in the file

    nodes = zeros(R,3);
    % nodes(1) = id
    % nodes(2) = longitude
    % nodes(3) = latitute

    n = 0;
    first_way = 1;
    % condition = zeros(1,R);
    % ci = 10; % condition intervals
    % for c = 1:ci-1
    %     condition(ceil(R*c/ci)) = 1;
    % end

    % Build node repository
    fprintf('Building node repository...')
    for r = 1:R

        temp = cell2mat(A{1}(r));
        %     disp(temp)

        if contains(temp,'<node')
            n = n+1;
            quot = strfind(temp,'"');

            nodes(n,1) = extract_value(temp, 'id', quot);
            nodes(n,2) = extract_value(temp, 'lon', quot);
            nodes(n,3) = extract_value(temp, 'lat', quot);

            last_node_row = r;
        end

        if first_way
            if contains(temp,'<way')
                first_way_row = r;
                first_way = 0;
            end
        end

        %     if condition(r)
        %         fprintf('.')
        %     end

    end
    fprintf(' %f\n', toc)
    fprintf('There are %d nodes\n\n', n)
    % fprintf('Last node: %d, first way: %d\n', last_node_row, first_way_row)
    nodes = nodes(1:n,:);
    % plot(nodes(:,2), nodes(:,3), '.b')




    ways = zeros(R,4);
    % ways(1) = code (0 unknown, 1 highway)
    % ways(2) = start row
    % ways(3) = end row
    % ways(4) = number of ref elements

    w = 0;
    inside_way = 0;
    structure_found = 0;
    highways = 0;
    refs = 0;

    % Search for components
    fprintf('Search for components...')
    for r = first_way_row:R

        temp = cell2mat(A{1}(r));

        if ~inside_way
            if contains(temp,'<way')
                w = w+1;
                ways(w,2) = r;
                inside_way = 1;
            end
        end

        if inside_way
            if contains(temp,'ref=')
                refs = refs+1;
            end

            if ~structure_found
                if contains(temp,'<tag k="highway"')
                    ways(w,1) = 1;
                    highways = highways+1;
                    structure_found = 1;
                end
            end

            if contains(temp,'</way>')
                ways(w,3) = r;
                ways(w,4) = refs;
                refs = 0;
                inside_way = 0;
                if structure_found
                    structure_found = 0;
                    %         else
                    %             cprintf('*cyan', 'Structure not found.\n')
                end
            end

        end

        %     if condition(r)
        %         fprintf('.')
        %     end

    end
    fprintf(' %f\n', toc)
    fprintf('There are %d components\n', w)
    fprintf('There are %d streets\n\n', highways)

    ways = ways(1:w,:);



    W = w;
    P = 0;
    % Plot streets
    fprintf('Plotting streets...')
    for w = 1:W

        if ways(w,1) == 1
            ref = zeros(1,ways(w,4));
            for scan = ways(w,2)+1:ways(w,3)-1
                temp = cell2mat(A{1}(scan));
                if contains(temp,'ref=')
                    P = P+1;
                    quot = strfind(temp,'"');
                    ref(P) = extract_value(temp, 'ref', quot);
                end
            end
            street_lon = zeros(P,1);
            street_lat = zeros(P,1);
            for p = 1:P
                r = find(ref(p) == nodes(:,1),1);
                street_lon(p) = nodes(r,2);
                street_lat(p) = nodes(r,3);
            end
            P = 0;
            plot(street_lon, street_lat, 'g')
            pause(0)
        end

    end
    fprintf(' %f\n', toc)
    %Limites del grafico.
    ylim([limLat(2),limLat(1)])
    xlim([limLong(2),limLong(1)])
end

% Funcion profe.
function value = extract_value(search_string, value_name, quot, varargin)

pos = strfind(search_string, [' ', value_name, '=']);
if ~isempty(pos)
    varquot = quot(find(quot>pos,2));
    value = str2double(search_string(varquot(1)+1:varquot(2)-1));
else
    cprintf('*cyan', 'No %s value found.\n', value_name)
    value = 0;
end

end

%4.- Calculo de las potencias.
function [X,Y,matRadiacion] = calcularPotencias(limLat,limLong,precision,coords,norm)
    %Funcion que calcule la distribucion de radiacion sobre la zona
    %deseada.
    
    %Generacion de la grilla.
    [X,Y,matPotencias] = generarGrilla(limLat,limLong,precision);
    %Calculo para cada estacio base.
    %Numero de coordenadas
    nCoord = size(coords,1);
    %Declaracion de la matriz de radiacion
    matRadiacion = zeros(size(matPotencias));
    %Ciclo.
    count = 1;
    while count <= nCoord
        %Agregar la radiacion de una estacion base.
        matRadiacion = matRadiacion + potenciaUnaBS(coords(count,:), X, Y, matPotencias);
        %.
        count = count + 1;
    end
    %Normalizar respecto 
    if (norm==1)
        %promedio = mean(reshape(matRadiacion,[],1));
        %desviacion = std(reshape(matRadiacion,[],1));
        maximo = min(reshape(matRadiacion,[],1));
        matRadiacion = (matRadiacion/maximo);
    end
end

function [X,Y,matPotencias] = generarGrilla(limLat,limLong,precision)
    %Funcion que genere los valores X e Y de una grilla con dimensiones de
    
    %Longitudes, ejeX
    %Limites.
    minLong = limLong(2);
    maxLong = limLong(1);
    %Vector.
    X = minLong:precision:maxLong;
    %Latitudes
    %Limites.
    minLat = limLat(2);
    maxLat = limLat(1);
    %Vector.
    Y = minLat:precision:maxLat;
    %Dimensiones de X e Y.
    dimX = length(X);
    dimY = length(Y);
    %Construcción de la matrizVacia
    matPotencias = zeros(dimY,dimX);
end

function [matUnaBS] = potenciaUnaBS(coordBS, X, Y, matPotencias)
    %Funcion que calcule los valores de potencia en los puntos de la matriz
    %de potencias.
    
    %Dimensiones de la matriz de potencias.
    [fils,cols] = size(matPotencias);
    %Inicializacion de la matriz de una BS.
    matUnaBS = zeros(fils,cols);
    %Ciclo de calculo.
    count1 = 1;
    while count1 <= fils 
        count2 = 1;
        while count2 <= cols
            %Coordenadas del punto a calcular.
            coordPunto = [X(count2),Y(count1)];
            %Calculo de la distancia entre los puntos.
            d = distanciaCoordenadas(coordPunto,coordBS);
            %Calculo de la potencia.
            potencia = friis(d);
            %Agregar potencia a la matriz de potencias.
            matUnaBS(count1,count2) = matUnaBS(count1,count2) + potencia;
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
    

end

function [power] = friis(d)
    %Funcion que calcule las potencia en un punto dada por la ecuación de
    %Friis.
    
    %Params:
    %d -> Distancia de la antena al punto de evaluacion.
    
    %Global, lambda y Pt.
    global lambda Pt 
    %Factor de reduccion
    factor = ((lambda/(4*pi))^2)*(1/d.^2);
    %Calculo de la potencia.
    power = Pt*factor;
end

function [dist] = distanciaCoordenadas(coord1,coord2)
    %Funcion que calcule la distancia en metros a partir de dos coordenadas.
    
    %Variable global, radio terrestre.
    global Rm
    %Coordenadas
    long1 = coord1(1);
    lat1 = coord1(2);
    long2 = coord2(1);
    lat2 = coord2(2);
    %Paso de grados a radianes
    long1 = long1*pi/180;
    lat1 = lat1*pi/180;
    long2 = long2*pi/180;
    lat2 = lat2*pi/180;
    %Valores positivos.
    long1 = abs(long1);
    lat1 = abs(lat1);
    long2 = abs(long2);
    lat2 = abs(lat2);
    %Deltas
    deltaLong = long2-long1;
    %factorAngulos
    factor = acos(cos(lat1) * cos(lat2) * cos(deltaLong) + sin(lat1) * sin(lat2));
    %Distancia
    dist = Rm * factor;
end

