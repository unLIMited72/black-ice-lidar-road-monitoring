function T = run_distribution_robustness()
checkpoint_setup(); c=checkpoint03_parameters(); parts=cell(6912,1); k=0; core=0;
for seed=c.robustness_seeds
 for t=[5 10 20 30]
  for angle=[0 30 50 70]
   for sigma=[5 10 20]
    for ref=["R0" "R1"]
     for stress=["L1" "L2-C"]
      core=core+1; x=blackice.ablation_config("A3",c);
      x.seed=seed; x.t_mm=t; x.theta_deg=angle; x.sigma0_mm=sigma;
      x.reference_mode=ref; x.stream_id=c.stream_offset+30000+core;
      if stress=="L1", x.p=0; x.q=0; end
      for noise=c.noise_families
       x.noise_family=noise;
       for enabled=[false true]
        x.surface_enabled=enabled;
        for policy=c.threshold_policies
         k=k+1; x.threshold_policy=policy;
         q=blackice.observability_cell(x,c); q.stress_family=repmat(stress,height(q),1); parts{k}=q;
        end
       end
      end
     end
    end
   end
  end
 end
end
T=vertcat(parts{:}); T.experiment=repmat("E7_distribution_robustness",height(T),1);
writetable(T,fullfile(c.processed,'checkpoint03_noise_robustness.csv'));
end
