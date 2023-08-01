function [data]=pre_run(data,p95,n)
% 剔除小于格点数n的持续一天的极端降水事件
% 输入：data-面数据，LAT*LON*time，time是天
%       p95-阈值
%       n-格点数


% 输出：data-剔除小于a0的极端高温事件后的数据
c=data>=p95;
cc = bwconncomp(c,8);
%---------------------------------------------------
a=cellfun(@length,cc.PixelIdxList);
an=find(a<n);

for i=1:length(an)
    data(cc.PixelIdxList{1,an(i)})=nan;
end



