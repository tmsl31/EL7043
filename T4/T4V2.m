%Script Tarea 4:OFDM
%Tomas Lara A.
%(Se omiten tildes).

%Siguiendo OFDMA Cookbok.
clear;
close all;

%% SCRIPT.
%0.- Parametros de simulacion
global largoCadena symPorSubportadora porcentajeCP
largoCadena = 100000;
symPorSubportadora = 5;
porcentajeCP = 20;
snr = 10000;
vectorSNR = linspace(-30,8,1000);
%Calculo de la curva.
vectorBER = BERvsSNR(vectorSNR);
%Calcula de la curva con promedio de varias secuencias.
vectorBERPromedio = BERvsSNRPromedio(vectorSNR, 10);
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
    
    largoCadena = largoCadena/2;
    bits = randi([0,1],[largoCadena,2]);
end

%2.- Paso a subportadoras.

function [matSubportadoras] = subportadoras(nSymSub,bitsModulados)
    %Funcion que ubique cada uno de los simbolos en cada una de las
    %subportadoras, considerando un número de simbolos por subportadora.
    
    %Params.
    %nSymSub -> Numero de simbolos admitidos por subportadora.
    %bitsModulados ->Cadena de bits modulados por QPSK.
    
    %Calcular el numero de simbolos.
    nSimbolos = length(bitsModulados);
    %Calcular las dimensiones de matriz necesarias
    %Numero de subportadoras.
    nSubportadoras = ceil(nSimbolos/nSymSub);
    %Creacion de la matriz.
    matSubportadoras = zeros(nSymSub,nSubportadoras);
    %Llenado de la matriz.
    count1 = 1;
    count = 1;
    while count1 <= nSubportadoras
        count2 = 1;
        while count2 <= nSymSub
            matSubportadoras(count2,count1) = bitsModulados(count);
            count2 = count2 + 1;
            count = count + 1;
        end
        count1 = count1 + 1;
    end
end
%3.- Aplicar IDFT.

function [matIDFT] = aplicarIDFT(mat)
    %Funcion que calcula de manera paralela la IDFT para las distintas
    %suportadoras.
    
    %Dimensiones.
    [nFilas,nCols] = size(mat);
    %Vector que guarde los valores de IDFT.
    matIDFT = zeros(nFilas,nCols);
    %Calculo de la IDFT.
    count = 1;
    while count <= nCols
        matIDFT(:,count) = ifft(mat(:,count));
        count = count + 1;
    end
    
end

%4.- Cyclic Prefix.
function [infoEnviar,largoCP] = agregarCP(matIDF,porcentajeSimbolos)
    %Funcion que agrega el prefijo ciclico a la matriz de simbolos donde
    %cada fila representa una subportadora y cada columna un simbolo.
    
    %Dimensiones de la matriz IDF.
    nSimbolos = size(matIDF,1);
    %Largo del prefijo Ciclico.
    largoCP = ceil(nSimbolos*porcentajeSimbolos/100);
    %Obtencion de la matriz de prefijos ciclicos.
    matCP = matIDF(nSimbolos - largoCP + 1:nSimbolos,:);
    %Concatenar matrices (agregar CP).
    infoEnviar = [matCP;matIDF];
end

%5.-
function matConRuido = agregarRuido(mat,SNRdB)
    %Funcion que agregue ruido a la informacion enviada.
    
    %Dimensiones originales
    [fils,cols] = size(mat);
    %Serializar los datos.
    vector = mat2Vec(mat);
    %Agregar ruido.
    vectorRuidoso = awgn(vector,SNRdB,'measured');
    %Volver a pasar a forma matricial.
    matConRuido = vec2Mat(vectorRuidoso,fils,cols);
end

function vector = mat2Vec(mat)
    %Funcion que serialice los datos para agregarles el ruido.
    %Portadora tras portadora.
    
    %Dimensiones
    [fils,cols] = size(mat);
    %vector.
    vector = zeros(1,fils*cols);
    %Llenar el vector
    count = 1;
    count1 = 1;
    while count1 <= cols
        count2 = 1;
        while count2 <=fils
            vector(count) = mat(count2,count1);
            count2 = count2 + 1;
            count = count + 1;
        end
        count1 = count1 + 1;
    end
end

function mat = vec2Mat(vec,fils,cols)
    %Funcion que lleve un vector a una matriz.
    
    %Matriz a llenar.
    mat = zeros(fils,cols);
    %Llenado.
    count = 1;
    count1 = 1;
    while count1 <= cols
        count2 = 1;
        while count2 <=fils
            mat(count2,count1) = vec(count);
            count = count + 1;
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
end

%6.- Quitar Prefijo Ciclico.
function [matSinCP] = quitarPrefijoCiclico(mat,largoCP)
    %Funcion que realiza la eliminacion del prefijo ciclico conociendo el
    %numero de elementos que este tiene.
    %Quitar prefijo ciclico.
    matSinCP = mat(largoCP + 1:end,:);
end

%7.- DFT por columnas.
function [matDFT] = calcularDFT(mat)
    %Funcion que calcule la DFT por cada columna.
        
    %Dimensiones.
    [nFilas,nCols] = size(mat);
    %Vector que guarde los valores de IDFT.
    matDFT = zeros(nFilas,nCols);
    %Calculo de la IDFT.
    count = 1;
    while count <= nCols
        matDFT(:,count) = fft(mat(:,count));
        count = count + 1;
    end
end

%8.- Decodificacion QPSK.
% function [vectorSimbolos] = mat2Vec(mat)
%     %Funcion que convierta una matriz en un vector de la misma forma que la
%     %cadena original.
%     
%     %Dimensiones de la matriz.
%     [fils,cols] = size(mat);
%     %Numero de simbolos.
%     nSimbolos = fils*cols;
%     %Vector
%     vectorSimbolos = zeros(1,nSimbolos);
%     %Agregar elementos de la matriz.
%     count = 1;
%     count3 = 1;
%     while count<=cols
%         count2 = 1;
%         while count2<=fils
%             %Asignar
%             vectorSimbolos(count3) = mat(count2,count);
%             %Contadores
%             count2 = count2 + 1;
%             count3 = count3 + 1;
%         end
%         count = count + 1;
%     end
% end

function [parBits] = QPSK2ParBits(simbolo)
    %Funcion que transforma un símbolo en una secuencia de bits.
    
    %Parte real e imaginaria.
    pReal = real(simbolo);
    pImag = imag(simbolo);
    %Casos para decodificacion.
    if (pReal >= 0)
        if(pImag >= 0)
            parBits = [1 1];
        else
            parBits = [1 0];
        end
    else
        if(pImag >= 0)
            parBits = [0 1];
        else
            parBits = [0 0];
        end
    end
end

function [bits] = QPSK2Bits(mat)
    %Funcion que pase de la matriz DFT con ruido a los simbolos recuperados
    %mediante decodificaicon QPSK.
    
    %Dimensiones matriz.
    [fils,cols] = size(mat);
    %Numero de simbolos.
    nSimbolos = fils*cols;
    %Crear matriz de bits.
    bits = zeros(nSimbolos,2);
    %Serializar
    vectorSimbolos = mat2Vec(mat);
    %Recorrer los simbolos.
    count = 1;
    while count < nSimbolos
        bits(count,:) = QPSK2ParBits(vectorSimbolos(count));
        count = count + 1;
    end
end

%9.- Calculo de BER.
function [BER] = calculoBER2(bits1,bits2)
    %La funcion calculo BER2 realiza el calculo del BER al entregar dos
    %matrices de pares de bits.
    
    %Dimensiones
    [fils,cols] = size(bits1);
    %Numero de elementos.
    nBits = fils * cols;
    %Serializar ambas matrices(reshape de la misma forma)
    bits1 = reshape(bits1,[nBits,1]);
    bits2 = reshape(bits2,[nBits,1]);
    %Comparacion.
    count = 1;
    suma = 0;
    while (count <= nBits)
        %Comparar
        if(bits1(count) == bits2(count))
            suma = suma + 1;
        end
        count = count + 1;
    end
    BER = 1-(suma/nBits);
end

%10.- Curva BER vs SNR.
function vectorBER = BERvsSNR(vectorSNR)
    %Funcion que genera la curva BERvsSNR.

    %Variables globales.
    global largoCadena symPorSubportadora porcentajeCP
    %vectorBER
    vectorBER = zeros(size(vectorSNR));
    %Generacion de la secuencia de bits.
    [secuenciaModulada,cadenaBits] = secuenciaQPSK(largoCadena);
    %Paso a las subportadoras
    [matSubportadoras] = subportadoras(symPorSubportadora,secuenciaModulada);
    %Calculo de la IDFT.
    [matIDFT] = aplicarIDFT(matSubportadoras);
    %Agregar CP.
    [infoEnviar,largoCP] = agregarCP(matIDFT,porcentajeCP);
    %Calcular ver para cada elementos del vector.
    count = 1;
    for valorSNRdB = vectorSNR
        %Agregar ruido.
        matConRuido = agregarRuido(infoEnviar,valorSNRdB);
        %Quitar CP.
        [matMat] = quitarPrefijoCiclico(matConRuido,largoCP);
        %Calculo DFT.
        [matDFT] = calcularDFT(matMat);
        %Decodificacio a bits.
        [bits] = QPSK2Bits(matDFT);
        %Calculo del ber.
        [BER] = calculoBER2(cadenaBits,bits);
        %Agregar al vector.
        vectorBER(count) = BER;
        %
        count = count + 1;
    end
    
    %Grafico.
    figure()
    hold on
    plot(vectorBER,vectorSNR,'-')
    title('SNR vs BER')
    ylabel('SNR (dB)')
    xlabel('BER (%)')
    hold off
end

%11.- Calculo con promedios.
function vectorBERPromedio = BERvsSNRPromedio(vectorSNR, numPromedios)
    %Funcion que genera la curva BERvsSNR.

    %Variables globales.
    global largoCadena symPorSubportadora porcentajeCP
    
    %Matriz que almacene los valores.
    matrizBER = zeros(numPromedios,length(vectorSNR));
    i = 1;
    while i <= numPromedios
        %vectorBER
        vectorBER = zeros(size(vectorSNR));
        %Generacion de la secuencia de bits.
        [secuenciaModulada,cadenaBits] = secuenciaQPSK(largoCadena);
        %Paso a las subportadoras
        [matSubportadoras] = subportadoras(symPorSubportadora,secuenciaModulada);
        %Calculo de la IDFT.
        [matIDFT] = aplicarIDFT(matSubportadoras);
        %Agregar CP.
        [infoEnviar,largoCP] = agregarCP(matIDFT,porcentajeCP);
        %Calcular ver para cada elementos del vector.
        count = 1;
        for valorSNRdB = vectorSNR
            %Agregar ruido.
            matConRuido = agregarRuido(infoEnviar,valorSNRdB);
            %Quitar CP.
            [matMat] = quitarPrefijoCiclico(matConRuido,largoCP);
            %Calculo DFT.
            [matDFT] = calcularDFT(matMat);
            %Decodificacio a bits.
            [bits] = QPSK2Bits(matDFT);
            %Calculo del ber.
            [BER] = calculoBER2(cadenaBits,bits);
            %Agregar al vector.
            vectorBER(count) = BER;
            %
            count = count + 1;
        end
        matrizBER (i,:) = vectorBER;
        i = i + 1;
    end
    
    vectorBERPromedio = mean(matrizBER);
    %Grafico.
    figure()
    hold on
    plot(vectorBERPromedio,vectorSNR,'-')
    title('SNR vs BER Promedio')
    ylabel('SNR (dB)')
    xlabel('BER (%)')
    hold off
end
