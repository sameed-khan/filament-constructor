classdef FilamentTree < handle
    %FILAMENTTREE MATLAB representation of Imaris Filament object. 
    %   Imaris allows for a diverse array of valuable statistics that can
    %   be gleaned from the Filaments plugin. A Filament object contains 
    %   statistics by dendrite and by point. However, one major drawback is
    %   that Imaris Filaments offers no information about how branches or
    %   points relate to each other. This class uses Imaris Pt Position and
    %   Dendrite Length to construct a Tree that models the corresponding
    %   Imaris Filament.
    %
    %   NOTE: This code was designed for segmentation of uterine glands via
    %   Filaments. This use case involves many separate filaments objects
    %   that are each relatively simple trees. Iteratively constructing the
    %   tree therefore takes the liberty of O(n^2) time complexity and is
    %   O(n^3) time complexity when called to construct all trees for a
    %   Filament Surpass object (assuming the Surpass object contains many
    %   filaments)
    
    properties
        filamentID; % Imaris ID of the Filament (NOT the Surpass object, but an individual filament)
        statistics; % MATLAB MapContainer containing Filament statistics
        pointStatisticsList; % cell array containing the names of metrics that this FilamentTree contains for its points.
        dendriteStatisticsList; % cell array containing the names of metrics that this FilamentTree contains for its dendrites (edges).
        mapping; % cell array containing Imaris IDs mapped to the actual FilamentPoints.
        imarisIndexLookup; % MapContainer facilitating easy lookup of FilamentPoint by Imaris ID.
        dendriteToPoint; % MapContainer linking dendrite Imaris ID to corresponding FilamentPoint
        root; % beginning point of the Filament object
    end
    
    methods
        function obj = FilamentTree(filamentID)
            % Constructor function to create basic FilamentTree. To
            % populate the FilamentTree with points and dendrites, please
            % call constructFromCSV(path_to_Pt_Distance.csv,
            % path_to_Dendrite_Length.csv) to populate the tree. 
            % @param filamentID: The Imaris ID of the filament. Used to
            % index into the CSV file and construct the appropriate
            % filament.
            % NOTE: constructFromCSV is not used as object constructor here
            % to allow for easier extensibility with subtrees and so forth.
            
            if nargin == 0
                obj.filamentID = NaN;
                disp("FilamentTree was constructed with no arguments!");
            end
            obj.filamentID = filamentID;
            obj.statistics = containers.Map();
            obj.pointStatisticsList = {};
            obj.dendriteStatisticsList = {};
            obj.mapping = cell(0);
            obj.imarisIndexLookup = containers.Map();
            obj.dendriteToPoint = containers.Map();
            obj.root = 'NULL';
        end
        function addTreeStatisticsFromCSV(obj, csvPath, statName, varargin)           
            parser = inputParser;
            addOptional(parser, "num_header_rows", 3);
            parse(parser, varargin{:});
            num_header_rows = parser.Results.num_header_rows;
            
            tbl = readtable(csvPath, 'NumHeaderLines', num_header_rows, 'VariableNamingRule', 'preserve');
            stat = tbl(tbl.ID == obj.filamentID, :);
            if height(stat) > 1
                error('FilamentTree:DuplicateID', 'FilamentTree %i is represented more than once in this CSV file. Please correct', obj.filamentID);
            end
            if isempty(stat)
                warning('FilamentTree:MissingID', 'FilamentTree %i is not found in this CSV file. Please correct.', obj.filamentID);
            end
            for j = 1:length(statName)
                nm = statName{j};
                obj.statistics(nm) = table2array(stat(1, nm));
            end
        end
        function addPointStatisticsFromCSV(obj, csvPath, statName, varargin)
        % Adds all point statistics for a particular filament from an
        % Imaris output CSV for any Filament statistic. 
        % @param csvPath: a string containing the path to the relevant
        % POINT statistics CSV file
        % @param statName: cell array; names of statistics being added
        % (certain statistics such as Pt Position are not a single
        % statistic but a combination of three values: X, Y, Z)
        % @param varargin: integer; only one keyword argument which is the
        % number of header rows in the CSV file being read in
            
            parser = inputParser;
            addOptional(parser, "num_header_rows", 3);
            parse(parser, varargin{:});
            num_header_rows = parser.Results.num_header_rows;
            
            if isempty(obj.root.childrenByReference)
                error(...
                    "FilamentTree contains no Filaments. Please call FilamentTree.constructFromCSV")
            end
            % Select relevant statistics from CSV data and filter for
            % this specific FilamentTree
            tbl = readtable(csvPath, 'NumHeaderLines', num_header_rows, 'VariableNamingRule', 'preserve');
            % Filter out 'Dendrite' points
            tbl = tbl(~strcmp(tbl.Type, 'Dendrite'),:);
            tbl = tbl(:, horzcat(statName, { 'FilamentID', 'ID' }));
            tbl = tbl(tbl.FilamentID == obj.filamentID, :);
            
            % Get the matching FilamentPoint for statistic and add stat
            for i = 1:length(tbl.ID)
                % If data contains points that are not in the FilamentTree,
                % discard. Besides Dendrite Beginning, Branching, and
                % Terminal Points, users can also get 'Dendrite' points -
                % junctions where a dendrite had a branch that was deleted
                if ~isKey(obj.imarisIndexLookup, tbl.ID(i))
                    continue
                end
                node = obj.imarisIndexLookup(tbl.ID(i));
                for j = 1:length(statName)
                    stat = statName{j};
                    node.addPointStat(stat, table2array(tbl(i, stat)));
                end
            end
            obj.pointStatisticsList = horzcat(obj.pointStatisticsList, statName);
        end
        function addDendriteStatisticsFromCSV(obj, csvPath, statName, varargin)
        % Adds all dendrite statistics for a particular filament from
        % an Imaris output CSV for any Filament statistic.
        % @param csvPath: a string containing the path to the relevant
        % statistics CSV file
        % @param statName: string; name of the statistic being added
        % @param varargin: integer; only one keyword argument which is the
        % number of header rows in the CSV file being read in
            
            parser = inputParser;
            addOptional(parser, "num_header_rows", 3);
            parse(parser, varargin{:});
            num_header_rows = parser.Results.num_header_rows;
               
            if isempty(obj.root.childrenByReference)
                error(...
                "FilamentTree contains no data. Please call FilamentTree.constructFromCSV")
            end
                        % Select relevant statistics from CSV data and filter for
            % this specific FilamentTree
            tbl = readtable(csvPath, 'NumHeaderLines', num_header_rows, 'VariableNamingRule', 'preserve');
            tbl = tbl(:, horzcat(statName, { 'FilamentID', 'ID' }));
            tbl = tbl(tbl.FilamentID == obj.filamentID, :);
            
            % Get the matching dendrite for statistic and add stat
            for i = 1:length(tbl.ID)
                % If data contains points that are not in the FilamentTree,
                % discard. Besides Dendrite Beginning, Branching, and
                % Terminal Points, users can also get 'Dendrite' points -
                % junctions where a dendrite had a branch that was deleted
                if ~isKey(obj.imarisIndexLookup, tbl.ID(i))
                    fprintf("Dendrite ID %i at Filament ID %i\n", ...
                        tbl(i, tbl.ID), obj.filamentID);
                    error("Dendrite with no matching FilamentPoint");
                end
                dendriteNode = obj.dendriteToPoint(tbl(i, tbl.ID));
                for j = 1:length(statName)
                    stat = statName{j};
                    dendriteNode.addDendriteStat(stat, table2array(tbl(i, stat)));
                end
            end
            obj.dendriteStatisticsList = horzcat(obj.dendriteStatisticsList, statName);
        end
        function statPresent = hasPointStatistic(obj, statName)
        % Returns true or false if FilamentTree has the statistic
        % @param statName: string; name of the Imaris statistic
            statPresent = ismember(statName, obj.pointStatisticsList);
        end
        function dStatPresent = hasDendriteStatistic(obj, statName)
        % Returns true or false if FilamentTree has the DENDRITE statistic
        % @param statName: string; name of the Imaris Dendrite statistic
            dStatPresent = ismember(statName, obj.dendriteStatisticsList);
        end
        function point = getExtendedTerminal(obj)
            [mx, idx] = max(cellfun(@(x) x.statistics('Pt Distance'), obj.mapping(:,2)));
            point = obj.mapping{idx,2};
        end
        function treeConstructor(obj, filamentPoints, ...
                filamentDendrites)
            % @param filamentPoints: an n x 4 matrix where n is the sum of all
            % terminal, branch, and beginning points within the filament. 
            % The matrix must be sorted in order of increasing depth. 
            % The columns should be ordered as follows:
            % || Pt Distance || Depth || Filament ID || Point ID
            %
            % @param filamentDendrites: an n x 4 matrix where n is the number of
            % dendrites that belong to the filament. Matrix must be sorted in order
            % of ascending depth. The columns should be ordered as follows:
            % || Dendrite Length || Depth || Filament ID || Dendrite ID
            %
            % @return obj: a new FilamentTree that models the specific
            % filament in Imaris
            obj.statistics = containers.Map();
            obj.mapping = cell(length(filamentPoints(:,1)), 2);
            obj.imarisIndexLookup = containers.Map('KeyType', 'double', ...
                'ValueType', 'any');
            obj.dendriteToPoint = containers.Map('KeyType', 'double', ...
                'ValueType', 'any');
            mappingIdx = 3; % first two points are added outside loop

            % Sorting by depth makes debugging easier later since each
            % iteration is organized based on depth
            filamentPoints = sortrows(filamentPoints, 2);
            filamentDendrites = sortrows(filamentDendrites, 2);

            % Get the beginning point and first branch point at depth 0
            ind = filamentPoints(:, 2) == 0;
            depthZeroPoints = filamentPoints(ind,:); % submatrix all pts depth 0
            depthZeroPoints = sortrows(depthZeroPoints, 1);
            if length(depthZeroPoints(:,1)) ~= 2
                error('FilamentTree:BranchingBeginningPoint', ...
                    'Filament ID %i has a branching beginning point. Please correct.', obj.filamentID);
            end
            bPoint = depthZeroPoints(1, :);
            brPoint = depthZeroPoints(2,:);

            % Construct the beginning point and first branch point
            beginningPoint = FilamentPoint(bPoint(4));
            beginningPoint.addPointStat('Pt Distance', 0);

            firstBranchPoint = FilamentPoint(brPoint(4));

            firstBranchPoint.addPointStat('Pt Distance', ...
                brPoint(1));
            firstBranchPoint.addDendriteStat('Dendrite Length', ...
                filamentDendrites(1, 1));
            firstBranchPoint.addDendriteStat('Depth', 0);
            firstBranchPoint.dendriteId = filamentDendrites(1, 4);                
            firstBranchPoint.parent = beginningPoint;

            beginningPoint.addChild(firstBranchPoint);
            obj.root = beginningPoint;

            % Add both points to the FilamentTree mapping and lookup
            obj.mapping{1, 1} = beginningPoint.id;
            obj.mapping{1, 2} = beginningPoint;
            obj.mapping{2, 1} = firstBranchPoint.id;
            obj.mapping{2, 2} = firstBranchPoint;

            obj.imarisIndexLookup(beginningPoint.id) = beginningPoint;
            obj.imarisIndexLookup(firstBranchPoint.id) = firstBranchPoint;
            obj.dendriteToPoint(firstBranchPoint.dendriteId) = firstBranchPoint;

            % Define tracker variables for iteratively adding nodes
            currentDepth = 1; % The depth of the tree which we are at
            parentPoints = { firstBranchPoint }; % List of parent points at current depth to assign children to, start with first branch point
            remainingTotalPoints = length(filamentPoints(:,1)) - 2; % Account for beginning point and first branch point

            % Iterate through list, adding points to tree breadth-wise
            while remainingTotalPoints ~= 0
                % Construct list of child points to assign at depth
                ind = filamentPoints(:, 2) == currentDepth;
                ind_d = filamentDendrites(:,2) == currentDepth;
                currentDepthPts = filamentPoints(ind, :);
                currentDepthDendrites = filamentDendrites(ind_d,:);
                numPoints = length(currentDepthPts(:,1)); % Describes the number of child points at this depth that need to be given parents
                childPoints = cell(1, numPoints);
                for i = 1:numPoints
                    fp = FilamentPoint(currentDepthPts(i, 4));
                    fp.addPointStat('Pt Distance', currentDepthPts(i, 1));
                    fp.addPointStat('Filament ID', obj.filamentID);
                    fp.addPointStat('Depth', currentDepth);
                    childPoints{i} = fp;
                end

                % Order of pts in currentDepthPtsData must match order
                % of pts in childPoints. Iteration above should ensure
                % this but potential source of bugs. 

                % Generate list of parent distances
                parentDistances = zeros(1, length(parentPoints));
                for i = 1:length(parentPoints)
                    parentDistances(i) = parentPoints{i}.statistics('Pt Distance');
                end

                % Generate difference matrix of child distance - parent
                % distance where the correct distance will match to the
                % dendrite length connecting the parent point to the
                % child point. Which child is connected to which parent
                % is encoded in the row and column indices of the
                % difference matrix.
                childDistances = currentDepthPts(:,1);
                dendriteLengths = currentDepthDendrites(:,1)';
                
                % Calculate difference threshold, account for similar
                % dendrite lengths, child distances, or parent distances so
                % that matching by length works. Default to 0.01 if
                % threshold is greater than this value. 
                threshs = ones(1, 3);
                if length(dendriteLengths) > 1
                    a = abs(dendriteLengths - dendriteLengths');
                    threshs(1) = min(a(a>0));
                end
                if length(childDistances) > 1
                    a = abs(childDistances - childDistances');
                    threshs(2) = min(a(a>0));
                end
                if length(parentDistances) > 1
                    a = abs(parentDistances - parentDistances');
                    threshs(3) = min(a(a>0));
                end
                threshold = min(threshs);
                if threshold < 0.01
                    threshold = [threshold, 0.01:0.001:0.02];
                else
                    threshold = 0.01;
                end
                
                childIdx = []; parentIdx = [];
                cCopy = childDistances;
                j = 1;
                while any(cCopy)
                    [t1, t2] = assignObjects(cCopy, parentDistances, dendriteLengths, threshold(j));
                    childIdx = vertcat(childIdx, t1);
                    parentIdx = vertcat(parentIdx, t2);
                    % Remove child points that are matched
                    for i = 1:length(t1)
                        cCopy(t1(i)) = 0;
                    end
                    j = j + 1;
                end
                
                childDdrIdx = []; dendriteIdx = [];
                cCopy = childDistances;
                j = 1;
                while any(cCopy)
                    [t1, t2] = assignObjects(cCopy, dendriteLengths, parentDistances, threshold(j));
                    childDdrIdx = vertcat(childDdrIdx, t1);
                    dendriteIdx = vertcat(dendriteIdx, t2);
                    % Remove child points that are matched
                    for i = 1:length(t1)
                        cCopy(t1(i)) = 0;
                    end
                    j = j + 1;
                end
                % Add code to check for missing and increase threshold just
                % to link the missing guy
%                 diffs = childDistances - parentDistances;
%                 locs = zeros(size(diffs));
%                 for i = 1:numPoints
%                     temp = diffs - dendriteLengths(i);
%                     temp = round(temp, 3);
%                     locs = locs + (temp > -1*threshold & temp < threshold);
%                     [childIdx, parentIdx] = find(locs);
%                 end
% 
%                 % Find the dendrites that belong to each child point
%                 % using the same approach as above. Child distance -
%                 % dendrite length must equal parent distance
% 
%                 diffs = childDistances - dendriteLengths;
%                 locs = zeros(size(diffs));
%                 for i = 1:length(parentPoints)
%                     temp = diffs - parentDistances(i);
%                     temp = round(temp, 3);
%                     locs = locs + (temp > -1*threshold & temp < threshold);
%                     [childDdrIdx, dendriteIdx] = find(locs);
%                 end

                % Error checking - number of children found via dendrite
                % matching must match the number of children available,
                % same for dendrites
                if length(childIdx) > numPoints
                    error('FilamentTree:TooLowChildParentThreshold',...
                        "False child match to parent at depth %i for FilamentTree %i", currentDepth, obj.filamentID);
                elseif length(childIdx) < numPoints
                    error('FilamentTree:TooHighChildParentThreshold',...
                        "Missing child match to parent at depth %i for FilamentTree %i", currentDepth, obj.filamentID);
                elseif length(childDdrIdx) > numPoints
                    error('FilamentTree:TooLowDendriteToChildThreshold',...
                        "False dendrite match to parent at depth %i for FilamentTree %i", currentDepth, obj.filamentID);
                elseif length(childDdrIdx) < numPoints
                    error('FilamentTree:TooHighDendriteToChildThreshold',...
                        "Missing dendrite match to parent at depth %i for FilamentTree %i", currentDepth, obj.filamentID);
                end
                % Link children and parents together
                for i = 1:length(childIdx)
                    pointIdx = childIdx(i);
                    pPointIdx = parentIdx(i);
                    point = childPoints{pointIdx};
                    parentPoint = parentPoints{pPointIdx};

                    point.parent = parentPoint;
                    parentPoint.addChild(point);
                end

                % Link child points to their dendrite
                for i = 1:length(childDdrIdx)
                    pointIdx = childDdrIdx(i);
                    ddrIdx = dendriteIdx(i);
                    point = childPoints{pointIdx};

                    point.dendriteId = currentDepthDendrites(ddrIdx, 4);
                    point.dendriteStatistics('Dendrite Length') = ...
                        currentDepthDendrites(ddrIdx, 1);
                    point.dendriteStatistics('Depth') = currentDepth;
                end

                % Add child points to FilamentTree mapping
                for i = 1:numPoints
                    obj.mapping{mappingIdx, 1} = childPoints{i}.id;
                    obj.mapping{mappingIdx, 2} = childPoints{i};
                    mappingIdx = mappingIdx + 1;
                    obj.imarisIndexLookup(childPoints{i}.id) = childPoints{i};
                    obj.dendriteToPoint(childPoints{i}.dendriteId) = childPoints{i};
                end

                % Update variables for next iteration
                remainingTotalPoints = remainingTotalPoints - numPoints;
                parentPoints = childPoints;
                currentDepth = currentDepth + 1;
            end
            obj.pointStatisticsList = horzcat(obj.pointStatisticsList, {'Depth', 'Pt Distance', 'Filament ID'});
            obj.dendriteStatisticsList = horzcat(obj.dendriteStatisticsList, {'Depth', 'Dendrite Length'}); 
        end
    end
end

