%Tarea 6: DIDO.
%Redes de Acceso Banda Ancha
%Tomás Lara A.

%% SCRIPT.

%1.- Generar antenas y personas
dMin = 10; %10 metros como distancia minima.
usuarios = 3; %3 usuarios.
dAntenaskm = 4; %km
%Generacion de las matrices.
[matAntenas,matPersonas] = escenario(dAntenaskm,dMin,usuarios);

%2.- Calcular matriz de funciones de transferencia
%Parametros.
perdidas1 = 0;
f = 700e6;
%Matriz de funciones de transferencia.
H = matH(matAntenas,matPersonas,f,perdidas1);

%% FUNCIONES.
%1.- Generar antenas y personas.
function[matAntenas,matPersonas] = escenario(distanciaAntenaskm,dMin,usuarios)
    %Funcion que entregue las coordenadas de las antenas y personas en
    %metros. Se consideran cuatroa antenas por instruccion del profesor.
    
    %Params:
    %distanciaAntenaskm -> Distancia entre las antenas en kilometros.
    
    %Distancia en metros.
    dAntenasm = distanciaAntenaskm * 1000;
    %Matriz de posiciones de las antenas.
    matAntenas = [0,0;0,dAntenasm;dAntenasm,dAntenasm;dAntenasm,0];
    %Posicion de las personas en el arreglo
    matPersonas = randi([dMin,dAntenasm-dMin],2,usuarios);
end

%2.-Funciones de transferencia
function [H] = matH(matAntenas,matPersonas,f,perdidas)
    %Funcion que retorne la matriz de funciones de transferencia H.
    
    %Params:
    %matAntenas-> Posiciones de las antenas dim(X) = [nAntenas,2];
    %matPersonas-> Posiciones de las personas dim(X) = [nPersonas,2];

    %Numero de antenas
    nAntenas = size(matAntenas,1);
    %Numero de personas.
    nPersonas = size(matPersonas,1);
    %Matriz H
    H = zeros(nPersonas,nAntenas);
    %Ciclo de llenado de la matriz H.
    count1 = 1;
    while count1 <= nPersonas
        %Avanzar con la persona
        count2 = 1;
        while count2 <= nAntenas
            %Avanzar con la antena.
            H(count1,count2) = funcionTransferencia(matPersonas(count1,:),matAntenas(count2,:),f,perdidas);
            count2 = count2 + 1;
        end
        count1 = count1 + 1;
    end
end

function [Hxy] = funcionTransferencia(pos1,pos2,f,perdidas)
    %Funcion que calcula la funcion de transferencia entre dos nodos, en
    %este caso Tx,Rx. Se calcula H_{x,y}
    
    %Params: pos1->X
    %        pos2->Y.
    %        perdidas -> Indica si considera o no perdidas de Free Space.
    
    %Velocidad de la luz 
    c = 3e8;
    %Calculo de distancia
    Rxy = distancia(pos1,pos2);
    %Calculo de factor de perdidas.
    if (perdidas == 1)
        %Caso con perdidas
        lambda = c/f;
        factor = (lambda/(4*pi*Rxy))^2;
    else
        factor = 1;
    end
    %Calculo la funcion de transferencia.
    exponente = (-1i * 2 * pi * f * Rxy)/c;
    Hxy = factor * exp(exponente);
end

function [d] = distancia(coord1,coord2)
    %Funcion que calcula la distancia euclideana.
    
    X1 = coord1(1);
    X2 = coord2(1);
    Y1 = coord1(2);
    Y2 = coord2(2);
    
    %Distancias
    d = sqrt((X1-X2)^2 + (Y1-Y2)^2);

end

%3.- Generacion de las signals en el receptor. 