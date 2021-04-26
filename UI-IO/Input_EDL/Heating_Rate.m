function Q_dot = Heating_Rate(x1,x2, h1, h2, rho0, S, Cf)
% MSL (Design): peak 200(W/cm^2) and Diameter 4.5m Highest aerothermodynamic
% (margined at ~250 W/cm2)
h_real = x1;
V_real = x2;
V = V_real*1000; % m/s

rho = rho0*exp((h2 - h_real)/h1)*10^-9;      % kg/m^3;
Q_dot = Cf*rho*V^3*S/4/10000;

% % Sutton Graves Equation
% k= 1.9027e-4;
% R_n = D/4;          % bluntness
% Q_dot2 = k*sqrt(rho/R_n)*V^3/10000;