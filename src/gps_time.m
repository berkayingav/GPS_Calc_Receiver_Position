function [week,sec_of_week] = gps_time(julday)

    a = floor(julday + 0.5);
    b = a+1537;
    c = floor((b-122.1)/365.25);
    e = floor(365.25*c);
    f = floor((b-e)/30.6001);
    d = b-e-floor(30.6001*f)+rem(julday+0.5,1);
    day_of_week = rem(floor(julday+ 0.5),7);
    week = floor((julday-2444244.5)/7);
    sec_of_week = (rem(d,1)+day_of_week+1)*86400;

    if day_of_week == 6
        sec_of_week = sec_of_week - 7*24*3600;
    end
    
end