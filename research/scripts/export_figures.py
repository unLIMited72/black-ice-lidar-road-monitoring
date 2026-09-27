"""Presentation-only export from frozen CSV columns. No simulation, fit or new statistic."""
from pathlib import Path
import sys,os,csv,json,hashlib,math
O=Path(__file__).resolve().parents[2];P=O/'research';os.environ.setdefault('MPLCONFIGDIR',str(O/'reproduced/mplconfig'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':9,'axes.labelsize':9,'axes.titlesize':9,'xtick.labelsize':9,'ytick.labelsize':9,'legend.fontsize':9,'lines.linewidth':1.35,'lines.markersize':3.7,'pdf.fonttype':42,'svg.fonttype':'none','axes.spines.top':False,'axes.spines.right':False})
OUT=O/'reproduced/figures';EDIT=O/'reproduced/editable';OUT.mkdir(parents=True,exist_ok=True);EDIT.mkdir(parents=True,exist_ok=True);records=[];current=[]
def read(rel):
 p=P/rel;rows=list(csv.DictReader(p.open(encoding='utf-8-sig')))
 for i,r in enumerate(rows):
  r['_line']=i+2;r['_source']=rel
 return rows
def value(r,k):return float(r[k])
def pick(rows,**cond):return [r for r in rows if all((r[k]==v if isinstance(v,str) else float(r[k])==v) for k,v in cond.items())]
def xy(rows,x,y,ax,label,ci=None,**kw):
 rows=sorted(rows,key=lambda r:value(r,x));xx=[value(r,x) for r in rows];yy=[value(r,y) for r in rows]
 rec={'source':rows[0]['_source'],'source_lines':[r['_line'] for r in rows],'x_column':x,'y_column':y,'x':xx,'y':yy,'legend':label}
 if ci:
  lo=[value(r,ci[0]) for r in rows];hi=[value(r,ci[1]) for r in rows];rec.update(interval_columns=ci,low=lo,high=hi)
  ax.errorbar(xx,yy,yerr=[np.array(yy)-lo,np.array(hi)-yy],fmt='-o',label=label,capsize=2,**kw)
 else:ax.plot(xx,yy,'-o',label=label,**kw)
 current.append(rec)
def layout(n=1,height=3.15):
 fig,axes=plt.subplots(1,n,figsize=(6.4,height),layout='constrained',squeeze=False)
 for ax in axes[0]:ax.grid(alpha=.22);ax.set_axisbelow(True)
 return fig,axes[0]
def finish(fig,name):
 fig.savefig(OUT/(name+'.pdf'));fig.savefig(EDIT/(name+'.svg'));fig.savefig(EDIT/(name+'.png'),dpi=180)
 records.append({'figure':name,'source_generator':'research/scripts/export_figures.py','operation':'Direct plotting of stored coordinates/intervals; no statistics or simulation','series':list(current),'pdf_sha256':hashlib.sha256((OUT/(name+'.pdf')).read_bytes()).hexdigest()});current.clear();plt.close(fig)
def legend(ax,**kw):ax.legend(frameon=False,**kw)
G=read('results/processed/geometry_analytical_sweep.csv');L=read('results/paper_tables/figure_level2_extract.csv');A=read('results/processed/checkpoint03_ablation.csv');C=read('results/processed/checkpoint03_specificity_control.csv')
# F1: diagram deliberately has no experiment labels or invented data.
fig,ax=plt.subplots(figsize=(6.4,2.6),layout='constrained');ax.axis('off');ax.set(xlim=(0,3),ylim=(0,1))
texts=[('EVIDENCE','Published range differences\n\nLayer-scale displacement\nMechanism unresolved'),('MODEL DECOMPOSITION','Geometry → range shift\nMeasurement + reference\n→ score\nReturn availability\n→ valid / Unknown'),('INTERPRETATION','Ice coverage ×\nconditional detection\n→ overall opportunity\n\nNot material identification')]
for i,(head,body) in enumerate(texts):
 ax.add_patch(FancyBboxPatch((i+.035,.08),.89,.82,boxstyle='round,pad=0.018',fc=['#eaf1f7','#eef4ed','#f9f0e3'][i],ec='#526a7b',lw=1))
 ax.text(i+.48,.79,head,ha='center',va='center',size=9,weight='bold');ax.text(i+.48,.44,body,ha='center',va='center',size=8.3,linespacing=1.55)
 if i<2:ax.annotate('',xy=(i+1.01,.51),xytext=(i+.95,.51),arrowprops={'arrowstyle':'->','lw':1.4})
finish(fig,'figure01_framework')
if (P/'data/paper/paper_temperature_table.csv').is_file():
 T=read('data/paper/paper_temperature_table.csv')
 fig,(ax,)=layout(height=2.8)
 for field,label in [('reported_difference_m','Reported'),('recomputed_difference_m','Recomputed asphalt − ice')]:
  # Unit conversion only, identical to original MATLAB generator.
  rows=[dict(r,mm=str(value(r,field)*1000)) for r in T];xy(rows,'temperature_C','mm',ax,label);current[-1]['y_column']=field;current[-1]['unit_scale']=1000
 ax.set(xlabel='Published temperature index (°C)',ylabel='Range difference (mm)',ylim=(25,55));legend(ax);finish(fig,'figure03_published_reassessment')
else:
 print('E1 skipped: optional user-supplied input absent; see reproduction/E1_USER_INPUT.md')
fig,axes=layout(2,3.25)
for t in sorted({value(r,'t_m') for r in G}):
 rows=[dict(r,mm=str(value(r,'DeltaD_geo_m')*1000)) for r in pick(G,H_m=1.5,t_m=t)];xy(rows,'theta_deg','mm',axes[0],f'{t*1000:g} mm');current[-1].update(y_column='DeltaD_geo_m',unit_scale=1000)
for a in [0,30,50,70]:
 rows=[dict(r,mm=str(value(r,'DeltaD_geo_m')*1000),tmm=str(value(r,'t_m')*1000)) for r in pick(G,H_m=1.5,theta_deg=a)];xy(rows,'tmm','mm',axes[1],f'{a}°');current[-1].update(x_column='t_m',x_scale=1000,y_column='DeltaD_geo_m',unit_scale=1000)
for i,ax in enumerate(axes):ax.set(xlabel='Incidence angle (°)' if i==0 else 'Ice thickness (mm)',ylabel='Geometric shift (mm)',title=['(a) Thickness','(b) Angle'][i]);legend(ax,ncol=2)
finish(fig,'figure04_geometry_response')
fig,(ax,)=layout(height=2.9)
for fam in ['L1','L2-A','L2-B','L2-C']:xy(pick(L,H_m=1.5,reference_mode='R0',stress_family=fam),'angle_deg','P_D',ax,fam,('P_D_CI_low','P_D_CI_high'))
ax.set(xlabel='Incidence angle (°)',ylabel=r'Conditional detection $P_D$',ylim=(0,1));legend(ax,ncol=2);finish(fig,'figure05_uncertainty')
fig,axes=layout(2,3.25)
for fam in ['L1','L2-C']:xy(pick(L,reference_mode='R0',stress_family=fam,angle_deg=30),'H_m','P_D',axes[0],fam,('P_D_CI_low','P_D_CI_high'))
for fam in ['L1','L2-C']:
 for ref in ['R0','R1']:xy(pick(L,H_m=1.5,reference_mode=ref,stress_family=fam),'angle_deg','P_D',axes[1],fam+' / '+ref)
axes[0].set(xlabel='Sensor height H (m)',ylabel=r'Conditional $P_D$',title='(a) Height, exact reference',ylim=(0,.4));axes[1].set(xlabel='Incidence angle (°)',ylabel=r'Conditional $P_D$',title='(b) Reference uncertainty',ylim=(0,1))
for ax in axes:legend(ax)
finish(fig,'figure06_height_reference')
Obs=read('results/processed/checkpoint03_observability.csv');q=pick(Obs,H_m=1.5,sigma0_mm=10,reference_mode='R1',pfa_target=.05,kappa=.5)
fig,axes=layout(3,3.0);angles=sorted({value(r,'angle_deg') for r in q});thickness=sorted({value(r,'thickness_mm') for r in q})
for ax,field,title in zip(axes,['coverage_ice','P_D','P_D_all'],['(a) Ice coverage','(b) Conditional '+r'$P_D$','(c) Overall opportunity']):
 z=np.full((len(thickness),len(angles)),np.nan)
 for r in q:z[thickness.index(value(r,'thickness_mm')),angles.index(value(r,'angle_deg'))]=value(r,field)
 cmap=plt.get_cmap('viridis').copy();cmap.set_bad('#cccccc');im=ax.imshow(z,origin='lower',vmin=0,vmax=1,cmap=cmap,interpolation='none',aspect='auto');ax.grid(False)
 ax.set(xticks=range(len(angles)),xticklabels=[f'{a:g}' for a in angles],yticks=range(len(thickness)),yticklabels=[f'{t:g}' for t in thickness],xlabel='Angle (°)',title=title)
 current.append({'source':q[0]['_source'],'source_lines':[r['_line'] for r in q],'field':field,'angles':angles,'thickness_discrete':thickness,'matrix':z.tolist(),'interpolation':'none','color_scale':[0,1]})
axes[0].set_ylabel('Thickness (mm; discrete)');fig.colorbar(im,ax=list(axes),label='Probability',fraction=.035,pad=.025);finish(fig,'figure07_coverage_detection')
fig,(ax,)=layout(height=3)
for st in ['A0','A1','A2','A3','A4','A5']:xy(pick(A,thickness_mm=10,pfa_target=.05,kappa=.5,stage=st),'angle_deg','P_D_all',ax,st)
ax.set(xlabel='Incidence angle (°)',ylabel='Overall detection opportunity',ylim=(0,1.03));legend(ax,ncol=2);finish(fig,'figure08_ablation')
fig,axes=layout(2,3.3);q=pick(C,H_m=1.5,thickness_mm=10,sigma0_mm=10,reference_mode='R1',pfa_target=.05)
for j,ax in enumerate(axes):
 xy(pick(q,kappa=.1),'angle_deg','C0_coverage_ice' if j==0 else 'C0_PD_all',ax,'C0: height only',color='black')
 for k in [.1,.5,1.5]:xy(pick(q,kappa=k),'angle_deg','coverage_ice' if j==0 else 'P_D_all',ax,r'C1: $\kappa$='+str(k))
 ax.set(xlabel='Incidence angle (°)',ylabel='Layer-class coverage' if j==0 else 'Overall opportunity',title=['(a) Return availability','(b) Decisions per attempt'][j]);legend(ax)
finish(fig,'figure09_surface_control')
D=read('results/processed/checkpoint03_distribution_summary.csv');fig,axes=layout(2,3.3)
for j,ax in enumerate(axes):
 for family in ['Gaussian','Uniform','Laplace']:
  q=pick(D,thickness_mm=10,sigma0_mm=10,reference_mode='R1',stress_family='L2-C',surface_enabled=0,pfa_target=.05,noise_family=family,threshold_policy='matched' if j==0 else 'Gaussian_fixed');v='PD' if j==0 else 'PFA';xy(q,'angle_deg',v+'_seed_mean',ax,family,(v+'_seed_min',v+'_seed_max'))
 ax.set(xlabel='Incidence angle (°)',ylabel=r'Conditional $P_D$' if j==0 else r'False alarm $P_{FA}$',title=['(a) Matched thresholds','(b) Gaussian-fixed thresholds'][j]);legend(ax)
axes[1].axhline(.05,color='black',ls=':',lw=1);finish(fig,'figureS01_distribution')
D=read('results/processed/checkpoint03_device_spec.csv');fig,(ax,)=layout(height=3)
for a in [0,30,50,70]:xy(pick(D,H_m=1.5,angle_deg=a),'thickness_mm','delta_mm',ax,f'{a}°')
ax.axhline(10,ls=':',color='black',label='Resolution: 10 mm');ax.axhline(25,ls='--',color='gray',label='Typical accuracy (<5 m): 25 mm');ax.set(xlabel='Ice thickness (mm)',ylabel='Shift / specification scale (mm)');legend(ax,ncol=2);finish(fig,'figureS02_device_scale')
sources={r['source'] for f in records for r in f['series']}
manifest={'scope':'Presentation only; identical stored points, intervals and filters to original MATLAB figure generator','font_points_at_export':{'base':9,'ticks_legend':9},'width_inches':6.4,'source_hashes':{s:hashlib.sha256((P/s).read_bytes()).hexdigest() for s in sources},'figures':records}
(O/'reproduced/figure_export_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('Exported',len(records),'figures from frozen data; geometry schematic unchanged.')
