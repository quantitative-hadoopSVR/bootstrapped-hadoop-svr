## -*- texinfo -*- 
## @deftypefn {Function File} {[@var{responseTime}, @var{inst}] =} parameter_selection (@var{responseTime}, @var{inst})
##
## Perform cross validation to find best parameters using label @var{responseTime} and feature @var{nCores}
## Best parameters are in @var{bestcv}, @var{bestc}, @var{bestg}
##
## @end deftypefn

function [bestcv,bestc,bestg] = parameter_selection (responseTime, nCores, wtrain)
bestcv = 0;
for log2c = -1:3,
  for log2g = -4:1,
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(wtrain, responseTime, nCores, cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    %%fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end