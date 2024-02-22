function plength = generatePathLength(treeArray, outputPath)
% Just gets the max point distance of each filament
if nargin < 2
    outputPath = false;
end

plength = zeros(length(treeArray), 2);
for i = 1:length(treeArray)
    plength(i,1) = treeArray{i}.filamentID;
    plength(i,2) = treeArray{i}.getExtendedTerminal().statistics('Pt Distance');
end
plength = array2table(plength, 'VariableNames', {'filament_id','central_length'});
if outputPath
    writetable(plength, outputPath);
end
end
