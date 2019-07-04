function [] = graficoHaz(d,anguloInicialGrad,animacion,modo,params)
    %Realiza el grafico que permita determinar mediante simulacion el
    %angulo maximo tal que el rayo no salga de la fibra optica.
    [vecX,vecY,vecT] = movimientoHaz(d,anguloInicialGrad,modo,params);
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
        xlabel('X(\mu m)')
        ylabel('Y(\mu m)')
        plot(vecX,vecY)
        ylim([-25 25])
    end
end