%% SCRIPT
matSenales = cargarDatos();
%% FUNCIONES
function [matSenales] = cargarDatos()
    %Cargar datos.
    m1 = load('matSenales1.mat','matSenales');
    m1 = m1.matSenales;
    m2 = load('matSenales2.mat','matSenales');
    m2 = m2.matSenales;
    %Cargar matriz
    matSenales = zeros(size(m1));
    indices = [1 2 3 4 5 6 7 8 9 10];
    for i = indices
        if(mod(i,2)==0)
            matSenales(i,:) = m2(i,:);
        else
            matSenales(i,:) = m1(i,:);
        end
    end
end