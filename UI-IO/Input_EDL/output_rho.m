function rho = output_rho(x1, x2, x3)
h = norm([x1, x2, x3]);
pb   = 1;   %slug/ft^3
Tb   = 210; %Kelvin
M    = 0.0189644; %kg/mol
g0   = 12.2; %ft/s^2
Rstar = 8.9494596E4; %ft^2 / (s*K)
hb   = 0;

rho = pb * exp((-g0*M*(h - hb)) / (Rstar*Tb));
end




