%% CABLE-POP
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\CABLE-POP_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;


for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NBP\month\CABLE-POP_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\GPP\month\CABLE-POP_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NPP\month\CABLE-POP_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\Ra\month\CABLE-POP_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\Rh\month\CABLE-POP_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\TER\month\CABLE-POP_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;

        LUCC_result=GPP_result-NBP_result-TER_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\LUCC\month\CABLE-POP_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NBP_correct\month\CABLE-POP_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NBP\year\CABLE-POP_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\GPP\year\CABLE-POP_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NPP\year\CABLE-POP_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\Ra\year\CABLE-POP_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\Rh\year\CABLE-POP_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\TER\year\CABLE-POP_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\LUCC\year\CABLE-POP_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CABLE-POP\NBP_correct\year\CABLE-POP_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% CARDAMOM
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\CARDAMOM_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NBP\month\CARDAMOM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\GPP\month\CARDAMOM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NPP\month\CARDAMOM_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Ra\month\CARDAMOM_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Rh\month\CARDAMOM_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\TER\month\CARDAMOM_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Fire\month\CARDAMOM_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\LUCC\month\CARDAMOM_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NBP_correct\month\CARDAMOM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NBP\year\CARDAMOM_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\GPP\year\CARDAMOM_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NPP\year\CARDAMOM_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Ra\year\CARDAMOM_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Rh\year\CARDAMOM_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\Fire\year\CARDAMOM_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\TER\year\CARDAMOM_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\LUCC\year\CARDAMOM_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CARDANOM\NBP_correct\year\CARDAMOM_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% CLASSIC
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\CLASSIC_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NBP\month\CLASSIC_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\GPP\month\CLASSIC_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NPP\month\CLASSIC_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Ra\month\CLASSIC_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Rh\month\CLASSIC_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\TER\month\CLASSIC_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Fire\month\CLASSIC_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\LUCC\month\CLASSIC_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NBP_correct\month\CLASSIC_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NBP\year\CLASSIC_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\GPP\year\CLASSIC_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NPP\year\CLASSIC_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Ra\year\CLASSIC_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Rh\year\CLASSIC_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\Fire\year\CLASSIC_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\TER\year\CLASSIC_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\LUCC\year\CLASSIC_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\CLASSIC\NBP_correct\year\CLASSIC_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% CLM6.0
% clc
% clear
% warning('off')
% 
% years = 2003:2024; % 提取的年份范围
% num_years = length(years);
% num_months = 12;
% 
% % 定义每个月的天数（平年为基准）
% days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% 
% % NBP
% NBP_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_nbp.nc",'nbp');
% NBP_sample=NBP_sample(:,:,end-263:end);
% NBP_sample=rot90(NBP_sample,1);
% NBP_sample=double(NBP_sample);
% NBP_sample(isnan(NBP_sample))=0;
% 
% % GPP
% GPP_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_gpp.nc",'gpp');
% GPP_sample=GPP_sample(:,:,end-263:end);
% GPP_sample=rot90(GPP_sample,1);
% GPP_sample=double(GPP_sample);
% GPP_sample(isnan(GPP_sample))=0;
% 
% % NPP
% NPP_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_ra.nc",'ra');
% NPP_sample=NPP_sample(:,:,end-263:end);
% NPP_sample=rot90(NPP_sample,1);
% NPP_sample=double(NPP_sample);
% NPP_sample(isnan(NPP_sample))=0;
% 
% % Ra
% Ra_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_ra.nc",'ra');
% Ra_sample=Ra_sample(:,:,end-263:end);
% Ra_sample=rot90(Ra_sample,1);
% Ra_sample=double(Ra_sample);
% Ra_sample(isnan(Ra_sample))=0;
% 
% % Rh
% Rh_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_rh.nc",'rh');
% Rh_sample=Rh_sample(:,:,end-263:end);
% Rh_sample=rot90(Rh_sample,1);
% Rh_sample=double(Rh_sample);
% Rh_sample(isnan(Rh_sample))=0;
% 
% % TER
% TER_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_rh.nc",'rh');
% TER_sample=TER_sample(:,:,end-263:end);
% TER_sample=rot90(TER_sample,1);
% TER_sample=double(TER_sample);
% TER_sample(isnan(TER_sample))=0;
% 
% % Fire
% Fire_sample=ncread("G:\TRENDYv14\resampled_all\CLM6.0_S3_fFire.nc",'fFire');
% Fire_sample=Fire_sample(:,:,end-263:end);
% Fire_sample=rot90(Fire_sample,1);
% Fire_sample=double(Fire_sample);
% Fire_sample(isnan(Fire_sample))=0;
% 
% for y = 1:num_years
%     current_year=years(y);
% 
%     % 检查是否为闰年
%     if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
%         days_in_month(2) = 29; % 闰年 2 月有 29 天
%     else
%         days_in_month(2) = 28; % 平年 2 月有 28 天
%     end
% 
%     % 计算当年的每月秒数
%     seconds_per_month = days_in_month * 24 * 3600;
% 
%     % 提取当年数据
%     month_start_idx = (y - 1) * num_months + 1;
%     month_end_idx = y * num_months;
%     NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
%     GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
%     NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
%     Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
%     Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
%     TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
%     Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);
% 
%     for m = 1:num_months
% 
%         NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         NBP_result=[NBP_result(:,181:360),NBP_result(:,1:180)];
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NBP\month\CLM6.0_NBP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,NBP_result,[-180,180],[-90,90]);
%         NBP_list(:,:,m)=NBP_result;
% 
%         GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         GPP_result=[GPP_result(:,181:360),GPP_result(:,1:180)];
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\GPP\month\CLM6.0_GPP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,GPP_result,[-180,180],[-90,90]);
%         GPP_list(:,:,m)=GPP_result;
% 
%         NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NPP\month\CLM6.0_NPP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,NPP_result,[-180,180],[-90,90]);
%         NPP_list(:,:,m)=NPP_result;
% 
%         Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Ra\month\CLM6.0_Ra_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,Ra_result,[-180,180],[-90,90]);
%         Ra_list(:,:,m)=Ra_result;
% 
%         Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Rh\month\CLM6.0_Rh_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,Rh_result,[-180,180],[-90,90]);
%         Rh_list(:,:,m)=Rh_result;
% 
%         TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         TER_result=[TER_result(:,181:360),TER_result(:,1:180)];
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\TER\month\CLM6.0_TER_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,TER_result,[-180,180],[-90,90]);
%         TER_list(:,:,m)=TER_result;
% 
%         Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         Fire_result=[Fire_result(:,181:360),Fire_result(:,1:180)];
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Fire\month\CLM6.0_Fire_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,Fire_result,[-180,180],[-90,90]);
%         Fire_list(:,:,m)=Fire_result;
% 
%         LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\LUCC\month\CLM6.0_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,LUCC_result,[-180,180],[-90,90]);
%         LUCC_list(:,:,m)=LUCC_result;
% 
%         Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
%         Re_NBP_result=NBP_result+Fire_result-Obser_fire;
%         filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NBP_correct\month\CLM6.0_NBP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
%         Re_NBP_list(:,:,m)=Re_NBP_result;
%     end
% 
%     NBP_annual_result=nansum(NBP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NBP\year\CLM6.0_NBP_' num2str(current_year) '.tif']
%     wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% 
%     GPP_annual_result=nansum(GPP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\GPP\year\CLM6.0_GPP_' num2str(current_year) '.tif']
%     wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
%     clear GPP_list
% 
%     NPP_annual_result=nansum(NPP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NPP\year\CLM6.0_NPP_' num2str(current_year) '.tif']
%     wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
%     clear NPP_list
% 
%     Ra_annual_result=nansum(Ra_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Ra\year\CLM6.0_Ra_' num2str(current_year) '.tif']
%     wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
%     clear Ra_list
% 
%     Rh_annual_result=nansum(Rh_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Rh\year\CLM6.0_Rh_' num2str(current_year) '.tif']
%     wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
%     clear Rh_list
% 
%     Fire_annual_result=nansum(Fire_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\Fire\year\CLM6.0_Fire_' num2str(current_year) '.tif']
%     wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
%     clear Fire_list
% 
%     TER_annual_result=nansum(TER_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\TER\year\CLM6.0_TER_' num2str(current_year) '.tif']
%     wtif(filename,TER_annual_result,[-180,180],[-90,90] );
%     clear TER_list
% 
%     LUCC_annual_result=nansum(LUCC_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\LUCC\year\CLM6.0_LUCC_' num2str(current_year) '.tif']
%     wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
%     clear LUCC_list
% 
%     Re_NBP_annual_result=nansum(Re_NBP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\CLM6.0\NBP_correct\year\CLM6.0_NBP_' num2str(current_year) '.tif']
%     wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% end
%% DLEM
% clc
% clear
% warning('off')
% 
% years = 2003:2024; % 提取的年份范围
% num_years = length(years);
% num_months = 12;
% 
% % 定义每个月的天数（平年为基准）
% days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% 
% % NBP
% NBP_sample=ncread("G:\TRENDYv14\resampled_all\DLEM_S3_nbp.nc",'nbp'); % yearly data
% NBP_sample=NBP_sample(:,:,end-23:end);
% NBP_sample=rot90(NBP_sample,1);
% NBP_sample=double(NBP_sample);
% NBP_sample(isnan(NBP_sample))=0;
% 
% % GPP
% GPP_sample=ncread("G:\TRENDYv14\resampled_all\DLEM_S3_gpp.nc",'gpp');
% GPP_sample=GPP_sample(:,:,end-263:end);
% GPP_sample=rot90(GPP_sample,1);
% GPP_sample=double(GPP_sample);
% GPP_sample(isnan(GPP_sample))=0;
% 
% % TER
% TER_sample=ncread("G:\TRENDYv14\resampled_all\DLEM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\DLEM_S3_rh.nc",'rh');
% TER_sample=TER_sample(:,:,end-263:end);
% TER_sample=rot90(TER_sample,1);
% TER_sample=double(TER_sample);
% TER_sample(isnan(TER_sample))=0;
% 
% 
% for y = 1:num_years
%     current_year=years(y);
% 
%     % 检查是否为闰年
%     if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
%         days_in_month(2) = 29; % 闰年 2 月有 29 天
%     else
%         days_in_month(2) = 28; % 平年 2 月有 28 天
%     end
% 
%     % 计算当年的每月秒数
%     seconds_per_month = days_in_month * 24 * 3600;
% 
%     % 提取当年数据
%     month_start_idx = (y - 1) * num_months + 1;
%     month_end_idx = y * num_months;
%     GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
%     TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
% 
%     for m = 1:num_months
% 
%         GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\GPP\month\DLEM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,GPP_result,[-180,180],[-90,90]);
%         GPP_list(:,:,m)=GPP_result;
% 
%         TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\TER\month\DLEM_TER_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,TER_result,[-180,180],[-90,90]);
%         TER_list(:,:,m)=TER_result;
% 
%     end
% 
% 
%     NBP_annual_result=NBP_sample(:,:,y)*1000*24*3600*sum(days_in_month);
%     filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\NBP\year\DLEM_NBP_' num2str(current_year) '.tif']
%     wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% 
%     Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\GFED\year\GFED_CO2_' num2str(current_year) '.tif']);
%     Re_NBP_annual_result=NBP_annual_result-Obser_fire;
%     filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\NBP_correct\year\DLEM_NBP_' num2str(current_year) '.tif']
%     wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% 
%     GPP_annual_result=nansum(GPP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\GPP\year\DLEM_GPP_' num2str(current_year) '.tif']
%     wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
%     clear GPP_list
% 
%     TER_annual_result=nansum(TER_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\TER\year\DLEM_TER_' num2str(current_year) '.tif']
%     wtif(filename,TER_annual_result,[-180,180],[-90,90] );
%     clear TER_list
% 
%     LUCC_annual_result=GPP_annual_result-TER_annual_result-NBP_annual_result;
%     filename=['E:\phd_file\Global_IAV\TRENDY\DLEM\LUCC\year\DLEM_LUCC_' num2str(current_year) '.tif']
%     wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
%     clear LUCC_list
% end
%% EDv3
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\EDv3_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\EDv3_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\EDv3_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NBP\month\EDv3_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\GPP\month\EDv3_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NPP\month\EDv3_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Ra\month\EDv3_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Rh\month\EDv3_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\TER\month\EDv3_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Fire\month\EDv3_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\LUCC\month\EDv3_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NBP_correct\month\EDv3_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NBP\year\EDv3_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\GPP\year\EDv3_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NPP\year\EDv3_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Ra\year\EDv3_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Rh\year\EDv3_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\Fire\year\EDv3_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\TER\year\EDv3_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\LUCC\year\EDv3_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\EDv3\NBP_correct\year\EDv3_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% GDSTEM
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\GDSTEM_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;


for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NBP\month\GDSTEM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\GPP\month\GDSTEM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NPP\month\GDSTEM_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\Ra\month\GDSTEM_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\Rh\month\GDSTEM_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\TER\month\GDSTEM_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;

        LUCC_result=GPP_result-NBP_result-TER_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\LUCC\month\GDSTEM_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NBP_correct\month\GDSTEM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NBP\year\GDSTEM_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\GPP\year\GDSTEM_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NPP\year\GDSTEM_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\Ra\year\GDSTEM_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\Rh\year\GDSTEM_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\TER\year\GDSTEM_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\LUCC\year\GDSTEM_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\GDSTEM\NBP_correct\year\GDSTEM_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% IBIS
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\IBIS_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\IBIS_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\IBIS_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;


for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NBP\month\IBIS_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\GPP\month\IBIS_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NPP\month\IBIS_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\Ra\month\IBIS_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\Rh\month\IBIS_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\TER\month\IBIS_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;

        LUCC_result=GPP_result-NBP_result-TER_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\LUCC\month\IBIS_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NBP_correct\month\IBIS_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NBP\year\IBIS_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\GPP\year\IBIS_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NPP\year\IBIS_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\Ra\year\IBIS_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\Rh\year\IBIS_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\TER\year\IBIS_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\LUCC\year\IBIS_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\IBIS\NBP_correct\year\IBIS_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% iMAPLE
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\iMAPLE_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;


for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NBP\month\iMAPLE_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\GPP\month\iMAPLE_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NPP\month\iMAPLE_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\Ra\month\iMAPLE_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\Rh\month\iMAPLE_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\TER\month\iMAPLE_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;

        LUCC_result=GPP_result-NBP_result-TER_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\LUCC\month\iMAPLE_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NBP_correct\month\iMAPLE_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NBP\year\iMAPLE_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\GPP\year\iMAPLE_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NPP\year\iMAPLE_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\Ra\year\iMAPLE_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\Rh\year\iMAPLE_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\TER\year\iMAPLE_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\LUCC\year\iMAPLE_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\iMAPLE\NBP_correct\year\iMAPLE_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% ISAM
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\ISAM_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\ISAM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\ISAM_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;


for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        NBP_result=[NBP_result(:,181:360),NBP_result(:,1:180)];
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NBP\month\ISAM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        GPP_result=[GPP_result(:,181:360),GPP_result(:,1:180)];
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\GPP\month\ISAM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NPP\month\ISAM_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\Ra\month\ISAM_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\Rh\month\ISAM_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        TER_result=[TER_result(:,181:360),TER_result(:,1:180)];
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\TER\month\ISAM_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;

        LUCC_result=GPP_result-NBP_result-TER_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\LUCC\month\ISAM_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NBP_correct\month\ISAM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NBP\year\ISAM_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\GPP\year\ISAM_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NPP\year\ISAM_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\Ra\year\ISAM_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\Rh\year\ISAM_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\TER\year\ISAM_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\LUCC\year\ISAM_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ISAM\NBP_correct\year\ISAM_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% JULES
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\JULES_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\JULES_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\JULES_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NBP\month\JULES_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\GPP\month\JULES_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NPP\month\JULES_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Ra\month\JULES_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Rh\month\JULES_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\TER\month\JULES_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Fire\month\JULES_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\LUCC\month\JULES_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NBP_correct\month\JULES_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NBP\year\JULES_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\GPP\year\JULES_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NPP\year\JULES_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Ra\year\JULES_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Rh\year\JULES_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\Fire\year\JULES_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\TER\year\JULES_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\LUCC\year\JULES_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\JULES\NBP_correct\year\JULES_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% LPJmL
% clc
% clear
% warning('off')
% 
% years = 2003:2024; % 提取的年份范围
% num_years = length(years);
% num_months = 12;
% 
% % 定义每个月的天数（平年为基准）
% days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% 
% % NBP
% NBP_sample=ncread("G:\TRENDYv14\resampled_all\LPJmL_S3_nbp.nc",'nbp'); % yearly data
% NBP_sample=NBP_sample(:,:,end-23:end);
% NBP_sample=rot90(NBP_sample,1);
% NBP_sample=double(NBP_sample);
% NBP_sample(isnan(NBP_sample))=0;
% 
% % GPP
% GPP_sample=ncread("G:\TRENDYv14\resampled_all\LPJmL_S3_gpp.nc",'gpp');
% GPP_sample=GPP_sample(:,:,end-263:end);
% GPP_sample=rot90(GPP_sample,1);
% GPP_sample=double(GPP_sample);
% GPP_sample(isnan(GPP_sample))=0;
% 
% 
% % TER
% TER_sample=ncread("G:\TRENDYv14\resampled_all\LPJmL_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\LPJmL_S3_rh.nc",'rh');
% TER_sample=TER_sample(:,:,end-263:end);
% TER_sample=rot90(TER_sample,1);
% TER_sample=double(TER_sample);
% TER_sample(isnan(TER_sample))=0;
% 
% 
% for y = 1:num_years
%     current_year=years(y);
% 
%     % 检查是否为闰年
%     if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
%         days_in_month(2) = 29; % 闰年 2 月有 29 天
%     else
%         days_in_month(2) = 28; % 平年 2 月有 28 天
%     end
% 
%     % 计算当年的每月秒数
%     seconds_per_month = days_in_month * 24 * 3600;
% 
%     % 提取当年数据
%     month_start_idx = (y - 1) * num_months + 1;
%     month_end_idx = y * num_months;
%     GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
%     TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
% 
%     for m = 1:num_months
% 
%         GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\GPP\month\LPJmL_GPP_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,GPP_result,[-180,180],[-90,90]);
%         GPP_list(:,:,m)=GPP_result;
% 
%         TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
%         filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\TER\month\LPJmL_TER_' num2str(current_year) '_' num2str(m) '.tif']
%         wtif(filename,TER_result,[-180,180],[-90,90]);
%         TER_list(:,:,m)=TER_result;
% 
%     end
% 
% 
%     NBP_annual_result=NBP_sample(:,:,y)*1000*24*3600*sum(days_in_month);
%     filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\NBP\year\LPJmL_NBP_' num2str(current_year) '.tif']
%     wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% 
%     Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\GFED\year\GFED_CO2_' num2str(current_year) '.tif']);
%     Re_NBP_annual_result=NBP_annual_result-Obser_fire;
%     filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\NBP_correct\year\LPJmL_NBP_' num2str(current_year) '.tif']
%     wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
%     clear NBP_list
% 
%     GPP_annual_result=nansum(GPP_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\GPP\year\LPJmL_GPP_' num2str(current_year) '.tif']
%     wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
%     clear GPP_list
% 
%     TER_annual_result=nansum(TER_list,3);
%     filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\TER\year\LPJmL_TER_' num2str(current_year) '.tif']
%     wtif(filename,TER_annual_result,[-180,180],[-90,90] );
%     clear TER_list
% 
%     LUCC_annual_result=GPP_annual_result-TER_annual_result-NBP_annual_result;
%     filename=['E:\phd_file\Global_IAV\TRENDY\LPJmL\LUCC\year\LPJmL_LUCC_' num2str(current_year) '.tif']
%     wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
%     clear LUCC_list
% end
%% LPJ-EOSIM
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\LPJ-EOSIM_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NBP\month\LPJ-EOSIM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\GPP\month\LPJ-EOSIM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NPP\month\LPJ-EOSIM_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Ra\month\LPJ-EOSIM_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Rh\month\LPJ-EOSIM_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\TER\month\LPJ-EOSIM_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Fire\month\LPJ-EOSIM_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\LUCC\month\LPJ-EOSIM_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NBP_correct\month\LPJ-EOSIM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NBP\year\LPJ-EOSIM_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\GPP\year\LPJ-EOSIM_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NPP\year\LPJ-EOSIM_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Ra\year\LPJ-EOSIM_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Rh\year\LPJ-EOSIM_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\Fire\year\LPJ-EOSIM_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\TER\year\LPJ-EOSIM_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\LUCC\year\LPJ-EOSIM_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPJ-EOSIM\NBP_correct\year\LPJ-EOSIM_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% LPX-Bern
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\LPX-Bern_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NBP\month\LPX-Bern_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\GPP\month\LPX-Bern_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NPP\month\LPX-Bern_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Ra\month\LPX-Bern_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Rh\month\LPX-Bern_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\TER\month\LPX-Bern_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Fire\month\LPX-Bern_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\LUCC\month\LPX-Bern_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NBP_correct\month\LPX-Bern_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NBP\year\LPX-Bern_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\GPP\year\LPX-Bern_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NPP\year\LPX-Bern_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Ra\year\LPX-Bern_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Rh\year\LPX-Bern_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\Fire\year\LPX-Bern_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\TER\year\LPX-Bern_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\LUCC\year\LPX-Bern_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\LPX-Bern\NBP_correct\year\LPX-Bern_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% ORCHIDEE
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\ORCHIDEE_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NBP\month\ORCHIDEE_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\GPP\month\ORCHIDEE_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NPP\month\ORCHIDEE_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Ra\month\ORCHIDEE_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Rh\month\ORCHIDEE_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\TER\month\ORCHIDEE_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Fire\month\ORCHIDEE_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\LUCC\month\ORCHIDEE_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NBP_correct\month\ORCHIDEE_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NBP\year\ORCHIDEE_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\GPP\year\ORCHIDEE_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NPP\year\ORCHIDEE_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Ra\year\ORCHIDEE_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Rh\year\ORCHIDEE_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\Fire\year\ORCHIDEE_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\TER\year\ORCHIDEE_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\LUCC\year\ORCHIDEE_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\ORCHIDEE\NBP_correct\year\ORCHIDEE_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% SDGVM
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\SDGVM_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NBP\month\SDGVM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\GPP\month\SDGVM_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NPP\month\SDGVM_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Ra\month\SDGVM_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Rh\month\SDGVM_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\TER\month\SDGVM_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Fire\month\SDGVM_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\LUCC\month\SDGVM_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NBP_correct\month\SDGVM_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NBP\year\SDGVM_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\GPP\year\SDGVM_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NPP\year\SDGVM_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Ra\year\SDGVM_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Rh\year\SDGVM_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\Fire\year\SDGVM_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\TER\year\SDGVM_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\LUCC\year\SDGVM_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\SDGVM\NBP_correct\year\SDGVM_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% VISIT
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\VISIT_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\VISIT_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\VISIT_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NBP\month\VISIT_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\GPP\month\VISIT_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NPP\month\VISIT_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Ra\month\VISIT_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Rh\month\VISIT_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\TER\month\VISIT_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Fire\month\VISIT_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\LUCC\month\VISIT_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NBP_correct\month\VISIT_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NBP\year\VISIT_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\GPP\year\VISIT_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NPP\year\VISIT_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Ra\year\VISIT_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Rh\year\VISIT_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\Fire\year\VISIT_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\TER\year\VISIT_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\LUCC\year\VISIT_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT\NBP_correct\year\VISIT_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end
%% VISIT-UT
clc
clear
warning('off')

years = 2003:2024; % 提取的年份范围
num_years = length(years);
num_months = 12;

% 定义每个月的天数（平年为基准）
days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% NBP
NBP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_nbp.nc",'nbp');
NBP_sample=NBP_sample(:,:,end-263:end);
NBP_sample=rot90(NBP_sample,1);
NBP_sample=double(NBP_sample);
NBP_sample(isnan(NBP_sample))=0;

% GPP
GPP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_gpp.nc",'gpp');
GPP_sample=GPP_sample(:,:,end-263:end);
GPP_sample=rot90(GPP_sample,1);
GPP_sample=double(GPP_sample);
GPP_sample(isnan(GPP_sample))=0;

% NPP
NPP_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_gpp.nc",'gpp')-ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_ra.nc",'ra');
NPP_sample=NPP_sample(:,:,end-263:end);
NPP_sample=rot90(NPP_sample,1);
NPP_sample=double(NPP_sample);
NPP_sample(isnan(NPP_sample))=0;

% Ra
Ra_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_ra.nc",'ra');
Ra_sample=Ra_sample(:,:,end-263:end);
Ra_sample=rot90(Ra_sample,1);
Ra_sample=double(Ra_sample);
Ra_sample(isnan(Ra_sample))=0;

% Rh
Rh_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_rh.nc",'rh');
Rh_sample=Rh_sample(:,:,end-263:end);
Rh_sample=rot90(Rh_sample,1);
Rh_sample=double(Rh_sample);
Rh_sample(isnan(Rh_sample))=0;

% TER
TER_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_ra.nc",'ra')+ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_rh.nc",'rh');
TER_sample=TER_sample(:,:,end-263:end);
TER_sample=rot90(TER_sample,1);
TER_sample=double(TER_sample);
TER_sample(isnan(TER_sample))=0;

% Fire
Fire_sample=ncread("G:\TRENDYv14\resampled_all\VISIT-UT_S3_fFire.nc",'fFire');
Fire_sample=Fire_sample(:,:,end-263:end);
Fire_sample=rot90(Fire_sample,1);
Fire_sample=double(Fire_sample);
Fire_sample(isnan(Fire_sample))=0;

for y = 1:num_years
    current_year=years(y);

    % 检查是否为闰年
    if mod(current_year, 4) == 0 && (mod(current_year, 100) ~= 0 || mod(current_year, 400) == 0)
        days_in_month(2) = 29; % 闰年 2 月有 29 天
    else
        days_in_month(2) = 28; % 平年 2 月有 28 天
    end

    % 计算当年的每月秒数
    seconds_per_month = days_in_month * 24 * 3600;

    % 提取当年数据
    month_start_idx = (y - 1) * num_months + 1;
    month_end_idx = y * num_months;
    NBP_yearly_data = NBP_sample(:, :, month_start_idx:month_end_idx);
    GPP_yearly_data = GPP_sample(:, :, month_start_idx:month_end_idx);
    NPP_yearly_data = NPP_sample(:, :, month_start_idx:month_end_idx);
    Ra_yearly_data = Ra_sample(:, :, month_start_idx:month_end_idx);
    Rh_yearly_data = Rh_sample(:, :, month_start_idx:month_end_idx);
    TER_yearly_data = TER_sample(:, :, month_start_idx:month_end_idx);
    Fire_yearly_data = Fire_sample(:, :, month_start_idx:month_end_idx);

    for m = 1:num_months

        NBP_result = NBP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NBP\month\VISIT-UT_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NBP_result,[-180,180],[-90,90]);
        NBP_list(:,:,m)=NBP_result;

        GPP_result = GPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\GPP\month\VISIT-UT_GPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,GPP_result,[-180,180],[-90,90]);
        GPP_list(:,:,m)=GPP_result;

        NPP_result = NPP_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NPP\month\VISIT-UT_NPP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,NPP_result,[-180,180],[-90,90]);
        NPP_list(:,:,m)=NPP_result;

        Ra_result = Ra_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Ra\month\VISIT-UT_Ra_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Ra_result,[-180,180],[-90,90]);
        Ra_list(:,:,m)=Ra_result;

        Rh_result = Rh_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Rh\month\VISIT-UT_Rh_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Rh_result,[-180,180],[-90,90]);
        Rh_list(:,:,m)=Rh_result;

        TER_result = TER_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\TER\month\VISIT-UT_TER_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,TER_result,[-180,180],[-90,90]);
        TER_list(:,:,m)=TER_result;
     
        Fire_result = Fire_yearly_data(:, :, m) * 1000 * seconds_per_month(m);
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Fire\month\VISIT-UT_Fire_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Fire_result,[-180,180],[-90,90]);
        Fire_list(:,:,m)=Fire_result;

        LUCC_result=GPP_result-NBP_result-TER_result-Fire_result;
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\LUCC\month\VISIT-UT_LUCC_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,LUCC_result,[-180,180],[-90,90]);
        LUCC_list(:,:,m)=LUCC_result;

        Obser_fire=importdata(['E:\phd_file\Global_IAV\Fire_emission\mean_value\month\Fire_CO2_' num2str(current_year) '_' num2str(m) '.tif']);
        Re_NBP_result=NBP_result+Fire_result-Obser_fire;
        filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NBP_correct\month\VISIT-UT_NBP_' num2str(current_year) '_' num2str(m) '.tif']
        wtif(filename,Re_NBP_result,[-180,180],[-90,90]);
        Re_NBP_list(:,:,m)=Re_NBP_result;
    end

    NBP_annual_result=nansum(NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NBP\year\VISIT-UT_NBP_' num2str(current_year) '.tif']
    wtif(filename,NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list

    GPP_annual_result=nansum(GPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\GPP\year\VISIT-UT_GPP_' num2str(current_year) '.tif']
    wtif(filename,GPP_annual_result,[-180,180],[-90,90] );
    clear GPP_list

    NPP_annual_result=nansum(NPP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NPP\year\VISIT-UT_NPP_' num2str(current_year) '.tif']
    wtif(filename,NPP_annual_result,[-180,180],[-90,90] );
    clear NPP_list

    Ra_annual_result=nansum(Ra_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Ra\year\VISIT-UT_Ra_' num2str(current_year) '.tif']
    wtif(filename,Ra_annual_result,[-180,180],[-90,90] );
    clear Ra_list
    
    Rh_annual_result=nansum(Rh_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Rh\year\VISIT-UT_Rh_' num2str(current_year) '.tif']
    wtif(filename,Rh_annual_result,[-180,180],[-90,90] );
    clear Rh_list

    Fire_annual_result=nansum(Fire_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\Fire\year\VISIT-UT_Fire_' num2str(current_year) '.tif']
    wtif(filename,Fire_annual_result,[-180,180],[-90,90] );
    clear Fire_list
    
    TER_annual_result=nansum(TER_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\TER\year\VISIT-UT_TER_' num2str(current_year) '.tif']
    wtif(filename,TER_annual_result,[-180,180],[-90,90] );
    clear TER_list

    LUCC_annual_result=nansum(LUCC_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\LUCC\year\VISIT-UT_LUCC_' num2str(current_year) '.tif']
    wtif(filename,LUCC_annual_result,[-180,180],[-90,90] );
    clear LUCC_list

    Re_NBP_annual_result=nansum(Re_NBP_list,3);
    filename=['E:\phd_file\Global_IAV\TRENDY\VISIT-UT\NBP_correct\year\VISIT-UT_NBP_' num2str(current_year) '.tif']
    wtif(filename,Re_NBP_annual_result,[-180,180],[-90,90] );
    clear NBP_list
end