function mk3_visualize_results
colormap('default');
close all;

DROP_TOL_COL=11;
ITERS_COL=12;
OP_CPLX=13;

RAW_PROBLEM_COLS=1:3;

%figure(1); vizme('viz-solvetime.data','Solve Time Ratio',DROP_TOL_COL);
%figure(2); vizme('viz-costest.data','Cost Estimate Ratio',DROP_TOL_COL);


%figure(3); cross_relate('viz-solvetime.data','Solve Time','viz-costest.data','Cost Estimate');
%print('-dpng','cost_estimate_ratio_accuracy.png');

%figure(4); surf_for_each_drop('viz-costest.data','normalized_dropping_surface.png',DROP_TOL_COL);



surf_for_each_drop('viz-costest.data','iters',DROP_TOL_COL,ITERS_COL,RAW_PROBLEM_COLS,[15,100]);

%figure(6); colormap('default');surf_for_each_drop('viz-costest.data','oc.png',DROP_TOL_COL,OP_CPLX,[1.5,2.25]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SKIP = calculate_skip(DATA,colid)
IDX=find(abs(DATA(:,colid) - DATA(1,colid)) < 1e-10);
SKIP = IDX(2) - 1;
SKIP=length(unique(sort(DATA(1:SKIP,colid))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function algorithms=get_drop_tols_from_dakota()
[status,textout]=system('grep elements dakota_lhs.in | tail -n1 | cut -f2- -ds| sed "s/^ *//" | sed "s/ /,/g"');
str=strcat('[',textout,']');
algorithms=eval(str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vizme(fname,mytitle,DROP_TOL_COL)
DATA=load(fname);

SKIP=calculate_skip(DATA,DROP_TOL_COL);
maxscale = DATA(:,2);

ALGS=sort(DATA(1:SKIP,DROP_TOL_COL));

aniso = maxscale;
dropping=DATA(:,DROP_TOL_COL);
ratio = DATA(:,end);


PLOTSTR={};
LABELS={};
for I=1:SKIP,
  IDX=find(abs(dropping-ALGS(I)) < 1e-10);
  d1=aniso(IDX);
  d2=ratio(IDX);
  
  [xdata,IDX2]=sort(d1);
  PLOTSTR={PLOTSTR{:},xdata,d2(IDX2),'x-'};
  LABELS={LABELS{:},sprintf('%6.4e',ALGS(I))};                   
end


semilogx(PLOTSTR{:},'LineWidth',3);
legend(LABELS{:},'Location','SouthWest');
set(gca,'FontSize',15);
xlabel('Maximum Stretch');
ylabel('Relative Performance');
title(mytitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cross_relate(f1,l1,f2,l2)
D1=load(f1);
D2=load(f2);
plot(D1(:,end),D2(:,end),'x','LineWidth',3)
set(gca,'FontSize',15);
xlabel(l1);
ylabel(l2);
function [ax,h]=subtitle(text)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Centers a title over a group of subplots.
%Returns a handle to the title and the handle to an axis.
% [ax,h]=subtitle(text)
%           returns handles to both the axis and the title.
% ax=subtitle(text)
%           returns a handle to the axis only.
ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title(text);
if (nargout < 2)
    return
end
h=get(ax,'Title');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function surf_for_each_drop(inname,outpref,DROP_TOL_COL,RESULTS_COL,RAW_PROBLEM_COLS,MYCAXIS)

DATA=load(inname);
if(~exist('RESULTS_COL')), RESULTS_COL=size(DATA,2);end
if(~exist('MYCAXIS')), MYCAXIS=[0,1];end

N=size(DATA,1);

ALGS=sort(get_drop_tols_from_dakota());
Ndrops = length(ALGS);
dropping = DATA(:,DROP_TOL_COL);

SIGMAS=[1e-6,1e-4,1e-2,1e0,1e2,1e4,1e6]; % FIXME: This is a
                                         % hack... Should be smarter...
mysigma = DATA(:,RAW_PROBLEM_COLS(3));

nr=ceil(sqrt(Ndrops));
nc=ceil(Ndrops/nr);

for J=1:length(SIGMAS),
  figure(J);
  h=suptitle(sprintf('\\sigma = %1.1e',SIGMAS(J)));
  set(h,'FontSize',15,'FontWeight','bold');
  for I=1:Ndrops,
    subplot(nr,nc,I);
    colormap(fliplr(parula));
    IDX=find(abs(dropping-ALGS(I)) < 1e-10 & ...
             abs(mysigma-SIGMAS(J)) < 1e-10 & ...
             abs(DATA(:,RESULTS_COL) + 1) >1e-10);  % Drop evaluation failures
             
    x=DATA(IDX,RAW_PROBLEM_COLS(1));
    y=DATA(IDX,RAW_PROBLEM_COLS(2));
    ratio = DATA(IDX,RESULTS_COL);
    scatter(x,y,75,ratio,'filled');
    caxis(MYCAXIS);
    set(gca,'xscale','log','yscale','log','FontSize',15);
    colorbar
    xlabel('Smaller Stretch');
    ylabel('Bigger Stretch');
    title(sprintf('%6.4e\n',ALGS(I)));
  end
  % Enlarge figure to full screen.
  set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96],'PaperPositionMode','auto');
  
  print('-dpng',sprintf('%s.%1.1e.png',outpref,SIGMAS(J)));
end
