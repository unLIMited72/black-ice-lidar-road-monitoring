function [Q,angle_penalty] = return_proxy(theta_deg,D_m,rho_rel,n,kappa,D_ref_m)
%RETURN_PROXY Dimensionless black-ice-motivated sensitivity, not reflectance/power.
validateattributes(theta_deg,{'numeric'},{'real','finite','>=',0,'<=',70});
validateattributes(D_m,{'numeric'},{'real','finite','positive'});
validateattributes(rho_rel,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(n,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(kappa,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(D_ref_m,{'numeric'},{'scalar','real','finite','positive'});
angle_penalty=exp(-kappa*tand(theta_deg).^2);
Q=rho_rel*cosd(theta_deg).^n.*angle_penalty./(D_m/D_ref_m).^2;
end
