function [area]=sk(lon,lat,r)
% r:分辨率-0.25
% area:平方公里
% lon、lat可以是一列，也可以是一个面LON、LAT
lat1=lat-r/2;lat2=lat+r/2;
lon1=lon-r/2;lon2=lon+r/2;
earthellipsoid = referenceSphere('earth','km');
area=areaquad(lat1,lon1,lat2,lon2,earthellipsoid);
