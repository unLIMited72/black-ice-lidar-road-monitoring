function s = verify_probability_table(T,family_alpha)
%VERIFY_PROBABILITY_TABLE Exact-binomial simultaneous gate; shared draws allowed.
k=[T.false_alarm_count;T.detection_count;T.false_alarm_count;T.detection_count;T.N_valid_dry;T.N_valid_ice];
n=[T.N_valid_dry;T.N_valid_ice;T.N_total;T.N_total;T.N_total;T.N_total];
p=[T.P_FA_theory;T.P_D_theory;T.P_FA_all_theory;T.P_D_all_theory;T.coverage_dry_theory;T.coverage_ice_theory];
use=n>0 & isfinite(p); k=k(use); n=n(use); p=p(use);
s.comparisons=numel(p); s.family_alpha=family_alpha;
[lo,hi]=blackice.binomial_exact_interval(k,n,family_alpha/numel(p));
s.failures=sum(p<lo-1e-9 | p>hi+1e-9); s.passed=s.failures==0;
s.max_overall_PD_error=max(abs(T.P_D_all-T.P_D_all_theory));
s.range_warning_rows=sum(T.range_warning);
s.zero_ice_valid_rows=sum(T.N_valid_ice==0);
end
