%Tarea 7: Trellis - Viterbi.
%Tomas Lara A.
%Redes de Acceso Banda Ancha.
%(se omiten tildes).
clear all
close all
clc
%% Script.
% 0.- Variables.
%Numero de bits de la cadena original.
nBits = 10;

%1.- Codificacion de una secuencia.
%Secuencia de bits original.
% seqBitsOriginal  = generarBits(nBits);
seqBitsOriginal = [1 0 1 1 0];
%Codificacion.
bitsCodificados = codificacionTV(seqBitsOriginal);

%3.- Agregar errores.
[todasPosibilidades] = posibilidadesError(bitsCodificados);

%% Funciones.
%1.- Codificacion de una secuencia.

function bitsCod = codificacionTV(seqBits)
    %Funcion que dada una secuencia de bits realiza la codificacion
    %utilizando Trellis - Viterbi.
    
    %Numero de bits de la entrada.
    nBits = length(seqBits);
    %Creacion del vector de salida.
    bitsCod = zeros(1,nBits * 2);
    %Creacion del shift register.
    registro = [0, 0];
    %Operaciones.
    count = 1;
    countOut = 1;
    while count <= nBits
       %Entrada actual.
       input = seqBits(count); 
       %Salida del bit mas significativo.
       outputMS = sumaBinaria(input,registro(2));
       %Salida del bit menos significativo
       outputLS = sumaBinaria(input,sumaBinaria(registro(1),registro(2)));
       %Llenar los bits de salida.
       bitsCod(countOut) = outputMS;
       bitsCod(countOut + 1) = outputLS;
       %Actualizar el registro.
       registro = actualizarRegistro(registro,input);
       %Contador.
       count = count + 1;
       countOut = countOut + 2;
    end
end

function seqBits = generarBits(nBits)
    %Funcion que genera una secuencia aleatoria de bits de largo nBits.
    
    seqBits = randi([0,1],[nBits,1]);
end

function suma = sumaBinaria(a,b)
    %Funcion que sume en binario.
    
    suma = a + b;
    %Caso de 1 + 1.
    if (suma == 2)
        suma = 0;
    end
end

function registro = actualizarRegistro(registro,input)
    %Funcion que actualiza el shiftRegister.
    
    %Cambio interno.
    registro(2) = registro (1);
    %Adicion de nuevo elemento.
    registro(1) = input;
end

%2.- Errores.
function [todasPosibilidades] = posibilidadesError(cadenaBits)
    %Funcion que genere un arreglo con donde cada matriz corresponda a
    %todas las posibles cadenas de bits con errores. 
    %El numero de la matriz en el arreglo corresponde al numero de errores.
    
    %Maximo de errores.
    maxError = length(cadenaBits) - 2;
    %Calcular cada matriz de variantes.
    todasPosibilidades = {};
    count = 1;
    while count <= maxError
        todasPosibilidades{count} = erroresEnBits(cadenaBits,count);
        count = count + 1;
    end
end

function [matCadenas] = erroresEnBits(cadenaBits,nErrores)
    %Funcion que entregue todas las posibles combinaciones de nErrores de
    %bit.
    
    %Largo de la cadena.
    nBits = length(cadenaBits);
    %Generar cadena de bits para XOR.
    bitsXOR = generarBitsXOR(nBits,nErrores);
    %Numero de posibles errores.
    nErrores = size(bitsXOR,1);
    %XOR
    matCadenas = [];
    count = 1;
    while count <= nErrores
        %xor.
        cadenaConError = double(xor(cadenaBits,bitsXOR(count,:)));
        %Agregar a la matriz
        matCadenas = [matCadenas;cadenaConError];
        count = count + 1;
    end
    
    
end

function [bitsXOR] = generarBitsXOR(nBits,nErrores)
    %Funcion que genere las cadenas de bits para hacer XOR.
    
    % Generacion del arreglo.
    aux = zeros(1,nBits);
    % Agregar el numero de uno de acuerdo a nErrores.
    aux(1:nErrores) = 1;
    %Generar las permutaciones
    permutaciones = perms(aux);
    %Eliminar las repetidas.
    permutacionesUnicas = unique(permutaciones,'rows');
    %Numero de permutaciones.
    nPermutaciones = size(permutacionesUnicas,1);
    %Eliminar los que tengan un uno en los dos ultimos bits (no modificar los ultimos).
    bitsXOR = [];
    count = 1;
    while count <= nPermutaciones
        permutacion = permutacionesUnicas(count,:);
        if ((permutacion(1,nBits) ~= 1) && (permutacion(1,nBits-1) ~= 1))
            bitsXOR = [bitsXOR;permutacion];
        end
        count = count + 1;
    end
end
