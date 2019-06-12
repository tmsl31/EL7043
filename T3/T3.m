% Tarea 3.
% Tomas Lara A.
% Redes de Acceso Banda Ancha.
clear;
close all;
%% Datos.
%0.- Datos del problema.
global a nClad nCore alpha distanciaRecorrida c;
%Velocidad de la luz.
c = 3e8;
%Ancho de la fibra optica (um).
a = 20;
%Indices de refraccion.
nClad = 1.4;
nCore = 1.5;
%Parametro de diseno.
alpha = 2;
%Precision del recorrido (um)
distanciaRecorrida = 1;

%% Script.
%1.-Variacion del indice de refraccion.
variacionN()

%2.- Determinacion del angulo máximo.
determinacionAnguloMax(1000,[0 3 5 8 10 13 14 14.5 15 18],0)
%Display de informacion.
disp('El Angulo maximo se encuentra entre 14 y 15 grados desde la horizontal')
disp('Para las proximas actividades se utiliza 14 grados desde la horizontal')

%3.- Variacion de Dispersion en funcion de la distancia.
vectorD = linspace(10,10000,100);
thetaInitGrados = 14;
dispersiones = variacionDispersion(vectorD,thetaInitGrados);
%4.- Comparacion con los valores teoricos.
dispersionesTeo = dispersionesTeoricas(vectorD);
%% Funciones.
%1.-
function [] = variacionN()
    % Variacion de N realiza un grafico de la variacion del indice de
    % refraccion de la fibra optica.
    
    %Radios a graficar.
    global a
    radios = -1*a:0.1:a;
    %Calculo de valores de n.
    vecN = indiceRefraccion(radios);
    %Grafico.
    figure()
    plot(radios,vecN);
    title('Variacion de N en la fibra');
    xlabel('Radio (\mu m)');
    ylabel('n');
end

function [n] = indiceRefraccion(r)
    %Funcion que calcula el indice de refraccion en una determinada zona.
    
    %Paramas:
    %r -> Distancia desde el centro de la fibra (um).
    
    %globales.
    global a nClad nCore alpha
    %Calculo de n.
    Delta = (nCore - nClad)/(nCore);
    if (abs(r)<=a)
        n = nCore .* (1-Delta.* (abs(r)./a).^alpha);
    else
        n = 1;
    end
end

%2.- 
function [] = determinacionAnguloMax(d,vecAngulos,animacion)
    %Funcion que pruebe diferentes angulos iniciales para la salida.
    
    figure()
    hold on
    for valor = vecAngulos
        graficoHaz(d,valor,animacion);
    end
    legend(string(vecAngulos))
end
function [] = graficoHaz(d,anguloInicialGrad,animacion)
    %Realiza el grafico que permita determinar mediante simulacion el
    %angulo maximo tal que el rayo no salga de la fibra optica.
    [vecX,vecY,vecT] = movimientoHaz(d,anguloInicialGrad);
    count = 1;
    if (animacion ==1)
        for k = vecT
            plot(vecX(count),vecY(count),'-*');
            title('Movimiento del haz en el tiempo.')
            xlabel('X(\mu m)')
            ylabel('Y(\mu m)')
            hold all
            pause(0.1)
            count = count + 1;
        end
    else
        title('Movimiento del haz en el tiempo.')
        xlabel('T(ms)')
        ylabel('Y(\mu m)')
%         line([vecT(1) vecT(end)],[20 20],'LineWidth',10)
%         line([vecT(1) vecT(end)],[-20 -20],'LineWidth',10)
        plot(vecT,vecY)
        ylim([-25 25])
    end
end

function [vecX,vecY,vecT] = movimientoHaz(d,anguloInicialGrad)
    %Funcion que realice el movimiento del haz en una fibra de longitud d (um).
    
    %Params:
    %d -> Longitud de la fibra (um)
    %anguloInicialGrad -> Angulo inicial (desde X) en grados.
    
    %Parametros globales.
    global distanciaRecorrida c
    %Angulo inicial en radianes.
    anguloInicial = anguloInicialGrad * pi /180;
    %Llenar Primer elemento de los vectores.
    vecAngulos(1) = anguloInicial;
    vecX(1) = 0;
    vecY(1) = 0;
    vecT(1) = 0;
    count = 1;
    while (vecX(count) < d)
        %Calcular distancias recorridas en X e Y
        theta1 = vecAngulos(count);
        dx = vecX(count) + distanciaRecorrida * cos(theta1);
        dy = vecY(count) + distanciaRecorrida * sin(theta1);
        if (dx > d)
            dx = d;
            dy = ((dx - vecX(count)) / cos(theta1))*sin(theta1) + vecY(count);
        end
        %Agregar las distancias a los vectores.
        vecX(count + 1) = dx;
        vecY(count + 1) = dy;
        %Calcular n1 y n2
        n2 = indiceRefraccion(vecY(count + 1));
        n1 = (indiceRefraccion(vecY(count)) + n2)/2;
        %Calcular el tiempo y agregar.
        v1 = c/n1;
        t1 = distanciaRecorrida/v1;
        if (dx == d)
            t1 = ((dx - vecX(count)) / cos(theta1))/v1;
        end
        %Tiempo en ms.
        vecT(count + 1) = t1*1e3 + vecT(count);
        %Calcular nuevo angulo de incidencia.
        deltaY = dy - vecY(count);
        %Solo usar ley de Snell si el punto cae dentro de la fibra. Si no,
        %seguira derecho Ahorro calculo
        if (dy <=20)    
            theta2 = leySnell(theta1,n1,n2,deltaY);
        elseif (dy == 0)
            theta2 = 0;
        else
            theta2 = theta1;            
        end
        vecAngulos(count + 1) = theta2;
        count = count + 1;
    end
end

function [theta2] = leySnell(theta1,n1,n2,deltaY)
    %Funcion que calcule el angulo de salida de acuerdo a la ley de Snell.
    
    %Arreglo del angulo.
    if (deltaY == 0)
        %Caso de rayo paralelo.
        theta2 = 0;
    else
        %Arreglar Angulo.
        thetaIn = pi/2 - abs(theta1);
        %Factor.
        factor = n1*sin(thetaIn)/n2;
        %Caso en que hay reflexion.
        if (abs(factor)>1)
            theta2 = -1 * theta1;
        elseif(abs(factor)==1)
            theta2 = theta1;
        else
            %Caso en que hay refraccion.
            thetaRefr = asin(factor);
            if (deltaY > 0)
                theta2 = pi/2 - thetaRefr;
            else
                theta2 = -1 * (pi/2 - thetaRefr);
            end
        end
    end
    
end

%3.-
function [dispersion] = calculoDispersion(d,thetaInitGrados)
    %Funcion que calcule el valor de dispersión temporal entre dos haces.
    
    [~,~,vecT] = movimientoHaz(d,thetaInitGrados);
    [~,~,vecT0] = movimientoHaz(d,0);
    %El rayo curvo va mas rapido, por lo que pongo esto para que de
    %positivo.
    dispersion = vecT0(end)-vecT(end);
end

function [dispersiones] = variacionDispersion(vectorD,thetaInitGrados)
    
    %Vector que almacene las dispersiones.
    dispersiones = zeros(size(vectorD));
    %Ciclo
    count =1;
    for d = vectorD
       dispersiones(count) = calculoDispersion(d,thetaInitGrados);
       count = count + 1;
    end
    %Grafico.
    figure()
    hold on
    plot(vectorD,dispersiones)
    xlabel('Largo fibra (\mu m)')
    ylabel('Dispersion (ms)')
    title('Dispersion en función de la distancia')
    hold off
end

%4.- 
function [dispersion] = dispersionTeorica(d)
    %Funcion que para una distancia realiza el calculo de la dispersion
    %teorica.

    %Variables globales.
    global  nClad nCore c;
    %Valor de Delta
    Delta = (nCore - nClad)/nCore;
    %Dispersion
    dispersion = (1/8) * ((nCore * d)/c) * Delta.^2;
end

function [dispersiones] = dispersionesTeoricas(vecD)
    %Se calcula los valores de dispersion para diferentes valores de
    %distancia.
    
    %Vector que guarde las dispersiones.
    dispersiones = zeros(size(vecD));
    %Ciclo.
    count = 1;
    for d = vecD
        dispersiones(count) = dispersionTeorica(d);
        count = count + 1;
    end
    %Grafico
    figure()
    hold on
    plot(vecD,1e3*dispersiones)
    xlabel('Largo fibra (\mu m)')
    ylabel('Dispersion (ms)')
    title('Dispersion teoricas en función de la distancia')
    hold off
end