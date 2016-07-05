function [ve] = computeVE (pred, sigma, mu, operational_vector, conf_to_predict)

     if ( conf_to_predict == 10 )
       ve = 100 * abs(pred(10) * sigma + mu - operational_vector(10))/operational_vector(10)

     endif

endfunction