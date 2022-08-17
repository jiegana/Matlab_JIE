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

%% Figures for Controls & Intervention Groups
figControl = figure;
figIntervention = figure;
%% Read cvs files and generates a Matrix (M) and a Table (T)
%%%%%%%%%%%%%%%%%%%%%%
% Defining variables %
%%%%%%%%%%%%%%%%%%%%%%

% Data points
numpt = 0;
numptControl = 0;
numptInterv = 0;
% goodBIS wrongSUPRE
gBISwSUPRE = 0;
gBISwSUPREControl = 0;
gBISwSUPREInterv = 0;
% goodBIS wrongSEF
gBISwSEF = 0;
gBISwSEFControl = 0;
gBISwSEFInterv = 0;
% goodBIS wrongSUPRE and wrongSEF
gBISwSUPREwSEF = 0;
gBISwSUPREwSEFControl = 0;
gBISwSUPREwSEFInterv = 0;
% goodBIS wrongSUPRE or wrongSEF
gBISwSUPRE_OR_wSEF = 0;
gBISwSUPRE_OR_wSEFControl = 0;
gBISwSUPRE_OR_wSEFInterv = 0;

% temporal data
t1 = [];
t2 = [];
t3 = [];

load ('T2.mat');

for numfile = 1:numel(filelist)
    % searchs for original files (without '_si.csv'in its name)
    if isempty(strfind(filelist(numfile).name,'_si.csv')) == 1
        disp (['correcto = ' filelist(numfile).name])
        %         Patient enrolment number
        numingres = str2double(filelist(numfile).name((end-5:end-4)));
        Mv4 = csvread(filelist(numfile).name,1,1);
        Tv4 = readtable (filelist(numfile).name,'Delimiter','comma','VariableNamingRule','preserve','VariableNamesLine',1);
        pacnum = str2double(regexp(filelist(numfile).name,'\d*','Match'));
        disp (['Working on ' filelist(numfile).name])
        for rindex = 1:size (Mv4,1)
            %
            %           SEDATION INDEX CALCULATION
            %
            
            %   Criteria use the following columns
            %   Column 1 = Bis1
            %   Column 10 = Supre1
            %   Column 11 = Sef951
            
            %   Oversedated = -1
            if Mv4(rindex,1) < 35 || Mv4(rindex,10) > 2 || Mv4(rindex,11) < 8
                Mv4(rindex,13) = -1;
                
                %   Undersedated = 1
            elseif Mv4(rindex,1) > 65 || Mv4(rindex,11) > 15
                Mv4(rindex,13) = 1;
                
                %   Properly sedated = 0
            else
                Mv4(rindex,13) = 0;
            end
        end
        % Diference between Matrix and Table
        % Table may omit first data if it is empty (',')
        diferencia = size(Mv4,1) - size(Tv4,1);
        
        % Change columns names
        realVarNames = [{'Hora_Fecha'} {'Bis1'} {'Bis3'} {'Qualy1'}...
            {'Qualy2'} {'Qualy3'} {'TPow1'} {'TPow3'} {'EmgPow1'}...
            {'EmgPow3'} {'Supre1'} {'Sef951'} {'Mfreq1'}];
        Tv4.Properties.VariableNames = realVarNames;
        
        % Concatenating Sedation Index
        Tv4.SedIndex = Mv4(diferencia+1:end,13);
        %         xlsfilename = [filelist(numfile).name(1:(end-4)) '_six.xls'];
        %         writetable(T,xlsfilename)
        BIS =str2double(string(Tv4.Bis1));
        SEF =str2double(string(Tv4.Sef951));
        SUPRE =str2double(string(Tv4.Supre1));
        
        %% Selecting figure to plot given Control = 0 or Intervention = 1
        CoI = T2.GRUPODEESTUDIO0_GrupoControl1_ProtocoloEEG(numingres);
        switch CoI
            case 0
                disp ([filelist(numfile).name ' is Control Group']);
                figure(figControl);
                hold on
                
            case 1
                disp ([filelist(numfile).name ' is Intervention Group']);
                figure(figIntervention);
                hold on
        end
        for numdata = 1:length(SUPRE)
            % Equalizing date formats
            ft1 = datetime(Tv4.Hora_Fecha(numdata),'InputFormat','HH:mm dd-MM-yy');
            ft2 = datetime(T2.FechaDeAleatorizaci_nDD_MM_AA(numingres),'InputFormat','dd-MM-yy');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             Date Range            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ft1 >= ft2 && ft1 < ft2+6
                numpt = numpt + 1;
                switch CoI
                    case 0
                        numptControl = numptControl + 1;
                    case 1
                        numptInterv = numptInterv + 1;
                end
                if SUPRE(numdata) > 2
                    col = 'r';
                else
                    col = 'b';
                end
                p1 = plot (SEF(numdata), BIS(numdata), '.', 'markersize',8,'color',col);
                
                %%%%
                %             Determining good and wrong
                %%%%
                
                %             good BIS wrong SUPRE
                if BIS(numdata) > 40 && BIS(numdata) < 60 && SUPRE(numdata) > 2
                    gBISwSUPRE = gBISwSUPRE + 1;
                    switch CoI
                        case 0
                            gBISwSUPREControl = gBISwSUPREControl + 1;
                        case 1
                            gBISwSUPREInterv = gBISwSUPREInterv + 1;
                    end
                end
                %             good BIS wrong SEF
                if BIS(numdata) > 40 && BIS(numdata) < 60 && SEF(numdata) < 10
                    gBISwSEF = gBISwSEF + 1;
                    switch CoI
                        case 0
                            gBISwSEFControl = gBISwSEFControl + 1;
                        case 1
                            gBISwSEFInterv = gBISwSEFInterv + 1;
                    end
                end
                %             good BIS wrong SUPRE and wrong SEF
                if BIS(numdata) > 40 && BIS(numdata) < 60 && SUPRE(numdata) > 2 && SEF(numdata) < 10
                    gBISwSUPREwSEF = gBISwSUPREwSEF + 1;
                    switch CoI
                        case 0
                            gBISwSUPREwSEFControl = gBISwSUPREwSEFControl + 1;
                        case 1
                            gBISwSUPREwSEFInterv = gBISwSUPREwSEFInterv + 1;
                    end
                end
                %             good BIS wrong SUPRE OR wrong SEF
                if (BIS(numdata) > 40 && BIS(numdata) < 60) && SUPRE(numdata) > 2 | SEF(numdata) < 10
                    gBISwSUPRE_OR_wSEF = gBISwSUPRE_OR_wSEF + 1;
                    switch CoI
                        case 0
                            gBISwSUPRE_OR_wSEFControl = gBISwSUPRE_OR_wSEFControl + 1;
                        case 1
                            gBISwSUPRE_OR_wSEFInterv = gBISwSUPRE_OR_wSEFInterv + 1;
                    end
                end
            end
        end
        t1 = cat(1,t1,SEF);
%         a = length(t1);
        
        t2 = cat(1,t2,BIS);
%         b = length(t2);
        
        t3 = cat(1,t3,SUPRE);
%         c = length(t3);
        
        
        suprimidos = find(SUPRE > 2);
        supercent(numfile) = (length(suprimidos)/length(SUPRE)) *100;
        xlabel ('SEF (Hz)','FontWeight','bold','FontSize',12)
        ylabel ('BIS','FontWeight','bold','FontSize',12)
        
        
        disp ([filelist(numfile).name ' ready' newline])
    else
        disp(['malo = ' filelist(numfile).name newline]);
    end
end

%% Plot details
%Figure Controls
figure(figControl)
title ('CONTROL');
ylim([0 100])
xlim([0 30])
% Line at SEF 10
x1 = [10 10];
y1 = [0 100];
line(x1,y1,'Color',[0.7 0.7 0.7 0.5], 'linewidth', 3)

%Legend
lgd = legend('SR < 2','SR > 2','','Location','northwest','FontSize',14,'Fontweight','bold');
legend('boxoff')
hold off

% Figure Intervention
figure(figIntervention)
title ('INTERVENTION');
ylim([0 100])
xlim([0 30])
% Line at SEF 10
x1 = [10 10];
y1 = [0 100];
line(x1,y1,'Color',[0.7 0.7 0.7 0.5], 'linewidth', 3)

%Legend
lgd = legend('SR < 2','SR > 2','','Location','northwest','FontSize',14,'Fontweight','bold');
legend('boxoff')
hold off
% % saveas(gcf,'Fig_extra_2','epsc')

%% Data in strucuture
DatAnid.SEF = t1;
DatAnid.BIS = t2;
DatAnid.SUPRE = t3;
DatAnid.gBISwSUPRE = gBISwSUPRE;
DatAnid.gBISwSEF = gBISwSEF;
DatAnid.gBISwSUPREwSEF = gBISwSUPREwSEF;
DatAnid.gBISwSUPRE_OR_wSEF = gBISwSUPRE_OR_wSEF;
% DatAnid.figure = fig1;

% save ('Data_Anid.mat','DatAnid')
