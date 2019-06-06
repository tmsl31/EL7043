%Script Tarea 4:OFDM
%Tomas Lara A.
%(Se omiten tildes).

%Siguiendo OFDMA Cookbok.


%% SCRIPT.
%0.- Parametros de simulacion
largoCadena = 100;
symPorSubportadora = 10;
porcentajeCP = 20;
snr = 1;

%1.- Modulacion
[bitsModulados,cadenaBits] = secuenciaQPSK(largoCadena);

%2.- SubPortadoras.
[matSubportadoras] = subportadoras(symPorSubportadora,bitsModulados);

%3.- Aplicacion de la IDFT.
[portadorasIDFT] = aplicarIDFT(matSubportadoras);

%4.- Agregar CP.
[inforEnviar] = agregarCP(portadorasIDFT,porcentajeCP);

%5.- Agregar ruido a la matriz.
[matRuido] = agregarRuido(inforEnviar,snr);
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
    %subportadoras, considerando un n�mero de simbolos por subportadora.
    
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
       count = count + 1; 
    end
    matSubportadoras = matSubportadoras';
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
function [infoEnviar] = agregarCP(matIDF,porcentajeSimbolos)
    %Funcion que agrega el prefijo ciclico a la matriz de simbolos donde
    %cada fila representa una subportadora y cada columna un simbolo.
    
    %Dimensiones de la matriz IDF.
    nSimbolos = size(matIDF,2);
    %Largo del prefijo Ciclico.
    largoCP = floor(nSimbolos*porcentajeSimbolos/100);
    %Obtencion de la matriz de prefijos ciclicos.
    matCP = matIDF(:,nSimbolos-largoCP:nSimbolos);
    %Concatenar matrices (agregar CP).
    infoEnviar = [matCP,matIDF];
end

%5.- Sumar Ruido.
function [dataSerial] = mat2Serial(mat)
    %Funcion que convierta una matriz en una representacion vectorial.
    %Serializacion.
    
    %Dimensiones de la matriz
    [fils,cols] = size(mat);
    %Creacion del vector.
    dim = fils*cols;
    dataSerial = zeros(1,dim);
    %Llenado del vector.
    count = 1;
    mat = mat';
    while count<=dim
        dataSerial(1,count) = mat(count);
        count = count + 1;
    end
end

function [mat] = serial2Mat(dataSerial,fils,cols)
    %Funcion que pasa la data desde serial a paralelo con las dimensiones
    %originales indicadas.
    
    %Pasar de la data a matriz.
    mat = zeros(cols,fils);
    %Agregar
    count = 1;
    for i = dataSerial
        mat(count) = i;
        count = count + 1;
    end
    mat = mat';
end

function [matRuido] = agregarRuido(mat,snr)
    %Funcion que agrega ruido a la matriz. Se agrega ruido con un valor de
    %SNR definido.
    
    %Dimensiones de la matriz.
    [fils,cols] = size(mat);
    %Serializar matriz.
    serial = mat2Serial(mat);
    %Agregar ruido AWGN.
    serialRuidoso = awgn(serial,snr);
    %Pasar a matriz
    matRuido = serial2Mat(serialRuidoso,fils,cols);
end