function [] = determinacionAnguloMax(d,vecAngulos,animacion,modo)
    %Funcion que pruebe diferentes angulos iniciales para la salida.
    
    figure()
    hold on
    for valor = vecAngulos
        graficoHaz(d,valor,animacion,modo);
    end
    legend(string(vecAngulos))
end
