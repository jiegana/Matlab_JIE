% SEDLINE_PATIENT_SPECTROGRAM_WITH_BOXPLOTS_AND_FOLDER_GUI
clear all; close all; clc;

% --- 1. Target Folder Path (GUI Selection) ---
fprintf('Waiting for folder selection...\n');
rootFolder = uigetdir(pwd, 'Select Patient Root Folder (e.g., Root_...)');
if rootFolder == 0
    fprintf('Folder selection canceled. Exiting.\n');
    return;
end

% --- 2. Find and Sort EDF Files Chronologically ---
fileList = dir(fullfile(rootFolder, '**', '*.edf'));
if isempty(fileList)
    error('No EDF files found in the target folder.');
end

[~, sortIdx] = sort({fileList.name});
fileList = fileList(sortIdx);

fprintf('Found %d EDF files. Processing...\n', length(fileList));

% --- 3. Concatenation and Gap-Filling Loop ---
catEEG_Ch2 = [];
catEEG_Ch3 = [];
Fs = [];
lastFileEndTime = [];

for idx = 1:length(fileList)
    currFile = fullfile(fileList(idx).folder, fileList(idx).name);
    [hdr, record] = edfreadUntilDone(currFile);
    
    if idx == 1
        if isfield(hdr, 'frequency')
            Fs = hdr.frequency(1);
        elseif isfield(hdr, 'samplingfrequency')
            Fs = hdr.samplingfrequency(1);
        else
            Fs = 178.28; 
        end
    end
    
    [~, fname] = fileparts(fileList(idx).name);
    timePartsStr = extractAfter(fname, 'EEG_');
    fileStartTime = datetime(timePartsStr, 'InputFormat', 'yyMMdd_HHmmss');
    
    currentSamplesCh2 = record(2, :)';
    currentSamplesCh3 = record(3, :)';
    
    if idx > 1
        gapSeconds = seconds(fileStartTime - lastFileEndTime);
        if gapSeconds > 0
            gapSamples = round(gapSeconds * Fs);
            catEEG_Ch2 = [catEEG_Ch2; zeros(gapSamples, 1)];
            catEEG_Ch3 = [catEEG_Ch3; zeros(gapSamples, 1)];
        end
    end
    
    catEEG_Ch2 = [catEEG_Ch2; currentSamplesCh2];
    catEEG_Ch3 = [catEEG_Ch3; currentSamplesCh3];
    
    fileDurationSecs = length(currentSamplesCh2) / Fs;
    lastFileEndTime = fileStartTime + seconds(fileDurationSecs);
end

% --- 4. Trim Initial and Final Zero-Signal Periods ---
signalDiff = abs(diff(catEEG_Ch3));
activeIdx = find(signalDiff > 0.1); 

if ~isempty(activeIdx)
    firstValid = activeIdx(1);
    lastValid = activeIdx(end) + 1;
    
    trimStartSecs = (firstValid - 1) / Fs;
    catEEG_Ch2 = catEEG_Ch2(firstValid:lastValid);
    catEEG_Ch3 = catEEG_Ch3(firstValid:lastValid);
else
    trimStartSecs = 0;
end

% --- 5. Preprocessing (0.5 - 45 Hz Bandpass) ---
fprintf('Applying 0.5 - 45 Hz bandpass filter...\n');
[b, a] = butter(2, [0.5, 45] / (Fs / 2), 'bandpass');
filtered_Ch2 = filtfilt(b, a, catEEG_Ch2);
filtered_Ch3 = filtfilt(b, a, catEEG_Ch3);

% --- 6. Chronux Spectrogram Parameters (10s Window, 10s Step) ---
params.Fs = Fs;
params.tapers = [5 9];     
params.pad = 0;
params.fpass = [0 45];
params.trialave = 0;
params.err = 0;
movingwin = [10 10];       

fprintf('Computing multitaper spectrograms for Channel 2 and 3...\n');
[S2, t2, f2] = mtspecgramc(filtered_Ch2, movingwin, params);
[S3, t3, f3] = mtspecgramc(filtered_Ch3, movingwin, params);

% --- 7. Parse Start Time, Date, & Apply Trim Offset ---
[~, fnameFirst] = fileparts(fileList(1).name);
timePartStr = extractAfter(fnameFirst, 'EEG_'); 
timeToken = extractAfter(timePartStr, '_');      
dateToken = extractBefore(timePartStr, '_');

startTimeStr = sprintf('%s:%s:%s', timeToken(1:2), timeToken(3:4), timeToken(5:6));
dateFormatted = sprintf('%s-%s-20%s', dateToken(5:6), dateToken(3:4), dateToken(1:2));

startHour = str2double(timeToken(1:2)) + str2double(timeToken(3:4))/60 + str2double(timeToken(5:6))/3600;
startHour = startHour + (trimStartSecs / 3600);
t3_hours = startHour + (t3 / 3600);

% --- 8. Clean Spectrogram Data (Mask Internal Gaps as NaN) ---
powerSum2 = sum(S2, 2);
gapIdx2 = (powerSum2 == 0 | isnan(powerSum2) | isinf(powerSum2));
S2(gapIdx2, :) = NaN;

powerSum3 = sum(S3, 2);
gapIdx3 = (powerSum3 == 0 | isnan(powerSum3) | isinf(powerSum3));
S3(gapIdx3, :) = NaN;
S3_dB = 10 * log10(S3');

% --- 9. Launch Event Logging GUI ---
fprintf('Launching Event Logging GUI...\n');
eventTable = launchEventGUI(startTimeStr);
eventsProcessed = parseEventTimes(eventTable, startHour);

% --- 10. Compute Spectral & Advanced Metrics ---
fprintf('Extracting spectral, LZC, and PAC metrics...\n');
Metrics.Ch2 = calculate_advanced_metrics(S2, f2, t2, filtered_Ch2, Fs, movingwin);
Metrics.Ch3 = calculate_advanced_metrics(S3, f3, t3, filtered_Ch3, Fs, movingwin);
Metrics.Events = eventsProcessed;

% --- 11. Plotting Spectrogram with Continuous SEF & Events ---
figure('Name', 'Sedline Spectrogram - Channel 3', 'Position', [100, 100, 1400, 600], 'Color', 'w');

imagesc(t3_hours, f3, S3_dB);
axis xy;
colormap(jet);
cb = colorbar;
cb.Label.String = 'Power (dB)';
cb.Label.FontSize = 11;

validVals = S3_dB(isfinite(S3_dB));
if ~isempty(validVals)
    caxis([prctile(validVals, 5), prctile(validVals, 99)]); 
end

hold on;
plot(t3_hours, Metrics.Ch3.SEF95, 'w-', 'LineWidth', 1.5, 'DisplayName', 'SEF 95');

min_x = t3_hours(1);
max_x = t3_hours(end);
if ~isempty(eventsProcessed)
    min_x = min(min_x, min(eventsProcessed.DecimalHours));
    max_x = max(max_x, max(eventsProcessed.DecimalHours));
end
xlim([min_x, max_x]);

if ~isempty(eventsProcessed)
    for e = 1:height(eventsProcessed)
        eTime = eventsProcessed.DecimalHours(e);
        xline(eTime, 'Color', 'r', 'LineWidth', 2.5, 'HandleVisibility', 'off');
    end
    
    for e = 1:height(eventsProcessed)
        eTime = eventsProcessed.DecimalHours(e);
        eName = eventsProcessed.EventName{e};
        
        if mod(e, 2) == 1
            alignFlag = 'right';
            padText = [eName ' ']; 
        else
            alignFlag = 'left';
            padText = [' ' eName];
        end
        
        text(eTime, 42, 1, padText, 'Color', 'k', 'FontWeight', 'bold', ...
            'Rotation', 0, 'VerticalAlignment', 'middle', 'HorizontalAlignment', alignFlag, ...
            'FontSize', 14, 'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 3);
    end
end

ylabel('Frequency (Hz)', 'FontWeight', 'bold');
title(sprintf('%s - Channel 3 - (Start: %s)', dateFormatted, startTimeStr), 'FontWeight', 'bold');
ylim([0 45]);
legend('Location', 'northeast', 'TextColor', 'w', 'Color', 'k');
set(gca, 'FontSize', 11);
setTimeAxisTicks(gca, [min_x, max_x]);
xlabel('Clock Time (HH:MM)', 'FontWeight', 'bold');


% --- 12. Plotting Epoch-Based Box Plots (9 Variables, Notched & Colored, No Outliers) ---
if ~isempty(eventsProcessed)
    figure('Name', 'Sedline Metrics Epoch Comparison', 'Position', [150, 100, 1400, 900], 'Color', 'w');
    
    eTimes = eventsProcessed.DecimalHours;
    eNames = eventsProcessed.EventName;
    numWindows = length(t3_hours);
    groupLabels = cell(numWindows, 1);
    
    % Assign each time window to a specific epoch
    for i = 1:numWindows
        t = t3_hours(i);
        if t <= eTimes(1)
            groupLabels{i} = sprintf('Start -> %s', eNames{1});
        elseif t > eTimes(end)
            groupLabels{i} = sprintf('%s -> End', eNames{end});
        else
            for k = 1:(length(eTimes)-1)
                if t > eTimes(k) && t <= eTimes(k+1)
                    groupLabels{i} = sprintf('%s -> %s', eNames{k}, eNames{k+1});
                    break;
                end
            end
        end
    end
    
    % Define the strict chronological order for the X-axis categories
    uniqueLabels = {sprintf('Start -> %s', eNames{1})};
    for k = 1:(length(eTimes)-1)
        uniqueLabels{end+1} = sprintf('%s -> %s', eNames{k}, eNames{k+1});
    end
    uniqueLabels{end+1} = sprintf('%s -> End', eNames{end});
    
    catGroups = categorical(groupLabels, uniqueLabels);
    
    varsToPlot = {'TotalPower', 'RelAlpha', 'RelBeta', 'SEF95', ...
                  'PeakCentroidAlpha', 'PAC_AlphaDelta', 'PAC_BetaDelta', 'PAC_GammaDelta', 'LZC'};
              
    plotTitles = {'Total Power', 'Relative Alpha Power', 'Relative Beta Power', 'SEF 95 (Hz)', ...
                  'Alpha Centroid Peak (Hz)', 'PAC Alpha-Delta', 'PAC Beta-Delta', 'PAC Gamma-Delta', 'LZC'};
    
    for v = 1:length(varsToPlot)
        subplot(3, 3, v);
        data = Metrics.Ch3.(varsToPlot{v});
        
        validIdx = ~isnan(data) & ~isinf(data) & ~isundefined(catGroups);
        
        if any(validIdx)
            hold on;
            cData = data(validIdx);
            cGroups = catGroups(validIdx);
            cats = categories(cGroups);
            colorMap = lines(length(cats));
            
            for c = 1:length(cats)
                cIdx = (cGroups == cats{c});
                if any(cIdx)
                    b = boxchart(cGroups(cIdx), cData(cIdx), 'Notch', 'on', 'MarkerStyle', 'none');
                    b.BoxFaceColor = colorMap(c, :);
                end
            end
            hold off;
            
            title(plotTitles{v}, 'FontWeight', 'bold');
            ylabel(plotTitles{v});
            set(gca, 'FontSize', 10);
            xtickangle(25); 
            grid off;
            legend('off');
        end
    end
end


% =========================================================================
% GUI & EVENT PROCESSING FUNCTIONS
% =========================================================================

function eventTable = launchEventGUI(startTimeStr)
    fig = uifigure('Name', 'Log Ketamine Clinical Events', 'Position', [500, 400, 450, 350]);
    
    uilabel(fig, 'Position', [25, 310, 400, 22], ...
        'Text', sprintf('Recording Monitor Start Time: %s', startTimeStr), ...
        'FontWeight', 'bold', 'FontSize', 11);
        
    uilabel(fig, 'Position', [25, 280, 400, 20], ...
        'Text', 'Enter event type and absolute clock time (HH:MM:SS):', ...
        'FontColor', [0.3 0.3 0.3]);

    uit = uitable(fig, 'Position', [25, 70, 400, 200], ...
        'ColumnName', {'Event Type (e.g., Bolus)', 'Clock Time (HH:MM:SS)'}, ...
        'ColumnEditable', [true, true], ...
        'ColumnWidth', {200, 175}, ...
        'Data', {'', ''});
    
    uibutton(fig, 'Position', [25, 25, 110, 30], 'Text', 'Add Row', ...
        'ButtonPushedFcn', @(btn,event) addRow(uit));
    
    uibutton(fig, 'Position', [315, 25, 110, 30], 'Text', 'Done / Plot', ...
        'BackgroundColor', [0 0.45 0.74], 'FontColor', 'w', ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));
    
    uiwait(fig);
    
    rawData = uit.Data;
    close(fig);
    
    validRows = ~cellfun(@(x) isempty(strtrim(char(x))), rawData(:,1)) & ...
                ~cellfun(@(x) isempty(strtrim(char(x))), rawData(:,2));
                
    if any(validRows)
        eventTable = cell2table(rawData(validRows, :), 'VariableNames', {'EventName', 'AbsoluteTime'});
    else
        eventTable = table('Size', [0 2], 'VariableTypes', {'string', 'string'}, 'VariableNames', {'EventName', 'AbsoluteTime'});
    end

    function addRow(t)
        t.Data(end+1, :) = {'', ''};
    end
end

function eventsProcessed = parseEventTimes(eventTable, baseStartHour)
    eventsProcessed = eventTable;
    nEvents = height(eventTable);
    decHours = NaN(nEvents, 1);
    
    for i = 1:nEvents
        tStr = char(eventTable.AbsoluteTime{i});
        try
            parts = sscanf(tStr, '%d:%d:%d');
            if length(parts) >= 2
                if length(parts) == 2, parts(3) = 0; end
                h = parts(1) + parts(2)/60 + parts(3)/3600;
                
                if h < (baseStartHour - 6)
                    h = h + 24; 
                end
                
                decHours(i) = h;
            end
        catch
            warning('Could not parse time string: %s', tStr);
        end
    end
    eventsProcessed.DecimalHours = decHours;
    eventsProcessed = rmmissing(eventsProcessed, 'DataVariables', 'DecimalHours');
end


% =========================================================================
% METRICS & HELPER FUNCTIONS
% =========================================================================

function met = calculate_advanced_metrics(S, f, t_sec, raw_data, Fs, movingwin)
    nWins = size(S, 1);
    
    bands.delta = [0.5 4];
    bands.theta = [4 8];
    bands.alpha = [8 13];
    bands.beta  = [13 30];
    bands.gamma = [30 45];
    
    met.TotalPower = NaN(nWins, 1);
    met.AlphaDeltaRatio = NaN(nWins, 1);
    met.SEF95 = NaN(nWins, 1);
    met.SEF50 = NaN(nWins, 1);
    
    bandNames = fieldnames(bands);
    for b = 1:length(bandNames)
        met.(['Abs' regexprep(bandNames{b},'^[a-z]','${upper($0)}')]) = NaN(nWins, 1);
        met.(['Rel' regexprep(bandNames{b},'^[a-z]','${upper($0)}')]) = NaN(nWins, 1);
        met.(['PeakMax' regexprep(bandNames{b},'^[a-z]','${upper($0)}')]) = NaN(nWins, 1);
        met.(['PeakCentroid' regexprep(bandNames{b},'^[a-z]','${upper($0)}')]) = NaN(nWins, 1);
        met.(['PeakMedian' regexprep(bandNames{b},'^[a-z]','${upper($0)}')]) = NaN(nWins, 1);
    end
    
    met.LZC = NaN(nWins, 1);
    met.PAC_AlphaDelta = NaN(nWins, 1);
    met.PAC_BetaDelta  = NaN(nWins, 1);
    met.PAC_GammaDelta = NaN(nWins, 1);
    
    d_phase = angle(hilbert(bandpass_filter(raw_data, Fs, bands.delta)));
    a_amp_alpha = abs(hilbert(bandpass_filter(raw_data, Fs, bands.alpha)));
    a_amp_beta  = abs(hilbert(bandpass_filter(raw_data, Fs, bands.beta)));
    a_amp_gamma = abs(hilbert(bandpass_filter(raw_data, Fs, bands.gamma)));
    
    win_samples = movingwin(1) * Fs;
    t_samples = round(t_sec * Fs);
    pac_bins = 18;
    
    idx_tot = f >= 0.5 & f <= 45;
    idx_sef = f >= 0.5 & f <= 30;
    f_sef = f(idx_sef);
    get_idx = @(b) f >= b(1) & f <= b(2);
    
    for i = 1:nWins
        P = S(i, :);
        if all(isnan(P)), continue; end
        
        total_p = trapz(f(idx_tot), P(idx_tot));
        met.TotalPower(i) = total_p;
        
        if total_p > 0
            for b = 1:length(bandNames)
                bn = bandNames{b};
                Bn = regexprep(bn,'^[a-z]','${upper($0)}');
                
                met.(['Abs' Bn])(i) = trapz(f(get_idx(bands.(bn))), P(get_idx(bands.(bn))));
                met.(['Rel' Bn])(i) = met.(['Abs' Bn])(i) / total_p;
                
                [p_max, p_cent, p_med] = get_band_peaks(f, P, bands.(bn));
                met.(['PeakMax' Bn])(i) = p_max;
                met.(['PeakCentroid' Bn])(i) = p_cent;
                met.(['PeakMedian' Bn])(i) = p_med;
            end
            
            if met.AbsDelta(i) > 0
                met.AlphaDeltaRatio(i) = met.AbsAlpha(i) / met.AbsDelta(i);
            end
            
            P_sef = P(idx_sef);
            if sum(P_sef) > 0
                norm_P = cumsum(P_sef) / sum(P_sef);
                idx95 = find(norm_P >= 0.95, 1, 'first');
                idx50 = find(norm_P >= 0.50, 1, 'first');
                if ~isempty(idx95), met.SEF95(i) = f_sef(idx95); end
                if ~isempty(idx50), met.SEF50(i) = f_sef(idx50); end
            end
        end
        
        samp_start = max(1, t_samples(i) - floor(win_samples/2));
        samp_end   = min(length(raw_data), t_samples(i) + ceil(win_samples/2));
        
        if (samp_end - samp_start) > 100
            seg_raw = raw_data(samp_start:samp_end);
            met.LZC(i) = calculate_lzc(seg_raw(:)');
            
            met.PAC_AlphaDelta(i) = calculate_modulation_index(d_phase(samp_start:samp_end), a_amp_alpha(samp_start:samp_end), pac_bins);
            met.PAC_BetaDelta(i)  = calculate_modulation_index(d_phase(samp_start:samp_end), a_amp_beta(samp_start:samp_end), pac_bins);
            met.PAC_GammaDelta(i) = calculate_modulation_index(d_phase(samp_start:samp_end), a_amp_gamma(samp_start:samp_end), pac_bins);
        end
    end
end

function [pk_max, pk_cent, pk_med] = get_band_peaks(f, P, band)
    idx = f >= band(1) & f <= band(2);
    if ~any(idx)
        pk_max = NaN; pk_cent = NaN; pk_med = NaN; return;
    end
    
    P_b = P(idx); f_b = f(idx);
    
    [m_val, m_idx] = max(P_b);
    if isempty(m_idx) || m_val == 0
        pk_max = NaN;
    else
        pk_max = f_b(m_idx);
    end
    
    sum_P = sum(P_b);
    if sum_P > 0
        pk_cent = sum(f_b .* P_b) / sum_P;
        
        norm_P = cumsum(P_b) / sum_P;
        idx50 = find(norm_P >= 0.50, 1, 'first');
        if ~isempty(idx50)
            pk_med = f_b(idx50);
        else
            pk_med = NaN;
        end
    else
        pk_cent = NaN;
        pk_med = NaN;
    end
end

function y = bandpass_filter(data, Fs, band)
    [b, a] = butter(2, band / (Fs/2), 'bandpass');
    y = filtfilt(b, a, data);
end

function mi = calculate_modulation_index(phase, amp, n_bins)
    edges = linspace(-pi, pi, n_bins+1);
    [~, bin_idx] = histc(phase, edges);
    mean_amp = zeros(1, n_bins);
    for b = 1:n_bins, mean_amp(b) = mean(amp(bin_idx == b)); end
    mean_amp(isnan(mean_amp)) = 0;
    P = mean_amp / sum(mean_amp);
    P(P==0) = eps; 
    H = -sum(P .* log(P));
    mi = (log(n_bins) - H) / log(n_bins);
end

function lzc = calculate_lzc(x)
    m = median(x);
    s = char((x > m) + '0'); 
    n = length(s);
    c = 1; l = 1; k = 1; k_max = 1;
    
    while (c + k <= n)
        if k_max < k, k_max = k; end
        seq = s(c : c + k - 1);
        history = s(1 : c + k - 2);
        if contains(history, seq)
            k = k + 1;
        else
            c = c + k; l = l + 1; k = 1;
        end
    end
    if n > 1
        lzc = l / (n / log2(n));
    else
        lzc = 0;
    end
end

function setTimeAxisTicks(ax, xRange)
    if isempty(xRange), return; end
    numTicks = 8;
    tickVals = linspace(xRange(1), xRange(2), numTicks);
    set(ax, 'XTick', tickVals);
    
    tickLabels = cell(length(tickVals), 1);
    for i = 1:length(tickVals)
        h_val = mod(tickVals(i), 24);
        if h_val < 0, h_val = h_val + 24; end
        hours = floor(h_val);
        minutes = floor((h_val - hours) * 60);
        tickLabels{i} = sprintf('%02d:%02d', hours, minutes);
    end
    set(ax, 'XTickLabel', tickLabels);
end