% This script uses functions from the BioSig Project
% (http://biosig.sourceforge.net/) to read Biosemi's .bdf files
% Please be sure to have the Biosig Project functions available by using
% biosig_installer.m
% Although in returns an warning regarding Automated Overlow detection and
% others, it correctly reads TTL identifiers and its time stamps
%
% Trig contains TTL information
% sig contains signal
% head contains file's header
%
% Use at your own risk
%
% Plastikfaith November 2021

%%
clear all                       %remove if necessary
close all                       %remove if necessary
%% Check Biosig sload function is available
A = exist('sload'); %#ok<EXIST>
if A == 0
    cd ('/Users/jiegana/Documents/Scripts_MatLab/biosig4octmat-2.92')
    biosig_installer
end
%% Select path to data (.bdf) files
datapath = '/Users/jiegana/Google Drive/Lab_GooDrive/Proyecto_EEG_Anesthesia_Pain/Proyecto_BNI/Pain_for_Purdon_Lab/PainData_fPL';
%% Find files and folders with EEG(bdf) files inside datapath
cd (datapath);
filelist = dir(fullfile(datapath, '**/*.bdf'));
%%
for tempidx = 1:length(filelist)
    numsiname = regexp(filelist(tempidx).folder,'\d+','Match'); %finds subject's ID number
    filelist(tempidx).pacnum = str2double(numsiname{1});        %add field to structure subject's number
end

%%
for fileindex = 1%:tempidx
    archi = [filelist(tempidx).folder '/' filelist(tempidx).name];
    [sig, head] = sload (archi,'BDF[4]');
    
    BDFJIE.event(:,1) = head.BDF.Trigger.TYP;   % TTL identifier
    BDFJIE.event(:,2) = head.BDF.Trigger.POS;   % Time position in sample number
    BDFJIE.event(:,3) = head.SampleRate;        % Sampling rate
    BDFJIE.signal = sig;
    BDFJIE.header = head;
    
end
