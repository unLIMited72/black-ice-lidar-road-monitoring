function T = summarize_scores(samples,meta,pfa_points,delta_m,alpha)
%SUMMARIZE_SCORES Statistics and predeclared null-distribution thresholds.
% Truth delta is used only for theoretical comparisons, not detection.
dry=samples.dry_score_m; ice=samples.ice_score_m;
N=numel(dry); sx=samples.sigma_score_m;
S=abs(mean(ice)-mean(dry));
dp=S/sqrt((var(dry,0)+var(ice,0))/2);
rows=cell(numel(pfa_points),1);
for j=1:numel(pfa_points)
    r=meta;
    r.N=N; r.mean_dry=mean(dry); r.std_dry=std(dry,0);
    r.mean_ice=mean(ice); r.std_ice=std(ice,0);
    r.separation=S; r.d_prime=dp;
    r.sigma_score_theory_m=sx; r.separation_theory_m=delta_m;
    r.d_prime_theory=delta_m/sx;
    r.pfa_target=pfa_points(j);
    r.threshold=blackice.threshold(r.pfa_target,sx);
    kFA=sum(blackice.detect(dry,r.threshold));
    kD=sum(blackice.detect(ice,r.threshold));
    r.false_alarm_count=kFA; r.detection_count=kD;
    r.P_FA_mc=kFA/N; r.P_D_mc=kD/N;
    r.P_FA_theory=blackice.normal_tail(r.threshold,0,sx);
    r.P_D_theory=blackice.normal_tail(r.threshold,delta_m,sx);
    [r.pfa_ci_low,r.pfa_ci_high]=blackice.wilson(kFA,N,alpha);
    [r.ci_low,r.ci_high]=blackice.wilson(kD,N,alpha);
    r.pfa_theory_in_ci=r.P_FA_theory>=r.pfa_ci_low-1e-14 && r.P_FA_theory<=r.pfa_ci_high+1e-14;
    r.pd_theory_in_ci=r.P_D_theory>=r.ci_low-1e-14 && r.P_D_theory<=r.ci_high+1e-14;
    r.invalid_count=samples.invalid_count;
    rows{j}=struct2table(r);
end
T=vertcat(rows{:});
end
