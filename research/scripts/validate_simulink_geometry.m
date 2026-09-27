function summary = validate_simulink_geometry()
%VALIDATE_SIMULINK_GEOMETRY V1, all 240 valid combinations in a vector batch.
cfg=checkpoint_setup();
T=readtable(fullfile(cfg.processed,'geometry_analytical_sweep.csv'));
g=blackice.simulate_geometry(T.H_m,T.t_m,T.theta_deg,cfg);
T.simulink_D_A_m=g.D_A_m; T.simulink_D_I_m=g.D_I_m;
T.simulink_DeltaD_m=g.delta_m;
T.error_DA_m=abs(g.D_A_m-T.D_A_m);
T.error_DI_m=abs(g.D_I_m-T.D_I_m);
T.error_DeltaD_m=abs(g.delta_m-T.DeltaD_geo_m);
summary=struct('max_abs_error_DA',max(T.error_DA_m), ...
    'max_abs_error_DI',max(T.error_DI_m), ...
    'max_abs_error_DeltaD',max(T.error_DeltaD_m), ...
    'number_of_cases',height(T),'tolerance_m',cfg.geometry_atol_m);
summary.pass=all(g.geometry_valid) && all([summary.max_abs_error_DA ...
    summary.max_abs_error_DI summary.max_abs_error_DeltaD]<cfg.geometry_atol_m);
writetable(T,fullfile(cfg.processed,'simulink_geometry_validation.csv'));
save(fullfile(cfg.processed,'simulink_geometry_validation.mat'),'summary','T');
disp(summary);
assert(summary.pass,'blackice:GeometryValidation','Analytical vs Simulink failed.');
end
