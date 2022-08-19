% This script is intended to read EDFs files from Pablo Speulveda's Sedline
% files. It is the first part of the analysis.
% It uses fieldtrip (http://www.fieldtriptoolbox.org/start) functions


clear all
close all
clc

EDFpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/Data_PEUMA2';
CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
%% Find folders with EDFs inside
cd (EDFpath);
filelist = dir(fullfile(EDFpath, '**/*.edf'));

%% Read Time data from CSV
cd (CSVpath);
TM = readtable('Tiempos.csv');
%%  
subjs = {'SFXXX'};
subfilecount = 0;
subcount = 1;
for findex =1:length(filelist)
%     Reading ID from folder name
    k = strfind(filelist(findex).folder,'/SF');
    subj = filelist(findex).folder((k+1):k+5); 
%     Reading file inititation time
    fintime = filelist(findex).name(12:18);
    
    tf = strcmp(subjs,subj);        %check change of subject

    if  tf == 0                         %if subject changes
        filelist(findex).ID = {subj};
        subjs = subj;
        filelist(findex).subjfilenum = 1;
%         sc = sc + 1;
        demo(subcount) = findex;
        subcount = subcount + 1;
        
  %for 2nd data point onwards (avoids reading non-existing data)
        if findex > 1
            filelist(findex-1).totfile = filelist(findex-1).subjfilenum;
        end
    elseif tf == 1                      %if same subject
        filelist(findex).ID = {subj};
        filelist(findex).subjfilenum = filelist(findex-1).subjfilenum + 1;
    end

    temp{findex} = subj;
    if findex == length(filelist)       %end of data (last file)
        filelist(findex).totfile = filelist(findex).subjfilenum;
    end
end
totsubjects = unique(temp);

    

