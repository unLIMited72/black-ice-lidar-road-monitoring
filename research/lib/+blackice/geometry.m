function g = geometry(H_m,t_m,theta_deg)
%GEOMETRY One-way ranges to parallel planes; angle from road normal.
% Scalar expansion is supported. Invalid physical/nonfinite inputs yield
% NaN ranges and geometry_valid=false, not a plausible valid range.
arguments
    H_m double {mustBeReal}
    t_m double {mustBeReal}
    theta_deg double {mustBeReal}
end
valid = isfinite(H_m) & isfinite(t_m) & isfinite(theta_deg) & ...
    H_m>t_m & t_m>=0 & theta_deg>=0 & theta_deg<90;
c = cosd(theta_deg);
DA = H_m./c;
DI = (H_m-t_m)./c;
delta = t_m./c;
DA = DA + zeros(size(valid));
DI = DI + zeros(size(valid));
delta = delta + zeros(size(valid));
DA(~valid)=NaN; DI(~valid)=NaN; delta(~valid)=NaN;
g=struct('D_A_m',DA,'D_I_m',DI,'delta_m',delta, ...
    'geometry_valid',valid);
end
