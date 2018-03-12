function [] = print_mdl(varargin)
% print_mdl()
%
% Syntax:
% print_mdl(Properties)
% print_mdl('Propertyname',PropertyValue,...)
%
% Argumente:
% 'system'            - Name des Simulink-Modells                           (default = gcs)
% 'path'              - Ordner in dem die Grafik gespeichert werden soll    (default = aktueller Ordner)
% 'format'            - Format                                              (default = 'eps')
% 'tag'               - alle Subsystems mit 'tag' im Namen werden gespeichert.
%                       Falls tag = 'all' werden alle Subsysteme gespeichert.
%
% Beispiel:
% print_mdl('system','sldemo_househeat','format','eps');
%
%     Notes:
%     1) System name must be given without extension, e.g. 'MySystem'.
%     2) Output directory must exist
%     3) When output directory is '', current working directory is used
%     4) Model is scanned recursively and goes under masks
%     5) When tag regexp is specified, only those of subsystems
%        which have property 'Tag' set to some non-empty value matching
%        the regular expression are considered.
%     6) Root system is always printed.
%     7) Output filenames are generated in two ways:
%        a) When no regexp is used, it is full pathname of the subsystem
%           within the model, with slashes replaced by underscores.
%        b) With regexp specified, tag values are used as filenames.
%     Cool After the printing, all subsystems are closed, root remains open.
%
%     Written by
%     Tomas Hajek
%     tomas.hajek@st.com
%     2006
%     Changed
%     Thomas Lehmann  
%     2012  

default.system = gcs;
default.path = cd;
default.format = 'eps';
default.tag = '';

if numel(varargin) == 1         % struct wird übergeben
    options = varargin{1};
else                            % PropertyName PropertyValue pairs
    param = {varargin{1:2:end}};
    value = {varargin{2:2:end}};
    options = cell2struct(value,param,2);
end

fn = fieldnames(options);
for l = 1:numel(fn)
    default.(fn{l}) = options.(fn{l});
end
options = default;
f = ['-d',options.format];



% print the root system
open_system(options.system,'force');
print(f, ['-s' options.system], [options.path, '\', strrep(options.system, '/', '_')]);

if nargin < 4
    return;
end


% print the subsystems
if strcmp(options.tag,'all')
    % print all of them, using their names as output filenames
    subsys=find_system(options.system, 'RegExp', 'On', 'LookUnderMasks', 'All', 'BlockType', 'SubSystem');
    for i=1:length(subsys),
        tag = subsys{i};
        open_system(subsys{i},'force');
       
        name_temp = [options.path,'\',strrep(strrep(tag,'/','_'),' ','')];
        try
            print(f, ['-s' subsys{i}], name_temp);
        catch
            warning('MATLAB:cantprint',['can not print ',name_temp]);
        end
        close_system(subsys{i});
    end
else
    % print only tagged ones, using the Tag values as output filenames
    subsys=find_system(options.system, 'RegExp', 'On', 'LookUnderMasks', 'All', 'BlockType', 'SubSystem', 'Tag', options.tag);
    for i=1:length(subsys),
        tag = get_param(subsys{i}, 'Tag');
        open_system(subsys{i},'force');
        print(f, ['-s' subsys{i}], [options.path,'/',tag]);
        close_system(subsys{i});
    end
end

end 
