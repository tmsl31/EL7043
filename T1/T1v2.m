%Tarea 1.
%Redes de Acceso Banda Ancha
%Tomás Lara A.


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
largoOriginal = imprimirTamanoOriginal(framesR);
 
%3.- Generacion de GOPs (I-Frames,B-Frames).
[RGOPs,GGOPs,BGOPs] = generarGOPs(framesR,framesG,framesB);
 
%4.-Comprimir los canales. Se genera una matriz de dimensión de gran dimensión 
%solo para almacenar los datos.
[matCompR,matCompG,matCompB] = comprimirCanales(RGOPs,GGOPs,BGOPs,8,matCompresion);
 
% %5.-Cálculo de tamano del archivo comprimido.
largoComprimido =  imprimirTamanoComprimido(matCompR,matCompG,matCompB);
%Porcentaje de compresion
porcentajeCompresion = 100-largoComprimido/largoOriginal*100;
disp(strcat('Porcentaje de Compresion: ',string(porcentajeCompresion)))
%6.- Descomprimir.
[hVideo,wVideo,~] = size(RGOPs);
[RDesc,GDesc,BDesc] = descomprimirVideo(matCompR,matCompG,matCompB,8,hVideo,wVideo,matCompresion);

% 7.-Reconstruir video a partir de los B frames.
[R,G,B] = reconstruccionCanales(RDesc,GDesc,BDesc);
 
%8.- Reproducir video original (se guarda).
framesOriginal = videoOriginal(framesR,framesG,framesB);
%9.- Reproducir video comprimido.
videoDescomprimido = repComprimido(R,G,B);

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
    R = double(R);
    G = double(G);
    B = double(B);
end

%2.-
function [pesoVideo] = imprimirTamanoOriginal(R)
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
    nuevoR(:,:,count+2) = ((nuevoR(:,:,count) + nuevoR(:,:,count+4))/2) - R(:,:,count+2);
    nuevoG(:,:,count+2) = ((nuevoG(:,:,count) + nuevoG(:,:,count+4))/2) - G(:,:,count+2);
    nuevoB(:,:,count+2) = ((nuevoB(:,:,count) + nuevoB(:,:,count+4))/2) - B(:,:,count+2);
    nuevoR(:,:,count+6) = ((nuevoR(:,:,count+4) + nuevoR(:,:,count+8))/2) - R(:,:,count+6);
    nuevoG(:,:,count+6) = ((nuevoG(:,:,count+4) + nuevoG(:,:,count+8))/2) - G(:,:,count+6);
    nuevoB(:,:,count+6) = ((nuevoB(:,:,count+4) + nuevoB(:,:,count+8))/2) - B(:,:,count+6);
    %Calculo de los B Restantes 
    nuevoR(:,:,count+1) = ((nuevoR(:,:,count) + nuevoR(:,:,count+2))/2) - R(:,:,count+1);
    nuevoG(:,:,count+1) = ((nuevoG(:,:,count) + nuevoG(:,:,count+2))/2) - G(:,:,count+1);
    nuevoB(:,:,count+1) = ((nuevoB(:,:,count) + nuevoB(:,:,count+2))/2) - B(:,:,count+1);
    nuevoR(:,:,count+3) = ((nuevoR(:,:,count+2) + nuevoR(:,:,count+4))/2) - R(:,:,count+3);
    nuevoG(:,:,count+3) = ((nuevoG(:,:,count+2) + nuevoG(:,:,count+4))/2) - G(:,:,count+3);
    nuevoB(:,:,count+3) = ((nuevoB(:,:,count+2) + nuevoB(:,:,count+4))/2) - B(:,:,count+3);
    nuevoR(:,:,count+5) = ((nuevoR(:,:,count+4) + nuevoR(:,:,count+6))/2) - R(:,:,count+5);
    nuevoG(:,:,count+5) = ((nuevoG(:,:,count+4) + nuevoG(:,:,count+6))/2) - G(:,:,count+5);
    nuevoB(:,:,count+5) = ((nuevoB(:,:,count+4) + nuevoB(:,:,count+6))/2) - B(:,:,count+5);
    nuevoR(:,:,count+7) = ((nuevoR(:,:,count+6) + nuevoR(:,:,count+8))/2) - R(:,:,count+7);
    nuevoG(:,:,count+7) = ((nuevoG(:,:,count+6) + nuevoG(:,:,count+8))/2) - G(:,:,count+7);
    nuevoB(:,:,count+7) = ((nuevoB(:,:,count+6) + nuevoB(:,:,count+8))/2) - B(:,:,count+7);
    count = count + 9;
end
disp('GOP generados');
end

%4.-
%FUNCION ZIGZAG REFERENCIADA EN ARCHIVO.

function [secuencia] = compresionBloque(bloque,matCompresion)
    %Dimensiones del bloque
    [alto,ancho] = size(bloque);
    %Normalizar Bloque.
    bloque = bloque - 128;
    %Calcular la DCT
    bloqueDCT = dct2(bloque,alto,ancho);
    %Pasar por matriz de compresion
    bloqueComp = bloqueDCT./matCompresion;
    %Redondear 
    bloqueComp = round(bloqueComp);
    %Serie.
    serieConCeros = zigzag(bloqueComp);
    %Quitar elementos y Agregar EoB.
    [~,maxPos] = max(serieConCeros==0);
    secuencia = zeros(1,maxPos);
    secuencia(1,1:maxPos-1) = serieConCeros(1,1:maxPos-1);
    %Agregar EoB = 300.
    secuencia(1,maxPos) = 300;
end

%Se ve bien.
function [secuencia] = comprimirUnFrameUnCanal(frame,dimBloques,matCompresion)
    %Funcion que realice la compresion de un frame de un canal.
    %Dimensiones del frame
    [alto,ancho] = size(frame);
    %Obtener secuencia de cada subgrupo.Orden es de izquierda a derecha 
    %luego bajando por la matriz.
    c1 = 1; 
    secuencia = [];
    while (c1 <= alto-dimBloques+1)
        c2 = 1;
        while(c2 <= ancho-dimBloques+1)
            secuenciaBloque = compresionBloque(frame(c1:c1+dimBloques-1,c2:c2+dimBloques-1),matCompresion);
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
    matSecuencias = zeros(numeroFrames,5000);
    %Generación de las secuencias.
    for i = 1:1:numeroFrames
        seq = comprimirUnFrameUnCanal(canal(:,:,i),dimBloques,matCompresion);
        len = length(seq);
        matSecuencias(i,1:len) = seq;
    end
end

function [matR,matG,matB] = comprimirCanales (R,G,B,dimBloques,matCompresion)
    matR = comprimirUnCanal(R,dimBloques,matCompresion);
    matG = comprimirUnCanal(G,dimBloques,matCompresion);
    matB = comprimirUnCanal(B,dimBloques,matCompresion);
    disp('Compresion realizada')
end

%5.-
function [pesoVideo] = imprimirTamanoComprimido(matCompR,matCompG,matCompB)
    elementosR = sum(sum(matCompR~=0));
    elementosG = sum(sum(matCompG~=0));
    elementosB = sum(sum(matCompB~=0));
    pesoVideo = (elementosR + elementosG + elementosB)*8;
    msgComprimido =strcat('El tamaño comprimido del archivo corresponde a:',num2str(pesoVideo/(1e6)),' Mb');
    disp(msgComprimido)

end

%6.-
function [matrizBloques] = separarBloques(vector,tamanoBloque,hVideo,wVideo)
    %Funcion separa el vector correspondiente a una imagen completamente
    %comprimida en una matriz de vectores correspondientes a los 
    EoB = 300;
    %Buscar posiciones del 300
    posiciones = find(vector==EoB);
    count = 1;
    matrizBloques = zeros(hVideo*wVideo/(tamanoBloque^2),tamanoBloque^2);
    while (count<=length(posiciones))
        if (count == 1)
            %%%VER RANGO DE ESTO
            agregar = vector(1:posiciones(count)-1);
            matrizBloques(count, 1:length(agregar)) = agregar;
        else
            %%VER RANGO DE ESTO
            agregar = vector(posiciones(count-1)+1:posiciones(count)-1);
            matrizBloques(count,1:length(agregar)) = agregar ;
        end
        count = count + 1;
    end 
end

function [bloque] = descomprimirBloque(vector,tamanoBloque,compMat)
    %Funcion que para un vector devuelve el bloque original.
    %Zigzag inverso.
    matBloqueComprimido = izigzag(vector,tamanoBloque,tamanoBloque);
    %Multiplicar por la matriz de compresión
    matBloqueDescomprimido = matBloqueComprimido.*compMat;
    %Calcular la DCT inversa
    bloque = idct2(matBloqueDescomprimido);
    %Descentrar
    bloque = bloque + 128;
end

function [frame] = descomprimirFrameUnCanal(vectorFrame,dimBloques,hVideo,wVideo,matCompresion)
    %Funcion que descomprima un frame completamente, a partir de un vector
    %comprimido
    %Obtener matriz
    matBloques = separarBloques(vectorFrame,dimBloques,hVideo,wVideo);
    %Generación de frameVacio
    frame = zeros(hVideo,wVideo);
    %Relleno del frame
    c1 = 1;
    c3 = 1;
        while (c1 <= hVideo-dimBloques+1)
            c2 = 1;
            while(c2 <= wVideo-dimBloques+1)
                %Descomprimir el bloque
                bloqueDescomprimido = descomprimirBloque(matBloques(c3,:),dimBloques,matCompresion);
                frame(c1:c1+dimBloques-1,c2:c2+dimBloques-1) = bloqueDescomprimido;
                c2 = c2 + dimBloques;
                c3 = c3 + 1;
            end
        c1 = c1 + dimBloques;
        end
end

function [framesCanal] = descomprimirCanal(matComprimida,dimBloques,hVideo,wVideo,matCompresion)
%Funcion que descomprime todo un canal a partir de la matriz comprimida.
%Cálculo de número de frames
[numeroFrames,~] = size(matComprimida);
framesCanal = zeros(hVideo,wVideo,numeroFrames);
%Descomprimir cada frame
for i = 1:1:numeroFrames
    vectorFrame = matComprimida(i,:);
    frame =  descomprimirFrameUnCanal(vectorFrame,dimBloques,hVideo,wVideo,matCompresion);
    framesCanal(:,:,i) = frame;
end
end

function [RDesc,GDesc,BDesc] = descomprimirVideo(RComp,GComp,BComp,dimBloques,hVideo,wVideo,matCompresion)
%Funcion que descomprima simultaneamente las tres matrices.
RDesc = descomprimirCanal(RComp,dimBloques,hVideo,wVideo,matCompresion);
GDesc = descomprimirCanal(GComp,dimBloques,hVideo,wVideo,matCompresion);
BDesc = descomprimirCanal(BComp,dimBloques,hVideo,wVideo,matCompresion);
disp('Descompresion lista')
end

%7.- 
function [frames] = reconstruccionUnCanal(canal)
%Funcion que realice la reconstrucción de imágenes a través de los I
%frames.
%Dimensiones
[alto,ancho,nFrames] = size(canal);
%Arreglo
frames = zeros(alto,ancho,nFrames);
%
for i = 1:9:nFrames-8
    %I Frames
    frames(:,:,i) = canal(:,:,i);
    frames(:,:,i+8) = canal(:,:,i+8);
    %Central
    frames(:,:,i+4) = ((frames(:,:,i)+frames(:,:,i+8))/2) - canal(:,:,i+4);
    %medios
    frames(:,:,i+2) = ((frames(:,:,i) + frames(:,:,i+4))/2) - canal(:,:,i+2);
    frames(:,:,i+6) = ((frames(:,:,i+8) + frames(:,:,i+4))/2) - canal(:,:,i+6);
    %ultimos
    frames(:,:,i+1) = (frames(:,:,i)+frames(:,:,i+2))/2-canal(:,:,i+1);
    frames(:,:,i+3) = (frames(:,:,i+2)+frames(:,:,i+4))/2-canal(:,:,i+3);
    frames(:,:,i+5) = (frames(:,:,i+4)+frames(:,:,i+6))/2-canal(:,:,i+5);
    frames(:,:,i+7) = (frames(:,:,i+6)+frames(:,:,i+8))/2-canal(:,:,i+7);
end
frames = uint8(frames);
end

function [R,G,B] = reconstruccionCanales(canalR,canalG,canalB)
    disp('Reconstruyendo frames a partir de GOPs')
    R = reconstruccionUnCanal(canalR);
    G = reconstruccionUnCanal(canalG);
    B = reconstruccionUnCanal(canalB);
end

%8.-
function [video] = videoOriginal(R,G,B)
%Reproducción de la reconstrucción del video comprimido.

%Dimensiones video
[alto,ancho,nFrames] = size(R);
%Generar matriz de frames
video = zeros(alto,ancho,3,nFrames);
for i = 1:1:nFrames
video(:,:,1,i) = R(:,:,i);
video(:,:,2,i) = G(:,:,i);
video(:,:,3,i) = B(:,:,i);
end
%Reproducir
implay(uint8(video))
end

%9.-
function [video] = repComprimido(R,G,B)
%Reproducción de la reconstrucción del video comprimido.

%Dimensiones video
[alto,ancho,nFrames] = size(R);
%Generar matriz de frames
video = zeros(alto,ancho,3,nFrames);
for i = 1:1:nFrames
video(:,:,1,i) = R(:,:,i);
video(:,:,2,i) = G(:,:,i);
video(:,:,3,i) = B(:,:,i);
end
%Reproducir
implay(uint8(video))
end

%% FUNCIONES REFERENCIADAS.
%Se utilizan dos funciones, las cuales se referencian en sus encabezados.
%Se obtienen de MathWorks: https://la.mathworks.com/matlabcentral/fileexchange/15317-zigzag-scan
% Zigzag scan of a matrix
% Argument is a two-dimensional matrix of any size,
% not strictly a square one.
% Function returns a 1-by-(m*n) array,
% where m and n are sizes of an input matrix,
% consisting of its items scanned by a zigzag method.
%
% Alexey S. Sokolov a.k.a. nICKEL, Moscow, Russia
% June 2007
% alex.nickel@gmail.com
function [output] = zigzag(in)
% initializing the variables
%----------------------------------
h = 1;
v = 1;
vmin = 1;
hmin = 1;
vmax = size(in,1);
hmax = size(in, 2);
i = 1;
output = zeros(1, vmax * hmax);
%----------------------------------
while ((v <= vmax) && (h <= hmax))
    
    if (mod(h + v, 2) == 0)                 % going up
        if (v == vmin)       
            output(i) = in(v, h);        % if we got to the first line
            if (h == hmax)
	      v = v + 1;
	    else
              h = h + 1;
            end
            i = i + 1;
        elseif ((h == hmax) && (v < vmax))   % if we got to the last column
            output(i) = in(v, h);
            v = v + 1;
            i = i + 1;
        elseif ((v > vmin) && (h < hmax))    % all other cases
            output(i) = in(v, h);
            v = v - 1;
            h = h + 1;
            i = i + 1;
        end
        
    else                                    % going down
       if ((v == vmax) && (h <= hmax))       % if we got to the last line
            output(i) = in(v, h);
            h = h + 1;
            i = i + 1;
        
       elseif (h == hmin)                   % if we got to the first column
            output(i) = in(v, h);
            if (v == vmax)
	      h = h + 1;
	    else
              v = v + 1;
            end
            i = i + 1;
       elseif ((v < vmax) && (h > hmin))     % all other cases
            output(i) = in(v, h);
            v = v + 1;
            h = h - 1;
            i = i + 1;
       end
    end
    if ((v == vmax) && (h == hmax))          % bottom right element
        output(i) = in(v, h);
        break
    end
end
end

% Function returns a two-dimensional matrix of defined sizes,
% consisting of input array items gathered by a zigzag method.
%
% Alexey S. Sokolov a.k.a. nICKEL, Moscow, Russia
% June 2007
% alex.nickel@gmail.com
function output = izigzag(in, vmax, hmax)
% initializing the variables
%----------------------------------
h = 1;
v = 1;
vmin = 1;
hmin = 1;
output = zeros(vmax, hmax);
i = 1;
%----------------------------------
while ((v <= vmax) && (h <= hmax))
    if (mod(h + v, 2) == 0)                % going up
        if (v == vmin)
            output(v, h) = in(i);
            if (h == hmax)
	      v = v + 1;
	    else
              h = h + 1;
            end
            i = i + 1;
        elseif ((h == hmax) && (v < vmax))
            output(v, h) = in(i);
            i;
            v = v + 1;
            i = i + 1;
        elseif ((v > vmin) && (h < hmax))
            output(v, h) = in(i);
            v = v - 1;
            h = h + 1;
            i = i + 1;
        end
        
    else                                   % going down
       if ((v == vmax) && (h <= hmax))
            output(v, h) = in(i);
            h = h + 1;
            i = i + 1;
        
       elseif (h == hmin)
            output(v, h) = in(i);
            if (v == vmax)
	      h = h + 1;
	    else
              v = v + 1;
            end
            i = i + 1;
       elseif ((v < vmax) && (h > hmin))
            output(v, h) = in(i);
            v = v + 1;
            h = h - 1;
            i = i + 1;
       end
    end
    if ((v == vmax) && (h == hmax))
        output(v, h) = in(i);
        break
    end
end
end