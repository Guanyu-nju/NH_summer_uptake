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

% 3. 加载通量与成员数据
load('GCB2025_NEE_Mean_detrend.mat');
load('GPP_Mean_detrend.mat');            
load('GCB2025_TER_Mean_detrend.mat');
load('GCB2025_NBE_detrend.mat');      
load('GPP_detrend.mat');   
load('Fire_detrend.mat');              
load('long_term_Fire_detrend.mat');

% 计算每个像素点的野火排放时间序列的标准差 (用于 4 sigma 判定门槛)
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');

% 4. 预分配结果
GCB_NEE_Ex_Anom = nan(180, 360);

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
            
            % 核心过滤逻辑：只有当野火异常绝对值在 2倍标准差之内时才保留
            % 如果这一格点的野火数据全为 NaN，说明没有火灾发生，默认保留(即认为异常为 0)
            if isnan(pixel_fire_std) || pixel_fire_std == 0
                is_fire_normal = true(10, 1);
            else
                is_fire_normal = (abs(pixel_fire_ts) <= 4 * pixel_fire_std);
            end
            
            % 最终纳入计算的有效年份：既是高温年，且野火异常未超标
            is_valid_year = is_heat_year & is_fire_normal(end-9:end);
            
            if any(is_valid_year)
                GCB_NEE_Ex_Anom(i,j) = mean(squeeze(GCB2025_NEE_Mean_detrend(i,j,is_valid_year)), 'omitnan');
            end
        end
    end
end
Ex_Heat_Mask_Summer = GCB_NEE_Ex_Anom;
Ex_Heat_Mask_Summer(~isnan(Ex_Heat_Mask_Summer))=1;

% ========================== 2. 加载各气候因子数据 (2015-2024) ==========================
% 确保以下数据已加载到工作区，维度均为 [180, 360, 10]
load('tmp_detrend.mat')
load('tmp_seasonal.mat')

% ========================== 3. 预分配结果变量 ==========================
TMP_Ex_Anom  = nan(180, 360);
TMP_Ex = nan(180, 360);          % 高温年份的平均实际温度

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
            
            % 核心过滤逻辑：只有当野火异常绝对值在 2倍标准差之内时才保留
            % 如果这一格点的野火数据全为 NaN，说明没有火灾发生，默认保留(即认为异常为 0)
            if isnan(pixel_fire_std) || pixel_fire_std == 0
                is_fire_normal = true(10, 1);
            else
                is_fire_normal = (abs(pixel_fire_ts) <= 4 * pixel_fire_std);
            end
            
            % 最终纳入计算的有效年份：既是高温年，且野火异常未超标
            is_valid_year = is_heat_year & is_fire_normal(end-9:end);

            if any(is_valid_year)
                % 1. 温度与气象因子均值响应
                TMP_Ex_Anom(i,j) = mean(tmp_detrend(i,j,is_valid_year), 'omitnan');
                TMP_Ex(i,j) = mean(tmp_seasonal(i,j,is_valid_year), 'omitnan');

            end
        end
    end
end

%
load('GCB_Topt_GPP.mat')
load('GCB_Topt_TER.mat')
%%

GCB_Topt_TER(GCB_Topt_TER>30)=30;
GCB_Topt_GPP(GCB_Topt_GPP>30)=30;

GCB_Topt_TER(GCB_Mask_no_Topt_TER== 1)=35;
GCB_Topt_GPP(GCB_Mask_no_Topt_GPP== 1)=35;

%%
base_colors = flipud(nclCM(232, 12)); 
no_topt_color = [104, 108, 116]/255; % 玫红色
my_colormap = [base_colors; no_topt_color];


ff=figure
t = tiledlayout(2,2);
set(gcf,'unit','pixels','position',[1002,194,683,604]);
t.TileSpacing = 'tight';
t.Padding = 'tight';

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,GCB_Topt_GPP.*Ex_Heat_Mask_Summer.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
colormap(a, my_colormap);
caxis([0, 32.5]); % 0-30 是温度，30-32.5 留给 No Topt
h=colorbar('FontName','Arial','FontSize',10,'Ticks', [0, 5, 10, 15, 20, 25, 30, 32.5],...
    'TickLabels', {'0','5','10','15','20','25','30','Undet.'},'location','eastoutside');
% set(get(h,'title'),'string','°C','fontsize',10);
title('\itT\rm^{GPP}_{opt} for satellite-derived GPP (°C)','FontName','Arial','FontSize',10);
text('string','a','Units','normalized','position',[-0.080326821682257,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
GPP_diff=TMP_Ex-GCB_Topt_GPP;
GPP_diff(GCB_Mask_no_Topt_GPP==1)=nan;
m_pcolor(lon1,lat1,GPP_diff.*Ex_Heat_Mask_Summer.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-4,4])
colormap(a,flipud(nclCM(150,12)));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
% set(get(h,'title'),'string','°C','fontsize',10);
title('\itT\rm_{summer} – \itT\rm^{GPP}_{opt} (°C)','FontName','Arial','FontSize',10);
text('string','b','Units','normalized','position',[-0.047938157714646,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
m_pcolor(lon1,lat1,GCB_Topt_TER.*Ex_Heat_Mask_Summer.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
colormap(a, my_colormap);
caxis([0, 32.5]); % 0-30 是温度，30-32.5 留给 No Topt
h=colorbar('FontName','Arial','FontSize',10,'Ticks', [0, 5, 10, 15, 20, 25, 30, 32.5],...
    'TickLabels', {'0','5','10','15','20','25','30','Undet.'},'location','eastoutside');
% set(get(h,'title'),'string','°C','fontsize',10);
title('\itT\rm^{TER}_{opt} for reconstructed TER (°C)','FontName','Arial','FontSize',10);
text('string','c','Units','normalized','position',[-0.080326821682257,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

a=nexttile
m_proj('stereographic','lat',90,'long',0,'radius',65);
m_coast('patch', [200, 200, 200]/255,'linestyle','none');hold on % 灰色填充
TER_diff=TMP_Ex-GCB_Topt_TER;
TER_diff(GCB_Mask_no_Topt_TER==1)=nan;
m_pcolor(lon1,lat1,TER_diff.*Ex_Heat_Mask_Summer.*Northern_mask,'linestyle','none');hold on
m_grid_notick('xtick',[],'tickdir','out','ytick',[],'linest','-','LineWidth',1,'Gridcolor',[211, 211, 211]/255,'fontsize',10);
m_coast('linewidth',0.5,'color',[0.6 0.6 0.6]); %填充矢量边界
m_plot([ABZ_boundary(:).X],[ABZ_boundary(:).Y],'linewidth',0.8,'color',[0.3 0.3 0.3]);% 填充矢量边界
caxis([-4,4])
colormap(a,flipud(nclCM(150,12)));
t1=caxis;
t1=linspace(t1(1),t1(2),5);
h=colorbar('FontName','Arial','FontSize',10,'ytick',t1,'location','eastoutside');
% set(get(h,'title'),'string','°C','fontsize',10);
title('\itT\rm_{summer} – \itT\rm^{TER}_{opt} (°C)','FontName','Arial','FontSize',10);
text('string','d','Units','normalized','position',[-0.047938157714646,1.056447745993309,0],'FontName','Arial','FontSize',14,'fontweight','bold')

%
Topt_list = {GCB_Topt_GPP .* Ex_Heat_Mask_Summer.* Northern_mask, ...
             GCB_Topt_TER .* Ex_Heat_Mask_Summer.* Northern_mask};
         
% 这里的 Mask 需要是：有值的点为 0，无最适温的点为 1
Mask_list = {GCB_Mask_no_Topt_GPP .* Ex_Heat_Mask_Summer.* Northern_mask, ...
             GCB_Mask_no_Topt_TER .* Ex_Heat_Mask_Summer.* Northern_mask};

% 4. 绘制嵌入直方图 (维持原始比例逻辑)
pos_list = {[0.042351098096633,0.541390728476821,0.128951976573938,0.122516556291391], [0.042351098096633,0.039383995222455,0.128951976573938,0.122516556291391]}; 

for k = 1:2
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


result=['E:\phd_file\Climate_extremes\Result\V5\NH_GCB_Topt_map.png']
% print(result,ff,'-r600','-dpng'); 
