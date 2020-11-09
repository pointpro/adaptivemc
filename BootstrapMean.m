%{
Bootstrap Performance Estimation: approximate the transient performance of 
the current ensemble estimation on the QoI, defined by the standard deviation
of the MC estimation error in terms of the QoI.
%}

%% The propagated mean is used as the QoI ()
function Acc = BootstrapMean(sam, Num_resam_bootstrap)
global N_d;

% Sample mean
Mean_sam = mean(sam);

% Means obtained from the bootstrap resampling sets (how to generalize it to arbitrary QoI?)
[bootstat, ~] = bootstrp(Num_resam_bootstrap, @mean, sam);

% The Variance of the bootstrap distribution used to approximate to the variance 
% of MC estimation error distribution in terms of the mean
Var_estimation_error = sum((bsxfun(@minus, bootstat, Mean_sam)).^2, 1)/(Num_resam_bootstrap - 1);

% The transient performance: the RMS vaule over all states for the SD of the 
% MC estimation error on the mean
Acc = sqrt(sum(Var_estimation_error)/N_d);

end