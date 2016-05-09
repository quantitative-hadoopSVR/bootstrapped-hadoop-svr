function [oper_data_chunks]  = collectSamples (oper_data, nSlots)

%% here we assume that each operational file has the same 
%% number or rows ( which basically means that each 
%% real experiment is performed sampling the same
%% number of observations.
rand ("seed", 17);
permutation = randperm (size (oper_data, 1));
[oper_data_scaled, mu, sigma] = zscore (oper_data);
oper_data_shuffled = oper_data_scaled(permutation, :);

splittable = oper_data_shuffled(1 : end - mod(size(oper_data_shuffled), nSlots), :);
remaining_obs = oper_data_shuffled(end - mod(size(oper_data_shuffled), nSlots) + 1 : end, :);
oper_data_chunks = mat2cell (splittable, size(splittable,1) ./ nSlots .* ones(1,nSlots), size(splittable,2));
temp = cell2mat (oper_data_chunks (end));
temp = [temp ; remaining_obs];
oper_data_chunks(end) = temp;

endfunction

