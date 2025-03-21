dataNav = readtable('nav_data_.csv');
dataObs = readtable('obs_data_.csv');

index = ~isnan(dataObs.L1) & ~isnan(dataObs.C1);
index1 = ~isnan(dataNav.SVclockBias) ;

filteredNav = dataNav(index1,:);
filteredObs = dataObs(index,:);

[~, idx_first] = unique(filteredNav.sv, 'stable');
unique_navData = filteredNav(idx_first, :);

x0 = [0; 0; 0; 0];  % X, Y, Z, clock bias (m)


timeStart = filteredObs.time(1);
for t = 0   
    targetTime = datetime(timeStart, 'Format', 'dd-MMM-uuuu HH:mm:ss') + seconds(t);
    [satID1, ~] = find(filteredObs.time == targetTime);

    baseobshour = filteredObs(satID1,:);

    y = targetTime.Year;
    m = targetTime.Month;
    d = targetTime.Day;
    h = targetTime.Hour;
    mi = targetTime.Minute;
    sec = targetTime.Second;
    juldayObs = julday(2025,03,19,00,00,00);
    [sat_week,sat_sec] = gps_time(juldayObs);
    
    juldayNav = julday(y,m,d,h,mi,(sec + t));
    [base_week,base_sec] = gps_time(juldayNav);

    navIDs = unique_navData.sv;
    obsIDs = baseobshour.sv;

    [commonIDs, idxNav, idxObs] = intersect(navIDs, obsIDs);

    obs = baseobshour.C1; 
    nav = unique_navData(idxNav,:);
    c = 299792458;

    for i=1:numel(obs)

        tx_RAW = base_sec - obs(i)/c;
        toe = unique_navData.Toe(i);
        dt = check_t(tx_RAW - sat_sec);
        tcorr = (nav.SVclockDriftRate(i)^2*dt ...
            + nav.SVclockDrift(i)*dt ...
            + nav.SVclockBias(i));

        eph = nav{i,3:end}; 
        
        satPos(:,i)  = satellitePosition(tx_GPS,i,nav);
        prc(i,1) = obs(i) + tcorr*c;
    end

    %lse equation 
    delta_x = ones(4,1);
    numSv = numel(obs);
    while norm(delta_x(1:3)) >= 1e-4
        x0 = x0 + delta_x;
        delta_t_u = x0(4)/-c;
        pr_hat = sqrt((satPos(1,:)-x0(1)).^2 + (satPos(2,:)-x0(2)).^2 + (satPos(3,:)-x0(3)).^(2)) + c * delta_t_u;
        delta_pr = pr_hat' - prc; %prc: corrected pseudorange by the calculated satellite clock bias
        a_x = (satPos(1,:)-x0(1))./sqrt((satPos(1,:)-x0(1)).^2 + (satPos(2,:)-x0(2)).^2 + (satPos(3,:)-x0(3)).^(2));
        a_y = (satPos(2,:)-x0(2))./sqrt((satPos(1,:)-x0(1)).^2 + (satPos(2,:)-x0(2)).^2 + (satPos(3,:)-x0(3)).^(2));
        a_z = (satPos(3,:)-x0(3))./sqrt((satPos(1,:)-x0(1)).^2 + (satPos(2,:)-x0(2)).^2 + (satPos(3,:)-x0(3)).^(2));
        H = [a_x(:) a_y(:) a_z(:) ones(numSv,1)];
        delta_x = inv(H'*H)*H'*delta_pr;
    end

    x0(4) = x0(4)/-c;
    ecefx = [x0(1),x0(2),x0(3)];
    posLLH = ecef2lla(ecefx);
end
