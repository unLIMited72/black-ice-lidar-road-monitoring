function [T,summary] = run_level2_full_e3(N)
%RUN_LEVEL2_FULL_E3 All geometry/noise, uncertainty, reference and validity cells.
checkpoint_setup(); c=level2_parameters();
[H,t,a]=ndgrid(c.heights_m,c.thicknesses_mm/1000,c.angles_deg);
sg=blackice.simulate_geometry(H(:),t(:),a(:),c);
ag=blackice.geometry(H(:),t(:),a(:));
assert(all(abs(sg.delta_m-ag.delta_m)<c.geometry_atol_m));
G=table(H(:),t(:)*1000,a(:),sg.D_A_m,sg.D_I_m,sg.delta_m,'VariableNames', ...
 {'H_m','thickness_mm','angle_deg','D_A_m','D_I_m','delta_m'});
writetable(G,fullfile(c.processed,'level2_geometry_inputs.csv'));
numCore=height(G)*numel(c.sigmas_mm)*height(c.families)*numel(c.reference_modes);
parts=cell(numCore,1); k=0; timer=tic;
for f=1:height(c.families)
 for h=1:height(G)
  g=struct('D_A_m',G.D_A_m(h),'D_I_m',G.D_I_m(h));
  for sigma=c.sigmas_mm
   for r=1:numel(c.reference_modes)
    k=k+1;
    Q=blackice.level2_cell(G.H_m(h),G.thickness_mm(h),G.angle_deg(h),sigma,c.families(f,:),c.reference_modes(r),N,c.stream_offset+k,c,g);
    Q.core_id(:)=k; Q.family_index(:)=f; Q.reference_index(:)=r;
    parts{k}=Q;
   end
  end
 end
 fprintf('E3 family %d/10 finished; %d core cells; %.1f s\n',f,k,toc(timer));
end
T=blackice.level2_finalize(vertcat(parts{:}),c); clear parts;
T.stress_family=c.families.family(T.family_index);
T.stress_severity=c.families.severity(T.family_index);
T.reference_mode=c.reference_modes(T.reference_index)';
T.model_level=ones(height(T),1); T.model_level(T.family_index>1)=2;
T.scenario_id="E3_"+compose('%05d',T.core_id)+"_V"+string(T.validity_index);
summary=verifyTheory(T,c);
summary.N=N; summary.core_scenarios=numCore;
summary.scenarios=numCore*height(c.validities); summary.rows=height(T);
summary.evaluated_class_attempts=2*N*summary.scenarios;
summary.unique_generated_score_samples=2*N*numCore;
summary.master_seed=c.master_seed; summary.elapsed_seconds=toc(timer);
summary.physical_warning_core_cells=numel(unique(T.core_id(T.gaussian_range_warning)));
summary.no_valid_scenario_count=numel(unique(T.scenario_id(T.N_valid==0)));
summary.conditional_precision_fraction=mean(T.conditional_precision_met);
summary.min_coverage=min(T.coverage); summary.max_coverage=max(T.coverage);
writetable(T,fullfile(c.processed,'level2_full_e3_results.csv'));
save(fullfile(c.processed,'level2_full_e3_results.mat'),'T','summary','c','-v7.3');
rep=T.H_m==c.figure_H_m & T.sigma0_mm==10 & T.pfa_target==.05 & T.validity_index==1 & ...
 ismember(T.thickness_mm,[0 10 30]) & ismember(T.angle_deg,[0 30 70]);
writetable(T(rep,:),fullfile(c.processed,'level2_representative_results.csv'));
sel=T.H_m==c.figure_H_m & T.sigma0_mm==10 & T.thickness_mm==10 & T.validity_index==1;
writetable(T(sel,:),fullfile(c.processed,'level2_threshold_sensitivity.csv'));
writetable(T(sel & T.pfa_target==.05,:),fullfile(c.processed,'level2_reference_sensitivity.csv'));
cols={'scenario_id','stress_family','stress_severity','reference_mode','validity_mode','validity_severity', ...
 'H_m','thickness_mm','angle_deg','sigma0_mm','sigma_amplification','P_D','P_FA','P_D_all','P_FA_all', ...
 'coverage','unknown_rate','N_valid_dry','N_valid_ice','conditional_precision_met','gaussian_range_warning'};
writetable(T(T.pfa_target==.05,cols),fullfile(c.processed,'level2_operating_summary.csv'));
blackice.write_utf8(fullfile(c.processed,'level2_summary.json'),jsonencode(summary,PrettyPrint=true));
assert(summary.simultaneous_gate_pass,'E3 simultaneous exact-binomial gate failed; data retained.');
end
function s=verifyTheory(T,c)
k=[T.false_alarm_count;T.detection_count;T.false_alarm_count;T.detection_count;T.N_valid_dry;T.N_valid_ice];
n=[T.N_valid_dry;T.N_valid_ice;T.N_total;T.N_total;T.N_total;T.N_total];
p=[T.P_FA_theory;T.P_D_theory;T.P_FA_all_theory;T.P_D_all_theory;T.coverage_dry_theory;T.coverage_ice_theory];
use=n>0 & isfinite(p); k=k(use); n=n(use); p=p(use);
s.simultaneous_comparisons=numel(p); s.family_alpha=c.family_alpha;
[lo,hi]=blackice.binomial_exact_interval(k,n,c.family_alpha/numel(p));
bad=p<lo-1e-9 | p>hi+1e-9;
s.simultaneous_failures=sum(bad); s.simultaneous_gate_pass=~any(bad);
s.maximum_probability_error=max(abs(k./n-p));
s.maximum_unconditional_PD_error=max(abs(T.P_D_all-T.P_D_all_theory));
end
