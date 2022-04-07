function [filelist] = AllFilesWithExt(varargin)
% AllFilesWithExt find all files with certain extension nested in a given directory
% 
% usage [outstruct] = AllFilesWithExt (extension{mandatory input},
% indir{optional}, outdir{optinal})
% 
% Allfilesext finds all files with a given extension located in a given directory 
% and in all directories nested within it. It uses varaible number of
% inputs (1-3).
% Only the extension to look for (exten) is mandatory and it must be used
% as the first input
% 
% exten = char array or string
% indir = folder
% outdir = folder
% 
% If not specified, input and output directories are current directory.
%  
% Output is a structure
%
% 
switch nargin
    case 0
        error ('You need to specify at least extension to look for')
    case 1
        exten = varargin{1};
        %check if extension is string and converts it to char for using it
        %in searchexte
        correxten = isstring(exten);
        if correxten == 1
            exten = convertStringsToChars(exten);
        end
        %If not specified, input and output directories are current directory.
        indir = pwd;
        outdir = pwd;
    case 2
        exten = varargin{1};
        %check if extension is string and converts it to char for using it
        %in searchexten
        correxten = isstring(exten);
        if correxten == 1
            exten = convertStringsToChars(exten);
        end
%         Cheks if indir is folder
        indir = varargin{2};
        checkindir = isfolder(indir);
        if checkindir == 0
            error ('Input directory does not exists');
            return
        end
        
        %If not specified, output directory same as input.
        outdir = varargin{2};
    case 3
        exten = varargin{1};
        %check if extension is string and converts it to char for using it
        %in searchexten
        correxten = isstring(exten);
        if correxten == 1
            exten = convertStringsToChars(exten);
        end
        indir = varargin{2};
%         Cheks if indir is folder
        checkindir = isfolder(indir);
        if checkindir == 0
            error ('Input directory does not exists');
            return
        end
        outdir = varargin{3};
%         Cheks if outdir is folder        
        checkoutdir = isfolder(outdir);
        if checkoutdir == 0
            error ('Output directory does not exists');
            return
        end
        
%     More than 3 inputs    
    otherwise
        error ('Too many inputs')
end
cd (indir);
searchexten = ['**/*.' exten];
filelist = dir(fullfile(indir, searchexten));
arefiles = isempty(filelist);
switch arefiles
    case 0
%finds if there are numbers in folders name
%if there are, assumes all files within that folder belong to same
%data/subject set
%adds data/subject number to structure field call datanum
%if no number is found datanum is void
        for tempidx = 1:length(filelist)
            numsiname = regexp(filelist(tempidx).folder,'\d*','Match'); 
            if ~isempty(numsiname)                                      %
                filelist(tempidx).datanum = str2double(numsiname{1});
            end     
        end
    case 1
        nofiles = ['No files with ' exten ' extension found'];
        disp (nofiles)
end
%filelist = rmfield(filelist,'isdir');
end
