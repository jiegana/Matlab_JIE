% Process PEUMA EDF in order to plot 1 Time/frequency chart (spectrogram)
% for all files for each patient.
% Reads data
% Appends data
% Generates plot (figure)


clear all
close all
clc

EDFpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/Data_PEUMA2';
CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
%% Find folders with EDFs inside
cd (EDFpath);
filelist = dir(fullfile(EDFpath, '**/*.edf'));

%% Read Time data from CSV
% cd (CSVpath);
% TM = readtable('Tiempos.csv');
%% Read Expert Windows selection from CSV
% cd (CSVpath);
% EW = readtable('Ventanas_Experto.csv');
%%  
subjs = {'SFXXX'};
subfilecount = 0;
subcount = 1;
for findex =1:length(filelist)
%     Reading ID from folder name
    ks = strfind(filelist(findex).folder,'/SF');
    subj = filelist(findex).folder((ks+1):ks+5);
    
% %     Reading file initiation timme from file name
%     kt = strfind(filelist(findex).name,'.edf');
%     finiSEC = filelist(findex).name (kt-2:kt-1);
%     finiMIN = filelist(findex).name (kt-4:kt-3);
%     finiHOUR = filelist(findex).name (kt-6:kt-5);
%     temp1 = [finiHOUR ':' finiMIN ':' finiSEC];
%     temp1 = datetime(temp1, 'Format', 'HH:mm:ss');
%     filelist(findex).initime = temp1;
    
    tf = strcmp(subjs,subj);        %check change of subject

    if  tf == 0                         %if subject changes
        filelist(findex).ID = {subj};
        subjs = subj;
        filelist(findex).subjfilenum = 1;
%         subcount = subcount + 1;
        
  %for 2nd data point onwards (avoids reading non-existing data)
        if findex > 1
            filelist(findex-1).totfile = filelist(findex-1).subjfilenum;
        end
    elseif tf == 1                      %if same subject
        filelist(findex).ID = {subj};
        filelist(findex).subjfilenum = filelist(findex-1).subjfilenum + 1;
    end

%     temp{findex} = subj;
    if findex == length(filelist)       %end of data (last file)
        filelist(findex).totfile = filelist(findex).subjfilenum;
    end
end
totsubjects = length(unique([filelist.ID]));
filespersub = [filelist.totfile];

    

