function [] = variacionN(modo)
    % Variacion de N realiza un grafico de la variacion del indice de
    % refraccion de la fibra optica.
    
    %Radios a graficar.
    global a
    radios = 0:0.1:(a+5);
    %Calculo de valores de n.
    vecN = indicesRefraccion(radios,modo);
    %Grafico.
    figure()
    plot(radios,vecN);
    title('Variacion de N en la fibra');
    xlabel('Radio (\mu m)');
    ylabel('n');
end