function jd = julday(y,m,d,h,min,sec)

%gps starting time
      if m <= 2, y = y-1; m = m+12; end
      if min>= 60
          h = h+1;
      end
      jd = floor(365.25 * (y + 4716)) + floor(30.6001 * ...
          (m + 1)) + d + h / 24 + min / 1440 + sec / 86400 - 1537.5;

%      mjd = jd-2400000.5;
end