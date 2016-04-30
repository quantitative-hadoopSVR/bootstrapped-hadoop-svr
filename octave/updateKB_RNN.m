  % Update function implemented with the KNN algorithm considering the euclidian distance.

  function [updated, new_weight]  = updateKB_RNN (current_kb, sample_to_add, old_weight)
  
  %%Assign weights to new samples. For now we consider that new samples are all
  %%weighted with the same value 2. 
  
  weight_value=4;

  for ii = 1 : length(sample_to_add)
    e_new = sample_to_add(ii);
    current_distance = 0;
    for jj = 1 : length(current_kb)
      e_old = current_kb(jj);
      if current_distance == 0;
        current_distance = sqrt(sum((e_new - e_old) .^ 2));
        idx = jj;
      else
        new_distance  = sqrt(sum((e_new - e_old) .^ 2));
        if( new_distance < current_distance)
          current_distance = new_distance;
          idx = jj;
        endif
      endif
    endfor
    current_kb(idx) = e_new;
    old_weight(idx) = weight_value;
  endfor

  updated = current_kb;
  new_weight = old_weight;
  
  endfunction