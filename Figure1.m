%% Mask create
clc
clear

% 创建环境
data=geotiffread('E:\phd_file\Boreal_North_America\region_lu.tif');
info=geotiffinfo('E:\phd_file\Boreal_North_America\region_lu.tif');
[m,n] = size(data);
k=1;
for i = 1:m
    for j = 1:1
        [lat,lon]= pix2latlon(info.RefMatrix, i, j);   %读取栅格数据第1列所有行的纬度；
        lat_(k,:)=lat; %将纬度数据存储为1列；
        k=k+1;
    end
end

k=1;
for ii = 1:1
    for jj = 1:n
        [lat,lon]= pix2latlon(info.RefMatrix, ii, jj);   %读取栅格数据第1行所有行的经度；
        lon_(k,:)=lon;  %将经度数据存储为1列；
        k=k+1;
    end
end
[lon1,lat1]=meshgrid(lon_,lat_);

clearvars -except lon1 lat1 pixel_mask bou_canX bou_canY m n
area_grid=importdata('E:\phd_file\Global_IAV\1degree_area.tif');

ABZ_boundary=shaperead("E:\phd_file\Climate_extremes\ABZ\ABZ_combined.shp");

LUCC_mask=importdata("E:\phd_file\Climate_extremes\land_cover\CCI\output\CCI_1degree.tif");
LUCC_mask=double(LUCC_mask);

ABZ_mask=importdata("E:\phd_file\Climate_extremes\ABZ\ABZ_mask.tif");

forest_mask=LUCC_mask;
forest_mask(forest_mask==50 | forest_mask==60 |forest_mask==61 |forest_mask==62 |forest_mask==70| forest_mask==71 ...
    |forest_mask==72 | forest_mask==80 |forest_mask==81 |forest_mask==82 |forest_mask==90| forest_mask==100|forest_mask==160| forest_mask==170)=666;
forest_mask(forest_mask~=666)=nan;
forest_mask(forest_mask==666)=1;


Wetland_mask=LUCC_mask;
Wetland_mask(Wetland_mask==180)=666;
Wetland_mask(Wetland_mask~=666)=nan;
Wetland_mask(Wetland_mask==666)=1;

Cropland_mask=LUCC_mask;
Cropland_mask(Cropland_mask==10 | Cropland_mask==11|Cropland_mask==12 | Cropland_mask==20|Cropland_mask==30 | Cropland_mask==40)=666;
Cropland_mask(Cropland_mask~=666)=nan;
Cropland_mask(Cropland_mask==666)=1;


Shrub_grass_mask=LUCC_mask;
Shrub_grass_mask(Shrub_grass_mask==110 | Shrub_grass_mask==130 | Shrub_grass_mask==120| Shrub_grass_mask==121 | Shrub_grass_mask==122 ...
    | Shrub_grass_mask==150| Shrub_grass_mask==151 | Shrub_grass_mask==152| Shrub_grass_mask==153 ...
    | Shrub_grass_mask==140| Shrub_grass_mask==150|Shrub_grass_mask==151 | Shrub_grass_mask==152|Shrub_grass_mask==153)=666;
Shrub_grass_mask(Shrub_grass_mask~=666)=nan;
Shrub_grass_mask(Shrub_grass_mask==666)=1;


LUCC_mask(forest_mask==1)=1;
LUCC_mask(Shrub_grass_mask==1)=2;
LUCC_mask(Wetland_mask==1)=4;
LUCC_mask(Cropland_mask==1)=3;

LUCC_result=LUCC_mask;

LUCC_mask(forest_mask==1 | Shrub_grass_mask==1| Cropland_mask==1| Wetland_mask==1)=1;
LUCC_mask(LUCC_mask~=1)=nan;

LUCC_result=LUCC_result.*LUCC_mask;
pixel_mask=LUCC_mask;

Northern_mask=pixel_mask;
Northern_mask(66:180,:)=nan;

ABZ_mask=Northern_mask.*ABZ_mask;

Temperate_mask=Northern_mask;
Temperate_mask(ABZ_mask==1)=nan;


%% 1. 数据路径与 6-8 月均值提取 (1985-2024)
temp_path = 'E:\phd_file\Climate_extremes\Air_temperature\ERA5-land\monthly\ERA5_land_air_temperature\';
years_all = 1985:2024;
num_years = length(years_all);
% 预分配空间
tmp_678_raw = nan(180, 360, num_years);
fprintf('正在处理 1985-2024 气候数据...\n');
for y = 1:num_years
    curr_year = years_all(y);
    ft6 = sprintf('%sERA5_land_air_temperature_%d_6.tif', temp_path, curr_year);
    ft7 = sprintf('%sERA5_land_air_temperature_%d_7.tif', temp_path, curr_year);
    ft8 = sprintf('%sERA5_land_air_temperature_%d_8.tif', temp_path, curr_year);
 
    if exist(ft6,'file') && exist(ft7,'file') && exist(ft8,'file')
        tmp_678_raw(:,:,y) = (double(importdata(ft6)) + double(importdata(ft7)) + double(importdata(ft8))) / 3;
    end
end
% 2. 去趋势与复合阈值定义 (80th)
tmp_678_anom = nan(180, 360, num_years);
for i = 1:180
    for j = 1:360
        ts_t = squeeze(tmp_678_raw(i,j,:));
        if ~any(isnan(ts_t)), tmp_678_anom(i,j,:) = detrend(ts_t, 'linear'); end
    end
end
T_Thr_80th = prctile(tmp_678_anom, 80, 3); 
tmp_recent_anom = tmp_678_anom(:,:,end-9:end);
% 3. 加载通量与成员数据
load('GCB2025_NEE_Mean_detrend.mat');
load('GPP_Mean_detrend.mat');            
load('GCB2025_TER_Mean_detrend.mat');
load('GCB2025_NBE_detrend.mat');      
load('GPP_detrend.mat');   
load('Fire_detrend.mat');              
load('long_term_Fire_detrend.mat');
mask_list = {Northern_mask, Temperate_mask, ABZ_mask};
reg_names = {'Northern', 'Temperate', 'Boreal'};
area_factor = area_grid / 10^15; % 用于将总量转化为 GtC yr^-1
% 计算每个像素点的野火排放时间序列的标准差 (用于 4 sigma 判定门槛)
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');
% 4. 预分配结果
GCB_NEE_Ex_Anom = nan(180, 360);
GCB_GPP_Ex_Anom = nan(180, 360);
GCB_TER_Ex_Anom = nan(180, 360);

% 🌟 结果矩阵预分配
Summer_GCB_Ex_Result_total = nan(3, 3); % 总量最优估计 [NEE, GPP, TER] (GtC yr^-1)
Summer_GCB_Ex_Std_total    = nan(3, 3); % 总量不确定性 [NEE, GPP, TER] (GtC yr^-1)
Summer_GCB_Ex_Unit_Result  = nan(3, 3); % 单位面积最优估计 [NEE, GPP, TER] (gC m^-2 yr^-1)
Summer_GCB_Ex_Unit_Std    = nan(3, 3); % 单位面积不确定性 [NEE, GPP, TER] (gC m^-2 yr^-1)

% 5. 逐像素识别与区域集成计算 (引入 4*std 野火异常剔除逻辑)
fprintf('执行复合极端识别与野火异常年份过滤（4-sigma门槛）...\n');
for i = 1:180
    for j = 1:360
        t_thr = T_Thr_80th(i,j);
        if isnan(t_thr), continue; end
        
        % 基础的高温年份判断（逻辑数组，长度10）
        is_heat_year = (squeeze(tmp_recent_anom(i,j,:)) > t_thr);
        
        if any(is_heat_year)
            % 提取当前格点 10 年内的野火排放异常值
            pixel_fire_ts = squeeze(long_term_Fire_detrend(i,j,:));
            pixel_fire_std = Fire_STD_Map(i,j);
            
            % 核心过滤逻辑：只有当野火异常绝对值在 4倍标准差之内时才保留
            if isnan(pixel_fire_std) || pixel_fire_std == 0
                is_fire_normal = true(10, 1);
            else
                is_fire_normal = (abs(pixel_fire_ts) <= 4 * pixel_fire_std);
            end
            
            % 最终纳入计算的有效年份：既是高温年，且野火异常未超标
            is_valid_year = is_heat_year & is_fire_normal(end-9:end);
            
            if any(is_valid_year)
                GCB_NEE_Ex_Anom(i,j) = mean(squeeze(GCB2025_NEE_Mean_detrend(i,j,is_valid_year)), 'omitnan');
                GCB_GPP_Ex_Anom(i,j) = mean(squeeze(GPP_Mean_detrend(i,j,is_valid_year)), 'omitnan');
                GCB_TER_Ex_Anom(i,j) = mean(squeeze(GCB2025_TER_Mean_detrend(i,j,is_valid_year)), 'omitnan');
            end
        end
    end
end

% B. 区域统计与不确定性传递 (同步更新年份过滤)
for r = 1:3
    curr_mask = mask_list{r};
    
    % 🌟 计算当前区域的总有效面积 (单位: m^2)，以便后续计算单位面积通量
    % area_grid 原始单位通常为 m^2
    valid_area_mask = curr_mask .* area_grid;
    valid_area_mask(isnan(valid_area_mask)) = 0;
    total_region_area = sum(valid_area_mask(:), 'omitnan'); 
    
    % --- 1. 最优估计集成 (加后缀 _total 以资识别) ---
    opt_gcb_nee_total = nansum(nansum(GCB_NEE_Ex_Anom(:,:) .* curr_mask .* area_factor));
    opt_gcb_gpp_total = nansum(nansum(GCB_GPP_Ex_Anom(:,:) .* curr_mask .* area_factor));
    opt_gcb_ter_total = nansum(nansum(GCB_TER_Ex_Anom(:,:) .* curr_mask .* area_factor));
    Summer_GCB_Ex_Result_total(r, :) = [opt_gcb_nee_total, opt_gcb_gpp_total, opt_gcb_ter_total];
    
    % --- 2. GCB NBE 成员标准差 (不确定性变量加后缀 _total) ---
    nbe_totals = nan(8,1);
    for m = 1:8
        tmp_map = nan(180,360);
        for i=1:180, for j=1:360
            t_thr = T_Thr_80th(i,j);
            is_heat_year = (squeeze(tmp_recent_anom(i,j,:)) > t_thr);
            if any(is_heat_year)
                pixel_fire_std = Fire_STD_Map(i,j);
                if isnan(pixel_fire_std) || pixel_fire_std == 0, is_fire_normal = true(10,1);
                else, is_fire_normal = (abs(squeeze(long_term_Fire_detrend(i,j,:))) <= 4 * pixel_fire_std); end
                is_valid_year = is_heat_year & is_fire_normal(end-9:end);
                
                if any(is_valid_year)
                    tmp_map(i,j) = mean(squeeze(GCB2025_NBE_detrend(i,j,is_valid_year,m)), 'omitnan');
                end
            end
        end, end
        nbe_totals(m) = nansum(nansum(tmp_map .* curr_mask .* area_factor));
    end
    unc_nbe_total = std(nbe_totals, 'omitnan');
    
    % --- 3. GCB GPP 成员标准差 (不确定性变量加后缀 _total) ---
    gpp_totals = nan(2,1);
    for g = 1:2
        tmp_map = nan(180,360);
        for i=1:180, for j=1:360
            t_thr = T_Thr_80th(i,j);
            is_heat_year = (squeeze(tmp_recent_anom(i,j,:)) > t_thr);
            if any(is_heat_year)
                pixel_fire_std = Fire_STD_Map(i,j);
                if isnan(pixel_fire_std) || pixel_fire_std == 0, is_fire_normal = true(10,1);
                else, is_fire_normal = (abs(squeeze(long_term_Fire_detrend(i,j,:))) <= 4 * pixel_fire_std); end
                is_valid_year = is_heat_year & is_fire_normal(end-9:end);
                
                if any(is_valid_year)
                    tmp_map(i,j) = mean(squeeze(GPP_detrend(i,j,is_valid_year,g)), 'omitnan');
                end
            end
        end, end
        gpp_totals(g) = nansum(nansum(tmp_map .* curr_mask .* area_factor));
    end
    unc_gpp_total = std(bootstrp(1000, @mean, gpp_totals));
    
    % --- 4. GCB Fire 误差 (不确定性变量加后缀 _total) ---
    fire_map = nan(180,360);
    for i=1:180, for j=1:360
        t_thr = T_Thr_80th(i,j);
        is_heat_year = (squeeze(tmp_recent_anom(i,j,:)) > t_thr);
        if any(is_heat_year)
            pixel_fire_std = Fire_STD_Map(i,j);
            if isnan(pixel_fire_std) || pixel_fire_std == 0, is_fire_normal = true(10,1);
            else, is_fire_normal = (abs(squeeze(long_term_Fire_detrend(i,j,:))) <= 4 * pixel_fire_std); end
            is_valid_year = is_heat_year & is_fire_normal(end-9:end);
            
            if any(is_valid_year)
                fire_map(i,j) = mean(squeeze(Fire_detrend(i,j,is_valid_year)), 'omitnan');
            end
        end
    end, end
    opt_fire_total = nansum(nansum(fire_map .* curr_mask .* area_factor));
    unc_fire_total = abs(opt_fire_total) * 0.20;
    
    % --- 5. 误差传递计算 (加后缀 _total) ---
    std_gcb_nee_total = sqrt(unc_nbe_total^2 + unc_fire_total^2);
    std_gcb_ter_total = sqrt(std_gcb_nee_total^2 + unc_gpp_total^2);
    Summer_GCB_Ex_Std_total(r, :) = [std_gcb_nee_total, unc_gpp_total, std_gcb_ter_total];
    
    % --- 🌟 6. 计算单位面积通量统计结果与不确定性传递 (单位: gC m^-2 yr^-1) ---
    % 转换因子: 1 GtC = 10^15 gC。所以总量 (GtC) / 面积 (m^2) * 10^15 转换为 gC m^-2
    % 这等价于直接除以 (area_grid / 10^15) 的空间积分。
    if total_region_area > 0
        % 单位面积 最优估计响应
        opt_gcb_nee_unit = (opt_gcb_nee_total * 10^15) / total_region_area;
        opt_gcb_gpp_unit = (opt_gcb_gpp_total * 10^15) / total_region_area;
        opt_gcb_ter_unit = (opt_gcb_ter_total * 10^15) / total_region_area;
        Summer_GCB_Ex_Unit_Result(r, :) = [opt_gcb_nee_unit, opt_gcb_gpp_unit, opt_gcb_ter_unit];
        
        % 单位面积 不确定性响应 (根据误差传递规律，乘以常数系数或除以面积标量)
        std_gcb_nee_unit = (std_gcb_nee_total * 10^15) / total_region_area;
        unc_gpp_unit     = (unc_gpp_total     * 10^15) / total_region_area;
        std_gcb_ter_unit = (std_gcb_ter_total * 10^15) / total_region_area;
        Summer_GCB_Ex_Unit_Std(r, :) = [std_gcb_nee_unit, unc_gpp_unit, std_gcb_ter_unit];
    else
        Summer_GCB_Ex_Unit_Result(r, :) = [nan, nan, nan];
        Summer_GCB_Ex_Unit_Std(r, :)    = [nan, nan, nan];
    end
end
disp('✨ 复合极端年份野火过滤、区域总量(_total)及单位面积通量与不确定性结果计算完成！');
% %%
% filename=["E:\phd_file\Climate_extremes\GCB_NEE_anomaly.tif"]
% 
% wtif(filename,GCB_NEE_Ex_Anom,[-180,180],[-90,90]);
%% GCB
customColors = [
    0.17 0.42 0.7;    % 绿色
    0.0667 0.4667 0.2;    % 蓝色
    1 0.6471 0;    % 黄色
    ];

ff=figure
t = tiledlayout(2,2);
set(gcf,'unit','pixels','position',[905,427,692,541]);
t.TileSpacing = 'tight';
t.Padding = 'tight';

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,GCB_NEE_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-30,30])
colormap(a,flipud(nclCM(150,12)));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('Inversion-based NEE anomaly','FontName','Arial','FontSize',10);
text('string','a','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')


b=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,GCB_GPP_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-60,60])
colormap(b,nclCM(399,12));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('Satellite-derived GPP anomaly','FontName','Arial','FontSize',10);
text('string','b','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')

c=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,GCB_TER_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界

caxis([-60,60])
colormap(c,nclCM(399,12));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('Reconstructed TER anomaly','FontName','Arial','FontSize',10);
text('string','c','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')

d=axes('Position',[0.56176480132868,0.072088724584103,0.396327684220453,0.377079482439926]);

% nexttile
bb = bar(Summer_GCB_Ex_Unit_Result(1:3,:),'FaceColor','flat'); hold on
bb(1).CData = [127, 197, 226]/255;
bb(2).CData = customColors(2,:);
bb(3).CData = customColors(3,:);
%分组误差棒
[M,N]=size(Summer_GCB_Ex_Unit_Result(1:3,:));
for i=1:N
    xx(:,i)=bb(i).XEndPoints';
end
h2=errorbar(xx(:,:),Summer_GCB_Ex_Unit_Result(1:3,:),Summer_GCB_Ex_Unit_Std(1:3,:), ...
    'LineStyle', 'none', 'Color', 'k', 'LineWidth',0.8,'CapSize',5,'Marker','none')

set(gca,'YTick', [-16:8:16],'YLim',[-16,16]);
set(gca,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
% title('Satellite inversions','FontName','Arial','FontSize',10)
ylabel('Flux anomaly (gC m^{-2})','FontName','Arial','FontSize',10)
text('string','d','Units','normalized','position',[-0.147586805749262,1.025823582853121,0],'FontName','Arial','FontSize',14,'fontweight','bold')

legend({'\DeltaNEE','\DeltaGPP','\DeltaTER'},'NumColumns',1,'FontName','Arial','FontSize',10,'Box','off','Location','northwest');

result=['E:\phd_file\Climate_extremes\Result\V5\NH_GCB_flux_anomalies_map.png']
% print(result,ff,'-r600','-dpng');