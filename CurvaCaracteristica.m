%% Opciones del programa

r = 1e-3; % Resolución para la velocidad angular

%% Ajuste de resolución de la velocidad

n = 1;
while(n<ne)
    Pm(n) = M(2,n);
    w(n) = M(3,n);
    n = n+1;
end

wmax = max(w); % Velocidad angular máxima en [rad/s]

wi = 0:r:wmax; % Genera un vector de velocidades de la resolución "r" dada
Pmi = interp1(w,Pm,wi,'pchip'); % Interpola valores de potencia para cada velocidad

%% Gráfica

figure(11)
plot(wi,Pmi)
title('Curva de seguimiento óptimo de la turbina')
xlabel('Velocidad angular[rad/s]')
ylabel('Potencia[W]')