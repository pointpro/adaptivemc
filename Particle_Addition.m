%{
Particle-addition scheme is applied when the transient performance of the
current estimation exceeds the prescribed upper error bound. Then, optimally
selected particles are sequentially introduced in batches to the initial 
ensemble, and then forward propagated to join the current ensemble, until
it reaches the prescribed level.
%}

function [Sam, Sam_ND, w, U, Acc] = Particle_Addition(sam_Old, Sam_ND_Old, w_Old, U_Old, Acc_Old, Current_time)
global Acc_UB P_Acc;
global N_d;
global Num_resam_bootstrap;
global Accuracy_check_frequency;
global Non_dim;
global P_removal; 
global Num_removal;
global mu0 Covar0;

Sam = sam_Old;
Sam_ND = Sam_ND_Old;
w = w_Old;
U = U_Old;
Acc = Acc_Old;

%% At the initial time, i.e., Current_time = 0
if Current_time == 0
   
       while Acc > P_Acc
           % Check the transient performance every Accuracy_check_frequency times
           for i = 1 : Accuracy_check_frequency
               % Generalize it for both "low" and "high" cases depending on the number of states?
               New_sam_U = ParticleGeneration_SamplingEfficiency_HighD(U);
%                New_sam_U = ParticleGeneration_SamplingEfficiency(U);            % Generate the next "optimal" particle at t_0 
                                                                                % according to the existing initial uniform ensemble                                                                                % in order to optimize its sampling efficiency                                                                                                 
                                                                              
               % Inverse transform
               New_sam = icdf('Normal', New_sam_U, mu0, sqrt(diag(Covar0))');
               New_w = mvnpdf(New_sam, mu0, Covar0);
               U = [U; New_sam_U];
               Sam = [Sam; New_sam];
               Sam_ND = [Sam_ND; New_sam./Non_dim];
               w = [w; New_w];
           end

          % Accuracy Estimation: Boostrap 
          Acc = BootstrapMean(Sam_ND, Num_resam_bootstrap);
       end
else
%% After forward propagation, i.e., Current_time > 0    
    while Acc > Acc_UB
        % Check if there is any previously "halted" particles (how to make it better?)
        if Num_removal ~= 0
            % Adding the most recently "halted" particles
            for k = 1 : size(P_removal(Num_removal).Sam, 1)                 % # of "halted" samples                                                                   
                ic = [P_removal(Num_removal).Sam(k, :) P_removal(Num_removal).w(k)];
                [te, x] = ode45(@VDPO_2D_SLE, [P_removal(Num_removal).T Current_time], ic);
                Sam = [Sam; x(end, 1 : N_d)];
                Sam_ND = [Sam_ND; x(end, 1 : N_d)./Non_dim];
                w = [w; x(end, N_d + 1)];
                U = [U; P_removal(Num_removal).U(k, :)];
                % Check if the current performance needs to be estimated
                if mod(k, Accuracy_check_frequency) == 0
                  Acc = BootstrapMean(Sam_ND, Num_resam_bootstrap); 
                  % The prescribed accuracy satisfied
                  if Acc <= Acc_UB
                    % Reset: collect the un-used "halted" particles
                    P_removal(Num_removal).w = P_removal(Num_removal).w(k + 1 : end);
                    P_removal(Num_removal).Sam = P_removal(Num_removal).Sam(k + 1 : end, :);
                    P_removal(Num_removal).U  = P_removal(Num_removal).U(k + 1 : end, :);
                    return;                                                 % jump out of the function
                  end  
                end  
            end
            % Reset: all the "halted" particles at time Num_removal are used
            P_removal(Num_removal) = [];                                     % delete all the "halted" particles at time Num_removal
            Num_removal = Num_removal - 1;                                   % Go to another time instant where the particle-removal has been applied  
            Acc = BootstrapMean(Sam_ND, Num_resam_bootstrap);  
            
        % No previous "halted" particles available, then generate new samples
        else
            for i = 1 : Accuracy_check_frequency
                New_sam_U = ParticleGeneration_SamplingEfficiency_HighD(U);
%                 New_sam_U = ParticleGeneration_SamplingEfficiency(U);
                U = [U; New_sam_U];
                % Inverse transform
                New_sam = icdf('Normal', New_sam_U, mu0, sqrt(diag(Covar0))');
                New_w = mvnpdf(New_sam, mu0, Covar0);
                % Forward Propagation
                ic = [New_sam New_w];
                [te, x] = ode45(@VDPO_2D_SLE, [0 Current_time], ic);
                Sam = [Sam; x(end, 1 : N_d)];
                Sam_ND = [Sam_ND; x(end, 1 : N_d)./Non_dim];
                w = [w; x(end, N_d + 1)];
            end
            Acc = BootstrapMean(Sam_ND, Num_resam_bootstrap);     
        end    
    end
    
   
end