  function [updated, new_weight]  = updateKB (current_kb, sample_to_add, old_weight, weight_value)
  
  %%Assign weights to new samples. For now we consider that new samples are all
  %%weighted with the same value 2. 
  
  %%Change here if you want to set old weights to one and use new weights only
  %%for one iteration.
  %old_weight=ones(size(current_kb),1);
  
  new_weight=repmat(weight_value,size(sample_to_add,1),1);
  new_weight=[old_weight ; new_weight];
  updated = [current_kb ; sample_to_add];
 
  %%Remove sample from analytical that is nearest to operational
  
  endfunction