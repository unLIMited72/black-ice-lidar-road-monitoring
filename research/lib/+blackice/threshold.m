function tau_m = threshold(pfa,sigma_score_m)
%THRESHOLD Known dry null distribution; independent of thickness and labels.
arguments
    pfa double {mustBeGreaterThan(pfa,0),mustBeLessThan(pfa,1)}
    sigma_score_m double {mustBePositive,mustBeFinite}
end
tau_m=sqrt(2)*sigma_score_m.*erfcinv(2*pfa);
end
