function T = device_spec_envelope(H_m,t_m,theta_deg,c)
%DEVICE_SPEC_ENVELOPE Specification-scale comparison, never a probability or sigma.
g=blackice.geometry(H_m,t_m,theta_deg);
assert(all(g.geometry_valid,'all'),'blackice:InvalidGeometry','Invalid geometry.');
DA=g.D_A_m(:); DI=g.D_I_m(:); delta=g.delta_m(:);
acc=c.spec_accuracy_near_m*ones(size(DA)); acc(DA>=c.spec_split_m)=c.spec_accuracy_far_m;
iceacc=c.spec_accuracy_near_m*ones(size(DI)); iceacc(DI>=c.spec_split_m)=c.spec_accuracy_far_m;
% Dry range chooses the primary scale; expose ice-range band crossings separately.
T=table(DA,DI,1000*delta,1000*acc,delta/ c.spec_resolution_m,delta./acc,delta./iceacc, ...
 DA<1 | DI<1,DA>=5 & DI<5,'VariableNames',{'D_A_m','D_I_m','delta_mm', ...
 'typical_accuracy_scale_mm','R_resolution','R_accuracy','R_accuracy_ice_range', ...
 'short_range_nonlinearity_warning','accuracy_band_crossing'});
T.comparison=repmat("below specification scale",height(T),1);
T.comparison(abs(T.R_accuracy-1)<1e-12)="equal specification scale";
T.comparison(T.R_accuracy>1+1e-12)="above specification scale";
end
