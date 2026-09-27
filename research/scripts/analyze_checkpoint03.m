function S = analyze_checkpoint03(E4,E5,U,E6,E7,E8)
checkpoint_setup(); c=checkpoint03_parameters();
B=[E5;U;E6;E7(:,E5.Properties.VariableNames)];
S.verification=blackice.verify_probability_table(B,c.family_alpha);
S.E4_rows=height(E4); S.E5_scenarios=height(E5)/3; S.E5_sensitivity_scenarios=height(U)/3;
S.E6_scenarios=height(E6)/3; S.E7_scenarios=height(E7)/3; S.E8_paired_comparisons=height(E8)/3;
S.stochastic_scenario_evaluations=height(B)/3;
S.class_attempt_evaluations=S.stochastic_scenario_evaluations*2*c.N;
S.N=c.N; S.primary_seed=c.master_seed; S.robustness_seeds=c.robustness_seeds;
S.old_output_files_regenerated=false;
thin=E4.thickness_mm>=2 & E4.thickness_mm<=10;
S.thin_R_acc_min=min(E4.R_accuracy(thin)); S.thin_R_acc_max=max(E4.R_accuracy(thin));
S.thin_delta_mm_min=min(E4.delta_mm(thin)); S.thin_delta_mm_max=max(E4.delta_mm(thin));
S.spec_short_range_rows=sum(E4.short_range_nonlinearity_warning);
S.spec_accuracy_band_crossings=sum(E4.accuracy_band_crossing);
keys={'thickness_mm','angle_deg','sigma0_mm','reference_mode','stress_family','noise_family','surface_enabled','threshold_policy','pfa_target'};
[group,G]=findgroups(E7(:,keys));
G.PD_seed_mean=splitapply(@mean,E7.P_D,group);
G.PD_seed_min=splitapply(@min,E7.P_D,group); G.PD_seed_max=splitapply(@max,E7.P_D,group);
G.PFA_seed_mean=splitapply(@mean,E7.P_FA,group);
G.PFA_seed_min=splitapply(@min,E7.P_FA,group); G.PFA_seed_max=splitapply(@max,E7.P_FA,group);
G.PD_all_seed_mean=splitapply(@mean,E7.P_D_all,group);
G.PD_theory=splitapply(@mean,E7.P_D_theory,group);
G.PFA_theory=splitapply(@mean,E7.P_FA_theory,group);
G.seed_count=splitapply(@numel,E7.master_seed,group);
writetable(G,fullfile(c.processed,'checkpoint03_distribution_summary.csv'));
% Cross-family probability differences at identical conditions (no return censoring).
M=E7(E7.threshold_policy=="matched" & ~E7.surface_enabled & E7.master_seed==42,:);
gkeys={'thickness_mm','angle_deg','sigma0_mm','reference_mode','stress_family','pfa_target'};
[id,D]=findgroups(M(:,gkeys));
D.PD_theory_min=splitapply(@min,M.P_D_theory,id); D.PD_theory_max=splitapply(@max,M.P_D_theory,id);
D.cross_distribution_spread=D.PD_theory_max-D.PD_theory_min;
writetable(D,fullfile(c.processed,'checkpoint03_distribution_spread.csv'));
S.max_matched_cross_distribution_PD_spread=max(D.cross_distribution_spread);
[~,maxIndex]=max(D.cross_distribution_spread); S.max_distribution_spread_condition=table2struct(D(maxIndex,:));
fixed=E7.threshold_policy=="Gaussian_fixed" & ~E7.surface_enabled;
S.max_fixed_threshold_PFA_misspecification=max(abs(E7.P_FA_theory(fixed)-E7.pfa_target(fixed)));
% Direction across angle endpoints, with a matched null and no surface gate.
K=M(M.angle_deg==0 | M.angle_deg==70,:);
[id,D]=findgroups(K(:,{'thickness_mm','sigma0_mm','reference_mode','stress_family','noise_family','pfa_target'}));
D.angle_endpoint_change=splitapply(@endpoint,K.P_D_theory,K.angle_deg,id);
S.L1_nonnegative_angle_trends=all(D.angle_endpoint_change(D.stress_family=="L1")>=-1e-12);
S.L2C_nonpositive_angle_trends=all(D.angle_endpoint_change(D.stress_family=="L2-C")<=1e-12);
writetable(D,fullfile(c.processed,'checkpoint03_angle_trend_robustness.csv'));
% All assigned optical tiers/links, including rho and Q-scale sensitivities.
base=sortrows(U(U.kappa==0,:),{'stream_id','pfa_target','rho_rel','Q_scale','return_link'});
effects=cell(3,1);
for j=1:3
 q=sortrows(U(U.kappa==c.kappas(j+1),:),{'stream_id','pfa_target','rho_rel','Q_scale','return_link'});
 q.PD_all_S0=base.P_D_all;
 q.assigned_specularity_increment=q.P_D_all-base.P_D_all;
 q.return_probability_ratio=q.P_return_ice./base.P_return_ice;
 effects{j}=q;
end
effects=vertcat(effects{:});
S.maximum_assigned_specularity_increment=max(effects.assigned_specularity_increment);
S.minimum_assigned_specularity_increment=min(effects.assigned_specularity_increment);
S.all_tier_link_increments_nonpositive=all(effects.assigned_specularity_increment<=1e-12);
writetable(effects,fullfile(c.processed,'checkpoint03_surface_sensitivity_contrasts.csv'));
W=E5(E5.H_m==1.5 & E5.sigma0_mm==10 & E5.reference_mode=="R1" & E5.kappa==.5 & E5.pfa_target==.05 & E5.thickness_mm<=10,:);
writetable(W,fullfile(c.processed,'checkpoint03_thin_layer_results.csv'));
S.interpretation='Directional conclusions conditional on model; absolute PD and null tails depend on distribution and return coefficients.';
blackice.write_utf8(fullfile(c.processed,'checkpoint03_summary.json'),jsonencode(S,PrettyPrint=true));
assert(S.verification.passed,'blackice:Checkpoint03Gate','Checkpoint03 simultaneous statistical gate failed.');
end
function delta=endpoint(y,angle)
delta=y(angle==70)-y(angle==0);
end
