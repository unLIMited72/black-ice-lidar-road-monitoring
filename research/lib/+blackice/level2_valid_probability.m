function pvalid = level2_valid_probability(theta_deg,D_m,v,D_ref_m)
%LEVEL2_VALID_PROBABILITY Class-independent hypothetical return availability.
validateattributes(theta_deg,{'numeric'},{'real','finite','>=',0,'<=',70});
validateattributes(D_m,{'numeric'},{'real','finite','positive'});
switch string(v.mode)
    case "V0"
        pvalid=ones(size(theta_deg+D_m));
    case "V1"
        pvalid=double(theta_deg<=v.theta_max_deg & D_m<=v.D_max_m);
    case "V2"
        exposure=(theta_deg/70).^2+max(0,D_m/D_ref_m-1).^2;
        pvalid=exp(-v.lambda*exposure);
    otherwise
        error('blackice:validityMode','Unknown validity mode.');
end
end
