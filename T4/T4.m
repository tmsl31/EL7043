%Script Tarea 4:OFDM
%Tomas Lara A.
%(Se omiten tildes).

%Siguiendo OFDMA Cookbok.


%% SCRIPT.
%1.- Modulacion
largoCadena = 100;
[bitsModulados,cadenaBits] = secuenciaQPSK(largoCadena);

%2.- SubPortadoras.
symPorSubportadora = 10;
[matSubportadoras] = subportadoras(symPorSubportadora,bitsModulados);

%3.- Aplicacion de la IDFT.
[portadorasIFT] = aplicarIDFT(matSubportadoras);
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
    repComplejas = [0.7+0.7i , -0.7+0.7i, -0.7-0.7i, 0.7-0.7i];
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

%2.- Paso a subportadoras.
function [matSubportadoras] = subportadoras(nSymSub,bitsModulados)
    %Funcion que ubique cada uno de los simbolos en cada una de las
    %subportadoras, considerando un número de simbolos por subportadora.
    
    %Calcular el numero de simbolos.
    nSimbolos = size(bitsModulados,1);
    %Calcular las dimensiones de matriz necesarias
    %Numero de subportadoras.
    nSubportadoras = ceil(nSimbolos/nSymSub);
    %Creacion de la matriz.
    matSubportadoras = zeros(nSymSub,nSubportadoras);
    %Llenado de la matriz.
    count = 1;
    while count <= nSimbolos
       matSubportadoras(count) = bitsModulados(count);
       disp(matSubportadoras)
       count = count + 1; 
    end
    matSubportadoras = matSubportadoras';
end

%3.- Aplicar IDFT.

function [matIDFT] = aplicarIDFT(mat)
    %Funcion que calcula de manera paralela la IDFT para las distintas
    %suportadoras.
    
end