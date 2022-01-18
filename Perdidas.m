%% Opciones del programa

r = 3; % N�mero de coeficientes a calcular

%% Seleci�n de los puntos de muestreo

R = numel(t); % Contabilizaci�n del n�mero de puntos de tiempo del ensayo

%Obtenci�n de los puntos de muestreo (situados a la misma distancia entre ellos)
n = 1;
while(n<=r)
    if(n==1)
        T(n) = 1;
    end
    if(n>1)
        T(n) = round(n*R/r); % Aproximaci�n al n�mero entero m�s cercano del punto de tiempo seleccionado
    end
    if(n==r)
        T(n) = R;
    end
    n = n+1;
end

%% Resoluci�n del sistema de ecuaciones lineales

% Obtenci�n de la matriz A
c = 1;
while(c<=r)
   f = 1;
   while(f<=r)
       A(f,c) = wgt(T(f))^(c-1);
       f = f+1;
   end
   c = c+1;
end

% Obtenci�n del vector columna b
f = 1;
while(f<=r)
   b(f,1) = -Jg*agt(T(f));
   f = f+1;
end

% Resoluci�n del sistema de ecuaciones lineales
x = A\b;
