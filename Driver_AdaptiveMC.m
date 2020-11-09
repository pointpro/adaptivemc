%{
Driver: An Closed-loop Adaptive Monte Carlo Algorithm for Uncertainty Forecasting.
It aims to control its transient performance as well as the associated 
computational load on-the-fly. "Transient Performance" is quantified in '
terms of the error incurred in estimating application-dependent quantities 
of interest (QoI), bounds on which are prescribed by the user. When MCS QoI 
estimation error, measured via bootstrap method, exceeds the prescribed 
upper threshold, optimally selected particles are sequentially introduced 
in batches to the initial ensemble, and then forward propagated to join the
current ensemble. This is done by a two-layered optimization of the MCS 
ensemble efficiency, quantified in terms of appropriate its space-filling 
and non-collapsing properties. On the other hand, when MCS QoI estimation 
error is measured to be under the prescribed lower threshold, particles are 
removed (halted) in the interest of alleviating computational load. Removal
is based on ranking particles by their relative particle weightage, 
evaluated by solving the associated stochastic Liouville equation via the
method of characteristics. As a result, the proposed approach allows the 
creation of a "minimal" particle representation of the state pdf within 
user defined accuracy bounds at each future time. 
%}

clear; close all; clc;

global N_d; %dimension of state-space
global t_f;
global mu;
global Num_resam_bootstrap;
global Accuracy_check_frequency;
global Non_dim;
global Acc_UB Acc_LB P_Acc;
global alpha;
global Num_candidate;
global P_removal; 
global mu0 Covar0
global Num_removal;
global Num_AI_limit;
% global a b;

%% Initialization

%%%
% System Dynamics
%%%
N_d = 2;                                            % System dimensionalities 
                                                    % (user-defined input, or can be obtained from the input dynamics)
%%%system parameters                                                    
mu = 1;                                             % System coefficient (e.g., VDPO)
Non_dim = [2, 3];                                   % Nondimensionalization parameters (user-defined input, or set as a default: how,
                                                    % and how to decide whether the input dynamics is nondimensionalized or not?)
                                                    
t_f = [0 0.5 1 1.5 2 2.5 3 3.5 4 5 6 8 10];         % Time of interest (user-defined input)
tLEN = length(t_f);
MCSAM = struct();                                   % Total information during the forward propagation
                                                    % e.g.,samples and their associated pdf values.                                                
%%%
% Adaptive MC settings 
%%%
% Prescribed accuracy level
P_Acc = 0.05;                                  
Acc_UB = (1 + 0.2)*P_Acc;                           % Prescribed error upper bound (user-defined input or set a default:                                                    % how since it is also related with the QoI?)                                                   
Acc_LB = (1 - 0.1)*P_Acc;                           % Prescribed error lower bound

% Particle-Addition parameters:
alpha = 0.5;                                        % Tolerance parameter defined the importance of the projected distance
Num_candidate = 10000;                              % # of candidates generated from which the next "optimal" particle is selected
                                                    % (user-defined input or set as a default, e.g., 5000)                                                 
Num_new_particle = 1;                               % # of new particles generated after one loop of particle-addition 
                                                    % scheme (e.g., first 10 particles after ranking)
                                                    % (user-defined input or set as a default, e.g., 1)
                                                    
Num_AI_limit = 10;                                  % Define the maximum number of admissible intervals
                                                    % allowed along each dimension (set as a default)
                         

% Particle-Removal parameters:
P_removal = struct();                               % Total information of the "halted" particles during the particle-removal scheme
Num_removal = 0;                                    % # of times that the particle-removal scheme applied

%%%
% Bootstrap estimation  
%%%
Num_resam_bootstrap = 1000;                         % # of bootstrap resampling sets (user-defined input or set a default, e.g., 1000)                                                    
Accuracy_check_frequency = 5;                       % number of P_addition module implementations, before accuracy is checked again, at a given, fixed time.

% (user-defined input or set as a default, e.g., 5) 
%%%
% Initial Uncertainty: Gaussian distribution N[mu0, Covar0] (user-defined input) 
%%%
mu0 = zeros(1, N_d);                                % Initial mean
Covar0 = diag(ones(1, N_d));                        % Initial covariance
Num_start = 10;                                     % # of particles to start the simulation 
                                                    % (user-defined input or set as a default, e.g., 10)
% a = zeros(N_d, 1);                            
% b = ones(N_d, 1);                                                    
U = lhsu(zeros(N_d, 1), ones(N_d, 1), Num_start);   % Generate uniform distributed particles by LHS

%%%,m,
% Inverse transform: (how to generalize it for different distributions and make it as a module?)
%%%
for i = 1 : N_d
    isample(:, i) = icdf('Normal', U(:, i), mu0(i), sqrt(Covar0(i, i)));
end

%%%
% Non-dimensionalization (QoI dependent?)
%%%
isample_ND = isample./repmat(Non_dim, Num_start, 1);   

% Accuracy Estimation: Boostrap 
Acc_cur = BootstrapMean(isample_ND, Num_resam_bootstrap);   % Estimate the accuracy of the current nondimensionalized ensemble 
                                                            % (how to generalize that can be used for any user-defined QoI)
Acc_all_Old(1, 1) = Acc_cur;                                % The transient performance of the current ensemble 

if t_f(1) == 0
    MCSAM(1).U = U;
    MCSAM(1).sam = isample;
    w = mvnpdf(isample, mu0, Covar0);
    MCSAM(1).w = w;
    MCSAM(1).sam_ND = isample_ND;
    MCSAM(1).Acc = Acc_cur;
    
    tctstart = 2;
    
else
    tctstart = 1;
end


%% Particle-addition scheme is applied until its performance reaches the desired level at the initial time 
% (how to generalize it for different QoI?)
[MCSAM(1).sam, MCSAM(1).sam_ND, MCSAM(1).w, MCSAM(1).U, MCSAM(1).Acc] ...
= Particle_Addition(MCSAM(1).sam, MCSAM(1).sam_ND, MCSAM(1).w, MCSAM(1).U, MCSAM(1).Acc, t_f(1));

Num_current_ensemble(1, 1) = length(MCSAM(1).w);        % # of the current ensemble
Acc_all_New(1, 1) = MCSAM(1).Acc;                       % The transient performance of MC estimation on QoI 


%% Plot the variation of the transient performance of the QoI with time 
% (Make it as a module?)
figure(1)
plot(t_f, repmat(Acc_UB, tLEN, 1),'r-', 'linewidth', 2);
hold on;
plot(t_f, repmat(Acc_LB, tLEN, 1),'r-', 'linewidth', 2);
hold on;
plot(t_f(1), MCSAM(1).Acc, 'kd', 'MarkerSize', 8, 'linewidth', 2);
hold on;
xlabel('Time(s)'); ylabel('Error');


%% Adaptive FMC: forward propagates into the targeted time instances while satisfying the prescribed accuracy
for tctr = tctstart : tLEN
    fprintf('Currently running %d/%d time instance, %d s ahead \n', tctr, tLEN, t_f(tctr));
    %%%
    % Forward Propagation (make it as a module, and how to generalize it when noise term is involved?)
    %%%
    for ctr = 1 : size(MCSAM(tctr - 1).sam, 1)
        ic = [MCSAM(tctr - 1).sam(ctr,:) MCSAM(tctr - 1).w(ctr,1)];         % Initial condition for forward propagation
        [te, x] = ode45(@VDPO_2D_SLE, [t_f(tctr - 1) t_f(tctr)], ic);       % Forward propagation with the associated SLE (integration accuracy?)
        MCSAM(tctr).sam(ctr, :) = x(end, 1 : N_d);                          % Propagated ensemble
        MCSAM(tctr).sam_ND(ctr, :) = MCSAM(tctr).sam(ctr, :)./Non_dim;      % Non-dimensionlization
        MCSAM(tctr).w(ctr, 1) = x(end, N_d + 1);                            % Current state-pdf value for each particle
    end
    
    %%% 
    % Accuracy Estimation: Boostrap 
    %%%  
    Acc_cur = BootstrapMean(MCSAM(tctr).sam_ND, Num_resam_bootstrap);
    Acc_all_Old(tctr, 1) = Acc_cur;
    
    % Plot
    figure(1)
    plot(t_f(tctr), Acc_cur,'bo','MarkerSize', 8, 'linewidth', 2);
    hold on;
    
    %%%   
    % Adaptive scheme
    %%%  
    % Particle_Addition when the performance of the current ensemble is greater than the prescribed upper error bound
    % (make it as a module)
    if Acc_cur > Acc_UB
        [MCSAM(tctr).sam, MCSAM(tctr).sam_ND, MCSAM(tctr).w, MCSAM(tctr).U, MCSAM(tctr).Acc] ...
         = Particle_Addition(MCSAM(tctr).sam, MCSAM(tctr).sam_ND, MCSAM(tctr).w, MCSAM(tctr - 1).U, Acc_cur, t_f(tctr));
    
    % Particle_Removal when the performance of the current ensemble is smaller than the prescribed lower error bound
    % (make it as a module, and how to let the user have the flexibility to select this or disenable it when noise is involved?)
    elseif Acc_cur < Acc_LB
        [MCSAM(tctr).sam, MCSAM(tctr).sam_ND, MCSAM(tctr).w, MCSAM(tctr).U, MCSAM(tctr).Acc]...
         = Particle_Removal(MCSAM(tctr).sam, MCSAM(tctr).sam_ND, MCSAM(tctr).w, MCSAM(tctr - 1).U, Acc_cur, t_f(tctr));
    
    % Within the prescribed accuracy bounds
    else
        MCSAM(tctr).Acc = Acc_cur;
        MCSAM(tctr).U = MCSAM(tctr - 1).U;
    end
    
    Num_current_ensemble(tctr, 1) = length(MCSAM(tctr).w);
    Acc_all_New(tctr, 1) = MCSAM(tctr).Acc;
    
    % Plot
    figure(1)
    plot(t_f(tctr), MCSAM(tctr).Acc,'kd','MarkerSize', 8, 'linewidth', 2);
    hold on;
end

% %% Generate accuracy history in terms of min and max number of samples
% Num_min = min(Num_P(:));
% Num_max = max(Num_P(:));
% % MCSAM(1).pseudo_min = mvnrnd(mu0, sigma0, Num_min);
% MCSAM(1).pseudo_min = rand([Num_min, N]);
% MCSAM(1).pseudo_minN = MCSAM(1).pseudo_min./repmat(NonDim, Num_min, 1);
% % bootstat_pseudo_min = bootstrp(nboot, @mean, MCSAM(1).pseudo_minN);
% % MeanSD_pseudo_min = std(bootstat_pseudo_min)/sqrt(Num_min);
% Acc_pseudo_min(1) = BoostrapMean(MCSAM(1).pseudo_minN, nboot);
% 
% % MCSAM(1).pseudo_max = mvnrnd(mu0, sigma0, Num_max);
% MCSAM(1).pseudo_max = rand([Num_max, N]);
% MCSAM(1).pseudo_maxN = MCSAM(1).pseudo_max./repmat(NonDim, Num_max , 1);
% % bootstat_pseudo_max = bootstrp(nboot, @mean, MCSAM(1).pseudo_maxN);
% % MeanSD_pseudo_max = std(bootstat_pseudo_max)/sqrt(Num_max);
% % Acc_pseudo_max(1) = sqrt(sum(MeanSD_pseudo_max.^2)/N);
% Acc_pseudo_max(1) = BoostrapMean(MCSAM(1).pseudo_maxN, nboot);
% 
% for tctr = tctstart : tLEN
%         for ctr = 1 : Num_min
%             [te, x] = ode45(@VDPO_2D, [0 t(tctr)], MCSAM(1).pseudo_min(ctr, :));
%             MCSAM(tctr).pseudo_min(ctr,:) = x(end, 1 : N);  
%         end
%         MCSAM(tctr).pseudo_minN = MCSAM(tctr).pseudo_min./repmat(NonDim, Num_min, 1);
% %         bootstat_pseudo_min = bootstrp(nboot, @mean, MCSAM(tctr).pseudo_minN);
% %         MeanSD_pseudo_min = std(bootstat_pseudo_min)/sqrt(Num_min);
% %         Acc_pseudo_min(tctr) = sqrt(sum(MeanSD_pseudo_min.^2)/N);
%         Acc_pseudo_min(tctr) = BoostrapMean(MCSAM(tctr).pseudo_minN, nboot);
%         
%         for ctr = 1 : Num_max
%             [te, x] = ode45(@VDPO_2D, [0 t(tctr)], MCSAM(1).pseudo_max(ctr, :));
%             MCSAM(tctr).pseudo_max(ctr,:) = x(end, 1 : N);  
%         end
%         MCSAM(tctr).pseudo_maxN = MCSAM(tctr).pseudo_max./repmat(NonDim, Num_max , 1);
% %         bootstat_pseudo_max = bootstrp(nboot, @mean, MCSAM(tctr).pseudo_maxN);
% %         MeanSD_pseudo_max = std(bootstat_pseudo_max)/sqrt(Num_max);
% %         Acc_pseudo_max(tctr) = sqrt(sum(MeanSD_pseudo_max.^2)/N);
%         Acc_pseudo_max(tctr) = BoostrapMean(MCSAM(tctr).pseudo_maxN, nboot);
%         
%     
% end
% 
% figure(1)
% plot(t, Acc_pseudo_min,'g^--', 'MarkerSize', 8, 'linewidth', 2);
% hold on;
% plot(t, Acc_pseudo_max,'mv--', 'MarkerSize', 8, 'linewidth', 2);
% set(gca,'FontSize',18, 'fontweight','bold');