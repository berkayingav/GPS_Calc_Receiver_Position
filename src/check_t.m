function tt = check_t(t);

 half_week = 302400;
 tt = t;

 if t >  half_week, tt = t-2*half_week; end
 if t < -half_week, tt = t+2*half_week; end

end


