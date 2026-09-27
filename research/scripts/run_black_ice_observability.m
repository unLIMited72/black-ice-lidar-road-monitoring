function [T,U] = run_black_ice_observability()
checkpoint_setup(); c=checkpoint03_parameters(); k=0; core=0;
parts=cell(7680,1);
for H=c.heights_m
 for t=c.thin_thickness_mm
  for angle=c.angles_deg
   for sigma=[5 10 20]
    for ref=["R0" "R1"]
     core=core+1; x=blackice.ablation_config("A3",c);
     x.H_m=H; x.t_mm=t; x.theta_deg=angle; x.sigma0_mm=sigma;
     x.reference_mode=ref; x.surface_enabled=true; x.stream_id=c.stream_offset+core;
     for kap=c.kappas
      k=k+1; x.kappa=kap; parts{k}=blackice.observability_cell(x,c);
     end
    end
   end
  end
 end
end
T=vertcat(parts{:}); T.experiment=repmat("E5_main",height(T),1);
writetable(T,fullfile(c.processed,'checkpoint03_observability.csv'));
parts=cell(2304,1); k=0;
for t=[2 5 10]
 for angle=c.angles_deg
  for ref=["R0" "R1"]
   core=core+1; x=blackice.ablation_config("A3",c);
   x.t_mm=t; x.theta_deg=angle; x.reference_mode=ref;
   x.surface_enabled=true; x.stream_id=c.stream_offset+core;
   for kap=c.kappas
    for rho=c.rho_sensitivity
     for qs=c.Q_sensitivity
      for link=c.return_links
       k=k+1; x.kappa=kap; x.rho_rel=rho; x.Q_scale=qs; x.return_link=link;
       parts{k}=blackice.observability_cell(x,c);
      end
     end
    end
   end
  end
 end
end
U=vertcat(parts{:}); U.experiment=repmat("E5_parameter_sensitivity",height(U),1);
writetable(U,fullfile(c.processed,'checkpoint03_observability_sensitivity.csv'));
end
