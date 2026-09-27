function [N,C] = run_level2_convergence()
%RUN_LEVEL2_CONVERGENCE Predeclared worst-case precision, fixed nested streams.
checkpoint_setup(); c=level2_parameters();
z=sqrt(2)*erfcinv(c.ci_alpha);
width=z./sqrt(c.N_candidates+z^2);
N=c.N_candidates(find(width<=c.max_unconditional_CI_width,1));
assert(~isempty(N),'No candidate meets precision criterion.');
% Boundary-like representative points: (t,angle,H,sigma0,family_index).
points=[10 30 1.5 10 1;10 60 2 10 9;20 40 3 10 9;5 70 1.5 5 10];
parts=cell(size(points,1)*2*numel(c.N_candidates),1); k=0;
for b=1:size(points,1)
 for r=1:2
  for n=c.N_candidates
   k=k+1; x=points(b,:);
   T=blackice.level2_cell(x(3),x(1),x(2),x(4),c.families(x(5),:),c.reference_modes(r),n,c.stream_offset+50000+2*b+r,c);
   T=blackice.level2_finalize(T,c);
   T.boundary_id(:)=b; T.reference_mode=repmat(c.reference_modes(r),height(T),1);
   T.stress_family=repmat(c.families.family(x(5)),height(T),1);
   parts{k}=T(T.pfa_target==.05,:);
  end
 end
end
C=vertcat(parts{:});
writetable(C,fullfile(c.processed,'level2_convergence.csv'));
rows=zeros(numel(c.N_candidates),7);
for j=1:numel(c.N_candidates)
    a=C(C.N_total==c.N_candidates(j),:);
    rows(j,:)=[c.N_candidates(j),width(j),mean(abs(a.P_D_all-a.P_D_all_theory)), ...
      mean(abs(a.P_FA_all-a.P_FA_all_theory)),mean(abs(a.coverage_ice-a.coverage_ice_theory)), ...
      max(a.P_D_all_CI_high-a.P_D_all_CI_low),max(a.P_D_CI_high-a.P_D_CI_low,[],'omitnan')];
end
convSummary=array2table(rows,'VariableNames',{'N','worst_case_width','mean_abs_PD_all_error', ...
 'mean_abs_PFA_all_error','mean_abs_coverage_ice_error','maximum_observed_PD_all_width','maximum_conditional_PD_width'});
writetable(convSummary,fullfile(c.processed,'level2_convergence_summary.csv'));
selection=struct('candidates',c.N_candidates,'worst_case_width',width,'maximum_width',c.max_unconditional_CI_width,'selected_N',N);
blackice.write_utf8(fullfile(c.processed,'level2_N_selection.json'),jsonencode(selection,PrettyPrint=true));
end
