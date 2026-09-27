function samples = draw_scores(DA_m,DI_m,sigma_m,reference_mode,N,master_seed,stream_id)
%DRAW_SCORES Generate ranges, then subtract reference. New independent
% reference noise is drawn for EVERY trial and class in R1. A single fixed
% noisy calibration shared by all trials is a different, unimplemented model.
arguments
    DA_m (1,1) double {mustBePositive,mustBeFinite}
    DI_m (1,1) double {mustBePositive,mustBeFinite}
    sigma_m (1,1) double {mustBeNonnegative,mustBeFinite}
    reference_mode (1,1) string {mustBeMember(reference_mode,["R0","R1"])}
    N (1,1) double {mustBeInteger,mustBePositive}
    master_seed (1,1) double {mustBeInteger,mustBeNonnegative}
    stream_id (1,1) double {mustBeInteger,mustBePositive}
end
% Four separate substreams preserve N-prefixes for convergence analysis.
r=RandStream('mrg32k3a','Seed',master_seed);
r.Substream=4*(stream_id-1)+1; eD=sigma_m*randn(r,N,1);
r.Substream=4*(stream_id-1)+2; eI=sigma_m*randn(r,N,1);
refSigma=sigma_m*double(reference_mode=="R1");
r.Substream=4*(stream_id-1)+3; eRD=refSigma*randn(r,N,1);
r.Substream=4*(stream_id-1)+4; eRI=refSigma*randn(r,N,1);
samples.dry_measured_m=DA_m+eD;
samples.ice_measured_m=DI_m+eI;
samples.dry_reference_m=DA_m+eRD;
samples.ice_reference_m=DA_m+eRI;
samples.dry_score_m=samples.dry_reference_m-samples.dry_measured_m;
samples.ice_score_m=samples.ice_reference_m-samples.ice_measured_m;
samples.sigma_score_m=hypot(sigma_m,refSigma);
samples.sigma_ref_m=refSigma;
samples.invalid_count=sum(samples.dry_measured_m<=0 | ...
    samples.ice_measured_m<=0 | samples.dry_reference_m<=0 | ...
    samples.ice_reference_m<=0);
end
