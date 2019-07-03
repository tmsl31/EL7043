function [y] = aproxRecta(vectorD,dispersiones)
    %Funcion que aproxima la dispersion a una recta.
    
    %Obtener los coeficientes del polinomio.
    coefs = polyfit(vectorD,dispersiones,1);
    %Obtener los valores de salida
    y = coefs(2) + vectorD.*coefs(1);

end