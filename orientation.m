function d = orientation(p, q, r)
    val = (q(2) - p(2)) * (r(1) - q(1)) - ...
          (q(1) - p(1)) * (r(2) - q(2)); 
    if (val == 0)
        d = 0;
    else
        d = 2 - (val > 0);
    end
end