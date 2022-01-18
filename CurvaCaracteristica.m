%% Opciones del programa

r = 1e-3; % Resoluci�n para la velocidad angular

%% Ajuste de resoluci�n de la velocidad

n = 1;
while(n<ne)
    Pm(n) = M(2,n);
    w(n) = M(3,n);
    n = n+1;
end

wmax = max(w); % Velocidad angular m�xima en [rad/s]

wi = 0:r:wmax; % Genera un vector de velocidades de la resoluci�n "r" dada
Pmi = interp1(w,Pm,wi,'pchip'); % Interpola valores de potencia para cada velocidad

%% Gr�fica

figure(11)
plot(wi,Pmi)
title('Curva de seguimiento �ptimo de la turbina')
xlabel('Velocidad angular[rad/s]')
ylabel('Potencia[W]')