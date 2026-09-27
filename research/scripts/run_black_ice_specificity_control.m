function C = run_black_ice_specificity_control(T)
%RUN_BLACK_ICE_SPECIFICITY_CONTROL Paired readout of E5, no material classifier.
checkpoint_setup(); c=checkpoint03_parameters();
base=sortrows(T(T.kappa==0,:),{'stream_id','pfa_target'}); parts=cell(3,1);
for j=1:3
 q=sortrows(T(T.kappa==c.kappas(j+1),:),{'stream_id','pfa_target'});
 assert(isequal(q.stream_id,base.stream_id) && isequal(q.pfa_target,base.pfa_target));
 q.C0_coverage_ice=base.coverage_ice; q.C0_PD=base.P_D; q.C0_PD_all=base.P_D_all;
 q.C0_Q_norm=base.Q_norm_ice;
 q.increment_coverage_ice=q.coverage_ice-base.coverage_ice;
 q.increment_PD_all=q.P_D_all-base.P_D_all;
 q.experiment(:)="E8_surface_specificity_control"; parts{j}=q;
end
C=vertcat(parts{:});
writetable(C,fullfile(c.processed,'checkpoint03_specificity_control.csv'));
end
