%% Opciones del programa

r = 3; % Número de coeficientes a calcular

%% Seleción de los puntos de muestreo

R = numel(t); % Contabilización del número de puntos de tiempo del ensayo

%Obtención de los puntos de muestreo (situados a la misma distancia entre ellos)
n = 1;
while(n<=r)
    if(n==1)
        T(n) = 1;
    end
    if(n>1)
        T(n) = round(n*R/r); % Aproximación al número entero más cercano del punto de tiempo seleccionado
    end
    if(n==r)
        T(n) = R;
    end
    n = n+1;
end

%% Resolución del sistema de ecuaciones lineales

% Obtención de la matriz A
c = 1;
while(c<=r)
   f = 1;
   while(f<=r)
       A(f,c) = wgt(T(f))^(c-1);
       f = f+1;
   end
   c = c+1;
end

% Obtención del vector columna b
f = 1;
while(f<=r)
   b(f,1) = -Jg*agt(T(f));
   f = f+1;
end

% Resolución del sistema de ecuaciones lineales
x = A\b;
