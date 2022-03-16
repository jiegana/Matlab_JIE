% This script uses functions from the BioSig Project
% (http://biosig.sourceforge.net/) to read Biosemi's .bdf files
% Please be sure to have the Biosig Project functions available by using
% biosig_installer.m
% Although in returns an warning regarding Automated Overlow detection and
% others, it correctly reads TTL identifiers and its time stamps
%
% Trig contains TTL information
% sig contains sinal
% head contains file's header 
%
% Use at your own risk
%                   
% Plastikfaith November 2021

%%
clear all                       %remove if necessary
close all                       %remove if necessary

%% Select path to data (.bdf) files
datapath = '/Users/jiegana/Google Drive/Lab_GooDrive/Proyecto_EEG_Anesthesia_Pain/Proyecto_BNI/Pain_for_Purdon_Lab/PainData_fPL';


%% Find folders with EEG files inside
cd (datapath);
filelist = dir(fullfile(datapath, '**/*.bdf'));
for tempidx = 1:length(filelist)
    numsiname = regexp(filelist(tempidx).folder,'\d+','Match');
    filelist(tempidx).pacnum = str2double(numsiname{1});
end

%%
for fileindex = 1%:tempidx
    archi = [filelist(tempidx).folder '/' filelist(tempidx).name];
    [sig, head] = sload (archi,'BDF[4]');
    Trig(:,1) = head.BDF.Trigger.TYP;   % TTL identifier
    Trig(:,2) = head.BDF.Trigger.POS;   % Time position in sample number
    Trig(:,3) = head.SampleRate;        % Sampling rate
    
end
