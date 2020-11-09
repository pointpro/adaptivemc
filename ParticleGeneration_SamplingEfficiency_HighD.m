function P_new = ParticleGeneration_SamplingEfficiency_HighD(U)
global alpha;
global N_d 
global Num_candidate;
global Num_AI_limit;                                            % Define the maximum number of admissible intervals
                                                                % allowed along each dimension

NSAM = size(U, 1);                                              % # of current samples
Min_projected_d  = alpha/(NSAM + 1);                            % Minimum allowed projected distance along each dimension
[U_sort, ~] = sort(U, 1);                                       % Sort the initial uniform ensemble along each dimension
Projected_coordinate = [zeros(1, N_d); U_sort; ones(1 ,N_d)]; 
Projected_d = diff(Projected_coordinate);                       % The projected distance between particles along each dimension

%% Generate candidates satisfied the non-collapsing criterion
for ntr = 1 : N_d
    d = Projected_d(:, ntr);  
    Admissible_interval = find(d > 2*Min_projected_d);          % Identify the admissable intervals along each dimension
    
    % Select the first Admissible_interval_limit number of largest admissible intervals
    if length(Admissible_interval) > Num_AI_limit   
        [~, inx] = sort(d, 'descend');
        Admissible_interval =  inx(1 : Num_AI_limit);
%     else
%         I_l = Admissible_interval;
    end
    
    % # of candidates generated inside each admissible interval (area dependent)
    num = ceil(Num_candidate*(d(Admissible_interval)./sum(d(Admissible_interval))));
   
    % Define each identified admissible interval, i.e., Unifrom: [a, a + b]
    a = repelem(Projected_coordinate(Admissible_interval, ntr) + Min_projected_d, num);  
    b = repelem(d(Admissible_interval) - 2*Min_projected_d, num);
   
    % Handle the edges
    if Admissible_interval(1) == 1                         % [0, Admissible_interval(1) - Min_projected_d]
        a(1 : num(1)) = 0;
        b(1 : num(1)) = b(1 : num(1)) + Min_projected_d;
    elseif Admissible_interval(end) == (NSAM + 1)          % [Admissible_interval(end - 1) - Min_projected_d, 1]
        b(end - num(end) + 1 : end) = b(end - num(end) + 1 : end) + Min_projected_d;
    end
    sam_all = a + b.*rand(sum(num), 1);
    order = randperm(length(sam_all));                     % Make it more efficient?
    cand(:, ntr) = sam_all(order(1 : Num_candidate));
end

%% Rank the generated candidateds by the centered L2-Discrepancy: 
for ctr = 1 : Num_candidate
       P_r = [U; cand(ctr, :)];     %The current design including the candidate point
       C_r = repmat(cand(ctr, :), NSAM + 1, 1);
       % First Part
       P1_r = 1 + abs(cand(ctr, :) - 0.5)/2 - (cand(ctr, :) - 0.5).^2/2;
       D1_r = (2/(NSAM + 1))*prod(P1_r, 2);
       % Second Part
       P2_r = 1 + 0.5*abs(P_r - 0.5) + 0.5*abs(C_r - 0.5) - 0.5*abs(P_r - C_r);
       P2_r = prod(P2_r, 2);
       P2_r(1 : end - 1) = 2*P2_r(1 : end - 1);
       D2_r = (1/(NSAM + 1)^2)*sum(P2_r);
       Discrp(ctr, 1) = (13/12)^N_d - D1_r + D2_r;
  
end

%% Find the "optimal" next particle with the minimum discrepancy
if isempty(Discrp) == 1
    fprintf('Did not find the next optimal simulation point.\n');
else
    [~,I] = min(Discrp);              
     P_new = cand(I, :);     
end

end
