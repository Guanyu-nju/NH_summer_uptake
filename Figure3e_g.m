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

clearvars -except lon_ lat_ lon1 lat1 pixel_mask bou_canX bou_canY m n
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
%% 生成夏季 (6-8月) 高温异常区域掩膜 (基于 80th 阈值)
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
load('tmp_detrend.mat')
load('tmp_seasonal.mat')

% 计算每个像素点的野火排放时间序列的标准差 (用于 4 sigma 判定门槛)
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');

% 4. 预分配结果
GCB_NEE_Ex_Anom = nan(180, 360);
GCB_GPP_Ex_Anom = nan(180, 360);
GCB_TER_Ex_Anom = nan(180, 360);
TMP_Ex_Anom  = nan(180, 360);
TMP_Ex = nan(180, 360);          % 高温年份的平均实际温度
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
                GCB_GPP_Ex_Anom(i,j) = mean(squeeze(GPP_Mean_detrend(i,j,is_valid_year)), 'omitnan');
                GCB_TER_Ex_Anom(i,j) = mean(squeeze(GCB2025_TER_Mean_detrend(i,j,is_valid_year)), 'omitnan');
                TMP_Ex_Anom(i,j) = mean(tmp_detrend(i,j,is_valid_year), 'omitnan');
                TMP_Ex(i,j) = mean(tmp_seasonal(i,j,is_valid_year), 'omitnan');
            end
        end
    end
end
Ex_Heat_Mask_Summer = GCB_NEE_Ex_Anom;
Ex_Heat_Mask_Summer(~isnan(Ex_Heat_Mask_Summer))=1;

%% 2. 加载 TER 通量数据与 Top 变量
load('GCB2025_TER_Mean_detrend.mat'); % 预期 [180,360,10]
load('GCB_Topt_TER.mat');             % 空间 Top 数据
load('GCB_Topt_GPP.mat');

Ta_TER_result  = (TMP_Ex - GCB_Topt_TER) .* Ex_Heat_Mask_Summer .* Northern_mask;
GCB_TER_result = GCB_TER_Ex_Anom .* Ex_Heat_Mask_Summer .* Northern_mask;

Ta_GPP_result  = (TMP_Ex - GCB_Topt_GPP) .* Ex_Heat_Mask_Summer .* Northern_mask;
GCB_GPP_result = GCB_GPP_Ex_Anom .* Ex_Heat_Mask_Summer .* Northern_mask;
GCB_NEE_result = GCB_NEE_Ex_Anom .* Ex_Heat_Mask_Summer .* Northern_mask;

ta_ter_vec   = Ta_TER_result(:);
ter_anom_vec = GCB_TER_result(:);

ta_gpp_vec   = Ta_GPP_result(:);
gpp_anom_vec = GCB_GPP_result(:);
nee_anom_vec = GCB_NEE_result(:);
% 3. 初始化分箱设置 (按要求恢复为固定边界形式，独立命名变量)
% 默认均为 -3:1:7，后续你可以在此处自由单独调整
TER_edges = -4:1:7;
GPP_edges = -4:1:7;

num_bins_ter = length(TER_edges) - 1;
num_bins_gpp = length(GPP_edges) - 1;

% 准备各通量分箱独立存储容器
Result_Ta       = cell(1, num_bins_ter); % 存放裁剪后的 TER 异常数据
Result_GPP_Anom = cell(1, num_bins_gpp); % 存放裁剪后的 GPP 异常数据
Result_NEE_Anom = cell(1, num_bins_gpp); % 存放裁剪后的 NEE 异常数据

% 4. 核心分箱提取与异常值过滤逻辑 (1.5 * IQR 准则)

% --- A. 处理 温度与 TER 最适温差值 vs TER 异常 ---
for b = 1:num_bins_ter
    low  = TER_edges(b);
    high = TER_edges(b+1);
    
    idx_ta = ta_ter_vec >= low & ta_ter_vec < high & ~isnan(ter_anom_vec);
    data_ta = ter_anom_vec(idx_ta);
    if ~isempty(data_ta)
        q1 = prctile(data_ta, 5);
        q3 = prctile(data_ta, 95);
        iqr_val = q3 - q1;
        Result_Ta{b} = data_ta(data_ta >= (q1 - 1.5*iqr_val) & data_ta <= (q3 + 1.5*iqr_val));
    end
end

% --- B. 处理 温度与 GPP 最适温差值 vs GPP/NEE 异常 ---
for b = 1:num_bins_gpp
    low  = GPP_edges(b);
    high = GPP_edges(b+1);
    
    idx_bin = ta_gpp_vec >= low & ta_gpp_vec < high;
    
    % GPP 异常提取
    data_gpp = gpp_anom_vec(idx_bin & ~isnan(gpp_anom_vec));
    if ~isempty(data_gpp)
        q1 = prctile(data_gpp, 5);
        q3 = prctile(data_gpp, 95);
        iqr_val = q3 - q1;
        % Result_GPP_Anom{b} = data_gpp(data_gpp >= (q1 - 1.5*iqr_val) & data_gpp <= (q3 + 1.5*iqr_val));
        Result_GPP_Anom{b} = data_gpp;
    end
    
    % NEE 异常提取
    data_nee = nee_anom_vec(idx_bin & ~isnan(nee_anom_vec));
    if ~isempty(data_nee)
        q1 = prctile(data_nee, 5);
        q3 = prctile(data_nee, 95);
        iqr_val = q3 - q1;
        % Result_NEE_Anom{b} = data_nee(data_nee >= (q1 - 1.5*iqr_val) & data_nee <= (q3 + 1.5*iqr_val));
        Result_NEE_Anom{b} = data_nee;
    end
end

% 5. 展开 Cell 并构建长向量与组标签 (用于绘图或 anova1)

% --- TER 汇总长向量 ---
all_ter_data = [];
group_ter_idx = [];
for i = 1:length(Result_Ta)
    current_data = Result_Ta{i}(:);
    num_pts = length(current_data);
    all_ter_data = [all_ter_data; current_data];
    group_ter_idx = [group_ter_idx; repmat(i, num_pts, 1)];
end

% --- GPP 汇总长向量 ---
all_gpp_data = [];
group_gpp_idx = [];
for b = 1:num_bins_gpp
    curr_bin_gpp = Result_GPP_Anom{b}(:);
    num_pts = length(curr_bin_gpp);
    all_gpp_data = [all_gpp_data; curr_bin_gpp];
    group_gpp_idx = [group_gpp_idx; repmat(b, num_pts, 1)]; 
end

% --- NEE 汇总长向量 ---
all_nee_data = [];
group_nee_idx = [];
for b = 1:num_bins_gpp
    curr_bin_nee = Result_NEE_Anom{b}(:);
    num_pts = length(curr_bin_nee);
    all_nee_data = [all_nee_data; curr_bin_nee];
    group_nee_idx = [group_nee_idx; repmat(b, num_pts, 1)]; 
end

disp('✨ TER、GPP、NEE 独立固定边界分箱及异常值过滤代码构建已全部恢复并完成！');
%%
ff=figure
t = tiledlayout(3,1);
set(gcf,'unit','pixels','position',[957,301,298,604]);
t.TileSpacing = 'tight';
t.Padding = 'tight';

nexttile
hold on
% 2. 绘制箱线图 - 使用协调的深色
% 深灰蓝色作为箱体颜色
fill([-5, -0.5, -0.5, -5], ...
             [-200, -200, 200, 200], ...
             [182 215 232]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
fill([-0.5, 15, 15, -0.5], ...
             [-200, -200, 200, 200], ...
             [246 178 147]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);

box_color = [0.2 0.2 0.2];

h = boxchart(group_nee_idx-5, all_nee_data, ...
    'BoxFaceColor', box_color, ...
    'MarkerColor', box_color, ...
    'BoxWidth', 0.65);
% hold on; scatter(cc, nee_anom_vec)

% 隐藏箱线图中的异常值标记（因为已经用swarmchart显示了）
h.MarkerStyle = 'none';
% h.LineWidth = 1;         % 适当加粗线条

yline(0, '--', 'Color', 'k', 'LineWidth', 1.2); % 灰色 0 基准线

cc=ta_gpp_vec;
cc(cc<-4)=nan;
cc(cc>7)=nan;

lm = fitlm(cc,nee_anom_vec);
slope = lm.Coefficients.Estimate(2);       % 斜率
P_value = lm.Coefficients.pValue(2);         % 斜率的 p 值
slope=roundn(slope,-2);
intercept = lm.Coefficients.Estimate(1);   % 截距

if P_value>0.05
    P_text='ns';
elseif P_value<=0.05 & P_value>0.01
    P_text='\itP\rm < 0.05';
elseif P_value<=0.001
    P_text='\itP\rm < 0.001';
end
sig_text=['Slope = ' num2str(slope) ' gC m^{-2} °C^{-1}'];
res_text=[sig_text,', ' P_text];

text('string',res_text,'Units','normalized','position',[0.970196620445752,0.924693139221602,0],'FontName','Arial','FontSize',8,'HorizontalAlignment','right')

x_fit = min(group_nee_idx-5)-0.5:0.1:max(group_nee_idx-5)+0.5;
y_fit = slope * x_fit + intercept;

% 绘制红色虚线拟合回归线
plot(x_fit, y_fit, 'r-', 'LineWidth', 1);


% 3. 坐标轴设置
set(gca, 'XTick', -4:6, 'XLim', [-5, 7]);
set(gca, 'YTick', -60:30:60, 'YLim', [-60, 60]);
set(gca, 'XTickLabel', {'[-4,-3]','[-3,-2]','[-2,-1]','[-1,0]','[0,1]','[1,2]',...
                        '[2,3]','[3,4]','[4,5]','[5,6]','[6,7]'}, ...
         'FontName', 'Arial', 'FontSize', 8);
xtickangle(40);

% 4. 美化整体外观
box off;
% title('Inversions','FontName','Arial','FontSize',10)
xlabel('\itT\rm_{summer} – \itT\rm^{GPP}_{opt} (°C)','FontName','Arial','FontSize',9)
ylabel('NEE anomaly (gC m^{-2})','FontName','Arial','FontSize',9)
text('string','e','Units','normalized','position',[-0.143217992884015,1.008418924583119,0],'FontName','Arial','FontSize',14,'fontweight','bold')


nexttile
hold on
fill([-5, -0.5, -0.5, -5], ...
             [-200, -200, 200, 200], ...
             [182 215 232]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
fill([-0.5, 15, 15, -0.5], ...
             [-200, -200, 200, 200], ...
             [246 178 147]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
% 2. 绘制箱线图 - 使用协调的深色
% 深灰蓝色作为箱体颜色
box_color = [0.2 0.2 0.2];

h = boxchart(group_gpp_idx-5, all_gpp_data, ...
    'BoxFaceColor', box_color, ...
    'MarkerColor', box_color, ...
    'BoxWidth', 0.65);


% 隐藏箱线图中的异常值标记（因为已经用swarmchart显示了）
h.MarkerStyle = 'none';
% h.LineWidth = 0.5;         % 适当加粗线条

yline(0, '--', 'Color', 'k', 'LineWidth', 1.2); % 灰色 0 基准线

cc=ta_gpp_vec;
cc(cc<-4)=nan;
cc(cc>7)=nan;

lm = fitlm(cc,gpp_anom_vec);
slope = lm.Coefficients.Estimate(2);       % 斜率
P_value = lm.Coefficients.pValue(2);         % 斜率的 p 值
slope=roundn(slope,-2);
intercept = lm.Coefficients.Estimate(1);   % 截距

if P_value>0.05
    P_text='ns';
elseif P_value<=0.05 & P_value>0.01
    P_text='\itP\rm < 0.05';
elseif P_value<=0.001
    P_text='\itP\rm < 0.001';
end
sig_text=['Slope = ' num2str(slope) ' gC m^{-2} °C^{-1}'];
res_text=[sig_text,', ' P_text];

text('string',res_text,'Units','normalized','position',[0.970196620445752,0.924693139221602,0],'FontName','Arial','FontSize',8,'HorizontalAlignment','right')

x_fit = min(group_gpp_idx-5)-0.5:0.1:max(group_gpp_idx-5)+0.5;
y_fit = slope * x_fit + intercept;

% 绘制红色虚线拟合回归线
plot(x_fit, y_fit, 'r-', 'LineWidth', 1);

% 3. 坐标轴设置
set(gca, 'XTick', -4:6, 'XLim', [-5, 7]);
set(gca, 'YTick', -120:60:120, 'YLim', [-120, 120]);
set(gca, 'XTickLabel', {'[-4,-3]','[-3,-2]','[-2,-1]','[-1,0]','[0,1]','[1,2]',...
                        '[2,3]','[3,4]','[4,5]','[5,6]','[6,7]'}, ...
         'FontName', 'Arial', 'FontSize', 8);
xtickangle(40);

% 4. 美化整体外观
box off;
% title('Inversions','FontName','Arial','FontSize',10)
xlabel('\itT\rm_{summer} – \itT\rm^{GPP}_{opt} (°C)','FontName','Arial','FontSize',9)
ylabel('GPP anomaly (gC m^{-2})','FontName','Arial','FontSize',9)
text('string','f','Units','normalized','position',[-0.143217992884015,1.064756952752133,0],'FontName','Arial','FontSize',14,'fontweight','bold')


nexttile
hold on
fill([-5, -0.5, -0.5, -5], ...
             [-200, -200, 200, 200], ...
             [182 215 232]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
fill([-0.5, 15, 15, -0.5], ...
             [-200, -200, 200, 200], ...
             [246 178 147]/255, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
% 2. 绘制箱线图 - 使用协调的深色
% 深灰蓝色作为箱体颜色
box_color = [0.2 0.2 0.2];

h = boxchart(group_ter_idx-5, all_ter_data, ...
    'BoxFaceColor', box_color, ...
    'MarkerColor', box_color, ...
    'BoxWidth', 0.65);

% 隐藏箱线图中的异常值标记（因为已经用swarmchart显示了）
h.MarkerStyle = 'none';
% h.LineWidth = 0.5;         % 适当加粗线条

yline(0, '--', 'Color', 'k', 'LineWidth', 1.2); % 灰色 0 基准线

cc=ta_ter_vec;
cc(cc<-4)=nan;
cc(cc>7)=nan;

lm = fitlm(cc,ter_anom_vec);
slope = lm.Coefficients.Estimate(2);       % 斜率
P_value = lm.Coefficients.pValue(2);         % 斜率的 p 值
slope=roundn(slope,-2);
intercept = lm.Coefficients.Estimate(1);   % 截距

if P_value>0.05
    P_text='ns';
elseif P_value<=0.05 & P_value>0.01
    P_text='\itP\rm < 0.05';
elseif P_value<=0.001
    P_text='\itP\rm < 0.001';
end
sig_text=['Slope = ' num2str(slope) ' gC m^{-2} °C^{-1}'];
res_text=[sig_text,', ' P_text];

text('string',res_text,'Units','normalized','position',[0.970196620445752,0.924693139221602,0],'FontName','Arial','FontSize',8,'HorizontalAlignment','right')

x_fit = min(group_ter_idx-5)-0.5:0.1:max(group_ter_idx-5)+0.5;
y_fit = slope * x_fit + intercept;

% 绘制红色虚线拟合回归线
plot(x_fit, y_fit, 'r-', 'LineWidth', 1);


% 3. 坐标轴设置
set(gca, 'XTick', -4:6, 'XLim', [-5, 7]);
set(gca, 'YTick', -120:60:120, 'YLim', [-120, 120]);
set(gca, 'XTickLabel', {'[-4,-3]','[-3,-2]','[-2,-1]','[-1,0]','[0,1]','[1,2]',...
                        '[2,3]','[3,4]','[4,5]','[5,6]','[6,7]'}, ...
         'FontName', 'Arial', 'FontSize', 8);
xtickangle(40);

% 4. 美化整体外观
box off;
% title('Inversions','FontName','Arial','FontSize',10)
xlabel('\itT\rm_{summer} – \itT\rm^{TER}_{opt} (°C)','FontName','Arial','FontSize',9)
ylabel('TER anomaly (gC m^{-2})','FontName','Arial','FontSize',9)
text('string','g','Units','normalized','position',[-0.143217992884015,1.064756952752133,0],'FontName','Arial','FontSize',14,'fontweight','bold')

result=['E:\phd_file\Climate_extremes\Result\V5\NH_flux_Topt_boxplot.png']
% print(result,ff,'-r600','-dpng'); 
