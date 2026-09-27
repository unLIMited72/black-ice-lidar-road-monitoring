function T = level2_finalize(T,c)
%LEVEL2_FINALIZE Conditional and unconditional estimands and Wilson CIs.
T.N_valid=T.N_valid_dry+T.N_valid_ice; % pooled, out of 2*N_total
T.coverage_dry=T.N_valid_dry./T.N_total;
T.coverage_ice=T.N_valid_ice./T.N_total;
T.coverage=T.N_valid./(2*T.N_total); T.valid_rate=T.coverage;
T.unknown_rate=1-T.coverage;
T.P_FA=T.false_alarm_count./T.N_valid_dry;
T.P_D=T.detection_count./T.N_valid_ice;
T.P_FA_all=T.false_alarm_count./T.N_total;
T.P_D_all=T.detection_count./T.N_total;
T.P_FA_theory=T.P_FA_all_theory./T.coverage_dry_theory;
T.P_D_theory=T.P_D_all_theory./T.coverage_ice_theory;
[T.P_FA_CI_low,T.P_FA_CI_high]=safeCI(T.false_alarm_count,T.N_valid_dry,c.ci_alpha);
[T.P_D_CI_low,T.P_D_CI_high]=safeCI(T.detection_count,T.N_valid_ice,c.ci_alpha);
[T.P_FA_all_CI_low,T.P_FA_all_CI_high]=blackice.wilson(T.false_alarm_count,T.N_total,c.ci_alpha);
[T.P_D_all_CI_low,T.P_D_all_CI_high]=blackice.wilson(T.detection_count,T.N_total,c.ci_alpha);
[T.coverage_dry_CI_low,T.coverage_dry_CI_high]=blackice.wilson(T.N_valid_dry,T.N_total,c.ci_alpha);
[T.coverage_ice_CI_low,T.coverage_ice_CI_high]=blackice.wilson(T.N_valid_ice,T.N_total,c.ci_alpha);
T.conditional_precision_met=(T.P_D_CI_high-T.P_D_CI_low)<=c.max_unconditional_CI_width & ...
 (T.P_FA_CI_high-T.P_FA_CI_low)<=c.max_unconditional_CI_width;
T.gaussian_range_warning=(T.physical_invalid_dry+T.physical_invalid_ice)>0;
T.validity_mode=c.validities.mode(T.validity_index);
T.validity_severity=c.validities.severity(T.validity_index);
T.pilot_or_final_pfa_target=T.pfa_target; % final E3 analysis point, not an application criterion
end
function [lo,hi]=safeCI(k,n,alpha)
lo=nan(size(k)); hi=lo; valid=n>0;
[lo(valid),hi(valid)]=blackice.wilson(k(valid),n(valid),alpha);
end
