function [chunks_to_return]  = collectSamples (directory, nSlots)

if (! ischar (directory))
  error ("read_from_directory: DIRECTORY should be a string");
endif

files = glob ([directory, "/*.csv"]);

chunks_to_return = {};

%% here we assume that each operational file has the same 
%% number or rows ( which basically means that each 
%% real experiment is performed sampling the same
%% number of observations.
for ii = 1:numel (files)
  file = files{ii};
  last_sample = read_data (file);
  [clean_sample, indices] = clear_outliers (last_sample);
  splittable = clean_sample(1 : end - mod(size(clean_sample), nSlots), :);
  remaining_obs = clean_sample(end - mod(size(clean_sample), nSlots) + 1 : end, :);
  current_chunks = mat2cell (splittable, size(splittable,1) ./ nSlots .* ones(1,nSlots), size(splittable,2));
  temp = cell2mat (current_chunks (end));
  temp = [temp ; remaining_obs];
  current_chunks(end) = temp;

  if(isempty(chunks_to_return))
    chunks_to_return = current_chunks;
  else
    for k = 1 : length(chunks_to_return)
      current_to_return = cell2mat(chunks_to_return (k));
      current = cell2mat(current_chunks (k));
      temp_matrix = [ current_to_return(: , 1)  current(: , 1) ];
      chunks_to_return {k} = [mean(temp_matrix .') .' , current_to_return(: , 2)];
    endfor
  end

endfor

endfunction

