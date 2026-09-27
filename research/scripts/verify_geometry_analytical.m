function T = verify_geometry_analytical()
%VERIFY_GEOMETRY_ANALYTICAL 240 fixed-height cases, including invariance.
cfg=checkpoint_setup();
[H,t,theta]=ndgrid(cfg.heights_m,cfg.thicknesses_mm/1000,cfg.angles_deg);
H_m=H(:); t_m=t(:); theta_deg=theta(:);
g=blackice.geometry(H_m,t_m,theta_deg);
T=table(H_m,t_m,theta_deg,g.D_A_m,g.D_I_m,g.delta_m,g.geometry_valid, ...
    'VariableNames',{'H_m','t_m','theta_deg','D_A_m','D_I_m','DeltaD_geo_m','geometry_valid'});
assert(all(T.geometry_valid));
assert(max(abs((T.D_A_m-T.D_I_m)-T.DeltaD_geo_m))<cfg.geometry_atol_m);
G=reshape(T.DeltaD_geo_m,numel(cfg.heights_m),[]);
height_spread_m=max(max(G,[],1)-min(G,[],1));
assert(height_spread_m<cfg.geometry_atol_m);
writetable(T,fullfile(cfg.processed,'geometry_analytical_sweep.csv'));
save(fullfile(cfg.processed,'geometry_analytical.mat'),'T','height_spread_m');
fprintf('Analytical geometry: %d cases; height spread %.3g m\n',height(T),height_spread_m);
end
