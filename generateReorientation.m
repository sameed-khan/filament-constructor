function reorient = generateReorientation(treeArray, orientation, yBounds, outputPath)
% orientation: -1 if negative Y = cervix; +1 if negative Y = oviduct
if nargin < 4 
    outputPath = false;
end
reorient = zeros(length(treeArray),3);
for i = 1:length(treeArray)
    t = treeArray{i};
    bP = [t.root.statistics('Pt Position X'), t.root.statistics('Pt Position Y'), t.root.statistics('Pt Position Z')];
    tt = t.getExtendedTerminal();
    tP = [tt.statistics('Pt Position X'), tt.statistics('Pt Position Y'), tt.statistics('Pt Position Z')];
    if ~orientation
        bP(2) = (bP(2) - yBounds(2)) * -1;
        tP(2) = (tP(2) - yBounds(2))* -1;
    end
    val = (tP(2) - bP(2));
    reorient(i, 1) = t.filamentID;
    reorient(i, 2) = val;
    reorient(i, 3) = bP(2);
end
reorient = array2table(reorient, 'VariableNames', {'filament_id', 'reorient', 'y_coord'});
if outputPath
    writetable(reorient, outputPath);
end
end
