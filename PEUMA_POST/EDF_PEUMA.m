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
    currPath = filelist(APSSubj).files.folder;
    currtINI = tAPS(NumSubj,1);
    currtEND = tAPS(NumSubj,2);
    currDel = DelTrue(NumSubj);
    
    
    for NumSFile = 1:length(filelist(APSSubj).files)
        currFile = filelist(APSSubj).files(NumSFile).name;
        f2r = [currPath '/' currFile];
        [hdr, record] = edfreadUntilDone(f2r);
        %         lrg(NumSFile) = length(record);
        catEEG = cat(2,catEEG,record);
        %         Fs = hdr.frequency(3);
        %         tempi = length(catEEG(1,:) / Fs)
    end
    
    %     Sampling Frequency
    Fs = hdr.frequency(3);
    
    %     EEG Data on APS times
    APSEEG = catEEG(:,floor(currtINI*60*Fs):floor(currtEND*60*Fs));
    
    %     SPECTROGRAMS
    wintime = 2; %in seconds
    winlen = floor(wintime*Fs);
    [S3,F3,T3,P3] = spectrogram(APSEEG(3,:),hann(winlen),[],[],floor(Fs),'yaxis');

%     Spectrograms plots
    fig(NumSubj) = figure;
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
    xlabel ('time (min)')
    ylabel ('Frequency')
    caxis([0 15])
    colorbar
    tt = char(currSubj);
    title(tt,'Fontsize',14);
    
    % Normalized power by time
    totP = sum(P3);
    alfaF = find(F3 > 8 & F3 < 12);
    alfaP = P3(alfaF,:);
    totalfa = sum(alfaP);
    relatalfa = totalfa./totP;
    meanrelatalfa = mean(relatalfa);
    SpecMat(NumSubj,:,:) = P3;
    
    switch currDel
        case 0
            NonDel = NonDel + 1;
            NonDelmeanrelatalfa(NonDel) = meanrelatalfa;
            NonDelMat(NonDel,:,:) = P3;
            
        case 1
            YesDel = YesDel + 1;
            YesDelmeanrelatalfa(YesDel) = meanrelatalfa;
            YesDelMat(YesDel,:,:) = P3;
    end
    
    %Save
    tt = ['Spect_APS_' tt '.jpg'];
    cd (SCTGpath);
%     saveas(gcf,tt, 'jpg')
    close all
end
% Not Delirium
NonDelAveSp = mean(NonDelMat,1);
NonDelAveSp = squeeze(NonDelAveSp);

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

% Not Delirium
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