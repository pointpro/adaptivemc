%Steven Romeo
%SSA Problem

%The following plot shows the ensemble sizes for a prescribed error of
%5x10^-3. 
%The plot will have several curves which represent different batch sizes used for the Monte Carlo simulations

time = [0 .5 1 1.5 2 2.5 3 3.5 4 5 6 8 10];

size1 = [6585 6585 6595 6660 6770 7340 7695 8320 8750 9260 9380 10065 10070]; %bat size=1
 
size10 = [6760 6760 6760 6800 6850 7450 7950 8290 9000 9625 9650 9980 9985]; %bat size=10

size20 = [6805 6805 6805 6870 7110 7335 7625 8215 9025 9445 9460 9700 9730]; %bat size=20

size50 = [6665 6665 6670 6775 7005 7530 7650 8130 8730 9250 9440 9685 9775]; %bat size=50

size100 = [6770 6770 6770 6885 7065 7355 7750 8140 9100 9355 9385 10035 10045]; %bat size=100

size1000 = [6700 6700 6700 6725 7120 7280 7760 8065 8730 9425 9475 9845 9845]; %bat size=1000

t_elap1 = 5055.5; %secs
t_elap10 = 4801.3; 
t_elap20 = 4722.4;
t_elap50 = 4735.4;
t_elap100 = 4861.4;
t_elap1000 = 4962.7;

figure(1)

plot(time,size1,'-o','LineWidth', 2)

hold on

plot(time,size10,'-+','LineWidth', 2)

plot(time,size20,'-*','LineWidth', 2)

plot(time,size50,'-x','LineWidth', 2)

plot(time,size100,'-d','LineWidth', 2)

plot(time,size1000,'-s','LineWidth', 2)

hold off

title('Ensemble Sizes for Differing Bat. Sizes (P_a_c_c = .005)')

xlabel('Time (s)')
ylabel('Ensemble Size (# particles)')

legend('Ensemble Size = 1', 'Ensemble Size = 10','Ensemble Size = 20', 'Ensemble Size = 50','Ensemble Size = 100','Ensemble Size = 1000','Location','southeast')