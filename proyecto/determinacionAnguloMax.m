function [] = determinacionAnguloMax(d,vecAngulos,animacion,modo,params)
    %Funcion que pruebe diferentes angulos iniciales para la salida.
    
    figure()
    hold on
    for valor = vecAngulos
        graficoHaz(d,valor,animacion,modo,params);
    end
    legend(string(vecAngulos))
end
