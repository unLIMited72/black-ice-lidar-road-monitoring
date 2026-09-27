function g = simulate_geometry(H_m,t_m,theta_deg,cfg)
%SIMULATE_GEOMETRY Vector batch through standard Simulink blocks.
% Every vector element is an independent static scenario, not a time step.
addpath(fullfile(cfg.root,'models'));
in=Simulink.SimulationInput(cfg.model);
in=in.setVariable('H_m',H_m(:),'Workspace',cfg.model);
in=in.setVariable('t_m',t_m(:),'Workspace',cfg.model);
in=in.setVariable('theta_deg',theta_deg(:),'Workspace',cfg.model);
in=in.setModelParameter('StopTime','0');
out=sim(in);
g.D_A_m=reshape(out.yout.getElement(1).Values.Data,[],1);
g.D_I_m=reshape(out.yout.getElement(2).Values.Data,[],1);
g.delta_m=reshape(out.yout.getElement(3).Values.Data,[],1);
g.geometry_valid=logical(reshape(out.yout.getElement(4).Values.Data,[],1));
end
