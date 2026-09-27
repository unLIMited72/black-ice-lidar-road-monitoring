function T = run_device_spec_analysis()
checkpoint_setup(); c=checkpoint03_parameters();
[H,t,a]=ndgrid(c.heights_m,c.thin_thickness_mm/1000,c.angles_deg);
T=blackice.device_spec_envelope(H(:),t(:),a(:),c);
T.H_m=H(:); T.thickness_mm=t(:)*1000; T.angle_deg=a(:);
T.resolution_scale_mm(:)=c.spec_resolution_m*1000;
T.source_id=repmat("G_p2",height(T),1);
T.analysis_type=repmat("deterministic specification-scale comparison; not probability",height(T),1);
writetable(T,fullfile(c.processed,'checkpoint03_device_spec.csv'));
end
