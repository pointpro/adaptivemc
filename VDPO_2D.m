function xp = VDPO_2D(t,x)
global N;
global mu;

xp = zeros(N,1);
xp(1) = x(2);
xp(2) = -x(1) + mu*x(2)*(1 - x(1)^2);

end
