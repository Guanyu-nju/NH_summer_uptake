function  wtif(outfilename,D,X,Y )
%WTIF 制作tif地理图
%   D,X,Y:数据及其经纬度
%   X:经度，Y:纬度


R=georasterref('Rastersize',size(D),'Latlim',...
    [double(min(Y)),double(max(Y))],'Lonlim',...
    [double(min(X)),double(max(X))]);
geotiffwrite(outfilename,flipud(D),R);

end

