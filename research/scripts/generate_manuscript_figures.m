function generate_manuscript_figures()
%GENERATE_MANUSCRIPT_FIGURES Publication graphics from frozen CSVs only.
% Lines connect tested points as visual guides; maps are discrete, not interpolated.
root=fileparts(fileparts(mfilename('fullpath'))); out=fullfile(root,'results','paper_figures');
if ~isfolder(out), mkdir(out); end
get=@(name) readtable(fullfile(root,'results','processed',name),'TextType','string');
G=get('geometry_analytical_sweep.csv'); L=readtable(fullfile(root,'results','paper_tables','figure_level2_extract.csv'),'TextType','string');
O=get('checkpoint03_observability.csv'); A=get('checkpoint03_ablation.csv'); C=get('checkpoint03_specificity_control.csv');
% F1: conceptual schematic, no numerical simulation.
[f,ax]=single(1200,610); axis(ax,[0 12 0 6]); axis(ax,'off'); hold(ax,'on');
boxtext(ax,[.2 4.3 3 1.1],{'Published black-ice studies','Table reassessment (E1)'});
boxtext(ax,[4.4 4.3 3 1.1],{'Road / ice geometry','Verified Simulink (E2)'});
boxtext(ax,[8.6 4.3 3 1.1],{'Specification scales (E4)','Separate deterministic layer'});
boxtext(ax,[.2 2.1 3 1.1],{'Measurement + reference','Uncertainty scenarios (E3)'});
boxtext(ax,[4.4 2.1 3 1.1],{'Generic + surface validity','Return sensitivity (E5)'});
boxtext(ax,[8.6 2.1 3 1.1],{'Valid range score','Threshold / Unknown'});
boxtext(ax,[2.8 .15 6.4 1],{'Coverage + conditional detection + overall opportunity','Ablation (E6), distribution (E7), paired control (E8)'});
arrow(ax,3.2,4.85,4.3,4.85); arrow(ax,7.4,4.85,8.5,4.85);
arrow(ax,5.9,4.2,5.9,3.3); arrow(ax,3.2,2.65,4.3,2.65); arrow(ax,7.4,2.65,8.5,2.65);
arrow(ax,10.1,2,9.3,.75); arrow(ax,4.3,4.2,2.4,3.3);
finish(f,out,'figure01_framework');
% F2: coordinate schematic, intentionally not to scale.
[f,ax]=single(1000,620); hold(ax,'on'); axis(ax,[-.45 2.7 -.3 2.55]); axis(ax,'equal'); axis(ax,'off');
plot(ax,[-.2 2.5],[0 0],'k-','LineWidth',2); plot(ax,[-.2 2.5],[.35 .35],'-','Color',[.2 .6 .85],'LineWidth',2);
plot(ax,[0 1.7],[2 0],'Color',[.7 .2 .1],'LineWidth',2); plot(ax,[0 0],[0 2],'k:');
plot(ax,0,2,'ko','MarkerFaceColor','k'); text(ax,-.1,2.18,'Sensor s=(0,0,H)','FontSize',13);
text(ax,1.9,-.12,'Road: z=0','FontSize',13); text(ax,1.9,.48,'Ice top: z=t','FontSize',13);
text(ax,-.3,1,'H','FontSize',14); text(ax,.8,1.32,'D_I','FontSize',14); text(ax,1.25,.6,'D_A','FontSize',14);
arrow(ax,2.35,0,2.35,.35); text(ax,2.44,.18,'t','FontSize',14);
arrow(ax,-.25,0,-.25,.65); text(ax,-.42,.75,'+z, n','FontSize',12);
ang=linspace(-pi/2,-pi/2+atan(1.7/2),35); plot(ax,.55*cos(ang),2+.55*sin(ang),'k-'); text(ax,.15,1.32,'\theta','FontSize',15);
text(ax,.1,-.25,'x (y=0 cross-section); schematic not to scale','FontSize',12);
finish(f,out,'figure02_geometry');
if isfile(fullfile(root,'data','paper','paper_temperature_table.csv'))
T=readtable(fullfile(root,'data','paper','paper_temperature_table.csv'));
[f,ax]=single(); hold(ax,'on');
plot(ax,T.temperature_C,T.reported_difference_m*1000,'s--','DisplayName','Reported difference','LineWidth',1.5);
plot(ax,T.temperature_C,T.recomputed_difference_m*1000,'o-','DisplayName','Recomputed asphalt - ice','LineWidth',1.5);
xlabel(ax,'Published temperature index (\circC)'); ylabel(ax,'Range difference (mm)'); legend(ax,'Location','northeast'); ylim(ax,[25 55]);
finish(f,out,'figure03_published_reassessment');
else
    fprintf('E1 skipped: optional user-supplied input absent. See reproduction/E1_USER_INPUT.md.\n');
end
[f,tl]=multi(2);
ax=nexttile(tl); hold(ax,'on');
for t=unique(G.t_m)'
 q=sortrows(G(G.H_m==1.5 & G.t_m==t,:),'theta_deg'); plot(ax,q.theta_deg,q.DeltaD_geo_m*1000,'-o','DisplayName',sprintf('%g mm',1000*t),'LineWidth',1.3);
end
xlabel(ax,'Incidence angle (deg)'); ylabel(ax,'Geometric range shift (mm)'); title(ax,'(a) Thickness series'); legend(ax,'Location','northwest'); style(ax);
ax=nexttile(tl); hold(ax,'on');
for a=[0 30 50 70]
 q=sortrows(G(G.H_m==1.5 & G.theta_deg==a,:),'t_m'); plot(ax,q.t_m*1000,q.DeltaD_geo_m*1000,'-o','DisplayName',sprintf('%g deg',a),'LineWidth',1.3);
end
xlabel(ax,'Ice thickness (mm)'); ylabel(ax,'Geometric range shift (mm)'); title(ax,'(b) Angle series'); legend(ax,'Location','northwest'); style(ax);
finish(f,out,'figure04_geometry_response');
[f,ax]=single(); hold(ax,'on');
for fam=["L1" "L2-A" "L2-B" "L2-C"]
 q=sortrows(L(L.H_m==1.5 & L.reference_mode=="R0" & L.stress_family==fam,:),'angle_deg');
 errorbar(ax,q.angle_deg,q.P_D,q.P_D-q.P_D_CI_low,q.P_D_CI_high-q.P_D,'-o','DisplayName',fam,'LineWidth',1.4);
end
xlabel(ax,'Incidence angle (deg)'); ylabel(ax,'Conditional detection probability'); ylim(ax,[0 1]); legend(ax,'Location','northwest'); finish(f,out,'figure05_uncertainty');
[f,tl]=multi(2); ax=nexttile(tl); hold(ax,'on');
for fam=["L1" "L2-C"]
 q=sortrows(L(L.reference_mode=="R0" & L.stress_family==fam & L.angle_deg==30,:),'H_m');
 errorbar(ax,q.H_m,q.P_D,q.P_D-q.P_D_CI_low,q.P_D_CI_high-q.P_D,'-o','DisplayName',fam,'LineWidth',1.4);
end
xlabel(ax,'Perpendicular sensor height H (m)'); ylabel(ax,'Conditional detection probability'); title(ax,'(a) Height sensitivity, R0'); legend(ax,'Location','best'); ylim(ax,[0 .4]); style(ax);
ax=nexttile(tl); hold(ax,'on');
for fam=["L1" "L2-C"]
 for ref=["R0" "R1"]
  q=sortrows(L(L.H_m==1.5 & L.reference_mode==ref & L.stress_family==fam,:),'angle_deg');
  plot(ax,q.angle_deg,q.P_D,'-o','DisplayName',fam+" / "+ref,'LineWidth',1.4);
 end
end
xlabel(ax,'Incidence angle (deg)'); ylabel(ax,'Conditional detection probability'); title(ax,'(b) Independent reference uncertainty'); legend(ax,'Location','northwest'); ylim(ax,[0 1]); style(ax);
finish(f,out,'figure06_height_reference');
[f,tl]=multi(3); q=O(O.H_m==1.5 & O.sigma0_mm==10 & O.reference_mode=="R1" & O.pfa_target==.05 & O.kappa==.5,:);
fields=["coverage_ice" "P_D" "P_D_all"]; labels=["(a) Ice-class coverage" "(b) Conditional detection" "(c) Overall opportunity"];
for j=1:3, ax=nexttile(tl); heat(ax,q,fields(j)); title(ax,labels(j)); end
finish(f,out,'figure07_coverage_detection');
[f,ax]=single(); hold(ax,'on');
for st=["A0" "A1" "A2" "A3" "A4" "A5"]
 q=sortrows(A(A.thickness_mm==10 & A.pfa_target==.05 & A.kappa==.5 & A.stage==st,:),'angle_deg');
 plot(ax,q.angle_deg,q.P_D_all,'-o','DisplayName',st,'LineWidth',1.4);
end
xlabel(ax,'Incidence angle (deg)'); ylabel(ax,'Overall detection opportunity'); ylim(ax,[0 1.03]); legend(ax,'Location','best'); finish(f,out,'figure08_ablation');
[f,tl]=multi(2); q=C(C.H_m==1.5 & C.thickness_mm==10 & C.sigma0_mm==10 & C.reference_mode=="R1" & C.pfa_target==.05,:);
for j=1:2
 ax=nexttile(tl); hold(ax,'on'); a=sortrows(q(q.kappa==.1,:),'angle_deg');
 if j==1, y=a.C0_coverage_ice; else, y=a.C0_PD_all; end
 plot(ax,a.angle_deg,y,'k--o','DisplayName','C0 asphalt-like layer','LineWidth',1.5);
 for k=[.1 .5 1.5]
  a=sortrows(q(q.kappa==k,:),'angle_deg'); if j==1, y=a.coverage_ice; else, y=a.P_D_all; end
  plot(ax,a.angle_deg,y,'-o','DisplayName',sprintf('C1: kappa=%g',k),'LineWidth',1.4);
 end
 xlabel(ax,'Incidence angle (deg)'); legend(ax,'Location','best'); style(ax);
 if j==1, ylabel(ax,'Layer-class coverage'); title(ax,'(a) Surface-return availability'); else, ylabel(ax,'Overall detection opportunity'); title(ax,'(b) Positive decisions per attempt'); end
end
finish(f,out,'figure09_surface_control');
% Two supplementary figures are re-rendered directly from frozen summaries.
R=get('checkpoint03_distribution_summary.csv'); [f,tl]=multi(2);
for j=1:2
 ax=nexttile(tl); hold(ax,'on');
 for fam=["Gaussian" "Uniform" "Laplace"]
  q=R(R.thickness_mm==10 & R.sigma0_mm==10 & R.reference_mode=="R1" & R.stress_family=="L2-C" & R.surface_enabled==0 & R.pfa_target==.05 & R.noise_family==fam,:);
  if j==1, q=q(q.threshold_policy=="matched",:); v='PD'; else, q=q(q.threshold_policy=="Gaussian_fixed",:); v='PFA'; end
  q=sortrows(q,'angle_deg'); y=q.([v '_seed_mean']);
  errorbar(ax,q.angle_deg,y,y-q.([v '_seed_min']),q.([v '_seed_max'])-y,'-o','DisplayName',fam,'LineWidth',1.4);
 end
 xlabel(ax,'Incidence angle (deg)'); legend(ax,'Location','best'); style(ax);
 if j==1, ylabel(ax,'Conditional detection probability'); title(ax,'(a) Distribution-matched thresholds');
 else, ylabel(ax,'False-alarm probability'); title(ax,'(b) Gaussian-fixed thresholds'); yline(ax,.05,'k:','HandleVisibility','off'); end
end
finish(f,out,'figureS01_distribution');
D=get('checkpoint03_device_spec.csv'); [f,ax]=single(); hold(ax,'on');
for a=[0 30 50 70]
 q=sortrows(D(D.H_m==1.5 & D.angle_deg==a,:),'thickness_mm'); plot(ax,q.thickness_mm,q.delta_mm,'-o','DisplayName',sprintf('%g deg',a),'LineWidth',1.3);
end
yline(ax,10,':','DisplayName','Resolution magnitude: 10 mm'); yline(ax,25,'--','DisplayName','Accuracy magnitude (<5 m): 25 mm');
xlabel(ax,'Ice thickness (mm)'); ylabel(ax,'Range-shift / specification magnitude (mm)'); legend(ax,'Location','northwest'); finish(f,out,'figureS02_device_scale');
fprintf('Created available figure exports; E1 requires optional user-supplied input. No simulations.\n');
end
function [f,ax]=single(w,h)
if nargin<1, w=1000; h=610; end
f=figure('Visible','off','Color','w','Position',[30 30 w h]); ax=axes(f); style(ax);
end
function [f,tl]=multi(n)
f=figure('Visible','off','Color','w','Position',[30 30 650*n 580]); tl=tiledlayout(f,1,n,'TileSpacing','compact','Padding','compact');
end
function style(ax)
set(ax,'FontName','Arial','FontSize',13,'LineWidth',1); grid(ax,'on'); box(ax,'on');
end
function finish(f,out,name)
exportgraphics(f,fullfile(out,[name '.png']),'Resolution',300);
print(f,fullfile(out,[name '.svg']),'-dsvg'); close(f);
end
function boxtext(ax,pos,lines)
rectangle(ax,'Position',pos,'FaceColor',[.94 .97 1],'EdgeColor',[.2 .35 .5],'LineWidth',1.2);
text(ax,pos(1)+pos(3)/2,pos(2)+pos(4)/2,lines,'HorizontalAlignment','center','FontSize',12);
end
function arrow(ax,x1,y1,x2,y2)
quiver(ax,x1,y1,x2-x1,y2-y1,0,'k','MaxHeadSize',.3,'LineWidth',1.3);
end
function heat(ax,q,field)
a=unique(q.angle_deg); t=unique(q.thickness_mm); z=nan(numel(t),numel(a)); [~,i]=ismember(q.angle_deg,a); [~,j]=ismember(q.thickness_mm,t); z(sub2ind(size(z),j,i))=q.(field);
im=imagesc(ax,z); im.AlphaData=isfinite(z); set(ax,'YDir','normal','Color',[.8 .8 .8],'XTick',1:numel(a),'XTickLabel',string(a),'YTick',1:numel(t),'YTickLabel',string(t),'FontSize',13);
xlabel(ax,'Incidence angle (deg)'); ylabel(ax,'Ice thickness (mm; discrete levels)'); clim(ax,[0 1]); colormap(ax,parula);
drawnow; cb=colorbar(ax); drawnow; ylabel(cb,'Probability');
end
