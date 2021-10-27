%% Greeting

disp(['Script is used to export loaded Simulink model to the previous ',...
    'Matlab releases'])

%% Defaults
outFolder = 'previous';

% new->old order
releases = [...
    "R2020b", "R2020a",...
    "R2019b", "R2019a",...
    "R2018b", "R2018a",...
    "R2017b", "R2017a",...
    "R2016b", "R2016a",...
    "R2015b", "R2015a"
    ];

%% Determining current and exporting releases

release = version('-release');

if release(1)~='R'
    release = strcat('R', release);
end

% Source - https://www.mathworks.com/matlabcentral/answers/44049-extract-numbers-from-mixed-string#answer_269941
year = str2double( regexprep( release, ...
    {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );

fprintf('Current release is %s.\n', release)

rel_index = -1;
for rel_i = 1:releases.length()
    if strcmpi(release,releases(rel_i))
        rel_index = rel_i;
        break;
    end
end

if rel_index == -1
   fprintf(['Your release is unknown\n',...
       'Please, put it in releases list in this file\n'])
   rel_year = str2double( regexprep( releases(1), ...
    {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    if year > rel_year
        fprintf('Assumpting that your release is newer than %s',...
            releases(1))
        rel_index = 0;
    else
        disp("Can't determine releases older than yours, exiting")
       return;
    end
end

%% Determining model

model = bdroot;

if isempty(model)
    [file,path] = uigetfile({'*.mdl;*.slx','Models (*.slx, *.mdl)'},...
        'Choose model');
    if isequal(file,0)
        
        disp('Nothing chosen, exiting');
        return;
    else
        
        disp(['Selected ', fullfile(path,file)]);
        open_system(fullfile(path,file),'loadonly')
        model = bdroot;
        if isempty(model)
            disp('Failed to open, exiting')
            return;
        end
        
    end
end

fprintf('Exporting loaded model %s\n', model)

%% Exporting

if ~exist(outFolder, 'dir')
       mkdir(outFolder)
end

for i = (rel_index+1):releases.length()
    try
        Simulink.exportToVersion(model,...
            sprintf('previous/%s_%s.slx',model, releases(i)),...
            releases(i));
    catch ME
        fprintf('Export failed for use in Simulink %s.\n', releases(i))
        continue
    end
end
