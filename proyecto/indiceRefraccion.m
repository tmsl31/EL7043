function [n] = indiceRefraccion(r,modo,params)
    %Funcion que calcula el indice de refraccion en una determinada zona.
    
    %Paramas:
    %r -> Distancia desde el centro de la fibra (um).
    %modo ->  Tipo de variación que se quiere para el valor de n.
    
    %globales.
    global a nClad nCore alpha
    %Calculo de n.
    if modo == 0
        %Modo base, utilizado en tarea 3.        
        Delta = (nCore^2 - nClad^2)/(2 * nCore^2);
        if (abs(r)<=a)
            n = nCore * (1-2 * Delta * (abs(r)/a)^alpha)^(1/2);
        else
            n = nClad;
        end
    elseif (modo == 1)
        %Modo utilizando polyfit y un polinomio de grado 3.
        x = abs(r);
        if (x<=a)
            n = x.^3 * params(1) + x.^2 * params(2) + x * params(3) + params(4);
        else
            n = nClad;
        end
    elseif (modo == 2)
        %Modo utilizando polyfit y un polinomio de grado 4.
        x = abs(r);
        if (x<=a)
            n = x.^4 * params(1) + x.^3 * params(2) + x.^2 * params(3) + x * params(4) + params(5);
        else
            n = nClad;
        end
    elseif (modo == 3)
        %Modo utilizando alfa variable.
        x = abs(r);
        Delta = (nCore^2 - nClad^2)/(2 * nCore^2);
        if (x<=a)
            n = nCore * (1-2 * Delta * (x/a)^params)^(1/2);
        else
            n = nClad;
        end
    elseif (modo == 4)
        %Modo utilizado para la optimizacion de parametros
        %Se realiza fitting de los parametros.
        fitting = polyfit([0,params(1),params(2),13.7186,a],[nCore,params(3),params(4),nCore,nClad],4);
        %Valor absoluto
        x = abs(r);
        %Casos para el radio.
        if (x<=a)
            n = x.^4 * fitting(1) + x.^3 * fitting(2) + x.^2 * fitting(3) + x * fitting(4) + fitting(5);
        else
            n = nClad;
        end
        
    end
    
    
end