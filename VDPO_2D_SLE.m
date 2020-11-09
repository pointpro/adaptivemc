function xp = VDPO_2D_SLE(t,x)
global N_d;
global mu;
xp = zeros(N_d + 1,1);
xp(1) = x(2);
xp(2) = -x(1) + mu*x(2)*(1 - x(1)^2);
xp(3) = -mu*(1 - x(1)^2)*x(3);
end
