function p = surface_observability(Q,Q_scale,link)
%SURFACE_OBSERVABILITY Assumed probability map; no calibrated receiver threshold.
validateattributes(Q,{'numeric'},{'real','finite','nonnegative'});
validateattributes(Q_scale,{'numeric'},{'scalar','real','finite','positive'});
switch string(link)
 case "rational", p=Q./(Q+Q_scale);
 case "exponential", p=-expm1(-Q/Q_scale);
 otherwise, error('blackice:ReturnLink','Unknown observability link.');
end
end
