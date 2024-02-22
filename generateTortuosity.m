function tort = generateTortuosity(treeArray, outputPath)
% Generates tortuosity by adding the dendrite lengths along the path to the
% most extended terminal point and then dividing that value by the
% straight-line distance from the beginning point to the terminal point.
if nargin < 2
    outputPath = false;
end

tort = zeros(length(treeArray), 2);
for i = 1:length(treeArray)
    tree = treeArray{i};
    tP = tree.getExtendedTerminal();
    pos2 = [tP.statistics('Pt Position X'), tP.statistics('Pt Position Y'), tP.statistics('Pt Position Z')];
    pos1 = [tree.root.statistics('Pt Position X'), tree.root.statistics('Pt Position Y'), tree.root.statistics('Pt Position Z')];
    tort(i,1) = tree.filamentID;
    tort(i,2) = norm(abs(pos2-pos1)) / tP.statistics('Pt Distance');
end
tort = array2table(tort, 'VariableNames', {'filament_id', 'straightness'});
if outputPath
    writetable(tort, outputPath);
end
end
    
