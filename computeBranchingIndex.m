function branchingIndex = computeBranchingIndex(treeArray, maxPoints, outputPath)
% COMPUTEBRANCHINGINDEX Computes the branching index for an array of
% FilamentTrees
%   Branching index is a value that describes the degree of planar
%   bifurcation or lateral branching a branch point (pair of two branches)
%   posssesses. Branching index > 0.5 indicates a planar bifurcation, while
%   a branching index < 0.5 indicates a lateral branch. Branching index is
%   calculated by first examining the degree of branching following the
%   branch point - if both children of the branch point are branch points,
%   then it is a planar bifurcation. The equality of the branching angles
%   is used to assess the degree of bifurcation. If one of the children of
%   the branch point is a terminal point, it is classified as a lateral
%   branch and the extent of lateral branching is computed based on the
%   branching angles. 
%
%   @param treeArray: A cell array containing all FilamentTrees for
%   which this value should be computed
%
%   @param maxPoints: integer; a rough estimate of the maximum number of
%   branch points that exist in the treeArray / Imaris file. Relevant for
%   preallocation. You can calcuate this by finding the number of points in
%   the most complex filament in your file and then multiplying that by the
%   number of filaments in the file. 
%
%   @OPTIONAL param outputPath: string; if left blank,
%   computeBranchingIndex will not output a CSV file, if a string is
%   entered, function will write a CSV file containing contents of cell
%   array to location specified by outputPath. CSV is formatted as follows:
%   
%   || FilamentID || Point ID || Branching Index ||
%
%   @return branchingIndex: An n x 3 cell array containing the branch point IDs
%   and branchingIndex value. Some branch point IDs have a value of NaN
%   which indicates a trifurcation. The cell array is formatted as such: 
%
%   NOTE: The FilamentTree must be constructed from CSV and contain the
%   statistic 'Branching Angle,' otherwise this function cannot compute a
%   branching index.
    if nargin < 3
        outputPath = false;
    end
    for i = 1:length(treeArray)
        tree = treeArray{i};
        if isempty(tree.root.childrenByReference)
            error('A FilamentTree at index %i contains no data!', i);
        elseif ~any(ismember(tree.dendriteStatisticsList, 'Branching Angle'))
            error('A FilamentTree at index %i has no branching angle data!',...
                i);
        end
    end
    branchingIndex = cell(maxPoints, 3);
    added_idx = 1;
    for i = 1:length(treeArray)
        tree = treeArray{i};
        % Filament must have at least 4 points to have "branching"
        if length(tree.mapping) < 4
            continue;
        end
        for j = 1:length(tree.mapping)
            fPoint = tree.mapping{j, 2};
            % TODO, CLEAN UP THIS SECTION SO NO MORE DUPLICATE CODE
            % If the point only has one child, skip it
            if length(fPoint.childrenByReference) < 2
                continue
                
            % Handle trifurcations
            elseif length(fPoint.childrenByReference) > 2
                branchingIndex{added_idx, 1} = tree.filamentID;
                branchingIndex{added_idx, 2} = fPoint.id;
                branchingIndex{added_idx, 3} = NaN;
                added_idx = added_idx + 1;
                continue
            end
            
            % The branch point has only two children
            if (fPoint.childrenByReference(1).isTerminal()) && ...
                    (fPoint.childrenByReference(2).isTerminal())
                branchingIndex{added_idx, 1} = tree.filamentID;
                branchingIndex{added_idx, 2} = fPoint.id;
                branchingIndex{added_idx, 3} = computeAtDoubleTerminal(fPoint);
                added_idx = added_idx + 1;
            elseif (fPoint.childrenByReference(1).isTerminal()) ...
                    || (fPoint.childrenByReference(2).isTerminal())                
                branchingIndex{added_idx, 1} = tree.filamentID;
                branchingIndex{added_idx, 2} = fPoint.id;
                branchingIndex{added_idx, 3} = computeLateralNess(fPoint);
                added_idx = added_idx + 1;
            else
                branchingIndex{added_idx, 1} = tree.filamentID;
                branchingIndex{added_idx, 2} = fPoint.id;
                branchingIndex{added_idx, 3} = computePlanarNess(fPoint);
                added_idx = added_idx + 1;
            end
        end
        % Crop the preallocated cell array to data
        branchingIndex = branchingIndex(1:added_idx-1, :);
    end
    if outputPath
        tb = cell2table(branchingIndex, 'VariableNames', {'filament_id',...
            'point_id','branching_index'});
        writetable(tb, outputPath);
    end
end