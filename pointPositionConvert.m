function pointPositionConvert(tree, minCoords, spacing)
% POINTPOSITIONCONVERT Helper function that converts the Pt Position values
% of a FilamentTree into voxel indices. Useful for operations that involve
% manipulating volume data in MATLAB based on Imaris statistics.
% @param tree: FilamentTree
% @param minCoords: 1x3 double vector containing the minimum micron
% coordinates of the Imaris file
% @param spacing: 1x3 double vector containing the microns/voxel value of the
% Imaris image file
% Output: File adds a new statistic to the FilamentTree, termed 
% "Voxel Position" containing the equivalent voxel index values for every 
% point position within the tree

for i = 1:length(tree.mapping)
    node = tree.mapping{i,2};
    positions = zeros(1,3);
    positions(1) = node.statistics('Pt Position X');
    positions(2) = node.statistics('Pt Position Y');
    positions(3) = node.statistics('Pt Position Z');
    
    converted = round((positions - minCoords) ./ spacing);
    node.addPointStat('Voxel Position X', converted(1));
    node.addPointStat('Voxel Position Y', converted(2));
    node.addPointStat('Voxel Position Z', converted(3));
end
tree.pointStatisticsList = horzcat(tree.pointStatisticsList, ...
    {'Voxel Position X', 'Voxel Position Y', 'Voxel Position Z'});
end