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


clear all


fileData = dir('*.bdf');            %Encuentra los archivos .asc dentro del
fileNames = {fileData.name};        %directorio especificado y saca nombres
narchi = length(fileNames);

%%
for fileindex = 1:narchi
    archi = fileNames{fileindex};
    [sig, head] = sload (archi,'BDF[4]');
    Trig(:,1) = head.BDF.Trigger.TYP;   % TTL identifier
    Trig(:,2) = head.BDF.Trigger.POS;   % Time position in sample number
    Trig(:,3) = head.SampleRate;        % Sampling rate
    
end