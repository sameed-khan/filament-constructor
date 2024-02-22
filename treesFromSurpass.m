function treeArray = treesFromSurpass(ptPath, lenPath, varargin)
% TREESFROMSURPASS This function constructs an array of FilamentTrees given
% the paths to CSV files containing the 'Pt Distance' and 'Dendrite Length'
% metric for a complete Filament Surpass Object
%   @param ptPath: string; path to CSV file containing 'Pt Distance' metric
%   for a complete Filament Surpass object
%   @param lenPath: string; path to CSV file containing 'Dendrite Length'
%   metric for a complete Filament Surpass object
%   @param varargin: variable length keyword argument; should be the number
%   of header lines in the CSV file being analyzed; 3 by default
%   @return treeArray: cell array; cell array containing all FilamentTree
%   objects for this Surpass object

    parser = inputParser;
    addOptional(parser, "num_header_rows", 3);
    parse(parser, varargin{:});
    num_header_rows = parser.Results.num_header_rows;

    pointTb = readtable(ptPath, 'NumHeaderLines', num_header_rows, 'VariableNamingRule', 'preserve');
    ddrTb = readtable(lenPath, 'NumHeaderLines',  num_header_rows, 'VariableNamingRule', 'preserve');
    pointTb.Type = categorical(pointTb.Type); % saves some memory
    
    %Remove 'Dendrite' classified points
    

    % Remove Filaments without beginning points and log them to output
    % TODO: compile all causes filaments were removed and report at bottom
    validFIDs = unique(pointTb.FilamentID(pointTb.Type=='Dendrite Beginning'));
    disp("The following Filament IDs do not have beginning points and were removed:");
    disp(setdiff(pointTb.FilamentID, validFIDs));
    fprintf("n = %i\n", length(validFIDs));

    pointTb = pointTb(ismember(pointTb.FilamentID, validFIDs), :);
    ddrTb = ddrTb(ismember(ddrTb.FilamentID, validFIDs), :);
    
    % Remove unnecessary columns from the data, matrix MUST BE in a
    % very specific format for treeConstructor to accept
    pointTb = pointTb(:, {'Pt Distance', 'Depth', 'FilamentID', 'ID'});
    ddrTb = ddrTb(:, {'Dendrite Length', 'Depth', 'FilamentID', 'ID'});
    pointTb = table2array(pointTb);
    ddrTb = table2array(ddrTb);
    
    treeArray = cell(1, length(validFIDs));
    for i = 1:length(validFIDs)
        fID = validFIDs(i);
        
        % Filter CSV data for this specific FilamentTree
        ptb = pointTb((pointTb(:,3)==fID),:);
        dtb = ddrTb((ddrTb(:,3)==fID),:);
       
        % Generate and construct the FilamentTree
        try
            ft = FilamentTree(fID);
            ft.treeConstructor(ptb, dtb);
        catch ME
            errorMessage = strcat(ME.message, sprintf("| Error from file: %s", ptPath));
            disp(errorMessage);
            continue
        end
        treeArray{i} = ft;
    end
    % Remove Filaments with errors from treeArray
    treeArray = treeArray(~cellfun('isempty', treeArray));

