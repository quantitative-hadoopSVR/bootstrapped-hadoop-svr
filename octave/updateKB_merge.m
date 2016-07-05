  function [updated]  = updateKB_merge (current_kb, sample_to_add)
  %%Assign weights to new samples. For now we consider that new samples are all
  %%weighted with the same value 2. 
  
  %%Change here if you want to set old weights to one and use new weights only
  %%for one iteration.
  %old_weight=ones(size(current_kb),1);
  
  updated = [current_kb ; sample_to_add];
 
  %%Remove sample from analytical that is nearest to operational
  
  endfunction