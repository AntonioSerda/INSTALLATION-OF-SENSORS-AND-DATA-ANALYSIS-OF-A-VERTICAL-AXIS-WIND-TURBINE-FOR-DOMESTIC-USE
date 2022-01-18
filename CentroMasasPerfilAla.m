%% Extracción de datos del perfil de ala del fichero de Excel a Matlab

xs = xlsread('ClarkY.xlsx','A:A'); % Coordenadas en x de la curva superior
ys = xlsread('ClarkY.xlsx','B:B'); % Coordenadas en y de la curva superior
xi = xlsread('ClarkY.xlsx','C:C'); % Coordenadas en x de la curva inferior
yi = xlsread('ClarkY.xlsx','D:D'); % Coordenadas en y de la curva inferior

%% Ajuste de vectores

% Resolución en el eje x
r = 5e-4;

% Reescalado de vectores
X = 0:r:1; % Vector de puntos en el eje x

X = X';

YS = interp1(xs,ys,X,'spline'); % Interpolación de los puntos del eje y de la curva superior del perfil para las coordenadas en x
YI = interp1(xi,yi,X,'spline'); % Interpolación de los puntos del eje y de la curva inferior del perfil para las coordenadas en x

X = X';
YS = YS';
YI = YI';

nX = numel(X); % Numero de componentes del vector de posición del eje x

%% Cálculo de la posición del centro de masas de las tapas

% Eje x
n = 1;
while (n<=nX)
    dmx(n) = YS(n)-YI(n); % Diferencial de masa ficticio en el eje x
    n = n+1;
end

mf = sum(dmx); % Masa ficticia total del perfil

n = 1;
xg = 0;
while (n<=nX)
    xg = xg+dmx(n)*X(n); % Ponderación de la posición de cada diferencial en el eje x por el valor de masa ficticia de cada uno de los mismos
    n = n+1;
end
XGp = xg/mf; % Posición del centro de masas del perfil en el eje x

% Eje y
n = 1;
while (n<=nX)
    ygdmx(n) = (YI(n)+YS(n))/2; % Posición del centro de masas en el eje y de cada diferencial de masas del eje x 
    n = n+1;
end

n = 1;
yg = 0;
while (n<=nX)
    yg = yg+dmx(n)*ygdmx(n); % Ponderación de la posición de cada diferencial en el eje y por el valor de masa ficticia de cada uno de los mismos
    n = n+1;
end
YGp = yg/mf; % Posición del centro de masas del perfil en el eje y

%%  Dibujo

figure
plot(X,YS,X,YI,XGp,YGp,'b--o')
title('Perfil de ala clarky-il')
legend('Curva superior','Curva inferior','Centro de masas')
