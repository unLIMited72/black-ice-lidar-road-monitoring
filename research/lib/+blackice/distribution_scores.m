function s = distribution_scores(DA,DI,sigma,mode,N,seed,stream,family)
%DISTRIBUTION_SCORES Gaussian delegates exactly to immutable legacy generator.
if family=="Gaussian"
 s=blackice.draw_scores(DA,DI,sigma,mode,N,seed,stream); return
end
assert(ismember(mode,["R0" "R1"]),'blackice:ReferenceMode','Unknown reference.');
refSigma=sigma*double(mode=="R1"); b=4*(stream-1);
s.dry_measured_m=DA+blackice.sample_noise_distribution(family,sigma,N,seed,b+1);
s.ice_measured_m=DI+blackice.sample_noise_distribution(family,sigma,N,seed,b+2);
s.dry_reference_m=DA+blackice.sample_noise_distribution(family,refSigma,N,seed,b+3);
s.ice_reference_m=DA+blackice.sample_noise_distribution(family,refSigma,N,seed,b+4);
s.dry_score_m=s.dry_reference_m-s.dry_measured_m;
s.ice_score_m=s.ice_reference_m-s.ice_measured_m;
s.sigma_score_m=hypot(sigma,refSigma); s.sigma_ref_m=refSigma;
s.invalid_count=sum(s.dry_measured_m<=0 | s.ice_measured_m<=0 | s.dry_reference_m<=0 | s.ice_reference_m<=0);
end
