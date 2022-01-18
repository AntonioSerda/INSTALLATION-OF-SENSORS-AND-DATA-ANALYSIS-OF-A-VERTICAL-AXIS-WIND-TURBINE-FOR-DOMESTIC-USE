%% Inicialización

clearvars -except Jg ne M % Elimina todas las variables excepto el momento de inercia de la turbina y la inicialización de los ensayos de curva característica(Evita errores)
close all % Cierra las gráficas (Evita confusiones con gráficas de ensayos distintos)

%% Parámetros físicos del aerogenerador

% Anemómetro
Ra = 70e-3; % Radio desde el eje del anemómetro a el centro de la pala en [m]
coma = 2; % Número de conmutaciones por vuelta que realiza el anemómetro
ca = 200/(21*pi); % Factor de cazoleta

% Generador
Rg = 265e-3; % Distancia a la que se encuentra el imán que detecta el sensor hall del eje del generador en [m]
npg = 5; % Número de conmutaciones por vuelta que realiza el sensor hall (número de palas del aerogenerador)

%% Opciones del programa

Tmin = 0; % Tiempo mínimo de muestreo en [ms] (No funciona con "modo=2")
Tmax = 300000; % Tiempo máximo de muestreo en [ms]
origen = 1; % Tiempo inicial en primera conmutación de cualquier dispositivo(0), tiempo inicial en primera conmutación del sensor hall(1)
modo = 3; % Sin compensación de palas(1), con compensación de palas(2), con un imán en total(3)
correccion = 1; % Sin corrección de error de muestreo(0), con corrección de error de muestreo(1)
ncorreccion5 = 0.91; % Factor de corrección de error de muestreo para cinco imanes
ncorreccion1 = 0.51; % Factor de corrección de error de muestreo para un imán
interpolaciona = 'lineal'; % Selecciona el tipo de interpolación en la velocidad del viento
interpolaciong = 'spline'; % Selecciona el tipo de interpolación en la velocidad de la turbina

%% Carga de vectores de tiempo

load('un_iman_pot3_cerca.mat')

%% Fijar el origen de tiempos en 0

% Contabilizar el número de conmutaciones en cada dispositivo
na = numel(ta);
nh = numel(th);

% Si se quiere que el origen de tiempo se sitúe en la primera conmutación de cualquier dispositivo
if(origen==0)
    if (ta(1)<th(1))
        ta0 = ta(1);
        n=1;
        while(n<=na)
            ta(n) = ta(n)-ta0;
            n = n+1;
        end
        n=1;
        while(n<=nh)
            th(n) = th(n)-ta0;
            n = n+1;
        end
    end

    if (ta(1)>th(1))
        th0 = th(1);
        n=1;
        while(n<=na)
            ta(n) = ta(n)-th0;
            n = n+1;
        end
        n=1;
        while(n<=nh)
            th(n) = th(n)-th0;
            n = n+1;
        end
    end

    if (ta(1)==th(1))
        ta0 = ta(1);
        n=1;
        while(n<=na)
            ta(n) = ta(n)-ta0;
            n = n+1;
        end
        n=1;
        while(n<=nh)
            th(n) = th(n)-ta0;
            n = n+1;
        end
    end
end

% Si se quiere que el origen de tiempo se sitúe en la primera conmutación del sensor hall
if(origen==1) 
    t0 = th(1);
    
    % Anemómeteo 
    n1 = 1;
    n2 = 1;
    while(n1<=na)
        if(ta(n1)>=t0)
            t(n2) = ta(n1); % Escribe los valores de tiempo superiores al origen de conmutación del sensor hall en un vector auxiliar t
            n2 = n2+1;
        end
        n1 = n1+1;
    end
    clearvars ta; % Borra el vector de tiempo antiguo
    ta = t; % Crea un nuevo vector de tiempos límitado al tiempo máximo
    clearvars t; % Borra el vector de tiempo auxiliar t
    na = numel(ta);
    n = 1;
    while(n<=na)
        ta(n) = ta(n)-t0;
        n = n+1;
    end
    
    % Sensor hall
    n = 1;
    while(n<=nh)
        th(n) = th(n)-t0;
        n = n+1;
    end
    nh = numel(th);
end

%% Limitación del tiempo máximo de muestreo

% Anemómetro
n1 = 1;
n2 = 1;
while(n1<=na)
    if(ta(n1)<=Tmax)
        t(n2) = ta(n1); % Escribe los valores de tiempo inferiores al tiempo máximo en un vector auxiliar t
        n2 = n2+1;
    end
    n1 = n1+1;
end
clearvars ta; % Borra el vector de tiempo antiguo
ta = t; % Crea un nuevo vector de tiempos límitado al tiempo máximo
clearvars t; % Borra el vector de tiempo auxiliar t

% Sensor Hall
n1 = 1;
n2 = 1;
while(n1<=nh)
    if(th(n1)<=Tmax)
        t(n2) = th(n1); % Escribe los valores de tiempo inferiores al tiempo máximo en un vector auxiliar t
        n2 = n2+1;
    end
    n1 = n1+1;
end
clearvars th; % Borra el vector de tiempo antiguo
th = t; % Crea un nuevo vector de tiempos límitado al tiempo máximo
clearvars t; % Borra el vector de tiempo auxiliar t

% Contabilizar el número de conmutaciones en cada dispositivo de nuevo
na = numel(ta);
nh = numel(th);

%% Vectores de tiempo para cada pala

if(modo==2)
    n = 1;
    m = 1;
    n1 = 1;
    n2 = 1;
    n3 = 1;
    n4 = 1;
    n5 = 1;
    while(n<=nh)
        if(m==1)
            th1(n1) = th(n);
            n1 = n1+1;
        end
        if(m==2)
            th2(n2) = th(n);
            n2 = n2+1;
        end
        if(m==3)
            th3(n3) = th(n);
            n3 = n3+1;
        end
        if(m==4)
            th4(n4) = th(n);
            n4 = n4+1;
        end
        if(m==5)
            th5(n5) = th(n);
            n5 = n5+1;
            m = 0;
        end
        n = n+1;
        m = m+1;
    end
    
    % Contabilizar el número de conmutaciones en cada pala
    nh1 = numel(th1);
    nh2 = numel(th2);
    nh3 = numel(th3);
    nh4 = numel(th4);
    nh5 = numel(th5);
end

%% Vectores de tiempo con misma referencia

if(ta(na)<th(nh))
    T = th(nh);
end

if(ta(na)>th(nh))
    T = ta(na);
end

if(ta(na)==th(nh))
    T = ta(na);
end

t = 0:T; % Genera un vector de tiempo en [ms]

%% Velocidades y aceleraciones

% Anemómetro
n = 1;
while (n<=na)
    if(n==1)
        wa(n) = 0; % El valor de la velocidad inicial es 0
    end
    if(n>1)
        wa(n) = (2*pi*1000/coma)/(ta(n)-ta(n-1)); % Velocidad angular del anemómetro en [rad/s]
    end
    n = n+1;
end
vvm = ca*Ra*wa; % Velocidad del viento en [m/s]
vvkm = 3.6*ca*Ra*wa; % Velocidad del viento en [km/h]
n=1;
while (n<=na)
    if(n==1)
        aa(n) = NaN; % El valor de la aceleración inicial no es un número
    end
    if(n>1)
        aa(n) = (wa(n)-wa(n-1))/(ta(n)-ta(n-1)); % Aceleración angular del anemómetro en [rad/s^2]
    end
    n = n+1;
end
avm = ca*Ra*aa; % Aceleración del viento en [m/s^2]
avkm = 3.6*ca*Ra*aa; % Aceleración del viento en [km/h^2]

% Hall con y sin compensación de palas
if(modo==1 || modo==2)
    n = 1;
    while (n<=nh)
        if(n==1)
            wgHz(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz(n) = (1000/npg)/(th(n)-th(n-1)); % Velocidad angular de la turbina en con 5 imanes[Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh && correccion==1) 
        if(n>2)
            if(wgHz(n-1)<=ncorreccion5*wgHz(n-2) && wgHz(n-1)<=ncorreccion5*wgHz(n))
                wgHz(n-1) = (wgHz(n)+wgHz(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg = 2*pi*wgHz; % Velocidad angular de la turbina en [rad/s]
    wgrpm = 60*wgHz; % Velocidad angular de la turbina en [rpm]
    n=1;
    while (n<=nh)
        if(n==1)
            agHz(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz(n) = (wgHz(n)-wgHz(n-1))/(th(n)-th(n-1)); % Aceleración angular de la turbina en [Hz^2]
        end
        n = n+1;
    end
    ag = 2*pi*agHz; % Aceleración angular de la turbina en [rad/s^2]
    agrpm = 60*agHz; % Aceleración angular de la turbina en [rpm^2]
end

% Hall con un imán en total
if(modo==3)
    n = 1;
    while (n<=nh)
        if(n==1)
            wgHz(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz(n) = 1000/(th(n)-th(n-1)); % Velocidad angular de la turbina con 1 imán en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh && correccion==1)
        if(n>2)
            if(wgHz(n-1)<=ncorreccion1*wgHz(n-2) && wgHz(n-1)<=ncorreccion1*wgHz(n))
                wgHz(n-1) = (wgHz(n)+wgHz(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg = 2*pi*wgHz; % Velocidad angular de la turbina en [rad/s]
    wgrpm = 60*wgHz; % Velocidad angular de la turbina en [rpm]
    n=1;
    while (n<=nh)
        if(n==1)
            agHz(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz(n) = (wgHz(n)-wgHz(n-1))/(th(n)-th(n-1)); % Aceleración angular de la turbina en [Hz^2]
        end
        n = n+1;
    end
    ag = 2*pi*agHz; % Aceleración angular de la turbina en [rad/s^2]
    agrpm = 60*agHz; % Aceleración angular de la turbina en [rpm^2]
end

% Hall por cada pala
if(modo==2)
    % Pala 1
    n = 1;
    while (n<=nh1)
        if(n==1)
            wgHz1(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz1(n) = 1000/(th1(n)-th1(n-1)); % Velocidad angular de la pala 1 en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh1 && correccion==1)
        if(n>2)
            if(wgHz1(n-1)<=ncorreccion5*wgHz1(n-2) && wgHz1(n-1)<=ncorreccion5*wgHz1(n))
                wgHz1(n-1) = (wgHz1(n)+wgHz1(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg1 = 2*pi*wgHz1; % Velocidad angular de la pala 1 en [rad/s]
    wgrpm1 = 60*wgHz1; % Velocidad angular de la pala 1 en [rpm]
    n=1;
    while (n<=nh1)
        if(n==1)
            agHz1(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz1(n) = (wgHz1(n)-wgHz1(n-1))/(th1(n)-th1(n-1)); % Aceleración angular de la pala 1 en [Hz^2]
        end
        n = n+1;
    end
    ag1 = 2*pi*agHz1; % Aceleración angular de la pala 1 en [rad/s^2]
    agrpm1 = 60*agHz1; % Aceleración angular de la pala 1 en [rpm^2]

    % Pala 2
    n = 1;
    while (n<=nh2)
        if(n==1)
            wgHz2(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz2(n) = 1000/(th2(n)-th2(n-1)); % Velocidad angular de la pala 2 en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh2 && correccion==1)
        if(n>2)
            if(wgHz2(n-1)<=ncorreccion5*wgHz2(n-2) && wgHz2(n-1)<=ncorreccion5*wgHz2(n))
                wgHz2(n-1) = (wgHz2(n)+wgHz2(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg2 = 2*pi*wgHz2;
    wgrpm2 = 60*wgHz2;
    n=1;
    while (n<=nh2)
        if(n==1)
            agHz2(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz2(n) = (wgHz2(n)-wgHz2(n-1))/(th2(n)-th2(n-1)); % Aceleración angular de la pala 2 en [Hz^2]
        end
        n = n+1;
    end
    ag2 = 2*pi*agHz2;
    agrpm2 = 60*agHz2;

    % Pala 3
    n = 1;
    while (n<=nh3)
        if(n==1)
            wgHz3(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz3(n) = 1000/(th3(n)-th3(n-1)); % Velocidad angular de la pala 3 en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh3 && correccion==1)
        if(n>2)
            if(wgHz3(n-1)<=ncorreccion5*wgHz3(n-2) && wgHz3(n-1)<=ncorreccion5*wgHz3(n))
                wgHz3(n-1) = (wgHz3(n)+wgHz3(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg3 = 2*pi*wgHz3;
    wgrpm3 = 60*wgHz3;
    n=1;
    while (n<=nh3)
        if(n==1)
            agHz3(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz3(n) = (wgHz3(n)-wgHz3(n-1))/(th3(n)-th3(n-1)); % Aceleración angular de la pala 3 en [Hz^2]
        end
        n = n+1;
    end
    ag3 = 2*pi*agHz3;
    agrpm3 = 60*agHz3;

    % Pala 4
    n = 1;
    while (n<=nh4)
        if(n==1)
            wgHz4(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz4(n) = 1000/(th4(n)-th4(n-1)); % Velocidad angular de la pala 4 en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh4 && correccion==1)
        if(n>2)
            if(wgHz4(n-1)<=ncorreccion5*wgHz4(n-2) && wgHz4(n-1)<=ncorreccion5*wgHz4(n))
                wgHz4(n-1) = (wgHz4(n)+wgHz4(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg4 = 2*pi*wgHz4;
    wgrpm4 = 60*wgHz4;
    n=1;
    while (n<=nh4)
        if(n==1)
            agHz4(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz4(n) = (wgHz4(n)-wgHz4(n-1))/(th4(n)-th4(n-1)); % Aceleración angular de la pala 4 en [Hz^2]
        end
        n = n+1;
    end
    ag4 = 2*pi*agHz4;
    agrpm4 = 60*agHz4;

    % Pala 5
    n = 1;
    while (n<=nh5)
        if(n==1)
            wgHz5(n) = 0; % El valor de la velocidad inicial es 0
        end
        if(n>1)
            wgHz5(n) = 1000/(th5(n)-th5(n-1)); % Velocidad angular de la pala 5 en [Hz]
        end
        n = n+1;
    end
    % Corrección de error de muestreo
    n = 1;
    while(n<=nh5 && correccion==1)
        if(n>2)
            if(wgHz5(n-1)<=ncorreccion5*wgHz5(n-2) && wgHz5(n-1)<=ncorreccion5*wgHz5(n))
                wgHz5(n-1) = (wgHz5(n)+wgHz5(n-2))/2;
            end
        end
        n = n+1;
    end
    %
    wg5 = 2*pi*wgHz5;
    wgrpm5 = 60*wgHz5;
    n=1;
    while (n<=nh5)
        if(n==1)
            agHz5(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHz5(n) = (wgHz5(n)-wgHz5(n-1))/(th5(n)-th5(n-1)); % Aceleración angular de la pala 5 en [Hz^2]
        end
        n = n+1;
    end
    ag5 = 2*pi*agHz5;
    agrpm5 = 60*agHz5;
end

%% Velocidades y aceleraciones en el vector de tiempo t en [ms]

% Velocidad angular en [Hz]
wat = interp1(ta,wa,t,interpolaciona); % Interpola la velocidad angular del anemómetro en [rad/s]
wgHzt = interp1(th,wgHz,t,interpolaciong); % Interpola la velocidad angular de la turbina en [Hz] (Para poder emplear distintos tipos de interpolación diferentes a la lineal es necesario que el parámetro "origen=1")

% Aceleración angular en [Hz^2]

    % Anemómetro
    n=1;
    while (n<=T+1)
        if(n==1)
            aat(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            aat(n) = (wat(n)-wat(n-1))/(t(n)-t(n-1)); % Aceleración angular del anemómetro en [Hz^2]
        end
        n = n+1;
    end
    %aat = interp1(ta,aa,t); % Aceleración angular del anemómetro en [Hz^2]
    
    % Turbina sin ponderación por palas o con un imán por pala
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt(n) = (wgHzt(n)-wgHzt(n-1))/(t(n)-t(n-1)); % Aceleración angular de la turbina en [Hz^2]
        end
        n = n+1;
    end
    %agHzt = interp1(th,agHz,t); % Aceleración angular de la turbina en [Hz^2]
    
% Limitación del tiempo mínimo de muestreo
    n1 = 1;
    n2 = 1;
    while(n1<=T+1)
        if(t(n1)>=Tmin)
            wauxa(n2) = wat(n1); % Escribe los valores de velocidad para tiempos superiores al tiempo mínimo en un vector auxiliar wauxa
            wauxg(n2) = wgHzt(n1); % Escribe los valores de velocidad para tiempos superiores al tiempo mínimo en un vector auxiliar wauxg
            aauxa(n2) = aat(n1); % Escribe los valores de aceleración para tiempos superiores al tiempo mínimo en un vector auxiliar aauxa
            aauxg(n2) = agHzt(n1); % Escribe los valores de aceleración para tiempos superiores al tiempo mínimo en un vector auxiliar aauxg
            n2 = n2+1;
        end
        n1 = n1+1;
    end
    clearvars wat; % Borra el vector de velocidad antiguo
    clearvars wgHzt; % Borra el vector de velocidad antiguo
    clearvars aat; % Borra el vector de aceleración antiguo
    clearvars agHzt; % Borra el vector de aceleración antiguo
    wat = wauxa; % Crea un nuevo vector de velocidad límitado al tiempo mínimo
    wgHzt = wauxg; % Crea un nuevo vector de velocidad límitado al tiempo mínimo
    aat = aauxa; % Crea un nuevo vector de aceleración límitado al tiempo mínimo
    agHzt = aauxg; % Crea un nuevo vector de aceleración límitado al tiempo mínimo
    clearvars wauxa; % Borra el vector de velocidad auxiliar wauxa
    clearvars wauxg; % Borra el vector de velocidad auxiliar wauxg
    clearvars aauxa; % Borra el vector de aceleración auxiliar aauxa
    clearvars aauxg; % Borra el vector de aceleración auxiliar aauxg

% Resto de velocidades y aceleraciones
  
    % Anemómetro
    vvmt = ca*Ra*wat; % Velocidad del viento en [m/s]
    vvkmt = 3.6*ca*Ra*wat; % Velocidad del viento en [km/h]
    avmt = ca*Ra*aat; % Aceleración del viento en [m/s^2]
    avkmt = 3.6*ca*Ra*aat; % Aceleración del viento en [km/h^2]
    
    % Turbina sin ponderación por palas o con un imán por pala
    wgt = 2*pi*wgHzt; % Velocidad angular de la turbina en [rad/s]
    wgrpmt = 60*wgHzt; % Velocidad angular de la turbina en [rpm]
    agt = 2*pi*agHzt; % Aceleración angular de la turbina en [rad/s^2]
    agrpmt = 60*agHzt; % Aceleración angular de la turbina en [rpm^2]


% Hall con ponderación por palas
if(modo==2)
    wgHzt1 = interp1(th1,wgHz1,t); % Velocidad angular de la pala 1 en [Hz]
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt1(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt1(n) = (wgHzt1(n)-wgHzt1(n-1))/(t(n)-t(n-1)); % Aceleración angular de la pala 1 en [Hz^2]
        end
        n = n+1;
    end
    %agHzt1 = interp1(th1,agHz1,t); % Aceleración angular de la pala 1 en [Hz^2]
    wgt1 = 2*pi*wgHzt1; % Velocidad angular de pala 1 en [rad/s]
    wgrpmt1 = 60*wgHzt1; % Velocidad angular de la pala 1 en [rpm]
    agt1 = 2*pi*agHzt1; % Aceleración angular de la pala 1 en [rad/s^2]
    agrpmt1 = 60*agHzt1; % Aceleración angular de la pala 1 en [rpm^2]

    wgHzt2 = interp1(th2,wgHz2,t); % Velocidad angular de la pala 2 en [Hz]
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt2(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt2(n) = (wgHzt2(n)-wgHzt2(n-1))/(t(n)-t(n-1)); % Aceleración angular de la pala 2 en [Hz^2]
        end
        n = n+1;
    end
    %agHzt2 = interp1(th2,agHz2,t); % Aceleración angular de la pala 2 en [Hz^2]
    wgt2 = 2*pi*wgHzt2; % Velocidad angular de pala 2 en [rad/s]
    wgrpmt2 = 60*wgHzt2; % Velocidad angular de la pala 2 en [rpm]
    agt2 = 2*pi*agHzt2; % Aceleración angular de la pala 2 en [rad/s^2]
    agrpmt2 = 60*agHzt2; % Aceleración angular de la pala 2 en [rpm^2]

    wgHzt3 = interp1(th3,wgHz3,t); % Velocidad angular de la pala 3 en [Hz]
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt3(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt3(n) = (wgHzt3(n)-wgHzt3(n-1))/(t(n)-t(n-1)); % Aceleración angular de la pala 3 en [Hz^2]
        end
        n = n+1;
    end
    %agHzt3 = interp1(th3,agHz3,t); % Aceleración angular de la pala 3 en [Hz^2]
    wgt3 = 2*pi*wgHzt3; % Velocidad angular de pala 3 en [rad/s]
    wgrpmt3 = 60*wgHzt3; % Velocidad angular de la pala 3 en [rpm]
    agt3 = 2*pi*agHzt3; % Aceleración angular de la pala 3 en [rad/s^2]
    agrpmt3 = 60*agHzt3; % Aceleración angular de la pala 3 en [rpm^2]

    wgHzt4 = interp1(th4,wgHz4,t); % Velocidad angular de la pala 4 en [Hz]
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt4(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt4(n) = (wgHzt4(n)-wgHzt4(n-1))/(t(n)-t(n-1)); % Aceleración angular de la pala 4 en [Hz^2]
        end
        n = n+1;
    end
    %agHzt4 = interp1(th4,agHz4,t); % Aceleración angular de la pala 4 en [Hz^2]
    wgt4 = 2*pi*wgHzt4; % Velocidad angular de pala 4 en [rad/s]
    wgrpmt4 = 60*wgHzt4; % Velocidad angular de la pala 4 en [rpm]
    agt4 = 2*pi*agHzt4; % Aceleración angular de la pala 4 en [rad/s^2]
    agrpmt4 = 60*agHzt4; % Aceleración angular de la pala 4 en [rpm^2]

    wgHzt5 = interp1(th5,wgHz5,t); % Velocidad angular de la pala 5 en [Hz]
    n=1;
    while (n<=T+1)
        if(n==1)
            agHzt5(n) = NaN; % El valor de la aceleración inicial no es un número
        end
        if(n>1)
            agHzt5(n) = (wgHzt5(n)-wgHzt5(n-1))/(t(n)-t(n-1)); % Aceleración angular de la pala 5 en [Hz^2]
        end
        n = n+1;
    end
    %agHzt5 = interp1(th5,agHz5,t); % Aceleración angular de la pala 5 en [Hz^2]
    wgt5 = 2*pi*wgHzt5; % Velocidad angular de pala 5 en [rad/s]
    wgrpmt5 = 60*wgHzt5; % Velocidad angular de la pala 5 en [rpm]
    agt5 = 2*pi*agHzt5; % Aceleración angular de la pala 5 en [rad/s^2]
    agrpmt5 = 60*agHzt5; % Aceleración angular de la pala 5 en [rpm^2]

    % Vector de tiempos para las palas
    tp = t;
    
    % Compensación de palas
    wgHztm = (wgHzt1+wgHzt2+wgHzt3+wgHzt4+wgHzt4)/5; % Velocidad angular de la turbina en [Hz]
    n=1;
    while (n<=numel(t))
        if(n==1)
            agHztm(n) = NaN;
        end
        if(n>1)
            agHztm(n) = (wgHztm(n)-wgHztm(n-1))/(t(n)-t(n-1)); % Aceleración angular de la turbina en [Hz^2]
        end
        n = n+1;
    end
    
    % Limitación del tiempo mínimo de muestreo
    n1 = 1;
    n2 = 1;
    while(n1<=T+1)
        if(t(n1)>=Tmin)
            wauxgm(n2) = wgHztm(n1); % Escribe los valores de velocidad para tiempos superiores al tiempo mínimo en un vector auxiliar wauxg
            aauxgm(n2) = agHztm(n1); % Escribe los valores de aceleración para tiempos superiores al tiempo mínimo en un vector auxiliar aauxg
            n2 = n2+1;
        end
        n1 = n1+1;
    end
    clearvars wgHztm; % Borra el vector de velocidad antiguo
    clearvars agHztm; % Borra el vector de aceleración antiguo
    wgHztm = wauxgm; % Crea un nuevo vector de velocidad límitado al tiempo mínimo
    agHztm = aauxgm; % Crea un nuevo vector de aceleración límitado al tiempo mínimo
    clearvars wauxgm; % Borra el vector de velocidad auxiliar wauxgm
    clearvars aauxgm; % Borra el vector de aceleración auxiliar aauxgm
    
    % Resto de velocidades y aceleraciones
    wgtm = 2*pi*wgHztm; % Velocidad angular de la turbina en [rad/s]
    wgrpmtm = 60*wgHztm; % Velocidad angular de la turbina en [rpm]
    agtm = 2*pi*agHztm; % Aceleración angular de la turbina en [rad/s^2]
    agrpmtm = 60*agHztm; % Aceleración angular de la turbina en [rpm^2]
end

% Limitación del tiempo mínimo de muestreo
n1 = 1;
n2 = 1;
while(n1<=T+1)
    if(t(n1)>=Tmin)
        taux(n2) = t(n1); % Escribe los valores de tiempo superior al tiempo mínimo en un vector auxiliar taux
        n2 = n2+1;
    end
    n1 = n1+1;
end
clearvars t; % Borra el vector de tiempo antiguo
t = taux; % Crea un nuevo vector de tiempo límitado al tiempo mínimo
clearvars taux; % Borra el vector de tiempo auxiliar taux

%% Velocidad media del viento

nt = numel(t); % Contabiliza el número de elementos del vector de tiempo
n = 1;
nn = isnan(wat);  
while (n<=nt)
    if (nn(n)==1)
        wan(n) = 0; % Crea un vector lógico indicando con un 1 los valores no numéricos (NaN) y con un 0 los que sí lo son
        n = n+1;
    else
        wan(n) = wat(n);
        n = n+1;
    end
end
wma = sum(wan)/T; % Velocidad angular media del anemómetro durante el ensayo en [rad/s]
vmvm = ca*Ra*wma; % Velocidad media del viento durante el ensayo en [m/s]
vmvkm = 3.6*ca*Ra*wma; % Velocidad media del viento durante el ensayo en [km/h]

%% Potencia en [W]

% Sin compensación de palas o con un imán por pala
Pmg = Jg*(wgt.*agt); 
[Pmgmax,nmax] = max(Pmg); % Indica el valor de la potencia máxima y su posición en el vector Pmg

% Con compensación de palas
if(modo==2)
    Pmg1 = Jg*(wgt1.*agt1); 
    Pmg2 = Jg*(wgt2.*agt2); 
    Pmg3 = Jg*(wgt3.*agt3); 
    Pmg4 = Jg*(wgt4.*agt4); 
    Pmg5 = Jg*(wgt5.*agt5);

    Pmgm = Jg*(wgtm.*agtm); 
    [Pmgmmax,nmax] = max(Pmgm); % Indica el valor de la potencia máxima y su posición en el vector Pmg
end

%% Gráficas

if(modo==1)
    figure (1)
    plot(t/1000,vvmt)
    title('Velocidad del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s]')
    
    figure (2)
    plot(t/1000,wgrpmt)
    title('Velocidad de la turbina sin compensación')
    xlabel('Tiempo[s]')
    ylabel('[rpm]')

    figure (3)
    plot(t/1000,avmt)
    title('Aceleració del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s^2]')
    
    figure (4)
    plot(t/1000,agt)
    title('Aceleración del anemómetro sin compensación')
    xlabel('Tiempo[s]')
    ylabel('[rad/s^2]')

    figure (5)
    plot(t/1000,Pmg)
    title('Potencia mecánica sin compensación')
    xlabel('Tiempo[s]')
    ylabel('[W]')

    figure(6)
    scatter(wgt,Pmg)
    title('Potencia mecánica frente a velocidad de la turbina sin compensación')
    xlabel('Velocidad angular[rad/s]')
    ylabel('Potencia[W]')
    
    figure(7)
    subplot(2,1,1);
    yyaxis left
    plot(t/1000,wgrpmt);
    title('Velocidades')
    xlabel('Tiempo[s]')
    ylabel('Velocidad de la turbina con un imán[rpm]')
    yyaxis right
    plot(t/1000,vvmt);
    ylabel('Velocidad del viento[m/s]')
    subplot(2,1,2);
    plot(t/1000,agt);
    title('Aceleraciones')
    xlabel('Tiempo[s]')
    ylabel('Aceleración de la turbina con un imán[rad/s^2]')
end

if(modo==2)
    figure (1)
    plot(t/1000,vvmt)
    title('Velocidad del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s]')
    
    figure (2)
    plot(t/1000,wgrpmtm)
    title('Velocidad de la turbina con compensación')
    xlabel('Tiempo[s]')
    ylabel('[rpm]')

    figure (3)
    plot(t/1000,avmt)
    title('Aceleración del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s^2]')
    
    figure (4)
    plot(t/1000,agtm)
    title('Aceleración de la turbina con compensación')
    xlabel('Tiempo[s]')
    ylabel('[rad/s^2]')

    figure (5)
    plot(t/1000,Pmgm)
    title('Potencia mecánica con compensación')
    xlabel('Tiempo[s]')
    ylabel('[W]')

    figure (6)
    scatter(wgt,Pmgm)
    title('Potencia mecánica frente a velocidad de la turbina con compensación')
    xlabel('Velocidad angular[rad/s]')
    ylabel('Potencia[W]') 
    
    figure (7)
    plot(tp/1000,wgrpmt1,tp/1000,wgrpmt2,tp/1000,wgrpmt3,tp/1000,wgrpmt4,tp/1000,wgrpmt5)
    title('Velocidad de cada pala')
    xlabel('Tiempo[s]')
    ylabel('[rpm]')
    legend('Pala 1','Pala 2','Pala 3','Pala 4','Pala 5')

    figure (8)
    plot(tp/1000,agt1,tp/1000,agt2,tp/1000,agt3,tp/1000,agt4,tp/1000,agt5)
    title('Aceleración de cada pala')
    xlabel('Tiempo[s]')
    ylabel('[rad/s^2]')
    legend('Pala 1','Pala 2','Pala 3','Pala 4','Pala 5')

    figure (9)
    plot(tp/1000,Pmg1,tp/1000,Pmg2,tp/1000,Pmg3,tp/1000,Pmg4,tp/1000,Pmg5)
    title('Potencia mecánica según cada pala')
    xlabel('Tiempo[s]')
    ylabel('[W]')
    legend('Pala 1','Pala 2','Pala 3','Pala 4','Pala 5')
    
    figure(10)
    subplot(2,1,1);
    yyaxis left
    plot(t/1000,wgrpmtm);
    title('Velocidades')
    xlabel('Tiempo[s]')
    ylabel('Velocidad de la turbina con un imán[rpm]')
    yyaxis right
    plot(t/1000,vvmt);
    ylabel('Velocidad del viento[m/s]')
    subplot(2,1,2);
    plot(t/1000,agtm);
    title('Aceleraciones')
    xlabel('Tiempo[s]')
    ylabel('Aceleración de la turbina con un imán[rad/s^2]')
end

if(modo==3)
    figure (1)
    plot(t/1000,vvmt)
    title('Velocidad del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s]')
    
    figure (2)
    plot(t/1000,wgrpmt)
    title('Velocidad de la turbina con un imán')
    xlabel('Tiempo[s]')
    ylabel('[rpm]')

    figure (3)
    plot(t/1000,avmt)
    title('Aceleración del viento')
    xlabel('Tiempo[s]')
    ylabel('[m/s^2]')
    
    figure (4)
    plot(t/1000,agt)
    title('Aceleración de la turbina con un imán')
    xlabel('Tiempo[s]')
    ylabel('[rad/s^2]')

    figure (5)
    plot(t/1000,Pmg)
    title('Potencia mecánica con un imán')
    xlabel('Tiempo[s]')
    ylabel('[W]')

    figure(6)
    scatter(wgt,Pmg)
    title('Potencia mecánica frente a velocidad de la turbina con un imán')
    xlabel('Velocidad angular[rad/s]')
    ylabel('Potencia[W]')
    
    figure(7)
    subplot(2,1,1);
    yyaxis left
    plot(t/1000,wgrpmt);
    title('Velocidades')
    xlabel('Tiempo[s]')
    ylabel('Velocidad de la turbina con un imán[rpm]')
    yyaxis right
    plot(t/1000,vvmt);
    ylabel('Velocidad del viento[m/s]')
    subplot(2,1,2);
    plot(t/1000,agt);
    title('Aceleraciones')
    xlabel('Tiempo[s]')
    ylabel('Aceleración de la turbina con un imán[rad/s^2]')
    
    figure(8)
    subplot(2,1,1);
    plot(t/1000,wgrpmt);
    title('Velocidad de la turbina con un imán')
    xlabel('Tiempo[s]')
    ylabel('[rpm]')
    subplot(2,1,2);
    plot(t/1000,agt);
    title('Aceleración de la turbina con un imán')
    xlabel('Tiempo[s]')
    ylabel('[rad/s^2]')
end

%% Almacenamiento de variables

N = [vmvm;Pmgmax;wgt(nmax)]; %Almacena las variables velocidad media del viento, potencia mecánica máxima y velocidad angular de la turbina para esa potencia en una matriz
M = [M, N]; % La matriz se va ampliando por columnas a medida que se realizan más ensayos
ne = ne+1; % Aumenta el contador de ensayos realizados para distintas velocidades del viento
