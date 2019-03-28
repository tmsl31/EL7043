%Tarea 1.
%Redes de Acceso Banda Ancha
%Tomás Lara A.
clear

%% SCRIPT

%DATOS.
%MATRIZ DE COMPRESION
matCompresion=[16 11 10 16 24 40 51 61;
         12 12 14 19 26 58 60 55;
         14 13 16 24 40 57 69 56;
         14 17 22 29 51 87 80 62;
         18 22 37 56 68 109 103 77;
         24 35 55 64 81 104 113 92;
         49 64 78 87 103 121 120 101;
         72 92 95 98 112 110 103 99];

%DESARROLLO     
%1.- Obtener el video como una secuencia de frames RGB.
[framesR,framesG,framesB] = video2RGB('videoConejo.mp4');
%Cortar el video para luego cortarlo en bloques de 8x8.
[framesR,framesG,framesB] = cortarVideo(framesR,framesG,framesB,16);

%2.-Imprimir la dimension original del video.
imprimirTamanoOriginal(framesR)

%3.- Generacion de GOPs (I-Frames,B-Frames).
[RGOPs,GGOPs,BGOPs] = generarGOPs(framesR,framesG,framesB);

%4.-Comprimir los canales. Se genera una matriz de dimensión de gran dimensión 
%solo para almacenar los datos.
[matCompR,matCompG,matCompB] = comprimirCanales(RGOPs,GGOPs,BGOPs,8,matCompresion);

%5.-Cálculo de tamano del archivo comprimido.
imprimirTamanoComprimido(matCompR,matCompG,matCompB);

%6.- Descomprimir.

%7.- Reproducir video original (se guarda).
framesOriginal = videoOriginal(framesR,framesG,framesB);
%8.- Reproducir video comprimido.

%% FUNCIONES.

%1.-
function [R,G,B] = video2RGB(nombreVideo)
%Función que obtenga la representación RGB de los frames para un video dado
%Lectura del video
video = VideoReader(nombreVideo);
%Almacenamiento de las matrices RGB.
k=1;
while hasFrame(video)
    frame = readFrame(video);
    R(:,:,k) = frame(:,:,1);
    G(:,:,k) = frame(:,:,2);
    B(:,:,k) = frame(:,:,3);
    k = k + 1;
end
%Numero de frames
nFrames = k;
%Cortar numero de frames a múltiplo de 9 para los GOP
if (mod(nFrames,9)~=0)
   factor = floor(nFrames/9);
   nFrames = factor*9;
   R = R(:,:,1:nFrames);
   G = G(:,:,1:nFrames);
   B = B(:,:,1:nFrames);
end
end
function [R,G,B] = cortarVideo(R0,G0,B0,dimBloques)
    %Se corta el video con el fin de poder dividir este en bloques de las
    %medidas exastas a definir (8x8 o 16x16).
    %Corte horizontal
    [h,w,~] = size(R0);
    R = R0;
    G = G0;
    B = B0;
    if ((mod(h,dimBloques)~=0) || (mod(w,dimBloques)~=0))
        nuevoH = floor(h/dimBloques)*dimBloques;
        nuevoW = floor(w/dimBloques)*dimBloques;
        R = R0(1:nuevoH,1:nuevoW,:);
        G = G0(1:nuevoH,1:nuevoW,:);
        B = B0(1:nuevoH,1:nuevoW,:);
    end
end

%2.-
function [] = imprimirTamanoOriginal(R)
    [alto,ancho,nFrames] = size(R);
    %Peso un frame
    pesoUnFrame = alto*ancho*8*3;
    %Peso del video
    pesoVideo = pesoUnFrame * nFrames;
    %Imprimir
    msgOriginal =strcat('El tamaño original del archivo corresponde a:',num2str(pesoVideo/(1e6)),' Mb');
    disp(msgOriginal)
end

%3.-
function [nuevoR,nuevoG,nuevoB] = generarGOPs(R,G,B)
[alto,ancho,nFrames] = size(R);
nuevoR = zeros(alto,ancho,nFrames);
nuevoG = zeros(alto,ancho,nFrames);
nuevoB = zeros(alto,ancho,nFrames);
count = 1;
while (count<= (nFrames-8))
    %I frames.
    nuevoR(:,:,count) = R(:,:,count);
    nuevoG(:,:,count) = G(:,:,count);
    nuevoB(:,:,count) = B(:,:,count);
    nuevoR(:,:,count+8) = R(:,:,count+8);
    nuevoG(:,:,count+8) = G(:,:,count+8);
    nuevoB(:,:,count+8) = B(:,:,count+8);
    %Calculo de B central.
    nuevoR(:,:,count+4) = ((R(:,:,count) + R(:,:,count+8))/2) - R(:,:,count+4);
    nuevoG(:,:,count+4) = ((G(:,:,count) + G(:,:,count+8))/2) - G(:,:,count+4);
    nuevoB(:,:,count+4) = ((B(:,:,count) + B(:,:,count+8))/2) - B(:,:,count+4);
    %Calculo de los B 'intermedios'
    nuevoR(:,:,count+2) = ((R(:,:,count) + R(:,:,count+4))/2) - R(:,:,count+2);
    nuevoG(:,:,count+2) = ((G(:,:,count) + G(:,:,count+4))/2) - G(:,:,count+2);
    nuevoB(:,:,count+2) = ((B(:,:,count) + B(:,:,count+4))/2) - B(:,:,count+2);
    nuevoR(:,:,count+6) = ((R(:,:,count+4) + R(:,:,count+8))/2) - R(:,:,count+6);
    nuevoG(:,:,count+6) = ((G(:,:,count+4) + G(:,:,count+8))/2) - G(:,:,count+6);
    nuevoB(:,:,count+6) = ((B(:,:,count+4) + B(:,:,count+8))/2) - B(:,:,count+6);
    %Calculo de los B Restantes 
    nuevoR(:,:,count+1) = ((R(:,:,count) + R(:,:,count+2))/2) - R(:,:,count+1);
    nuevoG(:,:,count+1) = ((G(:,:,count) + G(:,:,count+2))/2) - G(:,:,count+1);
    nuevoB(:,:,count+1) = ((B(:,:,count) + B(:,:,count+2))/2) - B(:,:,count+1);
    nuevoR(:,:,count+3) = ((R(:,:,count+2) + R(:,:,count+4))/2) - R(:,:,count+3);
    nuevoG(:,:,count+3) = ((G(:,:,count+2) + G(:,:,count+4))/2) - G(:,:,count+3);
    nuevoB(:,:,count+3) = ((B(:,:,count+2) + B(:,:,count+4))/2) - B(:,:,count+3);
    nuevoR(:,:,count+5) = ((R(:,:,count+4) + R(:,:,count+6))/2) - R(:,:,count+5);
    nuevoG(:,:,count+5) = ((G(:,:,count+4) + G(:,:,count+6))/2) - G(:,:,count+5);
    nuevoB(:,:,count+5) = ((B(:,:,count+4) + B(:,:,count+6))/2) - B(:,:,count+5);
    nuevoR(:,:,count+7) = ((R(:,:,count+6) + R(:,:,count+8))/2) - R(:,:,count+7);
    nuevoG(:,:,count+7) = ((G(:,:,count+6) + G(:,:,count+8))/2) - G(:,:,count+7);
    nuevoB(:,:,count+7) = ((B(:,:,count+6) + B(:,:,count+8))/2) - B(:,:,count+7);
    count = count + 9;
end
end

%4.-
%FUNCION ZIGZAG REFERENCIADA EN ARCHIVO.


function [secuencia] = compresionBloque(bloque,matCompresion)
    %Dimensiones del bloque
    [alto,ancho] = size(bloque);
    %Bloque ya se encuentra normalizado.
    %
    %Calcular la DCT
    bloqueDCT = dct2(bloque,alto,ancho);
    %Pasar por matriz de compresion
    bloqueComp = bloqueDCT./matCompresion;
    %Redondear 
    bloqueComp = floor(bloqueComp);
    %Serie.
    serieConCeros = zigzag(bloqueComp);
    %Quitar elementos y Agregar EoB.
    [~,maxPos] = max(serieConCeros==0);
    secuencia = zeros(1,maxPos+1);
    secuencia(1,1:maxPos) = serieConCeros(1,1:maxPos);
    %Agregar EoB = 300.
    secuencia(1,maxPos+1) = 300;
end

function [secuencia] = comprimirUnFrameUnCanal(frame,dimBloques,matCompresion)
    %Funcion que realice la compresion de un frame de un canal.
    %Normalizar el frame
    normFrame = frame - 128;
    %Dimensiones del frame
    [alto,ancho] = size(normFrame);
    %Obtener secuencia de cada subgrupo.Orden es de izquierda a derecha 
    %luego bajando por la matriz.
    c1 = 1; 
    c2 = 1;
    secuencia = [];
    while (c1 <= alto-dimBloques+1)
        while(c2 <= ancho-dimBloques+1)
            secuenciaBloque = compresionBloque(normFrame(c1:c1+dimBloques-1,c2:c2+dimBloques-1),matCompresion);
            secuencia = [secuencia,secuenciaBloque];
            c2 = c2 + dimBloques;
        end
    c1 = c1 + dimBloques;
    end
end

function [matSecuencias] = comprimirUnCanal(canal,dimBloques,matCompresion)
    %Funcion que calcule la matriz de secuencias para un canal.
    %Dimensiones
    [~,~,numeroFrames] = size(canal);
    %Generación de la matriz. Ancho fijado a través de experimentos.
    matSecuencias = zeros(numeroFrames,600);
    %Generación de las secuencias.
    for i = 1:1:numeroFrames
        seq = comprimirUnFrameUnCanal(canal(:,:,i),dimBloques,matCompresion);
        l = length(seq);
        matSecuencias(i,1:l) = seq;
    end
end

function [matR,matG,matB] = comprimirCanales (R,G,B,dimBloques,matCompresion)
    matR = comprimirUnCanal(R,dimBloques,matCompresion);
    matG = comprimirUnCanal(G,dimBloques,matCompresion);
    matB = comprimirUnCanal(B,dimBloques,matCompresion);
end

%5.-
function [] = imprimirTamanoComprimido(matCompR,matCompG,matCompB)
    elementosR = sum(sum(matCompR~=0));
    elementosG = sum(sum(matCompG~=0));
    elementosB = sum(sum(matCompB~=0));
    pesoVideo = (elementosR + elementosG + elementosB)*8;
    msgComprimido =strcat('El tamaño comprimido del archivo corresponde a:',num2str(pesoVideo/(1e6)),' Mb');
    disp(msgComprimido)

end

%8.-
function [framesOriginal] = videoOriginal(R,G,B)
    %Dimensiones
    [alto,ancho,nFrames] = size(R);
    %Constituir y almacenar frames
    framesOriginal = uint8(zeros(alto,ancho,nFrames));
    RGB = uint8(zeros(alto,ancho,3));
    vidOr = VideoWriter('newConejo');
    open(vidOr)
    for i = 1:1:nFrames
        RGB(:,:,1) = uint8(R(:,:,i));
        RGB(:,:,2) = uint8(G(:,:,i));
        RGB(:,:,3) = uint8(B(:,:,i));
        unFrame = im2frame(RGB);
        writeVideo(vidOr,unFrame);
    end
    close(vidOr)
end
