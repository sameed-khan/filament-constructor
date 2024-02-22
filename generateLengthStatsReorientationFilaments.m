function lenStats = generateLengthStatsReorientationFilaments(ooPath, outputPath)
% Outputs straight-line length and span
if nargin < 2
    outputPath = false;
end

bbOO = readtable(ooPath, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
lenStats = zeros(height(bbOO), 3);
for i = 1:height(bbOO)
    bbooB = bbOO{i, 'Filament BoundingBoxOO Length B'};
    bbooC = bbOO{i, 'Filament BoundingBoxOO Length C'};
    lenStats(i, 1) = bbOO{i, 'ID'};
    lenStats(i, 2) = bbooC;
    lenStats(i, 3) = bbooC / bbooB;
end
lenStats = array2table(lenStats, 'VariableNames', {'filament_id', 'straight_length', 'span'});
if outputPath
    writetable(lenStats, outputPath);
end
end