%% 空间图
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
%% 极端降水量
for k=1:55

        for i=1:length(data{k, 3}(1,:))% 循环每一次事件
            a=[data{k, 3}{1, i} data{k, 3}{2, i}];% [lat lon]
            b=data{k, 3}{4, i};% pre
            
            [unique_grid{i},IA] = uniquetol(a,'Byrows',true,'OutputAllIndices',true);
            
            for j=1:length(IA)
                unique_I{i}(j)=sum(b(IA{j}));% 每次事件每个unique点的强度
            end
            clear a b IA
        end
        %----------------------------------------------
        g=[];qd=[];
        for i=1:length(unique_grid)
            g=[g;unique_grid{i}];
            qd=[qd;unique_I{i}'];
        end
        
        [f_grid,IA] = uniquetol(g,'Byrows',true,'OutputAllIndices',true);
        
        for j=1:length(IA)
            f_I(j)=sum(qd(IA{j}));% 这一年所有格点的强度
        end
        
        [~, ia1, ~] = intersect(grid,f_grid,'rows');
        
        gg=nan.*zeros(1419,1);
        gg(ia1)=f_I;
        
        final_pre(k,:)=gg;
        
        clearvars -except data grid final_pre
    
end

figure
subplot(1,3,1)
[LON,LAT,pre]=raw2matrix(grid(:,2),grid(:,1),nanmean(final_pre));
CPECspatial(LON,LAT,pre)
title('\fontname{times new roman}(a) \fontname{宋体}极端降水量','fontsize',20);
%% 强度 mm/d
for k=1:55

        for i=1:length(data{k, 3}(1,:))% 循环每一次事件
            a=[data{k, 3}{1, i} data{k, 3}{2, i}];% [lat lon]
            b=data{k, 3}{4, i};% pre
            
            [unique_grid{i},IA] = uniquetol(a,'Byrows',true,'OutputAllIndices',true);
            
            for j=1:length(IA)
                unique_I{i}(j)=mean(b(IA{j}));% 每次事件每个unique点的强度
            end
            clear a b IA
        end
        %----------------------------------------------
        g=[];qd=[];
        for i=1:length(unique_grid)
            g=[g;unique_grid{i}];
            qd=[qd;unique_I{i}'];
        end
        
        [f_grid,IA] = uniquetol(g,'Byrows',true,'OutputAllIndices',true);
        
        for j=1:length(IA)
            f_I(j)=mean(qd(IA{j}));% 这一年所有格点的强度
        end
        
        [~, ia1, ~] = intersect(grid,f_grid,'rows');
        
        gg=nan.*zeros(1419,1);
        gg(ia1)=f_I;
        
        final_qd(k,:)=gg;
        
        clearvars -except data grid final_qd
    
end

% figure
subplot(1,3,2)
[LON,LAT,qd]=raw2matrix(grid(:,2),grid(:,1),nanmean(final_qd));
CPECspatial(LON,LAT,qd)
title('\fontname{times new roman}(b) \fontname{宋体}强度','fontsize',20);

%% 频率：年均，格点发生了多少次
for k=1:55

        for i=1:length(data{k, 3}(1,:))% 循环每一次事件
            a=[data{k, 3}{1, i} data{k, 3}{2, i}];% [lat lon]
            b=data{k, 3}{4, i};% pre
            
            [unique_grid{i},IA] = uniquetol(a,'Byrows',true,'OutputAllIndices',true);
            
            clear a b IA
        end
        %----------------------------------------------
        g=[];
        for i=1:length(unique_grid)
            g=[g;unique_grid{i}];
        end
        
        [f_grid,IA] = uniquetol(g,'Byrows',true,'OutputAllIndices',true);
        p=cellfun(@length,IA);% 频次
        
        [~, ia1, ~] = intersect(grid,f_grid,'rows');
        
        gg=nan.*zeros(1419,1);
        gg(ia1)=p';
        
        final_p(k,:)=gg;
        
        clearvars -except data grid final_qd final_p

end

% figure
subplot(1,3,3)
[LON,LAT,p]=raw2matrix(grid(:,2),grid(:,1),nanmean(final_p));
CPECspatial(LON,LAT,p)
title('\fontname{times new roman}(c) \fontname{宋体}频次','fontsize',20);
%% 持续时间：年均，格点持续时间
% for k=1:55
% 
%         for i=1:length(data{k, 3}(1,:))% 循环每一次事件
%             a=[data{k, 3}{1, i} data{k, 3}{2, i}];% [lat lon]
%             b=data{k, 3}{4, i};% pre
%             
%             [unique_grid{i},IA] = uniquetol(a,'Byrows',true,'OutputAllIndices',true);
%             
%             unique_d{i}=cellfun(@length,IA);% 频次
%             clear a b IA
%         end
%         %----------------------------------------------
%         g=[];d=[];
%         for i=1:length(unique_grid)
%             g=[g;unique_grid{i}];
%             d=[d;unique_d{i}];
%         end
%         
%         [f_grid,IA] = uniquetol(g,'Byrows',true,'OutputAllIndices',true);
%         
%         for j=1:length(IA)
%             f_d(j)=mean(d(IA{j}));% 这一年所有格点的持续时间
% %             f_d(j)=sum(d(IA{j}));% 这一年所有格点的持续时间
%         end
%         
%         [~, ia1, ~] = intersect(grid,f_grid,'rows');
%         
%         gg=nan.*zeros(1419,1);
%         gg(ia1)=f_d;
%         
%         final_d(k,:)=gg;
%         
%         clearvars -except data grid final_qd final_p final_d
% 
% end
% 
% figure
% % subplot(2,3,1)
% [LON,LAT,d]=raw2matrix(grid(:,2),grid(:,1),nanmean(final_d));
% CPECspatial(LON,LAT,d)