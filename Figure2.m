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
tmp_678_raw = nan(180, 360, num_years);

fprintf('正在读取 1985-2024 气候态气温数据...\n');
for y = 1:num_years
    curr_year = years_all(y);
    ft6 = sprintf('%sERA5_land_air_temperature_%d_6.tif', temp_path, curr_year);
    ft7 = sprintf('%sERA5_land_air_temperature_%d_7.tif', temp_path, curr_year);
    ft8 = sprintf('%sERA5_land_air_temperature_%d_8.tif', temp_path, curr_year);
    if exist(ft6,'file') && exist(ft7,'file') && exist(ft8,'file')
        tmp_678_raw(:,:,y) = (double(importdata(ft6)) + double(importdata(ft7)) + double(importdata(ft8))) / 3;
    end
end

tmp_678_anom = nan(180, 360, num_years);
for i = 1:180
    for j = 1:360
        ts_t = squeeze(tmp_678_raw(i,j,:));
        if ~any(isnan(ts_t)), tmp_678_anom(i,j,:) = detrend(ts_t, 'linear'); end
    end
end
T_Thr_80th = prctile(tmp_678_anom, 80, 3); 
tmp_recent_anom = tmp_678_anom(:,:,end-9:end); % 最近 10 年 (2015-2024)

% 3. 加载通量与水分、野火矩阵数据 (2015-2024)
load('GCB2025_NEE_Mean_detrend.mat');    % [180,360,10]
load('GPP_Mean_detrend.mat');            % [180,360,10]
load('GCB2025_TER_Mean_detrend.mat');    % [180,360,10]
load('GCB2025_NBE_detrend.mat');         % [180,360,10,8] 8个成员
load('GPP_detrend.mat');                 % [180,360,10,2] 2个成员
load('long_term_Fire_detrend.mat');      % [180,360,10]
load('Fire_detrend.mat');                % [180,360,10] 野火异常计算用
load('rzsm_detrend.mat');                % [180,360,10]
load('rzsm_seasonal.mat');               % [180,360,3] 季节循环

mask_list = {Northern_mask, Temperate_mask, ABZ_mask};
reg_names = {'Northern', 'Temperate', 'Boreal'};
area_factor = area_grid / 10^15;

% 计算野火排放标准差
Fire_STD_Map = std(long_term_Fire_detrend, 0, 3, 'omitnan');
% 计算 RZSM 气候态基准
rzs_base = mean(rzsm_seasonal, 3, 'omitnan');

% 3. 预分配参数与三维空间结果矩阵 (6个水分范围)
bin_edges = [inf, 0, -5, -10, -15, -20, -inf];
num_bins = 6;
bin_names = {'dRZSM > 0%', '-5% < dRZSM <= 0%', ...
             '-10% < dRZSM <= -5%', 'dRZSM <= -10%','-15% < dRZSM <= -5%', 'dRZSM <= -20%'};

% 👉 空间矩阵输出结果：维度为 [180, 360, 6]
GCB_NEE_Bin_Maps = nan(180, 360, num_bins);
GCB_GPP_Bin_Maps = nan(180, 360, num_bins);
GCB_TER_Bin_Maps = nan(180, 360, num_bins);

% 为了后续计算多模式成员不确定性，需要把像素按年份分配的中间矩阵存下来
% 空间多维矩阵：第4维为10年
Grid_NEE_Yr_Bin = nan(180, 360, 10, num_bins); 
Grid_Fire_Yr_Bin = nan(180, 360, 10, num_bins);
Grid_NBE_M_Yr_Bin = nan(180, 360, 10, 8, num_bins); % 8个NBE成员
Grid_GPP_G_Yr_Bin = nan(180, 360, 10, 2, num_bins); % 2个GPP成员

% 4. 逐像素、逐极端年份科学拆分与空间映射
fprintf('开始执行复合极端年份识别，并根据 RZSM 变幅对碳通量及各模式成员进行空间拆分...\n');
for i = 1:180
    for j = 1:360
        t_thr = T_Thr_80th(i,j);
        b_val = rzs_base(i,j);
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
        valid_years_idx = find(is_valid_year); 
        if isempty(valid_years_idx), continue; end
        
        % 建立当前像素在 4个区间的数据收集桶
        bin_nee = cell(num_bins, 1); bin_gpp = cell(num_bins, 1); bin_ter = cell(num_bins, 1);
        
        % 逐个转化有效极端年
        for y_idx = valid_years_idx'
            % 转换当前年份的水分百分比
            yr_rzsm_pct = (rzsm_detrend(i,j,y_idx) / b_val) * 100;
            
            % 检索所属的水分 Bin
            for b = 1:num_bins
                if yr_rzsm_pct <= bin_edges(b) && yr_rzsm_pct > bin_edges(b+1)
                    % 1. 最优估计均值归类
                    bin_nee{b} = [bin_nee{b}; GCB2025_NEE_Mean_detrend(i,j,y_idx)];
                    bin_gpp{b} = [bin_gpp{b}; GPP_Mean_detrend(i,j,y_idx)];
                    bin_ter{b} = [bin_ter{b}; GCB2025_TER_Mean_detrend(i,j,y_idx)];
                    
                    % 2. 带有年份标签的精细容器归类（用于后续不确定性集成）
                    Grid_NEE_Yr_Bin(i,j,y_idx,b)  = GCB2025_NEE_Mean_detrend(i,j,y_idx);
                    Grid_Fire_Yr_Bin(i,j,y_idx,b) = Fire_detrend(i,j,y_idx);
                    
                    for m = 1:8
                        Grid_NBE_M_Yr_Bin(i,j,y_idx,m,b) = GCB2025_NBE_detrend(i,j,y_idx,m);
                    end
                    for g = 1:2
                        Grid_GPP_G_Yr_Bin(i,j,y_idx,g,b) = GPP_detrend(i,j,y_idx,g);
                    end
                    break; 
                end
            end
        end
        
        % 将计算好的多年平均填入空间矩阵
        for b = 1:num_bins
            if ~isempty(bin_nee{b})
                GCB_NEE_Bin_Maps(i,j,b) = mean(bin_nee{b}, 'omitnan');
                GCB_GPP_Bin_Maps(i,j,b) = mean(bin_gpp{b}, 'omitnan');
                GCB_TER_Bin_Maps(i,j,b) = mean(bin_ter{b}, 'omitnan');
            end
        end
    end
end
disp('👉 空间矩阵结果 [180x360x6] 计算并存储完毕！');
% 5. 区域统计与多成员误差传递集成
% 初始化区域结果存储单元
Summer_GCB_Ex_Result_Bins = cell(3, 1); 

for r = 1:3
    curr_mask = mask_list{r};
    fprintf('\n==================== 正在计算区域: %s ====================\n', reg_names{r});
    
    % 创建当前区域的统计表格
    RegTable = table('Size', [num_bins, 8], ...
        'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
        'VariableNames', {'RZSM_Range', 'NEE_Ex_Anom', 'NEE_Std', 'GPP_Ex_Anom', 'GPP_Std', 'TER_Ex_Anom', 'TER_Std', 'Area'});
    
    for b = 1:num_bins
        % A. 最优估计的总量集成 (GtC summer-1)

        Area_sum = nansum(nansum(~isnan(GCB_NEE_Bin_Maps(:,:,b)) .* curr_mask .* area_grid));

        opt_nee = nansum(nansum(GCB_NEE_Bin_Maps(:,:,b) .* curr_mask .* area_factor));
        opt_gpp = nansum(nansum(GCB_GPP_Bin_Maps(:,:,b) .* curr_mask .* area_factor));
        opt_ter = nansum(nansum(GCB_TER_Bin_Maps(:,:,b) .* curr_mask .* area_factor));
        
        % B. 不确定性传递分项计算
        % 1. NBE 多模式成员标准差
        nbe_totals = nan(8,1);
        for m = 1:8
            % 提取当前Bin、当前成员下，各极端年份在空间掩膜内的总量均值
            tmp_yr_maps = squeeze(mean(Grid_NBE_M_Yr_Bin(:,:,:,m,b), 3, 'omitnan'));
            nbe_totals(m) = nansum(nansum(tmp_yr_maps .* curr_mask .* area_factor));
        end
        unc_nbe = std(nbe_totals, 'omitnan');
        if isnan(unc_nbe), unc_nbe = 0; end
        
        % 2. GPP 多模式成员标准差 (带 Bootstrap 扰动)
        gpp_totals = nan(2,1);
        for g = 1:2
            tmp_yr_maps = squeeze(mean(Grid_GPP_G_Yr_Bin(:,:,:,g,b), 3, 'omitnan'));
            gpp_totals(g) = nansum(nansum(tmp_yr_maps .* curr_mask .* area_factor));
        end
        if ~any(isnan(gpp_totals))
            unc_gpp = std(bootstrp(1000, @mean, gpp_totals));
        else
            unc_gpp = 0;
        end
        
        % 3. 野火不确定性估计 (20% 门槛误差)
        avg_fire_map = squeeze(mean(Grid_Fire_Yr_Bin(:,:,:,b), 3, 'omitnan'));
        opt_fire = nansum(nansum(avg_fire_map .* curr_mask .* area_factor));
        unc_fire = abs(opt_fire) * 0.20;
        
        % 4. 严谨的系统误差平方和传递
        std_gcb_nee = sqrt(unc_nbe^2 + unc_fire^2);
        std_gcb_ter = sqrt(std_gcb_nee^2 + unc_gpp^2);
        
        
        % 填入表格
        RegTable(b, :) = {bin_names{b}, opt_nee, std_gcb_nee, opt_gpp, unc_gpp, opt_ter, std_gcb_ter, Area_sum};
    end
    
    disp(RegTable);
    Summer_GCB_Ex_Result_Bins{r} = RegTable;
end

disp('================================================================');
disp('所有水分梯度下的空间矩阵输出与区域误差传递集成全部计算完成！');

%%
customColors = [
    253, 217, 119;
    254, 177, 76;
    253, 141, 61;
    252, 78, 41;
    227, 26, 28;
    177, 0, 37]/255;


load RF_output.mat
varname={'Summer temperature','Summer water availability','ΔTemperature','ΔRZSM','ΔVPD','ΔSR','Soil organic carbon','Soil nitrogen','Species richness','Soil clay','Tree cover','Canopy height','Root depth'};
num_vars = length(varname);

f=figure
t = tiledlayout(24,17);
t.TileSpacing = 'loose';
t.Padding = 'tight';
set(gcf,'unit','pixels','position',[999,167,964,773]);

nexttile([12,8])
[mean_imp_sorted, sort_idx] = sort(results(1).mean_imp, 'ascend');
std_imp_sorted = results(1).std_imp(sort_idx);
b1=barh(mean_imp_sorted,'FaceColor','flat', 'BarWidth', 0.65);
hold on;
errorbar(mean_imp_sorted, 1:num_vars, std_imp_sorted, 'horizontal', ...
        '.k', 'LineWidth', 1, 'CapSize', 3, 'Marker', 'none');
varname_sorted = varname(sort_idx);
xlim([0,13])
set(gca,'XTick', [0:3:14],'FontName','Arial','FontSize',10);
ylim([0.2,13.8])
yticks(1:num_vars);
set(gca,'YTickLabel',varname_sorted,'FontName','Arial','fontsize',10)
xlabel('Relative Importance for GPP anomaly (%)','FontName','Arial','fontsize',10);
% title('Satellite-derived GPP anomaly','FontName','Arial','FontSize',10)
% box off
b1.CData(13,:) = [103, 178, 227]/255;
b1.CData(12,:) = [103, 178, 227]/255;
b1.CData(11,:) = [103, 178, 227]/255;
b1.CData(10,:) = [103, 178, 227]/255;
b1.CData(9,:) = [108, 163, 54]/255;
b1.CData(8,:) = [103, 178, 227]/255;
b1.CData(7,:) = [108, 163, 54]/255;
b1.CData(6,:) = [103, 178, 227]/255;
b1.CData(5,:) = [217, 217, 215]/255;
b1.CData(4,:) = [108, 163, 54]/255;
b1.CData(3,:) = [217, 217, 215]/255;
b1.CData(2,:) = [108, 163, 54]/255;
b1.CData(1,:) = [217, 217, 215]/255;

R2=results(1).max_r2;
R2=roundn(R2,-2);
sig_text=['\itR\rm^2 = ' num2str(R2)];
text('string',sig_text,'Units','normalized','position',[0.703315857141422,0.069900820937924,0],'FontName','Arial','FontSize',10)
text('string','a','Units','normalized','position',[-0.527729532739703,0.998403029736279,0],'FontName','Arial','FontSize',14,'fontweight','bold')

nexttile([8,9])
bb = bar([Summer_GCB_Ex_Result_Bins{1, 1}{:,2}';Summer_GCB_Ex_Result_Bins{2, 1}{:,2}';Summer_GCB_Ex_Result_Bins{3, 1}{:,2}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    'FaceColor','flat'); hold on
box off

bb(1).CData = customColors(1,:);
bb(2).CData = customColors(2,:);
bb(3).CData = customColors(3,:);
bb(4).CData = customColors(4,:);
bb(5).CData = customColors(5,:);
bb(6).CData = customColors(6,:);

%分组误差棒
[M,N]=size([Summer_GCB_Ex_Result_Bins{1, 1}{:,2}';Summer_GCB_Ex_Result_Bins{2, 1}{:,2}';Summer_GCB_Ex_Result_Bins{3, 1}{:,2}']);
for i=1:N
    xx(:,i)=bb(i).XEndPoints';
end
h2=errorbar(xx(:,:),[Summer_GCB_Ex_Result_Bins{1, 1}{:,2}';Summer_GCB_Ex_Result_Bins{2, 1}{:,2}';Summer_GCB_Ex_Result_Bins{3, 1}{:,2}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    [Summer_GCB_Ex_Result_Bins{1, 1}{:,3}';Summer_GCB_Ex_Result_Bins{2, 1}{:,3}';Summer_GCB_Ex_Result_Bins{3, 1}{:,3}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],'LineStyle', 'none', 'Color', 'k', 'LineWidth',0.8,'CapSize',3,'Marker','none')
set(gca,'YTick', [-20:10:20],'YLim',[-20,20]);
set(gca,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
ylabel('NEE anomaly (gC m^{-2})','FontName','Arial','FontSize',10)
text('string','c','Units','normalized','position',[-0.142659004942238,1.01040226565111,0],'FontName','Arial','FontSize',14,'fontweight','bold')


nexttile([8,9])
bb = bar([Summer_GCB_Ex_Result_Bins{1, 1}{:,4}';Summer_GCB_Ex_Result_Bins{2, 1}{:,4}';Summer_GCB_Ex_Result_Bins{3, 1}{:,4}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    'FaceColor','flat'); hold on
box off

bb(1).CData = customColors(1,:);
bb(2).CData = customColors(2,:);
bb(3).CData = customColors(3,:);
bb(4).CData = customColors(4,:);
bb(5).CData = customColors(5,:);
bb(6).CData = customColors(6,:);

%分组误差棒
h2=errorbar(xx(:,:),[Summer_GCB_Ex_Result_Bins{1, 1}{:,4}';Summer_GCB_Ex_Result_Bins{2, 1}{:,4}';Summer_GCB_Ex_Result_Bins{3, 1}{:,4}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    [Summer_GCB_Ex_Result_Bins{1, 1}{:,5}';Summer_GCB_Ex_Result_Bins{2, 1}{:,5}';Summer_GCB_Ex_Result_Bins{3, 1}{:,5}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],'LineStyle', 'none', 'Color', 'k', 'LineWidth',0.8,'CapSize',3,'Marker','none')
set(gca,'YTick', [-70:35:70],'YLim',[-75,75]);
set(gca,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
ylabel('GPP anomaly (gC m^{-2})','FontName','Arial','FontSize',10)
text('string','d','Units','normalized','position',[-0.142659004942238,1.01040226565111,0],'FontName','Arial','FontSize',14,'fontweight','bold')


nexttile([12,8])
[mean_imp_sorted, sort_idx] = sort(results(2).mean_imp, 'ascend');
std_imp_sorted = results(2).std_imp(sort_idx);
b2=barh(mean_imp_sorted,'FaceColor','flat', 'BarWidth', 0.65);
hold on;
errorbar(mean_imp_sorted, 1:num_vars, std_imp_sorted, 'horizontal', ...
        '.k', 'LineWidth', 1, 'CapSize', 3, 'Marker', 'none');
varname_sorted = varname(sort_idx);
xlim([0,14])
set(gca,'XTick', [0:3:14],'FontName','Arial','FontSize',10);
ylim([0.2,13.8])
yticks(1:num_vars);
set(gca,'YTickLabel',varname_sorted,'FontName','Arial','fontsize',10)
xlabel('Relative Importance for TER anomaly (%)','FontName','Arial','fontsize',10);
% title('Reconstructed TER anomaly','FontName','Arial','FontSize',10)
% box off

b2.CData(13,:) = [103, 178, 227]/255;
b2.CData(12,:) = [103, 178, 227]/255;
b2.CData(11,:) = [103, 178, 227]/255;
b2.CData(10,:) = [103, 178, 227]/255;
b2.CData(9,:) = [103, 178, 227]/255;
b2.CData(8,:) = [103, 178, 227]/255;
b2.CData(7,:) = [217, 217, 215]/255;
b2.CData(6,:) = [217, 217, 215]/255;
b2.CData(5,:) = [108, 163, 54]/255;
b2.CData(4,:) = [217, 217, 215]/255;
b2.CData(3,:) = [108, 163, 54]/255;
b2.CData(2,:) = [108, 163, 54]/255;
b2.CData(1,:) = [108, 163, 54]/255;

R2=results(2).max_r2;
R2=roundn(R2,-2);
sig_text=['\itR\rm^2 = ' num2str(R2)];
text('string',sig_text,'Units','normalized','position',[0.703315857141422,0.069900820937924,0],'FontName','Arial','FontSize',10)
text('string','b','Units','normalized','position',[-0.527729532739703,0.998403029736279,0],'FontName','Arial','FontSize',14,'fontweight','bold')

nexttile([8,9])
bb = bar([Summer_GCB_Ex_Result_Bins{1, 1}{:,6}';Summer_GCB_Ex_Result_Bins{2, 1}{:,6}';Summer_GCB_Ex_Result_Bins{3, 1}{:,6}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    'FaceColor','flat'); hold on
box off

bb(1).CData = customColors(1,:);
bb(2).CData = customColors(2,:);
bb(3).CData = customColors(3,:);
bb(4).CData = customColors(4,:);
bb(5).CData = customColors(5,:);
bb(6).CData = customColors(6,:);

h2=errorbar(xx(:,:),[Summer_GCB_Ex_Result_Bins{1, 1}{:,6}';Summer_GCB_Ex_Result_Bins{2, 1}{:,6}';Summer_GCB_Ex_Result_Bins{3, 1}{:,6}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],...
    [Summer_GCB_Ex_Result_Bins{1, 1}{:,7}';Summer_GCB_Ex_Result_Bins{2, 1}{:,7}';Summer_GCB_Ex_Result_Bins{3, 1}{:,7}']* 10^15./[Summer_GCB_Ex_Result_Bins{1, 1}{:,end}';Summer_GCB_Ex_Result_Bins{2, 1}{:,end}';Summer_GCB_Ex_Result_Bins{3, 1}{:,end}'],'LineStyle', 'none', 'Color', 'k', 'LineWidth',0.8,'CapSize',3,'Marker','none')
set(gca,'YTick', [-70:35:70],'YLim',[-75,75]);
set(gca,'xTicklabel',{'NH','Temperate','Arctic-boreal'},'FontName','Arial','fontsize',10)
ylabel('TER anomaly (gC m^{-2})','FontName','Arial','FontSize',10)
text('string','e','Units','normalized','position',[-0.142659004942238,1.01040226565111,0],'FontName','Arial','FontSize',14,'fontweight','bold')

lgd=legend(bb,{'ΔRZSM > 0%','-5% < ΔRZSM < 0%','-10% < ΔRZSM < -5%','-15% < ΔRZSM < -10%','-20% < ΔRZSM < -15%','ΔRZSM < -20%'},'Location','southeastoutside','NumColumns',1,'FontName','Arial','FontSize',10)
% lgd.Layout.Tile = 'south';
% lgd.Position=[0.038017287988617,0,0.938608436638142,0.049324323035575]
lgd.ItemTokenSize = [15 9];

legend('boxoff')
result=['E:\phd_file\Climate_extremes\Result\V5\NH_GCB_flux_anomalies_RZSM_bar.png']
% print(result,f,'-r600','-dpng');
