function span = generateSpan(treeArray, outputPath)
if nargin < 2
    outputPath = false;
end

span = zeros(length(treeArray), 2);
for i = 1:length(treeArray)
    tree = treeArray{i};
    span(i,1) = tree.filamentID;
    span(i,2) = tree.statistics('Filament BoundingBoxOO Length C') / tree.statistics('Filament BoundingBoxOO Length B');
end
span = array2table(span, 'VariableNames', {'filament_id', 'span'});
if outputPath
    writetable(span, outputPath);
end
end