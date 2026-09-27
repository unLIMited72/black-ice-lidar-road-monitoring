function c = checkpoint03_parameters()
%CHECKPOINT03_PARAMETERS Frozen before E4-E8 results; all optical coefficients assumed.
c=level2_parameters(); c.protocol='checkpoint03_black_ice_return_v1';
c.N=5000; c.master_seed=42; c.robustness_seeds=[42 31415 271828];
c.thin_thickness_mm=[0 1 2 3 5 10 20 30];
c.kappas=[0 .1 .5 1.5]; c.surface_ids=["S0" "S1" "S2" "S3"];
c.rho_rel=1; c.rho_sensitivity=[.5 1]; c.n_diffuse=1;
c.Q_scale=.2; c.Q_sensitivity=[.05 .2 1];
c.return_links=["rational" "exponential"];
c.noise_families=["Gaussian" "Uniform" "Laplace"];
c.threshold_policies=["matched" "Gaussian_fixed"];
c.stream_offset=400000;
c.spec_resolution_m=.010; c.spec_accuracy_near_m=.025;
c.spec_accuracy_far_m=.100; c.spec_split_m=5;
c.source_manual='https://static.garmin.com/pumac/LIDAR_Lite_v3_Operation_Manual_and_Technical_Specifications.pdf';
end
