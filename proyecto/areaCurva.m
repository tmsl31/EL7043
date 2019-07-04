function [area] = areaCurva(X,Y)
    %Funcion que calcule el area de la curva utilizando integracion
    %trapezoidal.
    
    %Valor absoluto.
    Y = abs(Y);
    %Calculo de la integral.
    area = trapz(X,Y);
end