%% GCB2025 碳通量处理 (2015-2024) - 夏季(6-8月)累加精简版
clc; clear;

% 1. 配置定义
gcb_info = {'CMS-Flux','CMSF'; 'CAMS','CAMS'; 'GONGGA','GONGGA'; 'COLA','COLA'; ...
            'GCASv2','GCASv2'; 'NTFVAR','NTFVAR'; 'THU','THU'; 'NISMON-CO2-GOSAT','NISMON-GOSAT'};
gcb_root = 'E:\phd_file\Climate_extremes\GCB2025\ensemble_result\';
fire_base = 'E:\phd_file\Climate_extremes\Fire_emission\mean_value\month\';
gpp_sat_base = 'E:\phd_file\Climate_extremes\GPP\FluxSat\monthly\1degree\';
gpp_sif_base = 'E:\phd_file\Climate_extremes\GPP\GOSIF\monthly\1degree\';

years = 2015:2024;
num_years = length(years);

%% 2. 读取 GCB2025 NBE 8套成员并计算夏季(7-8月)累加
fprintf('正在读取 GCB2025 NBE 成员数据并计算夏季总量...\n');
% 成员季节性矩阵 [180, 360, 10, 8]
GCB2025_NBE_seasonal = nan(180, 360, num_years, 8);

for mdl = 1:8
    for y_idx = 1:num_years
        y = years(y_idx);
        % 构建7月和8月路径
        tif7 = sprintf('%s%s\\month\\%s_NBE_%d_7.tif', gcb_root, gcb_info{mdl,1}, gcb_info{mdl,2}, y);
        tif8 = sprintf('%s%s\\month\\%s_NBE_%d_8.tif', gcb_root, gcb_info{mdl,1}, gcb_info{mdl,2}, y);
        tif6 = sprintf('%s%s\\month\\%s_NBE_%d_6.tif', gcb_root, gcb_info{mdl,1}, gcb_info{mdl,2}, y);
        
        if exist(tif7, 'file') && exist(tif8, 'file')
            m6 = double(importdata(tif6));
            m7 = double(importdata(tif7));
            m8 = double(importdata(tif8));          
            % 夏季总量为 7-8 月累加
            GCB2025_NBE_seasonal(:,:,y_idx,mdl) = m6 + m7 + m8;
        end
    end
    fprintf('  - 已完成模型: %s\n', gcb_info{mdl,1});
end

% 计算 NBE 集合均值夏季总量
GCB2025_NBE_Mean_seasonal = mean(GCB2025_NBE_seasonal, 4, 'omitnan');

%% 3. 读取外部 Fire 和 GPP 并计算夏季总量
fprintf('读取公共数据用于衍生变量计算...\n');
fire_seasonal = nan(180, 360, num_years);
gpp_seasonal_mean = nan(180, 360, num_years);

for y_idx = 1:num_years
    y = years(y_idx);
    
    % Fire 7-8月累加
    f6 = double(importdata(sprintf('%sFire_CO2_%d_6.tif', fire_base, y)));
    f7 = double(importdata(sprintf('%sFire_CO2_%d_7.tif', fire_base, y)));
    f8 = double(importdata(sprintf('%sFire_CO2_%d_8.tif', fire_base, y)));
    fire_seasonal(:,:,y_idx) = f6 + f7 + f8;
    
    % GPP (2套均值) 7-8月累加
    g1_6 = double(importdata(sprintf('%sGPP_FluxSat_%d_6.tif', gpp_sat_base, y)));
    g1_7 = double(importdata(sprintf('%sGPP_FluxSat_%d_7.tif', gpp_sat_base, y)));
    g1_8 = double(importdata(sprintf('%sGPP_FluxSat_%d_8.tif', gpp_sat_base, y)));

    g2_6 = double(importdata(sprintf('%sGPP_GOSIF_%d_6.tif', gpp_sif_base, y)));
    g2_7 = double(importdata(sprintf('%sGPP_GOSIF_%d_7.tif', gpp_sif_base, y)));
    g2_8 = double(importdata(sprintf('%sGPP_GOSIF_%d_8.tif', gpp_sif_base, y)));
    gpp_seasonal_mean(:,:,y_idx) = ( (g1_6 + g1_7 + g1_8) + (g2_6 + g2_7 + g2_8) ) / 2;
end

%% 4. 计算衍生变量 (NEE = NBE - Fire, TER = GPP + NEE)
GCB2025_NEE_Mean_seasonal = GCB2025_NBE_Mean_seasonal - fire_seasonal;
GCB2025_TER_Mean_seasonal = gpp_seasonal_mean + GCB2025_NEE_Mean_seasonal;

%% 5. 去趋势处理与结果保存
% A. 处理 NBE 成员矩阵
GCB2025_NBE_detrend = nan(size(GCB2025_NBE_seasonal));
for mdl = 1:8
    for i = 1:180
        for j = 1:360
            ts = squeeze(GCB2025_NBE_seasonal(i,j,:,mdl));
            if sum(~isnan(ts)) > 2, GCB2025_NBE_detrend(i,j,:,mdl) = detrend(ts); end
        end
    end
end
save('GCB2025_NBE_seasonal.mat', 'GCB2025_NBE_seasonal', '-v7.3');
save('GCB2025_NBE_detrend.mat', 'GCB2025_NBE_detrend', '-v7.3');

% B. 处理集合均值变量
vars = {GCB2025_NBE_Mean_seasonal, 'GCB2025_NBE_Mean';
        GCB2025_NEE_Mean_seasonal, 'GCB2025_NEE_Mean';
        GCB2025_TER_Mean_seasonal, 'GCB2025_TER_Mean'};

for k = 1:size(vars, 1)
    seasonal_data = vars{k,1};
    detrend_data = nan(180, 360, num_years);
    for i = 1:180
        for j = 1:360
            ts = squeeze(seasonal_data(i,j,:));
            if sum(~isnan(ts)) > 2, detrend_data(i,j,:) = detrend(ts); end
        end
    end
    
    s_n = [vars{k,2}, '_seasonal']; d_n = [vars{k,2}, '_detrend'];
    eval([s_n, ' = seasonal_data;']); eval([d_n, ' = detrend_data;']);
    save([s_n, '.mat'], s_n); save([d_n, '.mat'], d_n);
end

disp('GCB2025 夏季(6-8月)碳通量累加处理全部完成！');