function [c] = myConstrain(params)
    %Funcion que defina las restricciones para el problema de optimización
    
    global nClad nCore
    
    c = -1;
    %Vector.
    x = 0:1:20;
    %Salidas.
    y = params(1) * x.^4 + params(2) * x.^3 + params(3) * x.^2 + params(4) * x + params(5);
    %Maximo de la salida.
    maximoY = max(y);
    %Minimo de la salida
    minimoY = min(y);
    if ((maximoY > nCore) || (minimoY<nClad))
        c = 10;
    end
    
end