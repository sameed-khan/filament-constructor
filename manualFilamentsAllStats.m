labels = [1,2,3];
res = '10x';
sample = 'GD3.5';
% GD3.5 bounds
bounds = [0, 27694.1; 0, 38566.1; 0, 65695.7];
orients = [-1, 1, 1];
% GD4.0 bounds
% bounds = [0, 70257.6; 0, 84176.6; 0, 84222.7];
%orients = [1, -1, 1];

for i = 1:length(labels)
    ptp = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Pt Distance.csv', res, sample, i);
    dtp = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Dendrite Length.csv', res, sample, i);
    posp = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Pt Position.csv', res, sample, i);
    bboo = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/BoundingBoxOO.csv', res, sample, i);
    tps = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Terminal Pts.csv', res, sample, i);
    fps = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Filament Dendrite Length.csv', res, sample, i);
    oup = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/Output Statistics/Overall_%i.csv', res, sample, i);
    if any(strcmp(sample, {'GD3.5', 'GD3.75', 'GD4.0'}))        
        b1 = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Boundary.csv', res, sample, i);
        b2 = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Second Boundary.csv', res, sample, i);
    end
    
    treeArray = treesFromSurpass(ptp, dtp);
    for j = 1:length(treeArray)
        tree = treeArray{j};
        tree.addPointStatisticsFromCSV(posp, {'Pt Position X', 'Pt Position Y', 'Pt Position Z'});
        tree.addTreeStatisticsFromCSV(bboo, {'Filament BoundingBoxOO Length A', 'Filament BoundingBoxOO Length B', 'Filament BoundingBoxOO Length C'});
        tree.addTreeStatisticsFromCSV(tps, {'Filament No. Dendrite Terminal Pts'});
        tree.addTreeStatisticsFromCSV(fps, {'Filament Dendrite Length (sum)'});
    end    
   %% Generate tree statistics
   treeStats = zeros(length(treeArray), 3);
   for j = 1:length(treeArray)
       treeStats(j, 1) = treeArray{j}.filamentID;
       treeStats(j, 2) = treeArray{j}.statistics('Filament No. Dendrite Terminal Pts');
       treeStats(j, 3) = treeArray{j}.statistics('Filament Dendrite Length (sum)');
   end
   treeStats = array2table(treeStats, 'VariableNames', {'filament_id', 'terminal_points', 'complete_length'});
   
   %% Generate all other stats
   if any(strcmp(sample, {'GD3.5', 'GD3.75', 'GD4.0'}))
       prom = generateProminence(treeArray, b1, b2);
       reorient = generateReorientation(treeArray, orients(i), bounds(i, :));
   end
   lenStats = generateLengthStats(treeArray);
   
   %% Merge tables
   t1 = join(treeStats, lenStats, 'Keys', 'filament_id');
   if any(strcmp(sample, {'GD3.5', 'GD3.75', 'GD4.0'}))
       t2 = join(prom, reorient, 'Keys', 'filament_id');
       t1 = join(t1, t2, 'Keys', 'filament_id');
   end
   writetable(t1, oup);
end