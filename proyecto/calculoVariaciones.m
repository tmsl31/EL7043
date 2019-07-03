function [variacion] = calculoVariaciones(vectorD,dispersiones,recta)
    %Funcion que obtenga la componente oscilatoria de la dispersion, esto
    %con el fin de luego poder minimizar la amplitud de esta.
    
    %Obtencion de la variacion.
    variacion = dispersiones - recta;
    %Grafico 1: Ajuste de la curva.
    figure()
    hold on
    plot(vectorD,recta)
    plot(vectorD,dispersiones);
    xlabel('Posicion X [\mu m]');
    ylabel('Dispersion [ms]')
    title('Curva de dispersión y recta ajustada')
    hold off
    %Grafico 2: Variaciones
    figure()
    hold on
    plot(vectorD,variacion,'o-')
    xlabel('Posicion X [\mu m]');
    ylabel('Oscilacion dispersion [ms]')
    title('Oscilacion de la dispersión')
    hold off

end