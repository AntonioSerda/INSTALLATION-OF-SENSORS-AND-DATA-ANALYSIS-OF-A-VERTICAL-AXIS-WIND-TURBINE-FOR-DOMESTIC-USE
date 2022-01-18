%% Parámetros

npg = 5; % Número de palas del aerogenerador
nbu =2; % Número de barras de unión entre cada pala y el eje

mp = 459e-3; % Masa de cada pala en [kg]
mbu = 19e-3; % Masa de cada barra de unión entre eje y pala en [kg]
me = 156e-3; % Masa del eje de la turbina en [kg]

Lp = 220e-3; % Longitud del eje horizontal del perfil de ala en [m]

Dpg = 245e-3; % Distancia del centro de masas de la pala al eje de la turbina en [m]

Re = 8e-3; % Radio exterior del eje de la turbina en [m]
Ri = 7e-3; % Radio interior del eje de la turbina en [m]

Lbu = 245e-3; % Longitud de cada barra de unión entre eje y pala en [m]

%% Ajuste de vectores

% Resolución
r = 1e-4;

% Reescalado de vectores
X = 0:r:1; % Vector de puntos en el eje x

X = X';

YS = interp1(xs,ys,X); % Interpolación de los puntos del eje y de la curva superior del perfil para las coordenadas en x
YI = interp1(xi,yi,X); % Interpolación de los puntos del eje y de la curva inferior del perfil para las coordenadas en x

X = X';
YS = YS';
YI = YI';

nX = numel(X); % Numero de componentes del vector de posición del eje x

% Cambio del origen del sistema de referencia al centro de masas
n=1;
while(n<=nX)
   X(n) = X(n)-XGp;
   n = n+1;
end

n=1;
while(n<=nX)
   YS(n) = YS(n)-YGp;
   YI(n) = YI(n)-YGp;
   n = n+1;
end

% Reescalado de vectores
YS = round(YS,4); % Aproximación de los valores en y de la curva superior del perfil a 4 decimales
YI = round(YI,4); % Aproximación de los valores en y de la curva inferior del perfil a 4 decimales

%% Cálculo momento de inercia de la turbina

% Momento de inercia de la pala respecto al centro de masas de la pala
Izp = 0;
n1 = 1;
n2 = 1;
n3 = 0;
while(n1<=nX)
   Yn = YI(n1):r:YS(n1); % División del perfil de ala en los puntos comprendidos entre las curvas superior e inferior con una resolución r
   nYn = numel(Yn); % Numero de componentes del vector de posición del eje y (número de puntos en los que se discretiza el perfil de ala)
   while(n2<=nYn)
       Izp = Izp + ((Lp*Yn(n2))^2+(Lp*X(n1))^2); % Momento de inercia del perfil de ala en función de la longitud del eje horizontal y sin tener en cuenta la masa
       n2 = n2+1;
   end
   n3 = n3+n2-1;
   n2 = 1;
   n1 = n1+1;
end

dmp = mp/n3; % Masa de cada punto en los que se divide el perfil de ala
Izp = Izp*dmp; 

% Momento de inercia del eje de la turbina respecto al eje de la turbina
Ize = (1/2)*me*(Re^2+Ri^2);

% Momento de inercia de cada barra de unión entre el eje y las palas al eje de la turbina
Izbu = (1/3)*mbu*Lbu^2;

% Momento de inercia total de la turbina respecto al eje de la turbina en [kg*m^2]
Jg = Ize+npg*nbu*Izbu+npg*Izp+npg*mp*Dpg^2;
