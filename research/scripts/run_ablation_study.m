function T = run_ablation_study()
checkpoint_setup(); c=checkpoint03_parameters(); parts=cell(288,1); k=0; core=0;
for t=[2 5 10 30]
 for angle=c.angles_deg
  core=core+1;
  for stage=["A0" "A1" "A2" "A3" "A4" "A5"]
   x=blackice.ablation_config(stage,c); x.t_mm=t; x.theta_deg=angle;
   x.stream_id=c.stream_offset+20000+core;
   kaps=.5; if stage=="A5", kaps=c.kappas; end
   for kap=kaps
    k=k+1; x.kappa=kap; parts{k}=blackice.observability_cell(x,c);
   end
  end
 end
end
T=vertcat(parts{:}); T.experiment=repmat("E6_ablation",height(T),1);
writetable(T,fullfile(c.processed,'checkpoint03_ablation.csv'));
% Incremental effects at fixed geometry, threshold point and common random numbers.
I=T; I.previous_stage=strings(height(T),1); I.increment_PD_all=nan(height(T),1);
I.increment_coverage_ice=nan(height(T),1);
for j=1:height(I)
 stageIndex=str2double(extractAfter(I.stage(j),"A"));
 if stageIndex==0, continue; end
 prev="A"+string(stageIndex-1);
 mask=T.stage==prev & T.thickness_mm==I.thickness_mm(j) & T.angle_deg==I.angle_deg(j) & T.pfa_target==I.pfa_target(j);
 I.previous_stage(j)=prev;
 I.increment_PD_all(j)=I.P_D_all(j)-T.P_D_all(mask);
 I.increment_coverage_ice(j)=I.coverage_ice(j)-T.coverage_ice(mask);
end
writetable(I,fullfile(c.processed,'checkpoint03_ablation_incremental.csv'));
end
