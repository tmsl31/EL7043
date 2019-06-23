%Tarea 5.
%Tomas Lara A.
%Redes de Acceso Banda Ancha.
clear all
close all
%% Script.
%Variables globales.
global Rkm Rm f c lambda Pt precision
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
Pt = 20; %W
%Precision.
precision = 0.0001;

%1.- Importar los datos.
[empresa,lat,long] = importarDatos('autorizacionBS3.xlsx');

%2.- Filtrar los datos segun la zona a estudiar.
%Limites de latitud y longitud.
limLat = [-33.4873, -33.4995];
limLong = [-70.6497, -70.6599];
%Prints.
disp('La zona a utilizar corresponde a un sector de la comuna de San Miguel')
disp('[-33.4832, -33.4954] Lat; [-70.6509, -70.6639] Long con antenas en tramite')
%Filtrado de los datos.
[empresa,coordsBS] = filtrarDatos(empresa,lat,long,limLat,limLong);

%3 .- Decaimiento de la potencia de acuerdo a la distancia (Visualizar).
%Prueba con 5 km
d = 0:1:5000;
PrdB = decaimientoFriis(d,1);
%Grafico
hold on
plot(d/1000,PrdB)
xlabel('Distancia [km]')
ylabel('Potencia Recibida [dB]')
title('Prueba de potencia recibida vs distancia')
hold off

%4.- Calculo de potencias de antenas actuales. 
disp('Calculando potencias...')
%Generar la grilla.
[longs,lats,matPotencias] = generarGrilla(limLat,limLong);
%Calcular las potencias.
matPotencias = calcularPotencias(matPotencias,longs,lats,coordsBS);

%4.- Grafico de antenas actuales y en tramite.
disp('Graficar antenas en tramite...')
disp('Se busca las antenas en tramite que se encuentran en la zona')
%Importar antenas en tramite.
[empresaT,latT,longT] = importarDatos('tramite.xlsx');
[empresaT,coordsBST] = filtrarDatos(empresaT,latT,longT,limLat,limLong);
%Graficar
graficoBSPotencia(coordsBS,coordsBST,matPotencias,longs,lats);

%5.- Plot de las calles.
disp('Graficando mapa...')
plotCalles('map2.osm',limLat,limLong)
hold off

%6.- Comparacion incluyendo las nuevas antenas.
disp('Comparacion considerando que se incluyen las nuevas antenas...')
%Calcular las potencias.
coordsBS2 = [coordsBS;coordsBST];
%Generar la grilla.
[longs2,lats2,matPotencias2] = generarGrilla(limLat,limLong);
%Calcular potencia total.
matPotencias2 = calcularPotencias(matPotencias2,longs2,lats2,coordsBS2);
%Graficar
graficoBSPotencia(coordsBS2,coordsBST,matPotencias2,longs2,lats2);
plotCalles('map2.osm',limLat,limLong)
title('Distribución de la potencia considerando antenas en tramite [dB].')
hold off

disp('Se observa que existe una correlación entre zonas de baja potencia y zonas donde se tiene antenas en tramite')
disp('Tambien, se observa solicitudes de ingreso de antenas en zonas cercanas a los metros San Miguel y Lo Vial')
disp('Lo que podría explicarse por la alta densidad de personas')
disp('Se observa un aumento de cobertura en zonas de baja potencia al agregar las antenas en tramite')
%% Funciones.

%1.- Importar los datos.
function [empresa,lat,long] = importarDatos(filename)
    %Funcion que realice la importacion de los datos, y los separa entre
    %empresa, latitud y longitud.
    
    %Disp
    disp('Importando Datos...')
    %Importar datos.
    datosBS = readtable(filename);
    %Separar datos.
    empresa = datosBS.Empresa;
    empresa = string(empresa);
    lat = datosBS.Latitud;
    lat = lat;
    long = datosBS.Longitud;
    long = long;
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
        end

    end
    fprintf(' %f\n', toc)
    %Limites del grafico.

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
function [matPotencias] = calcularPotencias(matPotencias,longs,lats,coordsBS)
    %Calculo de la potencia agregada de todas las estaciones base.
    
    %CoordBS = [long,lat];
       
    %Numero de coordenadas.
    nCoords = size(coordsBS,1);
    %Recorrido 
    count = 1;
    while count <= nCoords
        %Obtener coordenadas.
        coord = coordsBS(count,:);
        %Calcular la matriz de potencia
        matBS = potenciaUnaBS(coord, longs, lats);
        matPotencias = matPotencias + matBS;
        count = count + 1;
    end  
    %Paso a dB.
    matPotencias = 10*log10(matPotencias);
    
end
%Decaimiento segun la ecuacion de Friis.
function[matUnaBS] = potenciaUnaBS(coordBS, longs, lats)
    %Funcion que propague la potencia de una estacion base en toda la
    %matriz de potencias.
    
    %Dimensiones en X e Y.
    dimLong = length(longs);
    dimLat = length(lats);
    %Matriz de potencias.
    matUnaBS = zeros(dimLat,dimLong);
    %Ciclo de calculo
    count1 = 1;
    while count1 <= dimLong
        %Movimiento en longitud (ejeX)
        count2 = 1;
        while count2 <= dimLat
            %Movimiento en latitud (ejeY)
            %Coordenadas del punto
            coordPunto = [longs(count1),lats(count2)];
            %Calcular la distanncia entre las coordenadas.
            d = distanciaCoordenadas(coordPunto,coordBS);
            %Calculo de la potencia en el punto
            potenciaPunto = decaimientoFriis(d,0);
            %Agregar potencia.
            matUnaBS(count2,count1) = potenciaPunto;
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
end

function[longs,lats,matPotencias] = generarGrilla(limLat,limLong)
    %Funcion que genere la matriz de potencias
    
    %Variables globales.
    global precision
    
    %Longitudes.
    %Limites.
    minLong = min(limLong);
    maxLong = max(limLong);
    %Vector
    longs = minLong:precision:maxLong;
    %Latitudes
    %Limites.
    minLat = min(limLat);
    maxLat = max(limLat);
    %Vector
    lats = minLat:precision:maxLat;
    %Dimensiones en X e Y.
    dimLong = length(longs);
    dimLat = length(lats);
    %Matriz de potencias.
    matPotencias = zeros(dimLat,dimLong);
end

function [PrdB] = decaimientoFriis(distancia,modo)
    %Funcion que dada una distancia calcule la potencia en dB de acuerdo a
    %la ecuacion de Friis.
    %modo ->1 PdB ->0 W
    
    %Variables globales.
    global Pt lambda
    %Paso de la potencia de salida a decibeles.
    PtdB = 10 * log10(Pt);
    %Terminos
    t1 = 20 * log10(lambda);
    t2 = -20 * log10(distancia);
    t3 = -21.98;
    %Potencia recibida en dB.
    PrdB = PtdB + t1 + t2 + t3;
    if (modo == 0)
        %Potencia recibida no dB.
        PrdB = 10^(PrdB/10);
    end
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
    %Deltas
    deltaLat = lat2-lat1;
    deltaLong = long2-long1;
    %factorAngulos
    a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLong/2)^2;
    c=2*atan2(sqrt(a),sqrt(1-a));
    %Distancia
    dist = Rm * c;
end

%5.- Plot
function [] = graficoBSPotencia(coordBS,coordsBST,matPotencias,longs,lats)
    %Grafico.
    
    figure()
    hold on
    %Graficar el contorno.
    contourf(longs,lats,matPotencias,10)
    %Graficar BS.
    plot(coordBS(:,1)',coordBS(:,2)','+k','MarkerSize',10);
    %Graficar antenas en tramite.
    plotTramite(coordsBST);
    %Configuracion del plot
    ylim([min(lats),max(lats)])
    xlim([min(longs),max(longs)])
    title('Distribución de la potencia [dB]')
    xlabel('Longitud')
    ylabel('Latitud')
    colorbar
end

%6.- Graficar antenas en tramite.
function [] = plotTramite(coordsBST)
    %Funcion que en el mismo grafico ponga las antenas en tramite.
    
    %Graficar.
    plot(coordsBST(:,1)',coordsBST(:,2)','*r','MarkerSize',10)
    %
end