function [satPosition,E] = satellitePosition(t,epoch,nav)

GM = 3.986005e14;             % earth's universal gravitational
% parameter m^3/s^2
Omegae_dot = 7.2921151467e-5; % earth rotation rate, rad/s

svprn = nav.sv(epoch);
af0 = nav.SVclockBias(epoch);
af1 = nav.SVclockDrift(epoch);
af2 = nav.SVclockDriftRate(epoch);
M0 = nav.M0(epoch);
roota = nav.sqrtA(epoch);
deltan = nav.DeltaN(epoch);
ecc = nav.Eccentricity(epoch);
omega = nav.omega(epoch);
cuc = nav.Cuc(epoch);
cus = nav.Cus(epoch);
crc = nav.Crc(epoch);
crs = nav.Crs(epoch);
i0 = nav.Io(epoch);
idot = nav.IDOT(epoch);
cic =  nav.Cic(epoch);
cis =  nav.Cis(epoch);
omega0 =  nav.Omega0(epoch);
omegadot = nav.OmegaDot(epoch);
toe =  nav.Toe(epoch);

A = roota*roota;
tk = check_t(t-toe);
n0 = sqrt(GM/A^3);
n = n0+deltan;
M = M0+n*tk;
M = rem(M+2*pi,2*pi);
E = M;

for i = 1:10
   E_old = E;
   E = M+ecc*sin(E);
   dE = rem(E-E_old,2*pi);
   if abs(dE) < 1.e-12
      break;
   end
end

E = rem(E+2*pi,2*pi);

v = real(atan2(real(sqrt(1-ecc^2)*sin(E)), real(cos(E)-ecc)));
phi = v+omega;
phi = rem(phi,2*pi);
u = phi              + cuc*cos(2*phi)+cus*sin(2*phi);
r = A*(1-ecc*cos(E)) + crc*cos(2*phi)+crs*sin(2*phi);
i = i0+idot*tk       + cic*cos(2*phi)+cis*sin(2*phi);
Omega = omega0+(omegadot-Omegae_dot)*tk-Omegae_dot*toe;
Omega = rem(Omega+2*pi,2*pi);
x1 = cos(u)*r;
y1 = sin(u)*r;

satPosition = zeros(3,1);  % 4x1 hücre dizisi

satPosition(1,1) = x1*cos(Omega)-y1*cos(i)*sin(Omega);
satPosition(2,1) = x1*sin(Omega)+y1*cos(i)*cos(Omega);
satPosition(3,1) = y1*sin(i);

end