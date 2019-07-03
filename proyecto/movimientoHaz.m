function [vecX,vecY,vecT] = movimientoHaz(d,anguloInicialGrad,modo)
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
        n2 = indiceRefraccion(vecY(count + 1),modo);
        n1 = (indiceRefraccion(vecY(count),modo) + n2)/2;
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