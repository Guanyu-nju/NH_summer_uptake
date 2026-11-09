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


Tundra_wetland_mask=LUCC_mask;
Tundra_wetland_mask(Tundra_wetland_mask==180| Tundra_wetland_mask==140| Tundra_wetland_mask==150|Tundra_wetland_mask==151 | Tundra_wetland_mask==152|Tundra_wetland_mask==153)=666;
Tundra_wetland_mask=Tundra_wetland_mask.*ABZ_mask;
Tundra_wetland_mask(Tundra_wetland_mask~=666)=nan;
Tundra_wetland_mask(Tundra_wetland_mask==666)=1;

Cropland_mask=LUCC_mask;
Cropland_mask(Cropland_mask==10 | Cropland_mask==11|Cropland_mask==12 | Cropland_mask==20|Cropland_mask==30 | Cropland_mask==40)=666;
Cropland_mask(Cropland_mask~=666)=nan;
Cropland_mask(Cropland_mask==666)=1;


Shrub_grass_mask=LUCC_mask;
Shrub_grass_mask(Tundra_wetland_mask==1)=nan;
Shrub_grass_mask(Shrub_grass_mask==110 | Shrub_grass_mask==130 | Shrub_grass_mask==120| Shrub_grass_mask==121 | Shrub_grass_mask==122 ...
    | Shrub_grass_mask==150| Shrub_grass_mask==151 | Shrub_grass_mask==152| Shrub_grass_mask==153)=666;
Shrub_grass_mask(Shrub_grass_mask~=666)=nan;
Shrub_grass_mask(Shrub_grass_mask==666)=1;


LUCC_mask(forest_mask==1)=1;
LUCC_mask(Shrub_grass_mask==1)=2;
LUCC_mask(Tundra_wetland_mask==1)=3;
LUCC_mask(Cropland_mask==1)=4;


LUCC_mask(forest_mask==1 | Shrub_grass_mask==1| Cropland_mask==1| Tundra_wetland_mask==1)=1;

LUCC_mask(LUCC_mask~=1)=nan;

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
% 2. 加载 TRENDY 通量、野火数据与环境权重
load('TRENDY_NEE_Mean_detrend.mat');    % [180,360,10] 均值
load('TRENDY_GPP_Mean_detrend.mat');    % [180,360,10] 均值
load('TRENDY_TER_Mean_detrend.mat');    % [180,360,10] 均值
load('TRENDY_NEE_detrend.mat');         % [180,360,10,17] 17个独立模式成员
load('TRENDY_GPP_detrend.mat');         % [180,360,10,17]
load('TRENDY_TER_detrend.mat');         % [180,360,10,17]
load('long_term_Fire_detrend.mat');      % 野火背景数据
mask_list = {Northern_mask, Temperate_mask, ABZ_mask};
reg_names = {'Northern', 'Temperate', 'Boreal'};
area_factor = area_grid / 10^15;
% 计算野火排放标准差（4-sigma门槛判定用）
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');
% 3. 预分配空间矩阵结果与成员年平均追踪容器
TRENDY_NEE_Ex_Anom = nan(180, 360);
TRENDY_GPP_Ex_Anom = nan(180, 360);
TRENDY_TER_Ex_Anom = nan(180, 360);
% 用于在区域尺度计算多模型不确定性的成员时空图层容器 [180, 360, 10, 17]
Grid_NEE_M_Yr = nan(180, 360, 10, 17);
Grid_GPP_M_Yr = nan(180, 360, 10, 17);
Grid_TER_M_Yr = nan(180, 360, 10, 17);
% 4. 逐像素识别与多模式响应提取（空间映射）
fprintf('执行复合极端识别与野火异常年份过滤（4-sigma门槛），生成 TRENDY 空间响应矩阵...\n');
for i = 1:180
    for j = 1:360
        t_thr = T_Thr_80th(i,j);
        if isnan(t_thr), continue; end
        
        is_heat_year = (squeeze(tmp_recent_anom(i,j,:)) > t_thr);
        if ~any(is_heat_year), continue; end
        
        % 野火 4-sigma 动态过滤
        pixel_fire_std = Fire_STD_Map(i,j);
        if isnan(pixel_fire_std) || pixel_fire_std == 0
            is_fire_normal = true(10, 1);
        else
            is_fire_normal = (abs(squeeze(long_term_Fire_detrend(i,j,:))) <= 4 * pixel_fire_std);
        end
        
        is_valid_year = is_heat_year & is_fire_normal(end-9:end);
        
        if any(is_valid_year)
            % 1. 计算最优估计（集成均值）的高温期多年平均空间响应
            TRENDY_NEE_Ex_Anom(i,j) = mean(squeeze(TRENDY_NEE_Mean_detrend(i,j,is_valid_year)), 'omitnan');
            TRENDY_GPP_Ex_Anom(i,j) = mean(squeeze(TRENDY_GPP_Mean_detrend(i,j,is_valid_year)), 'omitnan');
            TRENDY_TER_Ex_Anom(i,j) = mean(squeeze(TRENDY_TER_Mean_detrend(i,j,is_valid_year)), 'omitnan');
            
            % 2. 抽取保留有效高温年份的 17 个成员的完整数据（用于不确定性区域集成）
            for m = 1:17
                Grid_NEE_M_Yr(i,j,is_valid_year,m) = TRENDY_NEE_detrend(i,j,is_valid_year,m);
                Grid_GPP_M_Yr(i,j,is_valid_year,m) = TRENDY_GPP_detrend(i,j,is_valid_year,m);
                Grid_TER_M_Yr(i,j,is_valid_year,m) = TRENDY_TER_detrend(i,j,is_valid_year,m);
            end
        end
    end
end
disp('👉 TRENDY 碳通量多模式高温响应空间矩阵 [180x360] 生成完毕！');
Ex_Heat_Mask_Summer = TRENDY_NEE_Ex_Anom;
Ex_Heat_Mask_Summer(~isnan(Ex_Heat_Mask_Summer))=1;

% =========================================================================
% 5. 区域统计与多模式不确定性集成表格输出 (修改为单位面积通量)
% =========================================================================
% 🌟 修改容器名称，存储单位面积结果 (gC m^-2 yr^-1)
Summer_TRENDY_Ex_Unit_Result = nan(3, 3);
Summer_TRENDY_Ex_Unit_Std    = nan(3, 3);

for r = 1:3
    curr_mask = mask_list{r};
    
    % 🌟 实时计算当前区域的实际有效总面积 (单位: m^2)
    valid_area_mask = curr_mask .* area_grid;
    valid_area_mask(isnan(valid_area_mask)) = 0;
    total_region_area = sum(valid_area_mask(:), 'omitnan');
    
    % A. 基于集成均值（Mean图层）计算区域最优通量总量 (GtC summer-1)
    opt_trendy_nee_total = nansum(nansum(TRENDY_NEE_Ex_Anom .* curr_mask .* area_factor));
    opt_trendy_gpp_total = nansum(nansum(TRENDY_GPP_Ex_Anom .* curr_mask .* area_factor));
    opt_trendy_ter_total = nansum(nansum(TRENDY_TER_Ex_Anom .* curr_mask .* area_factor));
    
    % B. 基于 17 个成员计算各自区域总量的模型间标准差（Inter-model SD）
    nee_m_totals = nan(17, 1);
    gpp_m_totals = nan(17, 1);
    ter_m_totals = nan(17, 1);
    
    for m = 1:17
        % 提取第 m 个模式在所有有效高温年的平均空间响应图层
        m_nee_map = squeeze(mean(Grid_NEE_M_Yr(:,:,:,m), 3, 'omitnan'));
        m_gpp_map = squeeze(mean(Grid_GPP_M_Yr(:,:,:,m), 3, 'omitnan'));
        m_ter_map = squeeze(mean(Grid_TER_M_Yr(:,:,:,m), 3, 'omitnan'));
        
        % 区域空间汇总总量 (GtC)
        nee_m_totals(m) = nansum(nansum(m_nee_map .* curr_mask .* area_factor));
        gpp_m_totals(m) = nansum(nansum(m_gpp_map .* curr_mask .* area_factor));
        ter_m_totals(m) = nansum(nansum(m_ter_map .* curr_mask .* area_factor));
    end
    
    % 计算 17 个模型横向对齐后的总量标准差
    unc_trendy_nee_total = std(nee_m_totals, 'omitnan');
    unc_trendy_gpp_total = std(gpp_m_totals, 'omitnan');
    unc_trendy_ter_total = std(ter_m_totals, 'omitnan');
    
    % 🌟 C. 统一缩放为单位面积指标并写入新容器 (单位: gC m^-2 yr^-1)
    if total_region_area > 0
        conv_factor = 10^15 / total_region_area;
        
        % 最优估计集成均值
        Summer_TRENDY_Ex_Unit_Result(r, 1) = opt_trendy_nee_total * conv_factor;
        Summer_TRENDY_Ex_Unit_Result(r, 2) = opt_trendy_gpp_total * conv_factor;
        Summer_TRENDY_Ex_Unit_Result(r, 3) = opt_trendy_ter_total * conv_factor;
        
        % 成员间不确定性标准差 (Inter-model SD)
        Summer_TRENDY_Ex_Unit_Std(r, 1)    = unc_trendy_nee_total * conv_factor;
        Summer_TRENDY_Ex_Unit_Std(r, 2)    = unc_trendy_gpp_total * conv_factor;
        Summer_TRENDY_Ex_Unit_Std(r, 3)    = unc_trendy_ter_total * conv_factor;
    else
        Summer_TRENDY_Ex_Unit_Result(r, :) = [nan, nan, nan];
        Summer_TRENDY_Ex_Unit_Std(r, :)    = [nan, nan, nan];
    end
end
disp('✨ TRENDY 集成均值与17个成员模型间单位面积不确定性（gC m^-2 yr^-1）计算全部完成！');

%%
%
load('TRENDY_Topt_GPP.mat')
load('TRENDY_Topt_TER.mat')
load('GCB_Topt_GPP.mat')
load('GCB_Topt_TER.mat')


TDY_Topt_TER_plot=TDY_Topt_TER;
TDY_Topt_GPP_plot=TDY_Topt_GPP;

TDY_Topt_TER_plot(TDY_Topt_TER_plot>30)=30;
TDY_Topt_GPP_plot(TDY_Topt_GPP_plot>30)=30;

TDY_Topt_TER_plot(TDY_Mask_no_Topt_TER== 1)=35;
TDY_Topt_GPP_plot(TDY_Mask_no_Topt_GPP== 1)=35;

Topt_list = {TDY_Topt_GPP_plot .* Ex_Heat_Mask_Summer.* Northern_mask, ...
             TDY_Topt_TER_plot .* Ex_Heat_Mask_Summer.* Northern_mask};

% 这里的 Mask 需要是：有值的点为 0，无最适温的点为 1
Mask_list = {TDY_Mask_no_Topt_GPP .* Ex_Heat_Mask_Summer.* Northern_mask, ...
             TDY_Mask_no_Topt_TER .* Ex_Heat_Mask_Summer.* Northern_mask};
%% TRENDY
customColors = [
    0.17 0.42 0.7;    % 绿色
    0.0667 0.4667 0.2;    % 蓝色
    1 0.6471 0;    % 黄色
    ];


ff=figure
t = tiledlayout(3,2);
set(gcf,'unit','pixels','position',[905,200,683,805]);
t.TileSpacing = 'tight';
t.Padding = 'tight';

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,TRENDY_NEE_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-30,30])
colormap(a,flipud(nclCM(150,12)));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('TRENDY NEE anomaly','FontName','Arial','FontSize',10);
text('string','a','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')


b=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,TRENDY_GPP_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-60,60])
colormap(b,nclCM(399,12));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('TRENDY GPP anomaly','FontName','Arial','FontSize',10);
text('string','b','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')

c=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,TRENDY_TER_Ex_Anom.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-60,60])
colormap(c,nclCM(399,12));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
set(get(h,'ylabel'),'string','gC m^{-2}','fontsize',10);
title('TRENDY TER anomaly','FontName','Arial','FontSize',10);
text('string','c','Units','normalized','position',[-0.088984830340266,1.034802724348287,0],'FontName','Arial','FontSize',14,'fontweight','bold')

base_colors = flipud(nclCM(232, 12)); 
no_topt_color = [104, 108, 116]/255; % 玫红色
my_colormap = [base_colors; no_topt_color];

d=nexttile(5)
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,TDY_Topt_TER_plot.*Ex_Heat_Mask_Summer.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
colormap(d, my_colormap);
caxis([0, 32.5]); % 0-30 是温度，30-32.5 留给 No Topt
h=colorbar('FontName','Arial','FontSize',10,'Ticks', [0, 5, 10, 15, 20, 25, 30, 32.5],...
    'TickLabels', {'0','5','10','15','20','25','30','Undet.'},'location','eastoutside');
set(get(h,'ylabel'),'string','°C','fontsize',10);
title('\itT\rm^{TER}_{opt} for TRENDY TER','FontName','Arial','FontSize',10);
text('string','e','Units','normalized','position',[-0.080326821682257,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

%
e=axes('Position',[0.569438779806208,0.369791666666662,0.423152242411893,0.265624999999995]);
bb = bar(Summer_TRENDY_Ex_Unit_Result(1:3,:),'FaceColor','flat'); hold on
bb(1).CData = [127, 197, 226]/255;
bb(2).CData = customColors(2,:);
bb(3).CData = customColors(3,:);
%分组误差棒
[M,N]=size(Summer_TRENDY_Ex_Unit_Result(1:3,:));
for i=1:N
    xx(:,i)=bb(i).XEndPoints';
end
h2=errorbar(xx(:,:),Summer_TRENDY_Ex_Unit_Result(1:3,:),Summer_TRENDY_Ex_Unit_Std(1:3,:), ...
    'LineStyle', 'none', 'Color', 'k', 'LineWidth',0.8,'CapSize',5,'Marker','none')

set(gca,'YTick', [-30:15:30],'YLim',[-30,30]);
set(gca,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
% title('TRENDY','FontName','Arial','FontSize',10)
ylabel('Flux anomaly (gC m^{-2})','FontName','Arial','FontSize',10)
text('string','d','Units','normalized','position',[-0.147586805749262,1.025823582853121,0],'FontName','Arial','FontSize',14,'fontweight','bold')
legend({'\DeltaNEE','\DeltaGPP','\DeltaTER'},'NumColumns',1,'FontName','Arial','FontSize',10,'Box','off','Location','southeast');

g=axes('Position',[0.569438779806208,0.03645833333333,0.423152242411893,0.265624999999999]);
GCB_Topt_TER_result=nanmean([reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*Northern_mask,180*360,1),reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*Temperate_mask,180*360,1),...
    reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*ABZ_mask,180*360,1)]);
GCB_Topt_TER_std=nanstd([reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*Northern_mask,180*360,1),reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*Temperate_mask,180*360,1),...
    reshape(GCB_Topt_TER.*Ex_Heat_Mask_Summer.*ABZ_mask,180*360,1)]);
TDY_Topt_TER_result=nanmean([reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*Northern_mask,180*360,1),reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*Temperate_mask,180*360,1),...
    reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*ABZ_mask,180*360,1)]);
TDY_Topt_TER_std=nanstd([reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*Northern_mask,180*360,1),reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*Temperate_mask,180*360,1),...
    reshape(TDY_Topt_TER.*Ex_Heat_Mask_Summer.*ABZ_mask,180*360,1)]);

xx=1:length(GCB_Topt_TER_result);
s6=errorbar(xx-0.125,GCB_Topt_TER_result,GCB_Topt_TER_std, ...
    "MarkerSize",10,'MarkerFaceColor',[58, 133, 190]/255,'LineWidth',3,'Marker','o','CapSize',0,'LineStyle','none','Color',[58, 133, 190]/255); hold on
s7=errorbar(xx+0.125,TDY_Topt_TER_result,TDY_Topt_TER_std, ...
    "MarkerSize",10,'MarkerFaceColor',[156, 182, 72]/255,'LineWidth',3,'Marker','o','CapSize',0,'LineStyle','none','Color',[156, 182, 72]/255)

xlim([0.5,3.5])
set(gca,'YTick', [8:4:28],'YLim',[6,28]);
set(gca,'XTick',xx,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
box on
ylabel('\itT\rm^{TER}_{opt} (°C)','FontName','Arial','FontSize',10);
text('string','f','Units','normalized','position',[-0.122810481812976,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

text(1,24,'***',...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none',...
        'Tag','sigstar_stars','FontSize',15);
text(2,26.2,'***',...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none',...
        'Tag','sigstar_stars','FontSize',15);
text(3,20,'***',...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none',...
        'Tag','sigstar_stars','FontSize',15);
lgd=legend([s6,s7],{'Reconstructed TER','TRENDY TER'},'NumColumns',1,'FontName','Arial','FontSize',10,'Box','off','Position',[0.578259847749919,0.037081478030279,0.206930204753238,0.045341613722144])
lgd.ItemTokenSize = [10, 5];


% 4. 绘制嵌入直方图 (维持原始比例逻辑)
pos_list = {[0.042313117066291,0.540250447227191,0.119887165021157,0.12701252236136], [0.042313117066291,0.029813664596273,0.119887165021157,0.080745341614907]}; 
for k = 2
    current_Topt = Topt_list{k};
    current_Mask = Mask_list{k};

    % --- 数据提取 ---
    % 1. 仅提取有最适温的有效点 (0-30°C)
    valid_Topt = current_Topt(current_Mask == 0 & ~isnan(current_Topt));
    % 2. 统计无最适温的点
    no_topt_count = sum(current_Mask(:) == 1);
    % 3. 全图有效点总数 (用于 No Topt 的占比)
    total_valid_points = sum(~isnan(current_Topt(:))); 

    % 创建嵌入 Axes
    ax_hist = axes('Position', pos_list{k}); hold on;

    % --- 绘制 0-30°C 部分 (局部归一化：分母是 sum(counts)) ---
    bin_edges = 0:2.5:30;
    [counts, ~] = histcounts(valid_Topt, bin_edges);
    topt_sum = sum(counts); 

    for b = 1:length(counts)
        % 每个 bar 的高度是该温度在“有值区域”中的频率
        bar(bin_edges(b) + 1.25, (counts(b)/topt_sum)*100, 2.5, ...
            'FaceColor', my_colormap(b, :));
    end

    % --- 绘制 No Topt 部分 (全局归一化：分母是全图总数) ---
    no_topt_percent = (no_topt_count / total_valid_points) * 100;
    bar(31.25, no_topt_percent, 2.5, 'FaceColor', no_topt_color);

    % --- 坐标轴修饰 ---
    ylim([0, 30]); % 根据需要调整高度上限
    xlim([0, 32.5]);
    set(ax_hist, 'FontSize', 8, 'TickDir', 'in', 'Box', 'on');
    set(ax_hist, 'XTick', [0, 15, 30], 'XTickLabel', {'0', '15', '30'});
    ylabel('Frequency (%)', 'FontSize', 8);
end
result=['E:\phd_file\Climate_extremes\Result\V5\NH_TRENDY_flux_anomalies_map.png']
% print(result,ff,'-r600','-dpng'); 

