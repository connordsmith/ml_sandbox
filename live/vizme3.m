DIRS={'.','constant-0.025','constant-0.05','constant-0.075'};
TITLES={'Avatar','0.025 Fixed','0.05 Fixed','0.075 Fixed'};


if(1==1),
% Chosen Tolerance (Adaptive)
DATA=load('results.out-processed');

scatter(DATA(:,1),DATA(:,2),75,DATA(:,3),'filled');
axis([min(DATA(:,1)),max(DATA(:,1)),min(DATA(:,2)),max(DATA(:,2))])
colormap(jet);

set(gca,'xscale','log','yscale','log','FontSize',15);

colorbar
xlabel('Smaller Stretch');
ylabel('Bigger Stretch');

hold on;
plot([1,100,1,1],[1,100,100,1],'k-','Linewidth',3);
hold off

%print('-dpng','avatar_tol.png')

CSCALE=[15,45];


for I=1:length(DIRS), 
  DATA=load(sprintf('%s/results.out-processed',DIRS{I}));
  figure(1+I);
  IDX=DATA(:,4) > 0;
  scatter(DATA(IDX,1),DATA(IDX,2),75,DATA(IDX,4),'filled');
  axis([min(DATA(:,1)),max(DATA(:,1)),min(DATA(:,2)),max(DATA(:,2))])
  colormap(jet);
  
  set(gca,'xscale','log','yscale','log','FontSize',15);
  
  colorbar; caxis(CSCALE);
  xlabel('Smaller Stretch');
  ylabel('Bigger Stretch');
  
  hold on;
  plot([1,100,1,1],[1,100,100,1],'k-','Linewidth',3);
  hold off
  title(TITLES{I});
end
end
  
%print('-dpng','avatar_iters.png')
  
% Data Comparison Stats
% NOTE: Assumes the same order
for I=1:length(DIRS), 
  IDATA{I}=load(sprintf('%s/results.out-processed',DIRS{I}));
end

WINDOW=3

for I=2:length(DIRS), 
  c_d = IDATA{I};
  a_d = IDATA{1};

  a_crash=(a_d==-1);
  c_crash=(c_d==-1);
  
  avoided_crash = length(find((a_crash == 0) & (c_crash == 1)));
  new_crash = length(find((a_crash == 1) & (c_crash == 0)));
  
  % Filter fails right
  a_d(a_crash) = Inf;
  c_d(c_crash) = Inf;
  N=size(c_d,1);
  

  
  
  nlt = length(find(a_d(:,4) < c_d(:,4) - WINDOW));
  ngt = length(find(a_d(:,4) > c_d(:,4) + WINDOW));
  
  fprintf('Adaptive vs. %s: %d better, %d same, %d worse, +/- %d/%d crashes\n',TITLES{I},...
          nlt,N-nlt-ngt,ngt,new_crash,avoided_crash);  
end
