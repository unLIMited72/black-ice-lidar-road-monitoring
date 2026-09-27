function sigma_m = uncertainty_sigma(sigma0_m,theta_deg,D_m,angle_factor,range_factor)
%UNCERTAINTY_SIGMA Level 2 INTERFACE ONLY: no calibrated functions supplied.
% Caller must document assumed, dimensionless positive functions explicitly.
% No Level 2 result is produced by checkpoint 01.
arguments
    sigma0_m (1,1) double {mustBePositive,mustBeFinite}
    theta_deg double {mustBeReal,mustBeFinite}
    D_m double {mustBePositive,mustBeFinite}
    angle_factor (1,1) function_handle
    range_factor (1,1) function_handle
end
fa=angle_factor(theta_deg); fr=range_factor(D_m);
validateattributes(fa,{'double'},{'real','finite','positive'});
validateattributes(fr,{'double'},{'real','finite','positive'});
sigma_m=sigma0_m.*fa.*fr;
end
