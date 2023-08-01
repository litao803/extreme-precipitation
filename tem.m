%%% 识别持续1d及其以上的极端降水事件
clc;clear
load D:\数据\中巴最新气温降水数据61-15（评估后）\点数据\CPEC_PRE61_15
tic
[LON,LAT,PRE]=raw2matrix(grid(:,2),grid(:,1),CPEC_PRE61_15);% 点变面
toc
%%% 1、计算阈值   95th
time=NYR(1961,2015);
j=1;
for i=1961:2015
    data=PRE(:,:,time(:,1)==i);
    data(data<0.1)=nan;% <0.1mm 降水不要
    p(:,:,j)=prctile(data,95,3);% 逐年阈值
    j=j+1;
end
p95=mean(p,3); % 多年平均
clear p
%%% 3、预处理：剔除小于10个格点的事件
% 参考文献：NC-A threefold rise in widespread extreme rain events over Central India
data=PRE;

tic
[PRE1]=pre_run(data,p95,10);% 预处理原数据，剔除小于10格点的极端降水事件
toc


%%% 识别每一年的持续1d或1d以上的极端降水事件
clc
tic
j=1;
for i=1961:2015
    a=PRE1(:,:,time(:,1)==i);
    T=time(time(:,1)==i,:);
    [pre_event1,day1,days1]=id_rain(a,LAT,LON,p95,T,1,0.25);
    b{j,1}=pre_event1;b{j,2}=day1;b{j,3}=days1;% 每一年的
    j=j+1;
end
toc

data=b;
clearvars -except data grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%           强度         %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
qd=data(:,3);

for i=1:55
    qd1=qd{i};
    for j=1:length(qd1(1,:))
        qd2=[qd1{1, j} qd1{2, j} qd1{4, j}];

        [qd3,~,~] = unique(qd2(:,1:2),'rows');

        for k=1:size(qd3,1)

            N=find(qd2(:,1)==qd3(k,1)&qd2(:,2)==qd3(k,2));
            qd4(k,1)=mean(qd2(N,3));
            clear N
        end
        qd5{i,j}=qd4;
        clear qd2 qd3 qd4
    end
    clear qd1
end
%
a=cellfun(@mean,qd5);
b=nanmean(a,2);clear a



figure
subplot(131)
x = [1961:1:2015]';
y = b;
mdl = fitlm(x,y);
a=plot(mdl,'Marker','none');set(a(2),'color','k');
set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);hold on;
plot(x,y,'k','LineWidth',2.5);
set(gca,'linewidth',1.5);
set(gca,'XLim',[1960 2015]);
set(gca,'XTick',[1960:10:2010]);
set(gca,'YLim',[12 22]);
set(gca,'YTick',[12:2:22]);

set(gca,'FontSize',14,'FontName', 'times new roman');
a=title('Frequency','fontname','times new roman','fontsize',20);
delete(a);
title('(a) Intensity','fontname','times new roman','fontsize',20);
xlabel('Year','fontname','times new roman','fontsize',16);
a=ylabel('Frequency','fontname','times new roman','fontsize',16);
delete(a);
% ylabel('Number','fontname','times new roman','fontsize',16);
legend('off')
r2 = roundn(mdl.Rsquared.Ordinary,-2); % 一元线性拟合的R?
a = roundn(table2array(mdl.Coefficients(2,1)),-2); % 即y=ax+b中的a值
b = roundn(table2array(mdl.Coefficients(1,1)),-2);    % 即y=ax+b中的b值
Formu = ['y=',num2str(a),'x',num2str(b)];   % 这里字符串是拟合公式和R平方
R2=['R^{2}=',num2str(r2)];
str={Formu,R2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%           频次         %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:55
    p(i,1)=length(data{i,3}(1,:));
end
% p(8)=0;% 1968年没有持续3d以上的
%-------------------------------------拟合
% ha = tight_subplot(1,3,[.07 .02],[0.3 0.3],[.03 .03]);%[子图垂直 水平]距离、[距边界上 下]距离、[距边界左 右]距离
% axes(ha(1));
subplot(132)
x = [1961:1:2015]';
y = p;
mdl = fitlm(x,y);
a=plot(mdl,'Marker','none');set(a(2),'color','k');
set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);hold on;
plot(x,y,'k','LineWidth',2.5);
set(gca,'linewidth',1.5);
set(gca,'XLim',[1960 2015]);
set(gca,'XTick',[1960:10:2010]);
set(gca,'YLim',[20 110]);
set(gca,'YTick',[20:10:110]);
% set(gcf,'position',[0 0 650 450]);
set(gca,'FontSize',14,'FontName', 'times new roman');
a=title('Frequency','fontname','times new roman','fontsize',20);
delete(a);
title('(b) Frequency','fontname','times new roman','fontsize',20);
xlabel('Year','fontname','times new roman','fontsize',16);
a=ylabel('Frequency','fontname','times new roman','fontsize',16);
delete(a);
% ylabel('Number','fontname','times new roman','fontsize',16);
legend('off')
r2 = roundn(mdl.Rsquared.Ordinary,-2); % 一元线性拟合的R?
a = roundn(table2array(mdl.Coefficients(2,1)),-2); % 即y=ax+b中的a值
b = roundn(table2array(mdl.Coefficients(1,1)),-2);    % 即y=ax+b中的b值
Formu = ['y=',num2str(a),'x',num2str(b)];   % 这里字符串是拟合公式和R平方
R2=['R^{2}=',num2str(r2)];
str={Formu,R2};
% text(min(x)+2,max(y)-2,str,'FontSize',14,'FontName','timesnewroman');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%         影响范围       %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ar=data(:,3);

for i=1:55

  
    ar1(i,1)=mean(cell2mat(ar{i}(8,:)));
   
end
% ha = tight_subplot(1,3,[.07 .05],[0.3 0.3],[.05 .05]);%[子图垂直 水平]距离、[距边界上 下]距离、[距边界左 右]距离
% axes(ha(3));
subplot(133)
x = [1961:1:2015]';
y = ar1./10000;

% figure
a=bar(x,y,'k','LineWidth',1);hold on;
a.FaceColor = [0.5 0.5 0.5];
mdl = fitlm(x,y);
b=plot(mdl,'Marker','none');set(b(2),'color','k');
set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);

set(gca,'linewidth',1.5);
set(gca,'XLim',[1960 2015]);
set(gca,'XTick',[1960:10:2010]);
set(gca,'YLim',[4 12]);
set(gca,'YTick',[4:2:12]);

set(gca,'FontSize',14,'FontName', 'times new roman');
a=title('Area','fontname','times new roman','fontsize',20);
delete(a);
title('Area','fontname','times new roman','fontsize',20);
xlabel('Year','fontname','times new roman','fontsize',16);
a=ylabel('Area','fontname','times new roman','fontsize',16);
delete(a);
ylabel('Area (10^{4}km^{2})','fontname','times new roman','fontsize',16);
legend('off')
r2 = roundn(mdl.Rsquared.Ordinary,-2); % 一元线性拟合的R?
a = roundn(table2array(mdl.Coefficients(2,1)),-2); % 即y=ax+b中的a值
b = roundn(table2array(mdl.Coefficients(1,1)),-2);    % 即y=ax+b中的b值
Formu = ['y=',num2str(a),'x',num2str(b)];   % 这里字符串是拟合公式和R平方
R2=['R^{2}=',num2str(r2)];
str={Formu,R2};
% text(min(x)+2,max(y)-0.5,str,'FontSize',14,'FontName','timesnewroman');