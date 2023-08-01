%%%%%%%%%%%%%%%% 极度降水事件/暴雨事件识别 %%%%%%%%%%%%%%
% by：陈金雨
%% 导入数据
% 我觉得用面数据较好，用格点数据再转换成面不准确
% 如果只有点数据，就转换成面
% 因为我的面数据是用中巴站点ANUSPLIN插出来的，内插精度好，外插精度差
% 所以，不用我插值生成的面数据，用点数据做成面的
clc;clear
load H:\LS\师兄电脑\Desktop\我文章\中巴极端降水风险\极端降水风险评估\CPEC_PRE61_15.mat%D:\数据\中巴最新气温降水数据61-15（评估后）\点数据\CPEC_PRE61_15
tic
[LON,LAT,PRE]=raw2matrix(grid(:,2),grid(:,1),CPEC_PRE61_15);% 点变面
toc
% CPECspatial(LON,LAT,PRE(:,:,100));
%% 1、计算阈值   95th
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
% save p95 p95 LON LAT
% CPECspatial(LON,LAT,p95);
%% 3、预处理：剔除小于10个格点的事件
% 参考文献：NC-A threefold rise in widespread extreme rain events over Central India 
data=PRE;

tic
[PRE1]=pre_run(data,p95,10);% 预处理原数据，剔除小于10格点的极端降水事件
toc
%% 2、识别事件
% 输入：data-面数据，LAT*LON*time，time是天
%       p95-阈值
%       time-年月日
%       d-持续天数
%       r-格点分辨率，本数据是0.25

% 输出：pre_event-这一年里所有发生的极端降水事件。每一行分别为：LAT、LON、page/time、pre、持续天数
%       day-持续d天的极端降水事件。
%       days-持续ds天及其以上的极端降水事件。
%       每一行分别为：LAT、LON、pre、开始时间、结束时间、格点影响面积（去了重复点）、总影响面积

tic
[pre_event,day1,days1]=id_rain(PRE1,LAT,LON,p95,time,1,0.25);
[~,day2,days2]=id_rain(PRE1,LAT,LON,p95,time,2,0.25);
[~,day3,days3]=id_rain(PRE1,LAT,LON,p95,time,3,0.25);
toc
%% 识别每一年的持续3d或3d以上的极端降水事件
clc
tic
j=1;
for i=1961:2015
    a=PRE1(:,:,time(:,1)==i);
    T=time(time(:,1)==i,:);
    [pre_event1,day31,days31]=id_rain(a,LAT,LON,p95,T,3,0.25);
    b{j,1}=pre_event1;b{j,2}=day31;b{j,3}=days31;% 每一年的
    j=j+1;
end
toc