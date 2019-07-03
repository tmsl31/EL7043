function [dispersiones,tiemposT,tiemposT0,X,X0,Y,Y0] = variacionDispersion(vectorD,thetaInitGrados,modo)
    %Datos para la obtencion del grafico de dispersion en funcion de la
    %distancia.
    
    %Numero de distancias
    nD = length(vectorD);
    %Vector que almacene las dispersiones.
    dispersiones = zeros(1,nD);
    tiemposT = zeros(1,nD);
    tiemposT0 = zeros(1,nD);
    X = zeros(1,nD);
    X0 = zeros(1,nD);
    Y = zeros(1,nD);
    Y0 = zeros(1,nD);
    %Ciclo
    count =1;
    for d = vectorD
        %Calculo de dispersion.
       [dispersion,XYT,XYT0] = calculoDispersion(d,thetaInitGrados,modo);
       %Agregar dispersion
       dispersiones(count) = dispersion; 
       %Agregar tiempos.
       tiemposT(count) = XYT(3);
       tiemposT0(count) = XYT0(3);
       %Agregar X.
       X(count) = XYT(1);
       X0(count) = XYT0(1);
       %Agregar Y.
       Y(count) = XYT(2);
       Y0(count) = XYT0(2);
       %
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

function [dispersion,XYT,XYT0] = calculoDispersion(d,thetaInitGrados,modo)
    %Funcion que calcule el valor de dispersión temporal entre dos haces.
    
    [vecX,vecY,vecT] = movimientoHaz(d,thetaInitGrados,modo);
    [vecX0,vecY0,vecT0] = movimientoHaz(d,0,modo);
    %El rayo curvo va mas rapido, por lo que pongo esto para que de
    %positivo.
    %Ultimos tiempos
    T0 = vecT0(end);
    T = vecT(end);
    %Posicion en que quedo en Y
    Y0 = vecY0(end);
    Y = vecY(end);    
    %Posicion en que quedo en X.
    X0 = vecX0(end);
    X = vecX(end);    
    %Datos XYT
    XYT = [X,Y,T];
    %Datos X0Y0T0
    XYT0 = [X0,Y0,T0];
    %Dispesion.
    dispersion = T0-T;
end
