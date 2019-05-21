%Script Tarea 4:OFDM
%Tomas Lara A.
%(Se omiten tildes).

%Siguiendo OFDMA Cookbok.


%% SCRIPT.
%1.- Modulacion
largoCadena = 10;
[bitsModulados,cadenaBits] = secuenciaQPSK(largoCadena);

%2.- Paralelizacion 



%% FUNCIONES.
%1.- Modulacion

function [secuenciaModulada,cadenaBits] = secuenciaQPSK(largoCadena)
    %Funcion que genere la secuencia modulada con el numero de bits
    %indicado en el campo.
    
    %Generacion de la secuencia en bits.
    cadenaBits = generarBits(largoCadena);
    %Modulacion
    secuenciaModulada = QPSK(cadenaBits);
end

function [bitsModulados] = QPSK(cadenaBits)
    %Genera la modulacion de una cadena de bits 
    
    %Consideramos  un radio igual a sqrt(2)
    %Codigo Gray en sentido antihorario
    repComplejas = [1+1i , -1+1i, -1-1i, 1-1i];
    %Vector que almacene las modulaciones.
    [nBits,~] = size(cadenaBits);
    bitsModulados = zeros(nBits,1);
    %Asignacion de codigos a cada par de bits de la cadena.
    count = 1;
    while count <= nBits
        %Par de bits
        par = cadenaBits(count,:);
        if (par(1) == 1)
            if (par(2) == 1)
                %[1 1]
                bitsModulados(count) = repComplejas(1);
            elseif(par(2)==0)
                %[1 0]
                bitsModulados(count) = repComplejas(4);
            end
        else
            if(par(2) == 1)
                %[0 1]
                bitsModulados(count) = repComplejas(2);
            elseif(par(2)==0)
                %[0 0]
                bitsModulados(count) = repComplejas(3);
            end
        end
        count = count + 1;
    end 
end

function [bits] = generarBits(largoCadena) 
    %Genera la secuencia de bits a enviar. se indica el largo de los pares de
    %bits a generar.
    
    bits = randi([0,1],[largoCadena,2]);
end
