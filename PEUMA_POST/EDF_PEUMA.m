% This script is intended to read EDFs files from PEUMA Sedline
% files. It is the first part of the analysis.

clear all
close all
clc

EDFpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/Data_PEUMA2';
CSVpath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2';
cd (EDFpath);
%% Find folders with EDFs inside
Finfo = dir;                            %Directory information
SubF = find ([Finfo.isdir] == 1);       %Find SubFolders
RealF = {Finfo(SubF).name};             %Folders Names
IndexSA = strmatch('SF',RealF)';        %Indices of Folders named 'caso_'
SDataF = RealF(IndexSA);                %Names of all Folders name containing 'caso_'

%% Find EDF files for each subject folder

for SFindex = 1:length (SDataF)
%         hasedf(1,SFindex) = any(size(dir([[EDFpath '/' SDataF{SFindex}] '**/*.edf' ]),1));
    filelist(SFindex).files = dir(fullfile([EDFpath '/' SDataF{SFindex}], '**/*.edf'));
end

% clearvars -except filelist datapath scriptspath
%%
for NumSubj = 1%:length(filelist,2)
    currSubj = SDataF(NumSubj);
%     numDirs = 
    break
    
    
    
    %%
    
    switch hasbasal
        case 0
            disp ('no Basal File') % No basal File
            EDFFiles = dir('*.edf');
            % Opening EDFs using edfread https://www.mathworks.com/matlabcentral/fileexchange/31900-edfread
            for findex = 1:numel(EDFFiles)
                currFile = char({EDFFiles(findex).name});
                disp(['Working in Subject ' Subjects{NumSubj} 'File ' currFile]);
                PSFile.Subject = currSubj;
                PSFile.File = currFile;
                cfg            = [];
                cfg.dataset    = currFile;
                cfg.continuous = 'yes';
                cfg.channel    = 'all';
                data           = ft_preprocessing(cfg);
                save ([currSubj '_file_' num2str(findex) '.mat'],'data');
            end
            cd (datapath);
        case 1
            disp ('has Basal File') % With Basal File
            
            cd([datapath '/' Subjects{NumSubj} '/Basal']) % Open Basal Dir
            EDFFiles = dir('*.edf');
            for findex = 1:numel(EDFFiles)
                currFile = char({EDFFiles(findex).name});
                disp(['Working in Subject ' Subjects{NumSubj} ' Basal File  ' currFile]);
                PSFile.Subject = currSubj;
                PSFile.File = currFile;
                cfg            = [];
                cfg.dataset    = currFile;
                cfg.continuous = 'yes';
                cfg.channel    = 'all';
                data           = ft_preprocessing(cfg);
                cd([datapath '/' Subjects{NumSubj}])
                save ([currSubj '_Basal_file.mat'],'data');
            end
            cd([datapath '/' Subjects{NumSubj}]) % Return to Subjects dir
            EDFFiles = dir('*.edf');
            for findex = 1:numel(EDFFiles)
                currFile = char({EDFFiles(findex).name});
                disp(['Working in Subject ' Subjects{NumSubj} ' Basal File  ' currFile]);
                PSFile.Subject = currSubj;
                PSFile.File = currFile;
                cfg            = [];
                cfg.dataset    = currFile;
                cfg.continuous = 'yes';
                cfg.channel    = 'all';
                data           = ft_preprocessing(cfg);
                cd([datapath '/' Subjects{NumSubj}])
                save ([currSubj '_file_' num2str(findex) '.mat'],'data');
            end
            
            cd (datapath);
    end
end

%
%     Files = dir ('*.mat');
%     realfile = 0;
%     for findex = 1:numel(Files)
%         findex;
%         statcheck = strfind (Files(findex).name, 'stat');
%         if isempty (statcheck)   ~0
%             realfile = realfile + 1
%             Files(findex).name
%             load(Files(findex).name)
%             eval(['data' num2str(realfile) '= data'])
%             clear data
%         end
%     end
%   for datindex = 1:realfile;
%       datis{datindex} = ['data' num2str(datindex)];
%   end
%

% end
