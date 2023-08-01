function time=NYR(k1,k2)%k1开始年份，k2结束年份；
c1=[31 29 31 30 31 30 31 31 30 31 30 31];
c2=[31 28 31 30 31 30 31 31 30 31 30 31];
time=[];
for i=k1:k2
    n=0;
    if(((mod(i,4)==0&mod(i,100)~=0))|mod(i,400)==0)
        c=c1;
    else
        c=c2;
    end
    n=0;
    for j=1:12
        n=0;
        for k=1:c(j)
           n=n+1;
            time=[time;i j n];
        end
    end
end
