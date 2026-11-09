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

load('rzsm_detrend.mat');      
load('rzsm_seasonal.mat');     
load('vpd_detrend.mat');       
load('par_detrend.mat');       
load('pre_detrend.mat');       
load('tmp_detrend.mat')

mask_list = {Northern_mask, Temperate_mask, ABZ_mask};
reg_names = {'Northern', 'Temperate', 'Boreal'};
area_factor = area_grid / 10^15; % 用于将总量转化为 GtC yr^-1
% 计算每个像素点的野火排放时间序列的标准差 (用于 4 sigma 判定门槛)
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');
% 4. 预分配结果
GCB_NEE_Ex_Anom = nan(180, 360);
GCB_GPP_Ex_Anom = nan(180, 360);
GCB_TER_Ex_Anom = nan(180, 360);
TMP_Ex_Anom  = nan(180, 360);
RZSM_Ex_Anom = nan(180, 360); 
VPD_Ex_Anom  = nan(180, 360);
SR_Ex_Anom   = nan(180, 360);
PRE_Ex_Anom  = nan(180, 360);


% 🌟 结果矩阵预分配
Summer_GCB_Ex_Result_total = nan(3, 3); % 总量最优估计 [NEE, GPP, TER] (GtC yr^-1)
Summer_GCB_Ex_Std_total    = nan(3, 3); % 总量不确定性 [NEE, GPP, TER] (GtC yr^-1)
Summer_GCB_Ex_Unit_Result  = nan(3, 3); % 单位面积最优估计 [NEE, GPP, TER] (gC m^-2 yr^-1)
Summer_GCB_Ex_Unit_Std    = nan(3, 3); % 单位面积不确定性 [NEE, GPP, TER] (gC m^-2 yr^-1)
rzs_base = mean(rzsm_seasonal, 3, 'omitnan');
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
                TMP_Ex_Anom(i,j) = mean(tmp_detrend(i,j,is_valid_year), 'omitnan');
                VPD_Ex_Anom(i,j) = mean(vpd_detrend(i,j,is_valid_year), 'omitnan');
                SR_Ex_Anom(i,j)  = mean(par_detrend(i,j,is_valid_year), 'omitnan');
                PRE_Ex_Anom(i,j) = mean(pre_detrend(i,j,is_valid_year), 'omitnan');

                % 2. RZSM 百分比计算
                anom_val_avg = mean(rzsm_detrend(i,j,is_valid_year), 'omitnan');
                base_val     = rzs_base(i,j);

                if base_val > 0.001
                    RZSM_Ex_Anom(i,j) = (anom_val_avg / base_val) * 100;
                end
            end
        end
    end
end

load('tmp_seasonal.mat'); % 假设其维度为 [180, 360, 10] 或类似，代表近10年夏季温度
Mean_Temp_Recent = mean(tmp_seasonal(:,:,end-9:end), 3, 'omitnan'); 

for year=2015:2024

    AET_summer_list(:,:,year-2014)=importdata(['E:\phd_file\Climate_extremes\WAI\AET\Terra_climate_AET\Terra_climate_AET_' num2str(year) '_6.tif'])+...
        importdata(['E:\phd_file\Climate_extremes\WAI\AET\Terra_climate_AET\Terra_climate_AET_' num2str(year) '_7.tif'])+...
        importdata(['E:\phd_file\Climate_extremes\WAI\AET\Terra_climate_AET\Terra_climate_AET_' num2str(year) '_8.tif']);
 
    PRE_summer_list(:,:,year-2014)=importdata(['E:\phd_file\Climate_extremes\WAI\PRE\Terra_climate_Pre\Terra_climate_PRE_' num2str(year) '_6.tif'])+...
        importdata(['E:\phd_file\Climate_extremes\WAI\PRE\Terra_climate_Pre\Terra_climate_PRE_' num2str(year) '_7.tif'])+...
        importdata(['E:\phd_file\Climate_extremes\WAI\PRE\Terra_climate_Pre\Terra_climate_PRE_' num2str(year) '_8.tif']);

    LAI_summer_list(:,:,year-2014)=importdata(['E:\phd_file\Amazon_2023_24\LAI\Modis_LAI\1degree\MODIS_LAI_' num2str(year) '_6.tif'])+...
        importdata(['E:\phd_file\Amazon_2023_24\LAI\Modis_LAI\1degree\MODIS_LAI_' num2str(year) '_7.tif'])+...
        importdata(['E:\phd_file\Amazon_2023_24\LAI\Modis_LAI\1degree\MODIS_LAI_' num2str(year) '_8.tif']);
end

Mean_WAI_Recent = nanmean(AET_summer_list,3)-nanmean(PRE_summer_list,3);
Mean_LAI = nanmean(LAI_summer_list,3);

SOC = importdata("E:\phd_file\Climate_extremes\Soil_proporty\Soil_C\Soil_C_combine.tif"); 
Soil_N = importdata("E:\phd_file\Climate_extremes\Soil_proporty\Soil_N\Soil_N_combine.tif");
Species_richness = importdata("E:\phd_file\Climate_extremes\species_richness\species_richness_1deg.tif");
Soil_clay = importdata("E:\phd_file\Climate_extremes\Soil_proporty\Soil_Caly\Soil_Clay_combine.tif");
Tree_cover = importdata("E:\phd_file\Climate_extremes\Tree_cover\Tree_cover_combine.tif");
Canopy_height = importdata("E:\phd_file\Climate_extremes\canopy_hight\height_1deg.tif");
Root_depth = importdata("E:\phd_file\Climate_extremes\Root_depth\MRD_1deg.tif");


%%
Boreal_GCB_NEE_Ex_Anom=GCB_NEE_Ex_Anom.*Northern_mask;
Boreal_GCB_GPP_Ex_Anom=GCB_GPP_Ex_Anom.*Northern_mask;
Boreal_GCB_TER_Ex_Anom=GCB_TER_Ex_Anom.*Northern_mask;

Boreal_TMP_Ex_Anom=TMP_Ex_Anom.*Northern_mask;
Boreal_VPD_Ex_Anom=VPD_Ex_Anom.*Northern_mask;
Boreal_SR_Ex_Anom=SR_Ex_Anom.*Northern_mask;
Boreal_RZSM_Ex_Anom=RZSM_Ex_Anom.*Northern_mask;
Boreal_Mean_LAI=Mean_LAI.*Northern_mask;
Boreal_Mean_Temp_Recent=Mean_Temp_Recent.*Northern_mask;
Boreal_Mean_WAI_Recent=Mean_WAI_Recent.*Northern_mask;
Boreal_SOC=SOC.*Northern_mask;
Boreal_Soil_N=Soil_N.*Northern_mask;
Boreal_Species_richness=Species_richness.*Northern_mask;
Boreal_Soil_clay=Soil_clay.*Northern_mask;
Boreal_Tree_cover=Tree_cover.*Northern_mask;
Boreal_Canopy_height=Canopy_height.*Northern_mask;
Boreal_Root_depth=Root_depth.*Northern_mask;


Boreal_variable=[Boreal_Mean_Temp_Recent(:),Boreal_Mean_WAI_Recent(:),Boreal_TMP_Ex_Anom(:),...
    Boreal_RZSM_Ex_Anom(:),Boreal_VPD_Ex_Anom(:),Boreal_SR_Ex_Anom(:),Boreal_SOC(:),...
    Boreal_Soil_N(:),Boreal_Species_richness(:),Boreal_Soil_clay(:),Boreal_Tree_cover(:),...
    Boreal_Canopy_height(:),Boreal_Root_depth(:)];

Boreal_variable_new=Boreal_variable(~any(isnan(Boreal_variable), 2),:);

Boreal_GCB_NEE_Ex_Anom=Boreal_GCB_NEE_Ex_Anom(:);
Boreal_GCB_NEE_Ex_Anom_new=Boreal_GCB_NEE_Ex_Anom(~any(isnan(Boreal_variable), 2),:);

Boreal_GCB_GPP_Ex_Anom=Boreal_GCB_GPP_Ex_Anom(:);
Boreal_GCB_GPP_Ex_Anom_new=Boreal_GCB_GPP_Ex_Anom(~any(isnan(Boreal_variable), 2),:);

Boreal_GCB_TER_Ex_Anom=Boreal_GCB_TER_Ex_Anom(:);
Boreal_GCB_TER_Ex_Anom_new=Boreal_GCB_TER_Ex_Anom(~any(isnan(Boreal_variable), 2),:);

%% 参数初始化
nTree = 400;
nLeaf = 10;
num_runs = 50; % 随机运行次数

% 1. 特征名称列表
varname = {'MAT','WAI','del_T','del_RZSM','del_VPD','del_SR','SOC', ...
           'Soil_N','Species_richness','Soil_clay','Tree_cover','Canopy_height','Root_depth'};
num_vars = length(varname);

% 2. 打包两个因变量，方便循环处理
targets = struct();
targets(1).name = 'GPP Anomaly (Boreal GCB GPP Ex Anom)';
targets(1).data = Boreal_GCB_GPP_Ex_Anom_new;

targets(2).name = 'TER Anomaly (Boreal GCB TER Ex Anom)';
targets(2).data = Boreal_GCB_TER_Ex_Anom_new;

num_targets = length(targets);

% 保存最终结果的结构体
results = struct();

% 循环处理两个因变量
for t = 1:num_targets
    target_name = targets(t).name;
    y_true = targets(t).data;
    SS_tot = sum((y_true - mean(y_true, 'omitnan')).^2);
    
    importance_all = zeros(num_runs, num_vars);
    r2_all = zeros(num_runs, 1);
    
    fprintf('====================================================\n');
    fprintf('正在处理因变量 [%d/%d]: %s ...\n', t, num_targets, target_name);
    fprintf('====================================================\n');
    
    % 100 次随机训练
    for k = 1:num_runs
        model = TreeBagger(nTree, Boreal_variable_new, y_true, ...
            'Method', 'regression', ...
            'OOBPredictorImportance', 'on', ...
            'MinLeafSize', nLeaf);
        
        % 提取重要性并归一化为百分比 (%)
        imp = model.OOBPermutedPredictorDeltaError;
        importance_all(k, :) = (imp / sum(imp)) * 100;
        
        % 计算 OOB R^2
        y_pred = oobPredict(model);
        SS_res = sum((y_true - y_pred).^2, 'omitnan');
        r2_all(k) = 1 - (SS_res / SS_tot);
        
        if mod(k, 20) == 0
            fprintf('  已完成 %d / %d 次训练...\n', k, num_runs);
        end
    end
    
    % 统计均值、标准差与最高 R^2
    [max_r2, best_idx] = max(r2_all);
    mean_r2 = mean(r2_all);
    mean_imp = mean(importance_all, 1);
    std_imp  = std(importance_all, 0, 1);
    
    % 存入结果结构体
    results(t).name = target_name;
    results(t).mean_imp = mean_imp;
    results(t).std_imp = std_imp;
    results(t).max_r2 = max_r2;
    results(t).mean_r2 = mean_r2;
    results(t).best_idx = best_idx;
    
    fprintf('--> 完成！最高 R^2 = %.4f (第 %d 次), 平均 R^2 = %.4f\n\n', ...
        max_r2, best_idx, mean_r2);
end

%%
save RF_output.mat results
