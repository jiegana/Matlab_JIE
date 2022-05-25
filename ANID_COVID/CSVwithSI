% Indice de sedacion datos ANID-COVID
% Este código utiliza los csv ANID-COVID para determinar el nivel de
% sedación.
%
% El nivel se clasifica en
% -1 = Muy sedado
% 0  = Adecuadamente sedado
% 1  = Insuficientemente sedado

%% Cleaning
clear all;                                                  % Clear variables
close all;
clc                                                         % Clear Command Window
datapath = '/Users/jiegana/Dropbox/rBIS/Datos_ANID/DATOS BIS Y CLINICOS/Convertidos a CSV';      % Data Path (Optional)
scriptpath = '/Users/jiegana/Dropbox/rBIS/Datos_ANID/DATOS BIS Y CLINICOS';

%% Find folders with EEG files inside
cd (datapath);
filelist = dir(fullfile(datapath, '**/Paciente*.csv')); %specify token and extension

% this for loops seeks for more than one file within a folder. If that is
% the case, it assumes those files belong to the same subject. Optional
% for tempidx = 1:length(filelist)
%     numsiname = regexp(filelist(tempidx).folder,'\d*','Match');
%     if str2double(numsiname) ~=0
%         filelist(tempidx).pacnum = str2double(numsiname{1});
%         [pacgr, pacid] = findgroups([filelist(:).pacnum]);
%         numpac = length(pacid);
%     end
% end

%% Read cvs files and generates a Matrix (M) and a Table (T)

for numfile = 1:numel(filelist)
    % searchs for original files (without '_si.csv'in its name)
    if isempty(strfind(filelist(numfile).name,'_si.csv')) == 1
        disp (['correcto = ' filelist(numfile).name])
        
        M = csvread(filelist(numfile).name,1,1);
        T = readtable (filelist(numfile).name,'VariableNamingRule','preserve','VariableNamesLine',1);
        
        disp (['Working on ' filelist(numfile).name])
        for rindex = 1:size (M,1)
            %
            %           SEDATION INDEX CALCULATION
            %
            
            %   Criteria use the following columns
            %   Column 1 = Bis1
            %   Column 10 = Supre1
            %   Column 11 = Sef951
            
            %   Oversedated = -1
            if M(rindex,1) < 35 || M(rindex,10) > 2 || M(rindex,11) < 8
                M(rindex,13) = -1;
                
            %   Undersedated = 1
            elseif M(rindex,1) > 65 || M(rindex,11) > 15
                M(rindex,13) = 1;
                
            %   Properly sedated = 0
            else
                M(rindex,13) = 0;
            end
        end
        % Diference between Matrix and Table
        % Table may omit first data if it is empty (',')
        diferencia = size(M,1) - size(T,1);
        
        % Change columns names
        realVarNames = [{'Hora'} {'Fecha'} {'Bis1'} {'Bis3'} {'Qualy1'}...
            {'Qualy2'} {'Qualy3'} {'TPow1'} {'TPow3'} {'EmgPow1'}...
            {'EmgPow3'} {'Supre1'} {'Sef951'} {'Mfreq1'}];
        T.Properties.VariableNames = realVarNames;
        
        % Concatenating Sedation Index
        T.SedIndex = M(diferencia+1:end,13);
        xlsfilename = [filelist(numfile).name(1:(end-4)) '_six.xls'];
        writetable(T,xlsfilename)
        disp ([filelist(numfile).name ' ready' newline])
    else
        disp(['malo = ' filelist(numfile).name newline]);
    end
end

