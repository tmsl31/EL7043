function [vecN,radios] = variacionN(modo)
    % Variacion de N realiza un grafico de la variacion del indice de
    % refraccion de la fibra optica.
    
    %Radios a graficar.
    global a
    radios = -1*(a+5):0.1:(a+5);
    %Calculo de valores de n.
    vecN = indicesRefraccion(radios,modo);
end