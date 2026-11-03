function [Topt, Mask_no_Topt] = calculate_Topt(Tem_monthly, Flux_monthly)
% =========================================================================
% 输入:
%   Tem_monthly  - 温度数据矩阵 (row * col * time)
%   Flux_monthly - 碳通量数据矩阵 (row * col * time)，如 GPP 或 TER
% 输出:
%   Topt         - 识别的最适温矩阵 (row * col)
%   Mask_no_Topt - 无最适温掩膜 (row * col)，1表示单调上升无峰值
% =========================================================================

    [rows, cols, ~] = size(Flux_monthly);
    
    % 参数设置
    bin_size = 0.1;       % 0.1°C 不重叠分箱
    
    % 初始化
    Topt = nan(rows, cols);
    Mask_no_Topt = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            % 1. 提取序列并剔除 NaN
            t_raw = squeeze(Tem_monthly(i,j,:));
            f_raw = squeeze(Flux_monthly(i,j,:));
            
            % 只有当数据完整时才计算（这里默认120个点，可根据实际情况调整）
            valid_idx = ~isnan(t_raw) & ~isnan(f_raw);
            % if sum(valid_idx) < 120
            %     continue;
            % end
            
            t_data = t_raw(valid_idx);
            f_data = f_raw(valid_idx);

            % --- 2. 0.1°C 标准分箱与 90 分位数对应温度提取 ---
            t_min = floor(min(t_data));
            t_max = ceil(max(t_data));
            bins = t_min : bin_size : t_max;
            
            res_F = []; % 存储 [对应温度, 90分位数通量]
            
            for k = 1:length(bins)-1
                % 寻找落入当前分箱的索引
                idx_in_bin = find(t_data >= bins(k) & t_data < bins(k+1));
                
                if ~isempty(idx_in_bin)
                    sub_t = t_data(idx_in_bin);
                    sub_f = f_data(idx_in_bin);
                    
                    % 计算 90 分位数
                    val_f90 = prctile(sub_f, 90);
                    
                    % 找到最接近 90 分位数的原始观测点的索引
                    [~, loc] = min(abs(sub_f - val_f90)); 
                    
                    % 记录该点对应的原始温度和通量值
                    res_F = [res_F; sub_t(loc), val_f90];
                end
            end

            % --- 3. 识别最适温 (直接寻找最大值) ---
            if ~isempty(res_F)
                [~, max_idx] = max(res_F(:,2));
                
                % 判断峰值位置
                num_bins = size(res_F, 1);
                if max_idx == num_bins
                    % 若最大值在最高温分箱，视为无最适温
                    Mask_no_Topt(i,j) = 1; 
                else
                    % 记录最大值对应的原始温度
                    Topt(i,j) = res_F(max_idx, 1); 
                end
            end
        end
    end
end