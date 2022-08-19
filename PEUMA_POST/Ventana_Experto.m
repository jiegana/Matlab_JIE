% This script is intended to read EDFs files from Pablo Speulveda's Sedline
% files. It is the first part of the analysis.
% It uses fieldtrip (http://www.fieldtriptoolbox.org/start) functions


clear all
close all
clc

datapath = '/Users/jiegana/Dropbox/Respaldo_FONDEF_ID19I10345/Scripts_Prep_PEUMA2/Data_PEUMA2';
cd (datapath)
%% Find folders with EDFs inside
cd (datapath);
filelist = dir(fullfile(datapath, '**/*.edf'));
%%  
subjs = {'SFXXX'};
subfilecount = 0;
subcount = 1;
for findex =1:length(filelist)
    k = strfind(filelist(findex).folder,'/SF');
    subj = filelist(findex).folder((k+1):k+5);
    
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

    
% %
% for NumSubj = 1:1%length(Subjects)
%     currSubj = Subjects{NumSubj};
%     cd (currSubj)
%     %     Checking wether there is a Basal dir
%     BFinfo = dir;
%     BSubF = find ([BFinfo.isdir] == 1);
%     BRealF = {BFinfo(BSubF).name};
%     disp(['Working in Subject ' Subjects{NumSubj}]);
%     testbasal = strmatch('Basal',BRealF)';
%     
%     if testbasal ~[];
%         hasbasal = 1;
%     else
%         hasbasal = 0;
%     end
%     
%     cd([datapath '/' Subjects{NumSubj}])
%     
%     
%     %%
%     
%     switch hasbasal
%         case 0
%             disp ('no Basal File') % No basal File
%             EDFFiles = dir('*.edf');
%             % Opening EDFs using edfread https://www.mathworks.com/matlabcentral/fileexchange/31900-edfread
%             for findex = 1:numel(EDFFiles)
%                 currFile = char({EDFFiles(findex).name});
%                 disp(['Working in Subject ' Subjects{NumSubj} 'File ' currFile]);
%                 PSFile.Subject = currSubj;
%                 PSFile.File = currFile;
%                 cfg            = [];
%                 cfg.dataset    = currFile;
%                 cfg.continuous = 'yes';
%                 cfg.channel    = 'all';
%                 data           = ft_preprocessing(cfg);
%                 save ([currSubj '_file_' num2str(findex) '.mat'],'data');
%             end
%             cd (datapath);
%         case 1
%             disp ('has Basal File') % With Basal File
%             
%             cd([datapath '/' Subjects{NumSubj} '/Basal']) % Open Basal Dir
%             EDFFiles = dir('*.edf');
%             for findex = 1:numel(EDFFiles)
%                 currFile = char({EDFFiles(findex).name});
%                 disp(['Working in Subject ' Subjects{NumSubj} ' Basal File  ' currFile]);
%                 PSFile.Subject = currSubj;
%                 PSFile.File = currFile;
%                 cfg            = [];
%                 cfg.dataset    = currFile;
%                 cfg.continuous = 'yes';
%                 cfg.channel    = 'all';
%                 data           = ft_preprocessing(cfg);
%                 cd([datapath '/' Subjects{NumSubj}])
%                 save ([currSubj '_Basal_file.mat'],'data');
%             end
%             cd([datapath '/' Subjects{NumSubj}]) % Return to Subjects dir
%             EDFFiles = dir('*.edf');
%             for findex = 1:numel(EDFFiles)
%                 currFile = char({EDFFiles(findex).name});
%                 disp(['Working in Subject ' Subjects{NumSubj} ' Basal File  ' currFile]);
%                 PSFile.Subject = currSubj;
%                 PSFile.File = currFile;
%                 cfg            = [];
%                 cfg.dataset    = currFile;
%                 cfg.continuous = 'yes';
%                 cfg.channel    = 'all';
%                 data           = ft_preprocessing(cfg);
%                 cd([datapath '/' Subjects{NumSubj}])
%                 save ([currSubj '_file_' num2str(findex) '.mat'],'data');
%             end
%             
%             cd (datapath);
%     end
% end
% 
% %
% %     Files = dir ('*.mat');
% %     realfile = 0;
% %     for findex = 1:numel(Files)
% %         findex;
% %         statcheck = strfind (Files(findex).name, 'stat');
% %         if isempty (statcheck)   ~0
% %             realfile = realfile + 1
% %             Files(findex).name
% %             load(Files(findex).name)
% %             eval(['data' num2str(realfile) '= data'])
% %             clear data
% %         end
% %     end
% %   for datindex = 1:realfile;
% %       datis{datindex} = ['data' num2str(datindex)];
% %   end
% %
% 
% % end
