function groAngles = generateLumenAngles(treeArray, utStart, utEnd, outputPath)
% GENERATELUMENANGLES This function computes each gland's angle relative to
% the lumen. A significant change in gland angle relative to lumen is
% observed at implantation; termed "gland reorientation" This function
% requires FilamentTrees to contain the "Point X," "Point Y," and "Point Z"
% statistics. 
% @param treeArray: cell array of FilamentTrees representing the Filament
% Surpass object. Construct using treesFromSurpass
% @param utStart: 1x3 double array; Contains the X,Y,Z coordinates of a
% line approximating the uterus (oviductal side) 
% @param utEnd: 1x3 double array; Contains the X,Y,Z coordinates of the end
% point of a line approximating the uterus (cervical side) 
% @param outputPath: string; an OPTIONAL parameter, if listed, saves the
% output as a .CSV file at the location specified by the string. CSV file
% is formatted as follows:
%   Filament ID || Gland Angle || Y Coordinate of Filament Relative to
%   Uterine Start

if nargin < 4
    outputPath = false;
end

% Check if all FilamentTrees have the prerequisite statistics
for i = 1:length(treeArray)
    if ~treeArray{i}.hasPointStatistic('Pt Position X') || ...
            ~treeArray{i}.hasPointStatistic('Pt Position Y') || ...
            ~treeArray{i}.hasPointStatistic('Pt Position Z')
        fprintf("A FilamentTree with id %i has no Pt Position statistic\n", ...
            treeArray{i}.filamentID);
        error(['Your FilamentTree does not contain the Pt Position statistic. ' ...
            'Gland reorientation angles cannot be calculated.']);
    end
end

groAngles = cell(length(treeArray), 3);
% Find the terminal point of the tree with the most extreme Y coordinate
% relative to tree beginning point
for i = 1:length(treeArray)
    tree = treeArray{i};
    stPoint = [ ...
    tree.root.statistics('Pt Position X'), ...
    tree.root.statistics('Pt Position Y'), ...
    tree.root.statistics('Pt Position Z') ];
    % Get all terminal points from the tree
    points = [ tree.mapping{:,2} ];
    terms = points(arrayfun(@(x) x.isTerminal(), points));
    % Get the terminal point with the furthest Pt Distance value
%     [mx, idx] = max( ...
%         arrayfun(@(x) x.statistics('Pt Distance'), terms))
%     tPoint = [ ...
%         terms(idx).statistics('Pt Position X'), ...
%         terms(idx).statistics('Pt Position Y'), ...
%         terms(idx).statistics('Pt Position Z'), ];
    % Get the terminal point with the most extreme Y coordinate
    [mx, idx] = max( ...
        arrayfun(@(x) abs(x.statistics('Pt Position Y') - stPoint(2)),  ... 
        terms));
    tPoint = [ ...
        terms(idx).statistics('Pt Position X'), ...
        terms(idx).statistics('Pt Position Y'), ...
        terms(idx).statistics('Pt Position Z') ];
    
    angle = computeLumenAngle(utStart, utEnd, stPoint, tPoint);
    groAngles{i, 1} = tree.filamentID;
    groAngles{i, 2} = angle;
    groAngles{i, 3} = abs(stPoint(2) - utStart(2));
end
if outputPath
    tb = cell2table(groAngles, 'VariableNames', {'filament_id', 'lumen_angle', 'y_coord'});
    writetable(tb, outputPath);
end
