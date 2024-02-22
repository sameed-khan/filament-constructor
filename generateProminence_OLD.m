function prominenceStatistics = generateProminence_OLD(treeArray, utCSVPath, volPath, outputPath)
% GENERATEPROMINENCE Function computes a table of values containing the
% prominence for all Filaments within a given Surpass object. Prerequisite
% statistics for this metric is Pt Position X, Pt Position Y, and Pt
% Position Z
% @param treeArray: cell array of FilamentTrees representing the Filament
% Surpass object. Construct using treesFromSurpass
% @param utCSVPath: string; path to file containing the Measurement Point
% coordinates of the Manual Approximated Lumen
% @param outputPath: string; optional parameter containing the destination of
% an output CSV file. If this parameter is not included, no CSV file will 
% be generated. 

if nargin < 4
    outputPath = false;
end
% Check if treeArray contains FilamentTrees with requisite statistics
for i = 1:length(treeArray)
    if ~treeArray{i}.hasPointStatistic('Pt Position X') || ...
            ~treeArray{i}.hasPointStatistic('Pt Position Y') || ...
            ~treeArray{i}.hasPointStatistic('Pt Position Z')
        fprintf("A FilamentTree with id %i has no Pt Position statistic\n", ...
            treeArray{i}.filamentID);
        error(['Your FilamentTree does not contain the Pt Position statistic. ' ...
            'Prominence cannot be calculated.']);
    end
end

% Assemble numeric array of uterine line points that will make up the
% spline curve that approximates the uterine centerline
temp = readtable(utCSVPath);
utLine = zeros(height(temp), 3);
utLine(:,1) = temp.PositionX;
utLine(:,2) = temp.PositionY;
utLine(:,3) = temp.PositionZ;
utLine = sortrows(utLine,2);

% Generate list of most extended terminal points
termPoints = zeros(length(treeArray), 3);
startPoints = zeros(length(treeArray), 3);
maxes = zeros(length(treeArray), 1);
for i = 1:length(treeArray)
    tree = treeArray{i};
     
    % Get all terminal points from the tree
    points = [ tree.mapping{:,2} ];
    terms = points(arrayfun(@(x) x.isTerminal(), points));
    % Get the terminal point with the furthest Pt Distance value
    [mx, idx] = max( ...
        arrayfun(@(x) x.statistics('Pt Distance'), terms))
    maxes(i) = mx;
    tPoint = [ ...
        terms(idx).statistics('Pt Position X'), ...
        terms(idx).statistics('Pt Position Y'), ...
        terms(idx).statistics('Pt Position Z'), ];
    
    termPoints(i, :) = tPoint;
    
    stPoint = [ ...
    tree.root.statistics('Pt Position X'), ...
    tree.root.statistics('Pt Position Y'), ...
    tree.root.statistics('Pt Position Z') ];
    startPoints(i, :) = stPoint;
end

[splinePoints, null, null2] = distance2curve(utLine, startPoints, 'spline');
prominence = zeros(length(treeArray), 1);
prominenceStatistics = zeros(length(treeArray), 3);

for i = 1:length(treeArray)
    prominence(i) = computeProminence(splinePoints(i,:), startPoints(i,:), termPoints(i,:));
end
% First column is FilamentID of each FilamentTree
for i = 1:length(treeArray)
    prominenceStatistics(i,1) = treeArray{i}.filamentID;
end
prominenceStatistics(:,2) = prominence;
prominenceStatistics(:,3) = vecnorm(termPoints - startPoints, 2, 2);
prominenceStatistics = array2table(prominenceStatistics, 'VariableNames', {'filament_id', 'prominence', 'sraight_line_length'});

if outputPath
    writetable(prominenceStatistics, outputPath);
end
end