%% Directing and Initializing
clear all
close all
clc
compuCheck_PA
%% Find folders with Report File inside
cd (datapath);
Finfo = dir;                          %Directory information
SubF = find ([Finfo.isdir] == 1);     %Find SubFolders
RealF = {Finfo(SubF).name};           %SubFolders Names
IndexSA = strmatch('SA_',RealF)';     %Indices of SubFolders named 'SA_'
SDataF = RealF(IndexSA);              %Names of all Subfolders name containing 'SA_'

% Find indices of fubfoldres that contains bdf files
for SFindex = 1:length (SDataF);
    hasBeh (1,SFindex) = any(size(dir([[datapath '/' SDataF{SFindex}] '/Report*.mat' ]),1));
end

Subjects = SDataF(hasBeh);          % Subfolders with bdf names
clearvars -except datapath Subjects
%%
for NumSubj = 1:length(Subjects)
    disp(['Working in Subject ' Subjects{NumSubj}]);
    cd([datapath '/' Subjects{NumSubj}])
    Allfile = dir('Beh_*.mat');
    temp = Allfile.name;
    load (temp);
    factor = 10;
    %     Grand Behavior Structure
    % Age
    GBeh.Suj(NumSubj).age = beh.age;
    GBeh.Suj(NumSubj).PFth = beh.PFth;
    GBeh.Suj(NumSubj).Dth = [beh.Dth];
    GBeh.Suj(NumSubj).remi = [beh.remi];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pain Intensity = 1
    GBeh.Suj(NumSubj).Di1 = mean([beh.Ds1i1.raw(:,2)*factor; beh.Ds2i1.raw(:,2)*factor; beh.Ds3i1.raw(:,2)*factor]);
    % Pain Intensity = 2
    GBeh.Suj(NumSubj).Di2 = mean([beh.Ds1i2.raw(:,2)*factor; beh.Ds2i2.raw(:,2)*factor; beh.Ds3i2.raw(:,2)*factor]);
    % Pain Intensity = 3
    GBeh.Suj(NumSubj).Di3 = mean([beh.Ds1i3.raw(:,2)*factor; beh.Ds2i3.raw(:,2)*factor; beh.Ds3i3.raw(:,2)*factor]);
    % Pain Intensity = 4
    GBeh.Suj(NumSubj).Di4 = mean([beh.Ds1i4.raw(:,2)*factor; beh.Ds2i4.raw(:,2)*factor; beh.Ds3i4.raw(:,2)*factor]);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% ANALGESIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % MILD
    % Analgesia mild, Intensity = 1
    GBeh.Suj(NumSubj).A1i1 = mean([beh.A1s1i1.raw(:,2)*factor; beh.A1s2i1.raw(:,2)*factor; beh.A1s3i1.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 2
    GBeh.Suj(NumSubj).A1i2 = mean([beh.A1s1i2.raw(:,2)*factor; beh.A1s2i2.raw(:,2)*factor; beh.A1s3i2.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 3
    GBeh.Suj(NumSubj).A1i3 = mean([beh.A1s1i3.raw(:,2)*factor; beh.A1s2i3.raw(:,2)*factor; beh.A1s3i3.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 4
    GBeh.Suj(NumSubj).A1i4 = mean([beh.A1s1i4.raw(:,2)*factor; beh.A1s2i4.raw(:,2)*factor; beh.A1s3i4.raw(:,2)*factor]);
    
    % MODERATE
    % Analgesia mild, Intensity = 1
    GBeh.Suj(NumSubj).A2i1 = mean([beh.A2s1i1.raw(:,2)*factor; beh.A2s2i1.raw(:,2)*factor; beh.A2s3i1.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 2
    GBeh.Suj(NumSubj).A2i2 = mean([beh.A2s1i2.raw(:,2)*factor; beh.A2s2i2.raw(:,2)*factor; beh.A2s3i2.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 3
    GBeh.Suj(NumSubj).A2i3 = mean([beh.A2s1i3.raw(:,2)*factor; beh.A2s2i3.raw(:,2)*factor; beh.A2s3i3.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 4
    GBeh.Suj(NumSubj).A2i4 = mean([beh.A2s1i4.raw(:,2)*factor; beh.A2s2i4.raw(:,2)*factor; beh.A2s3i4.raw(:,2)*factor]);
    
    % INTENSE
    % Analgesia mild, Intensity = 1
    GBeh.Suj(NumSubj).A3i1 = mean([beh.A3s1i1.raw(:,2)*factor; beh.A3s2i1.raw(:,2)*factor; beh.A3s3i1.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 2
    GBeh.Suj(NumSubj).A3i2 = mean([beh.A3s1i2.raw(:,2)*factor; beh.A3s2i2.raw(:,2)*factor; beh.A3s3i2.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 3
    GBeh.Suj(NumSubj).A3i3 = mean([beh.A3s1i3.raw(:,2)*factor; beh.A3s2i3.raw(:,2)*factor; beh.A3s3i3.raw(:,2)*factor]);
    % Analgesia mild, Intensity = 4
    GBeh.Suj(NumSubj).A3i4 = mean([beh.A3s1i4.raw(:,2)*factor; beh.A3s2i4.raw(:,2)*factor; beh.A3s3i4.raw(:,2)*factor]);
    
    GBeh.Suj(NumSubj).Di1mA1i1 = GBeh.Suj(NumSubj).Di1 - GBeh.Suj(NumSubj).A1i1;
    GBeh.Suj(NumSubj).Di1mA2i1 = GBeh.Suj(NumSubj).Di1 - GBeh.Suj(NumSubj).A2i1;
    GBeh.Suj(NumSubj).Di1mA3i1 = GBeh.Suj(NumSubj).Di1 - GBeh.Suj(NumSubj).A3i1;
    
    GBeh.Suj(NumSubj).Di2mA1i2 = GBeh.Suj(NumSubj).Di2 - GBeh.Suj(NumSubj).A1i2;
    GBeh.Suj(NumSubj).Di2mA2i2 = GBeh.Suj(NumSubj).Di2 - GBeh.Suj(NumSubj).A2i2;
    GBeh.Suj(NumSubj).Di2mA3i2 = GBeh.Suj(NumSubj).Di2 - GBeh.Suj(NumSubj).A3i2;
    
    GBeh.Suj(NumSubj).Di3mA1i3 = GBeh.Suj(NumSubj).Di3 - GBeh.Suj(NumSubj).A1i3;
    GBeh.Suj(NumSubj).Di3mA2i3 = GBeh.Suj(NumSubj).Di3 - GBeh.Suj(NumSubj).A2i3;
    GBeh.Suj(NumSubj).Di3mA3i3 = GBeh.Suj(NumSubj).Di3 - GBeh.Suj(NumSubj).A3i3;
    
    GBeh.Suj(NumSubj).Di4mA1i4 = GBeh.Suj(NumSubj).Di4 - GBeh.Suj(NumSubj).A1i4;
    GBeh.Suj(NumSubj).Di4mA2i4 = GBeh.Suj(NumSubj).Di4 - GBeh.Suj(NumSubj).A2i4;
    GBeh.Suj(NumSubj).Di4mA3i4 = GBeh.Suj(NumSubj).Di4 - GBeh.Suj(NumSubj).A3i4;
end
%%%%%%%%%%%%%%%%%
% GROUP NUMBERS %
%%%%%%%%%%%%%%%%%

% Pain Intensity = 1
GBeh.G.Di1.mean = mean([GBeh.Suj.Di1]);
GBeh.G.Di1.std  = std([GBeh.Suj.Di1]);
GBeh.G.Di1.serr = std([GBeh.Suj.Di1]) / sqrt( length([GBeh.Suj.Di1]));
% Pain Intensity = 2
GBeh.G.Di2.mean = mean([GBeh.Suj.Di2]);
GBeh.G.Di2.std  = std([GBeh.Suj.Di2]);
GBeh.G.Di2.serr = std([GBeh.Suj.Di2]) / sqrt( length([GBeh.Suj.Di1]));
% Pain Intensity = 3
GBeh.G.Di3.mean = mean([GBeh.Suj.Di3]);
GBeh.G.Di3.std  = std([GBeh.Suj.Di3]);
GBeh.G.Di3.serr = std([GBeh.Suj.Di3]) / sqrt( length([GBeh.Suj.Di3]));
% Pain Intensity = 4
GBeh.G.Di4.mean = mean([GBeh.Suj.Di4]);
GBeh.G.Di4.std  = std([GBeh.Suj.Di4]);
GBeh.G.Di4.serr = std([GBeh.Suj.Di4]) / sqrt( length([GBeh.Suj.Di4]));



%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANALGESIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MILD
% Analgesia mild, Intensity = 1
GBeh.G.A1i1.mean = mean([GBeh.Suj.A1i1]);
GBeh.G.A1i1.std  = std([GBeh.Suj.A1i1]);
GBeh.G.A1i1.serr = std([GBeh.Suj.A1i1]) / sqrt( length([GBeh.Suj.A1i1]));
% Analgesia mild, Intensity = 2
GBeh.G.A1i2.mean = mean([GBeh.Suj.A1i2]);
GBeh.G.A1i2.std  = std([GBeh.Suj.A1i2]);
GBeh.G.A1i2.serr = std([GBeh.Suj.A1i2]) / sqrt( length([GBeh.Suj.A1i2]));
% Analgesia mild, Intensity = 3
GBeh.G.A1i3.mean = mean([GBeh.Suj.A1i3]);
GBeh.G.A1i3.std  = std([GBeh.Suj.A1i3]);
GBeh.G.A1i3.serr = std([GBeh.Suj.A1i3]) / sqrt( length([GBeh.Suj.A1i3]));
% Analgesia mild, Intensity = 4
GBeh.G.A1i4.mean = mean([GBeh.Suj.A1i4]);
GBeh.G.A1i4.std  = std([GBeh.Suj.A1i4]);
GBeh.G.A1i4.serr = std([GBeh.Suj.A1i4]) / sqrt( length([GBeh.Suj.A1i4]));



% MODERATE
% Analgesia moderate, Intensity = 1
GBeh.G.A2i1.mean = mean([GBeh.Suj.A2i1]);
GBeh.G.A2i1.std  = std([GBeh.Suj.A2i1]);
GBeh.G.A2i1.serr = std([GBeh.Suj.A2i1]) / sqrt( length([GBeh.Suj.A2i1]));
% Analgesia moderate, Intensity = 2
GBeh.G.A2i2.mean = mean([GBeh.Suj.A2i2]);
GBeh.G.A2i2.std  = std([GBeh.Suj.A2i2]);
GBeh.G.A2i2.serr = std([GBeh.Suj.A2i2]) / sqrt( length([GBeh.Suj.A2i2]));
% Analgesia moderate, Intensity = 3
GBeh.G.A2i3.mean = mean([GBeh.Suj.A2i3]);
GBeh.G.A2i3.std  = std([GBeh.Suj.A2i3]);
GBeh.G.A2i3.serr = std([GBeh.Suj.A2i3]) / sqrt( length([GBeh.Suj.A2i3]));
% Analgesia moderate, Intensity = 4
GBeh.G.A2i4.mean = mean([GBeh.Suj.A2i4]);
GBeh.G.A2i4.std  = std([GBeh.Suj.A2i4]);
GBeh.G.A2i4.serr = std([GBeh.Suj.A2i4]) / sqrt( length([GBeh.Suj.A2i4]));

% INTENSE
% Analgesia intense, Intensity = 1
GBeh.G.A3i1.mean = mean([GBeh.Suj.A3i1]);
GBeh.G.A3i1.std  = std([GBeh.Suj.A3i1]);
GBeh.G.A3i1.serr = std([GBeh.Suj.A3i1]) / sqrt( length([GBeh.Suj.A3i1]));
% Analgesia intense, Intensity = 2
GBeh.G.A3i2.mean = mean([GBeh.Suj.A3i2]);
GBeh.G.A3i2.std  = std([GBeh.Suj.A3i2]);
GBeh.G.A3i2.serr = std([GBeh.Suj.A3i2]) / sqrt( length([GBeh.Suj.A3i2]));
% Analgesia intense, Intensity = 3
GBeh.G.A3i3.mean = mean([GBeh.Suj.A3i3]);
GBeh.G.A3i3.std  = std([GBeh.Suj.A3i3]);
GBeh.G.A3i3.serr = std([GBeh.Suj.A3i3]) / sqrt( length([GBeh.Suj.A3i3]));
% Analgesia intense, Intensity = 4
GBeh.G.A3i4.mean = mean([GBeh.Suj.A3i4]);
GBeh.G.A3i4.std  = std([GBeh.Suj.A3i4]);
GBeh.G.A3i4.serr = std([GBeh.Suj.A3i4]) / sqrt( length([GBeh.Suj.A3i4]));

%%

figu(1)=figure('Color','w','Position',[300 200 800 600]);

x = [1 2 3];
x1 = mean([GBeh.Suj.Di1mA1i1]);
x2 = mean([GBeh.Suj.Di1mA2i1]);
x3 = mean([GBeh.Suj.Di1mA3i1]);

subplot(1,4,1)
bar(x,[x1 x2 x3],0.75,'c')
hold on
for index = 1:numel(GBeh.Suj)
    plot(x,[GBeh.Suj(index).Di1mA1i1 GBeh.Suj(index).Di1mA2i1 GBeh.Suj(index).Di1mA3i1],'-o','color',[0.4 0.4 0.4],...
        'MarkerFaceColor',[0 0 0]);
    hold on
end

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YTickLabel = {'+10' '0' '-10' '-20' '-30' '-40' '-50' '-60'};
% xlabel('Level of Analgesia','FontSize',20,'FontWeight','bold')
title ('Intensity 1', 'FontSize', 20)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = mean([GBeh.Suj.Di2mA1i2]);
x2 = mean([GBeh.Suj.Di2mA2i2]);
x3 = mean([GBeh.Suj.Di2mA3i2]);

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
ylabel('Change in Pain','FontSize',20,'FontWeight','bold')

subplot(1,4,2)
bar(x,[x1 x2 x3],0.75,'g')
hold on
for index = 1:numel(GBeh.Suj)
    plot(x,[GBeh.Suj(index).Di2mA1i2 GBeh.Suj(index).Di2mA2i2 GBeh.Suj(index).Di2mA3i2],'-o','color',[0.4 0.4 0.4],...
        'MarkerFaceColor',[0 0 0]);
    hold on
end

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
set(gca,'YTickLabel',[]);
title ('Intensity 2', 'FontSize', 20)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1 = mean([GBeh.Suj.Di3mA1i3]);
x2 = mean([GBeh.Suj.Di3mA2i3]);
x3 = mean([GBeh.Suj.Di3mA3i3]);

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
% ylabel('Reduction in Pain','FontSize',20,'FontWeight','bold')

subplot(1,4,3)
bar(x,[x1 x2 x3],0.75,'Facecolor',[0.5412 0.1686 0.8863])
hold on
for index = 1:numel(GBeh.Suj)
    plot(x,[GBeh.Suj(index).Di3mA1i3 GBeh.Suj(index).Di3mA2i3 GBeh.Suj(index).Di3mA3i3],'-o','color',[0.4 0.4 0.4],...
        'MarkerFaceColor',[0 0 0]);
    hold on
end

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
set(gca,'YTickLabel',[]);
title ('Intensity 3', 'FontSize', 20)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1 = mean([GBeh.Suj.Di4mA1i4]);
x2 = mean([GBeh.Suj.Di4mA2i4]);
x3 = mean([GBeh.Suj.Di4mA3i4]);

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
% ylabel('Reduction in Pain','FontSize',20,'FontWeight','bold')

subplot(1,4,4)
bar(x,[x1 x2 x3],0.75,'Facecolor',[1 0 0])
hold on
for index = 1:numel(GBeh.Suj)
    plot(x,[GBeh.Suj(index).Di4mA1i4 GBeh.Suj(index).Di4mA2i4 GBeh.Suj(index).Di4mA3i4],'-o','color',[0.4 0.4 0.4],...
        'MarkerFaceColor',[0 0 0]);
    hold on
end

ax = gca;
% ax.XLim = [0.75 3.25];
ax.XTick = [1 2 3];
ax.XTickLabel = {'A1' 'A2' 'A3'};

ax.YLim = [-15 60];
set(gca,'YTickLabel',[]);
title ('Intensity 4', 'FontSize', 20)
%%
i1 = [GBeh.G.Di1.mean GBeh.G.A1i1.mean GBeh.G.A2i1.mean GBeh.G.A2i1.mean];
i2 = [GBeh.G.Di2.mean GBeh.G.A1i2.mean GBeh.G.A2i2.mean GBeh.G.A2i2.mean];
i3 = [GBeh.G.Di3.mean GBeh.G.A1i3.mean GBeh.G.A2i3.mean GBeh.G.A2i3.mean];
i4 = [GBeh.G.Di4.mean GBeh.G.A1i4.mean GBeh.G.A2i4.mean GBeh.G.A2i4.mean];
figu(2)=figure('Color','w','Position',[300 200 800 600]);

x = [1 2 3 4];
ypos = x*0;
yneg = [GBeh.G.Di1.serr GBeh.G.A1i1.serr GBeh.G.A2i1.serr GBeh.G.A3i1.serr];
errorbar(x,i1,ypos,yneg,'-<','Color',[0.4 0.4 0.4],'Linewidth',2,...
    'markersize',20,'MarkerFaceColor','c','MarkerEdgeColor',[0.2 0.2 0.2])
hold on
yneg = [GBeh.G.Di2.serr GBeh.G.A1i2.serr GBeh.G.A2i2.serr GBeh.G.A3i2.serr];
errorbar(x,i2,ypos,yneg,'-<','Color',[0.4 0.4 0.4],'Linewidth',2,...
    'markersize',20,'MarkerFaceColor','g','MarkerEdgeColor',[0.2 0.2 0.2])
hold on
yneg = [GBeh.G.Di3.serr GBeh.G.A1i3.serr GBeh.G.A2i3.serr GBeh.G.A3i3.serr];
errorbar(x,i3,ypos,yneg,'-<','Color',[0.4 0.4 0.4],'Linewidth',2,...
    'markersize',20,'MarkerFaceColor',[0.5412 0.1686 0.8863],...
    'MarkerEdgeColor',[0.2 0.2 0.2])
hold on
yneg = [GBeh.G.Di4.serr GBeh.G.A1i4.serr GBeh.G.A2i4.serr GBeh.G.A3i4.serr];
errorbar(x,i4,ypos,yneg,'-<','Color',[0.4 0.4 0.4],'Linewidth',2,...
    'markersize',20,'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[0.2 0.2 0.2])

ax = gca;
ax.XLim = [0.75 4.25];
ax.XTick = [1 2 3 4];
ax.XTickLabel = {'No A' 'A1' 'A2' 'A3'};
xlabel('Level of Analgesia','FontSize',20,'FontWeight','bold')

ax.YLim = [0 60];
ylabel('Intensity of perception (0-100)','FontSize',20,'FontWeight','bold')
legend({'Int 1','Int 2','Int 3','Int 4'},'FontSize',32,'Location','north','Orientation','horizontal')
