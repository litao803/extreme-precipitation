function [pre_event,day,days]=id_rain(data,LAT,LON,p95,time,d,r)
% 输入：data-面数据，LAT*LON*time，time是天
%       p95-阈值
%       time-年月日
%       d-持续天数
%       r-格点分辨率，本数据是0.25

% 输出：pre_event-这一年里所有发生的极端降水事件。每一行分别为：LAT、LON、page/time、pre、持续天数
%       day-持续d天的极端降水事件。
%       days-持续ds天及其以上的极端降水事件。
%       每一行分别为：LAT、LON、pre、开始时间、结束时间、格点影响面积（去了重复点）、总影响面积
% data=PRE(:,:,time(:,1)==1961);
c=data>=p95;
cc = bwconncomp(c,26);
%---------------------------------------------------
for i=1:length(cc.PixelIdxList)
    % pre_event 第一行为每个点所在的行，lat
    % pre_event 第二行为每个点所在的列，lon
    % pre_event 第三行为每个点所在的页（天），page
    % pre_event 第四行为每个点的降水量，pre
    [row,col,pre_event{3,i}] = ind2sub(size(data),cc.PixelIdxList{1,i});
    pre_event{1,i}=LAT(row,1);pre_event{2,i}=LON(1,col)';
    pre_event{4,i}=data(cc.PixelIdxList{1,i});
end
gg=cellfun(@unique,pre_event(3,:),'UniformOutput',false);% 事件发生在哪一天
% pre_event 第五行为每个事件的持续时间，day
pre_event(5,:)=num2cell(cellfun(@length,gg));
%% 分别统计一下持续d天、持续ds天以上事件的lat、lon、page/day、pre、开始时间、结束时间、影响面积
%--------------------------------------------------------------持续d天：day
day(1,:)=pre_event(1,cell2mat(pre_event(5,:))==d);% lat
if isempty(day)
    day=nan;
else
day(2,:)=pre_event(2,cell2mat(pre_event(5,:))==d);% lon
day(3,:)=pre_event(3,cell2mat(pre_event(5,:))==d);% page/day
day(4,:)=pre_event(4,cell2mat(pre_event(5,:))==d);% pre

t=gg(1,cell2mat(pre_event(5,:))==d);
for i=1:length(t)
    day{5,i}=time(t{i}(1),:);% 开始时间
    day{6,i}=time(t{i}(end),:);% 结束时间
end

for i=1:length(day(1,:))
    as=cat(2,day{1,i},day{2,i});
    as_unique=unique(as,'rows');
    day{7,i}=sk(as_unique(:,2),as_unique(:,1),r);% 影响面积，持续一天的面积不会重叠
end
day(8,:)=num2cell(cellfun(@sum,day(7,:)));% 事件总影响面积
end
%--------------------------------------------------------------持续d天及以上：days
days(1,:)=pre_event(1,cell2mat(pre_event(5,:))>=d);% lat
if isempty(days)
    days=nan;
else
days(2,:)=pre_event(2,cell2mat(pre_event(5,:))>=d);% lon
days(3,:)=pre_event(3,cell2mat(pre_event(5,:))>=d);% page/day
days(4,:)=pre_event(4,cell2mat(pre_event(5,:))>=d);% pre

t=gg(1,cell2mat(pre_event(5,:))>=d);
for i=1:length(t)
    days{5,i}=time(t{i}(1),:);% 开始时间
    days{6,i}=time(t{i}(end),:);% 结束时间
end

for i=1:length(days(1,:))
    as=cat(2,days{1,i},days{2,i});
    as_unique=unique(as,'rows');
    days{7,i}=sk(as_unique(:,2),as_unique(:,1),r);% 影响面积，持续一天的面积不会重叠
end
days(8,:)=num2cell(cellfun(@sum,days(7,:)));% 事件总影响面积
end
