function [ns] = indicesRefraccion(radios,modo)
    %Calculo del indice de refraccion para varios radios.
    
    %Numero de radios.
    nRadios = length(radios);
    %Arreglo de indices.
    ns = zeros(1,nRadios);
    %Calculo de los n.
    count = 1;
    while count <= nRadios
        %Radio actual
        r = radios(count);
        %nActual
        n = indiceRefraccion(r,modo);
        %Agregar al vector de salida.
        ns(count) = n;
        %
        count = count + 1; 
    end
end

