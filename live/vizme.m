DATA=load('results.out-processed');


scatter(DATA(:,1),DATA(:,2),75,DATA(:,3),'filled');
axis([min(DATA(:,1)),max(DATA(:,1)),min(DATA(:,2)),max(DATA(:,2))]);
colormap(jet);

set(gca,'xscale','log','yscale','log','FontSize',15);

h=colorbar; set(h,'Ticks',[0.025,0.05,0.075]);
xlabel('Smaller Stretch');
ylabel('Bigger Stretch');

hold on;
plot([1,100,1,1],[1,100,100,1],'k-','Linewidth',3);
hold off


print('-dpng','avatar_tol.png')


figure(2);
IDX=DATA(:,4) > 0;
scatter(DATA(IDX,1),DATA(IDX,2),75,DATA(IDX,4),'filled');
axis([min(DATA(:,1)),max(DATA(:,1)),min(DATA(:,2)),max(DATA(:,2))]);
colormap(jet);

set(gca,'xscale','log','yscale','log','FontSize',15);

colorbar
xlabel('Smaller Stretch');
ylabel('Bigger Stretch');

hold on;
plot([1,100,1,1],[1,100,100,1],'k-','Linewidth',3);
hold off

print('-dpng','avatar_iters.png')