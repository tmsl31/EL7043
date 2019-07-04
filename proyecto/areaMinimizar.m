function [area] = areaMinimizar(params)
    %Función que retorne el área de la curva de dispersion asociada a un
    %set de parametros. Adicionalmente se entregan las condiciones tal que
    %para valores que no cumplan las condiciones del proble, se entregue un
    %area muy grande.
    
    %Params:
    %params: Corresponde a los parametros del polinomio en orden
    %decreciente.
    
    %Angulo de prueba (14.5 grados).
    anguloInicial = 14.5;
    %Vector de pruebas de distancia.
    vectorD = linspace(1, 300,200);        
    %Obtencion de las dispersiones.  
    [dispersiones,~,~,~,~] = variacionDispersion(vectorD,anguloInicial,2,params);
    %Area de la curva de distancias y dispersiones.
    area = areaCurva(vectorD,dispersiones);
end