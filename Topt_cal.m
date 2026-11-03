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

%% GCB2025
% 1. 路径与配置定义
gcb_info = {'CMS-Flux','CMSF'; 'CAMS','CAMS'; 'GONGGA','GONGGA'; 'COLA','COLA'; ...
            'GCASv2','GCASv2'; 'NTFVAR','NTFVAR'; 'THU','THU'; 'NISMON-CO2-GOSAT','NISMON-GOSAT'};
gcb_root = 'E:\phd_file\Climate_extremes\GCB2025\ensemble_result\';
fire_base = 'E:\phd_file\Climate_extremes\Fire_emission\mean_value\month\';
gpp_sat_base = 'E:\phd_file\Climate_extremes\GPP\FluxSat\monthly\1degree\';
gpp_sif_base = 'E:\phd_file\Climate_extremes\GPP\GOSIF\monthly\1degree\';


% 2. 读取 GCB2025 NBE (8套集合成员)
fprintf('正在读取 GCB2025 NBE 8套成员月尺度数据...\n');
all_gcb_nbe_monthly = nan(180, 360, 120, 8);
for mdl = 1:8
    idx = 1;
    for y = 2015:2024
        for m = 1:12
            tif_file = sprintf('%s%s\\month\\%s_NBE_%d_%d.tif', gcb_root, gcb_info{mdl,1}, gcb_info{mdl,2}, y, m);
            if exist(tif_file, 'file')
                all_gcb_nbe_monthly(:,:,idx,mdl) = double(importdata(tif_file));
            else
                warning('文件缺失: %s', tif_file);
            end
            idx = idx + 1;
        end
    end
    fprintf('  - 已完成模型: %s\n', gcb_info{mdl,1});
end
% 计算集合均值 (月尺度保持均值，后续季节处理再累加)
gcb_nbe_mean_monthly = mean(all_gcb_nbe_monthly, 4, 'omitnan');

% 3. 读取用于推算的公共 Fire 和 GPP 均值
fprintf('读取公共 Fire/GPP 月尺度数据用于 NEE/TER 推算...\n');
fire_ext_monthly = nan(180, 360, 120); 
all_gpp_monthly = nan(180, 360, 120, 2);
idx = 1;
for y = 2015:2024
    for m = 1:12
        fire_ext_monthly(:,:,idx) = double(importdata(sprintf('%sFire_CO2_%d_%d.tif', fire_base, y, m)));
        all_gpp_monthly(:,:,idx,1) = double(importdata(sprintf('%sGPP_FluxSat_%d_%d.tif', gpp_sat_base, y, m)));
        all_gpp_monthly(:,:,idx,2) = double(importdata(sprintf('%sGPP_GOSIF_%d_%d.tif', gpp_sif_base, y, m)));
        idx = idx + 1;
    end
end
gpp_mean_monthly = mean(all_gpp_monthly, 4, 'omitnan');

% 4. 计算基于 GCB2025 集合均值的衍生变量 (月尺度)
gcb_nee_mean_monthly = gcb_nbe_mean_monthly - fire_ext_monthly;
gcb_ter_mean_monthly = gpp_mean_monthly + gcb_nee_mean_monthly;
%% TRENDY
% 1. 模型列表定义
models = {'CABLE-POP', 'CARDAMOM', 'CLASSIC', 'DLEM', 'EDv3', 'GDSTEM', ...
          'iMAPLE', 'IBIS', 'ISAM', 'JULES', 'LPJ-EOSIM', 'LPJmL', ...
          'LPX-Bern', 'ORCHIDEE', 'SDGVM', 'VISIT', 'VISIT-UT'};
      
root_path = 'E:\phd_file\Climate_extremes\TRENDY\';
num_models = length(models);

% 2. 预分配 5D 集合异常矩阵 [180, 360, 10年, 3个月, 模型数]
fprintf('正在初始化 TRENDY 5D 矩阵...\n');
% TRENDY_GPP_5D = nan(180, 360, 10, 3, num_models);
% TRENDY_TER_5D = nan(180, 360, 10, 3, num_models);
% TRENDY_NEE_5D = nan(180, 360, 10, 3, num_models);

% 3. 逐个模型循环处理
for m = 1:num_models
    model_name = models{m};
    fprintf('正在处理 TRENDY 模型 [%d/%d]: %s\n', m, num_models, model_name);
    
    gpp_monthly = nan(180, 360, 120);
    ter_monthly = nan(180, 360, 120);
    
    idx = 1;
    for y = 2015:2024
        for mon = 1:12
            gpp_file = sprintf('%s%s\\GPP\\month\\%s_GPP_%d_%d.tif', root_path, model_name, model_name, y, mon);
            ter_file = sprintf('%s%s\\TER\\month\\%s_TER_%d_%d.tif', root_path, model_name, model_name, y, mon);
            
            if exist(gpp_file, 'file') && exist(ter_file, 'file')
                gpp_monthly(:,:,idx) = double(importdata(gpp_file));
                ter_monthly(:,:,idx) = double(importdata(ter_file));
            end
            idx = idx + 1;
        end
    end
        
    TRENDY_GPP_5D(:,:,:,:,m) = gpp_monthly;
    TRENDY_TER_5D(:,:,:,:,m) = ter_monthly;
end

% 4. 计算集合平均 (Multi-model Mean)
fprintf('正在计算 TRENDY 集合平均...\n');
TRENDY_GPP_Mean = mean(TRENDY_GPP_5D, 5, 'omitnan');
TRENDY_TER_Mean = mean(TRENDY_TER_5D, 5, 'omitnan');

%% TROPOMI
i=1;
for year =2019:2024
    for month =1:12
        SIF_monthly(:,:,i)=importdata(['E:\phd_file\Tropical_2024\SIF\TROPOMI\month\1degree\SIF_' num2str(year) '_' num2str(month) '.tif']);
    i=i+1;
    end
end
% temperature
i=1;
for year =2019:2024
    for month =1:12
        Tem_monthly(:,:,i)=importdata(['E:\phd_file\Climate_extremes\Air_temperature\ERA5-land\monthly\ERA5_land_air_temperature\ERA5_land_air_temperature_' num2str(year) '_' num2str(month) '.tif']);
    i=i+1;
    end
end

%% temperature
i=1;
for year =2015:2024
    for month =1:12
        Tem_monthly(:,:,i)=importdata(['E:\phd_file\Climate_extremes\Air_temperature\ERA5-land\monthly\ERA5_land_air_temperature\ERA5_land_air_temperature_' num2str(year) '_' num2str(month) '.tif']);
    i=i+1;
    end
end

%%
[GCB_Topt_TER, GCB_Mask_no_Topt_TER] = calculate_Topt(Tem_monthly, gcb_ter_mean_monthly);
[GCB_Topt_GPP, GCB_Mask_no_Topt_GPP] = calculate_Topt(Tem_monthly, gpp_mean_monthly);
[TDY_Topt_TER, TDY_Mask_no_Topt_TER] = calculate_Topt(Tem_monthly, TRENDY_TER_Mean);
[TDY_Topt_GPP, TDY_Mask_no_Topt_GPP] = calculate_Topt(Tem_monthly, TRENDY_GPP_Mean);

[GCB_Topt_SIF, GCB_Mask_no_Topt_SIF] = calculate_Topt(Tem_monthly, SIF_monthly);

save GCB_Topt_TER.mat GCB_Topt_TER GCB_Mask_no_Topt_TER
save TRENDY_Topt_TER.mat TDY_Topt_TER TDY_Mask_no_Topt_TER

save GCB_Topt_GPP.mat GCB_Topt_GPP GCB_Mask_no_Topt_GPP
save TRENDY_Topt_GPP.mat TDY_Topt_GPP TDY_Mask_no_Topt_GPP

save GCB_Topt_SIF.mat GCB_Topt_SIF GCB_Mask_no_Topt_SIF
%%
[Sens_Ratio, GCB_AUC, TRENDY_AUC] = calculate_TER_Sensitivity_Diff(Tem_monthly, gcb_ter_mean_monthly, TRENDY_TER_Mean);

%% GOME2
clc
clear
i=1;
for year =2015:2023
    for month =1:12
        SIF_monthly(:,:,i)=importdata(['E:\phd_file\Climate_extremes\SIF\GOME2\1degree\SIF_' num2str(year) '_' num2str(month,'%02d') '.tif']);
    i=i+1;
    end
end
% temperature
i=1;
for year =2015:2023
    for month =1:12
        Tem_monthly(:,:,i)=importdata(['E:\phd_file\Climate_extremes\Air_temperature\ERA5-land\monthly\ERA5_land_air_temperature\ERA5_land_air_temperature_' num2str(year) '_' num2str(month) '.tif']);
    i=i+1;
    end
end

[GOME_Topt_SIF, GOME_Mask_no_Topt_SIF] = calculate_Topt(Tem_monthly, SIF_monthly);
save GOME_Topt_SIF.mat GOME_Topt_SIF GOME_Mask_no_Topt_SIF