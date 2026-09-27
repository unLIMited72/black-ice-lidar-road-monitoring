function [sigma_m,A] = level2_sigma(sigma0_m,theta_deg,D_m,p,q,D_ref_m)
%LEVEL2_SIGMA Assumed amplification with no improvement below D_ref.
validateattributes(theta_deg,{'numeric'},{'real','finite','>=',0,'<=',70});
validateattributes(p,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(q,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(D_ref_m,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(sigma0_m,{'numeric'},{'scalar','real','finite','nonnegative'});
if sigma0_m==0
    % Dimensionless amplification remains defined in the zero-noise limit.
    A=blackice.uncertainty_sigma(1,theta_deg,D_m, ...
      @(a) cosd(a).^(-p), @(d) max(1,d./D_ref_m).^q);
    sigma_m=zeros(size(A));
    return
end
sigma_m=blackice.uncertainty_sigma(sigma0_m,theta_deg,D_m, ...
 @(a) cosd(a).^(-p), @(d) max(1,d./D_ref_m).^q);
A=sigma_m./sigma0_m;
end
