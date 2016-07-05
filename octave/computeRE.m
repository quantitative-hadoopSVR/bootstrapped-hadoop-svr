function [re] = computeRE (pred, sigma, mu, operational_vector, conf_to_predict)

     if ( conf_to_predict == 10 )
       re = 100 * ( abs(pred(1) * sigma + mu - operational_vector(1))/operational_vector(1) +
                    abs(pred(2) * sigma + mu - operational_vector(2))/operational_vector(2) +
                    abs(pred(3) * sigma + mu - operational_vector(3))/operational_vector(3) +
                    abs(pred(4) * sigma + mu - operational_vector(4))/operational_vector(4) +
                    abs(pred(5) * sigma + mu - operational_vector(5))/operational_vector(5) +
                    abs(pred(6) * sigma + mu - operational_vector(6))/operational_vector(6) +
                    abs(pred(7) * sigma + mu - operational_vector(7))/operational_vector(7) +
                    abs(pred(8) * sigma + mu - operational_vector(8))/operational_vector(8) +
                    abs(pred(9) * sigma + mu - operational_vector(9))/operational_vector(9) ) / 9;
     endif

endfunction