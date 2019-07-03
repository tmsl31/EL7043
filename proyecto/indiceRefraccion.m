function [n] = indiceRefraccion(r,modo)
    %Funcion que calcula el indice de refraccion en una determinada zona.
    
    %Paramas:
    %r -> Distancia desde el centro de la fibra (um).
    %modo ->  Tipo de variación que se quiere para el valor de n.
    
    %globales.
    global a nClad nCore alpha ajuste3
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
            n = x.^3*ajuste3(1) + x.^2*ajuste3(2) + x*ajuste3(3) + ajuste3(4);
        else
            n = nClad;
        end
    end
end