% This script is intended to read EDFs files from PEUMA Sedline
% files. It is the first part of the analysis.

clear all
close all
clc

EDFpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/Data_PEUMA2';
CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
SCTGpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/SPECTG';
cd (EDFpath);
%% Find folders with EDFs inside
Finfo = dir;                            %Directory information
SubF = find ([Finfo.isdir] == 1);       %Find SubFolders
RealF = {Finfo(SubF).name};             %Folders Names
IndexSA = strmatch('SF',RealF)';        %Indices of Folders named 'SF'
SDataF = RealF(IndexSA)';               %Names of all Folders name containing 'caso_'

%% Find EDF files for each subject folder

for SFindex = 1:length (SDataF)
    %         hasedf(1,SFindex) = any(size(dir([[EDFpath '/' SDataF{SFindex}] '**/*.edf' ]),1));
    filelist(SFindex).files = dir(fullfile([EDFpath '/' SDataF{SFindex}], '**/*.edf'));
end
%% Read Time data from CSV
cd (CSVpath);
TAPS = readtable('times_APS.csv');
APSSubj = table2cell(TAPS(:,1));                    %Subjects by APS
TAPS.AlphaRelativePow = zeros(size(TAPS,1),1);
TAPS.AlphaPeakFreq = zeros(size(TAPS,1),1);
%% Finding APS subjects
[APSval,APSpos]=intersect(SDataF,APSSubj);          % coincidences
[APSdifval,APSdifpos] = setdiff(SDataF,APSSubj);    % differences
tAPS = cell2mat(table2cell(TAPS(:,2:3)));           % Times by APS
tAPS = rmmissing(tAPS);
DelTrue = cell2mat(table2cell(TAPS(:,4)));
%%
% Delirium/No Delirium counters
NonDel = 0;
YesDel = 0;
% Main Loop
for NumSubj = 1:length(APSval)
    catEEG = [];
    
    APSSubj = APSpos(NumSubj); %replacing by subjects in APS's list
    
    currSubj = char(SDataF(APSSubj))
    tt = char(currSubj);
    currPath = filelist(APSSubj).files.folder;
    currtINI = tAPS(NumSubj,1);
    currtEND = tAPS(NumSubj,2);
    currDel = DelTrue(NumSubj);
    
    %     Reading all EDF files for each subject
    for NumSFile = 1:length(filelist(APSSubj).files)
        currFile = filelist(APSSubj).files(NumSFile).name;
        f2r = [currPath '/' currFile];
        %         File exchange function edfreadUntilDone
        %         https://www.mathworks.com/matlabcentral/fileexchange/66088-edfreaduntildone-fname-varargin
        [hdr, record] = edfreadUntilDone(f2r);
        catEEG = cat(2,catEEG,record);
    end
    
    %     Sampling Frequency
    Fs = hdr.frequency(3);
    
    %     EEG Data on APS times
    APSEEG = catEEG(:,floor(currtINI*60*Fs):floor(currtEND*60*Fs));
    
    %     Cutting Points (APSEEGcp)    %
    %     Divide EEG length in 7. Middle five will be used for obtaining 5
    %     windows of 15 seconds lenght
    APSEEGcp = floor(linspace(1,length(APSEEG),7)); %APSEEG cutting points
    APSEEGcp = APSEEGcp(2:6);
    APSEEGcpt = floor(APSEEGcp/Fs);
    SelChan = 3;
    tAPSEEG = APSEEG(SelChan,:);
    for rgindex = 1:5
        RGEEG(rgindex,:) = tAPSEEG(APSEEGcp(rgindex):(APSEEGcp(rgindex)+floor((15*Fs))));
    end
    
    % noise detector
    for RGwinindex = 1:5
        noiseindex = find (RGEEG(RGwinindex,:) > 100 | RGEEG(RGwinindex,:) < -100);
        totnoise = length(noiseindex);
        if totnoise < floor(length(RGEEG(RGwinindex,:)))/20 % 5 percent over/belor +/- 100 microV
            break
        end
    end
    %     RGwinindex
    %     SPECTROGRAMS
    wintime = 15; %in seconds
    winlen = floor(wintime*Fs);
    %     If winlen is odd
    %     if bitget(winlen,1) == 1
    %         winlen2 = winlen-1;
    %     else winlen2 = winlen;
    %     end
    
    %     Spectrograms for all channels APS windows
    for nchan = 1:size(catEEG,1)
        [S1,F1,T1,P1] = spectrogram(APSEEG(1,:),hann(winlen),[],[],Fs,'yaxis');
        [S2,F2,T2,P2] = spectrogram(APSEEG(2,:),hann(winlen),[],[],Fs,'yaxis');
        [S3,F3,T3,P3] = spectrogram(APSEEG(3,:),hann(winlen),[],[],Fs,'yaxis');
        [S4,F4,T4,P4] = spectrogram(APSEEG(4,:),hann(winlen),[],[],Fs,'yaxis');
    end
    
    
    
    %     Spectrograms for channel 3 whole record
    [WS3,WF3,WT3,WP3] = spectrogram(catEEG(3,:),hann(winlen),[],[],Fs,'yaxis');
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%        Multitaper spectrum for RGEEG           %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    params.tapers = [3 5];        %[TW K] Time(T) = 3 segs, Bandwith(W) = 1 Hz, Tapers(K) = 2TW-1 = 5
    params.pad = 0;               % Padding factor; -1 no padding; 0 to the next power of 2
    params.Fs = Fs;
    params.fpass = [1 40];
    params.err = 0;               % Error calculation; 1: theorical; 2: Jackniffe
    params.trialave = 0;          % A verage over trial
    
    win = 5;                      % Window length in seconds
    segave = 1;                   % average over segments for 1, dont average for 0
    fq_resolution = 2*params.tapers(1)/win;
    
    [MTS1,f] = mtspectrumsegc(RGEEG(RGwinindex,:),win,params,segave);
    %         [MTS2,f] = mtspectrumsegc(APSEEG(2,:),win,params,segave);
    %         [MTS3,f] = mtspectrumsegc(APSEEG(3,:),win,params,segave);
    %         [MTS4,f] = mtspectrumsegc(APSEEG(4,:),win,params,segave);
    %
    %         MTS1 = pow2db(MTS1);
    %     MTS2 = pow2db(MTS2);
    %     MTS3 = pow2db(MTS3);
    %     MTS4 = pow2db(MTS4);
    
    % Alpha characteristics
    totP = sum(MTS1);                       % total power
    alfaF = find(f > 8 & f < 12);           % index of alpha
    alfaP = MTS1(alfaF,:);                  % alpha pòwer
    alfapeakv = max(alfaP,[],1);            % alpha peak value
    alfapeaki = find(MTS1 == alfapeakv);    % alpha peak index
    alfapeakf = f(alfapeaki);
    totalfa = sum(alfaP);
    relatalfa = totalfa/totP;
    
    %     Adding to table
    TAPS.AlphaRelativePow(NumSubj) = relatalfa;
    TAPS.AlphaPeakFreq(NumSubj) = alfapeakf;
    
    %%%%%%%%%%%%%%%%%%
    %%%%  FIGURE  %%%%
    %%%%%%%%%%%%%%%%%%
    figure('Position',[80 85 1280 720]);
    
    subplot(2,2,1)
    sf = surf(WT3/60,WF3,10*log10(WP3));   % time in minutes and power in dB
    colormap('jet');                    % COLORMAP
    sf.EdgeColor = 'none';
    axis tight
    view(0,90)
    ylim([0 30]);
    xlabel ('time (min)','Fontsize',14)
    ylabel ('Frequency','Fontsize',14)
    caxis([0 15])
    colorbar
    title('Whole session', 'Fontsize',20)
    hold on
    
    subplot(2,2,3)
    sf = surf(T3/60,F3,10*log10(P3));   % time in minutes and power in dB
    colormap('jet');                    % COLORMAP
    sf.EdgeColor = 'none';
    axis tight
    view(0,90)
    ylim([0 30]);
    xt = xticks;
    numel(xt);
    newxticks = linspace(currtINI,currtEND,numel(xt)+1);
    nxtl = num2cell(newxticks(2:end));
    xticklabels(nxtl);
    xlabel ('time (min since start)','Fontsize',14)
    ylabel ('Frequency','Fontsize',14)
    caxis([0 15])
    colorbar
    xx = 1:length(RGEEG(1,:));
    xsp1 = xx/Fs;
    title('APS selected window','Fontsize',20)
    hold on
    
    subplot(2,2,2)
    plot(xsp1,RGEEG(RGwinindex,:),'k')
    axis ('tight')
    xlabel ('time (s)')
    ylabel ('\mu V')
    ylim ([-50 50])
    legend ('Raw EEG','Fontsize',12)
    tempti = ['Window ' num2str(RGwinindex) '/5'];
    title (tempti,'Fontsize',20);
    
    subplot(2,2,4)
    plot(f,MTS1,'LineWidth',2)
    xlabel ('Frequency (Hz)')
    ylabel ('\mu V^2/Hz')
    tempti = ['Alpha Peak = ' sprintf('%.2f',alfapeakf) ' Hz'];
    legend (tempti,'Fontsize',12)
    tempti = ['Alpha rPower = ' sprintf('%.2f',relatalfa)];
    title(tempti,'Fontsize',20)
    
    
    %  Title for figure
    sgtitle(currSubj,'Fontsize',24,'Fontweight','bold')
    hold off
    % Saving figure
    ttjpg = ['Sig_and_Spect_' tt '.jpg'];
    cd (SCTGpath)
    saveas(gcf,ttjpg, 'jpg');
    close
    %%
    %     %     Spectrograms plots
    %     fig(NumSubj) = figure;
    %     sf = surf(T3/60,F3,10*log10(P3));   % time in minutes and power in dB
    %     colormap('jet');                    % COLORMAP
    %     sf.EdgeColor = 'none';
    %     axis tight
    %     view(0,90)
    %     ylim([0 30]);
    %     xt = xticks;
    %     numel(xt);
    %     newxticks = linspace(currtINI,currtEND,numel(xt)+1);
    %     nxtl = num2cell(newxticks(2:end));
    %     xticklabels(nxtl);
    %     xlabel ('time (min)')
    %     ylabel ('Frequency')
    %     caxis([0 15])
    %     colorbar
    %     tt = char(currSubj);
    %     title(tt,'Fontsize',14);
    
    
    %     meanrelatalfa = mean(relatalfa);
    %     stdrelatalfa = std(relatalfa);
    %     TAPS.MeanRelatAlfa(NumSubj) = mean(relatalfa);
    %     TAPS.STDRelatAlfa(NumSubj) = std(relatalfa);
    SpecMat(NumSubj,:,:) = P3;
    
    switch currDel
        case 0
            NonDel = NonDel + 1;
            NonDelrelatalfa(NonDel) = relatalfa;
            NonDelalfapeakf(NonDel) = alfapeakf;
            NonDelMat(NonDel,:,:) = P3;
            
        case 1
            YesDel = YesDel + 1;
            YesDelrelatalfa(YesDel) = relatalfa;
            YesDelalfapeakf(YesDel) = alfapeakf;
            YesDelMat(YesDel,:,:) = P3;
    end
    
    %Save
    ttjpg = ['Spect_APS_' tt '.jpg'];
    ttRG = ['Spectra_' tt '_5x15.mat'];
    cd (SCTGpath);
    save (ttRG,'RGEEG','Fs','currSubj');
    %     saveas(gcf,ttjpg, 'jpg')
    %     close all
end
% Not Delirium
NonDelAveSp = mean(NonDelMat,1);
NonDelAveSp = squeeze(NonDelAveSp);
% Alpha relative power
NonDelAverelatalfa = mean(NonDelrelatalfa);
NonDelSTDrelatalfa = std(NonDelrelatalfa);
% Alpha peak frequency
NonDelAvealfapeakf = mean(NonDelalfapeakf);
NonDelSTDalfapeakf = std(NonDelalfapeakf);

NotDelfigAve = figure;
sf = surf(T3/60,F3,10*log10(NonDelAveSp)); % time in minutes and power in dB
colormap('jet');      %COLORMAP
sf.EdgeColor = 'none';
axis tight
view(0,90)
ylim([0 30]);
xlabel ('time (min)')
ylabel ('Frequency')
caxis([0 15])
colorbar
title('Not Delirium','Fontsize',14);

% Yes Delirium
YesDelAveSp = mean(YesDelMat,1);
YesDelAveSp = squeeze(YesDelAveSp);

NotDelfigAve = figure;
sf = surf(T3/60,F3,10*log10(YesDelAveSp)); % time in minutes and power in dB
colormap('jet');      %COLORMAP
sf.EdgeColor = 'none';
axis tight
view(0,90)
ylim([0 30]);
xlabel ('time (min)')
ylabel ('Frequency')
caxis([0 15])
colorbar
title('Yes Delirium','Fontsize',14);
