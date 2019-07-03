function [theta2] = leySnell(theta1,n1,n2,deltaY)
    %Funcion que calcule el angulo de salida de acuerdo a la ley de Snell.
    
    if (deltaY == 0)
        %Caso de rayo paralelo.
        theta2 = 0;
    else
        %Arreglar Angulo.
        %Valido para casos en que suba y baje el rayo.
        thetaIn = pi/2 - abs(theta1);
        %Factor.
        factor = n1*sin(thetaIn)/n2;
        %Caso en que hay reflexion (supera el angulo critico).
        if (abs(factor)>1)
            theta2 = -1 * theta1;
        elseif(abs(factor)==1)
            %Caso de angulo critico.
            theta2 = 0;
        else
            %Caso en que hay refraccion.
            %Calculo del angulo de salida.
            thetaRefr = asin(factor);
            if (deltaY > 0)
                %Caso en que el rayo esta en ascenso.
                theta2 = pi/2 - thetaRefr;
            else
                %Caso en que el rayo esta en descenso.
                theta2 = -1 * (pi/2 - thetaRefr);
            end
        end
    end
    
end