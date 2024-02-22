labels = [1,2,3];
res = '20x';
sample = 'GD3.5';

for i = 1:length(labels)
%     ptp = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Pt Distance.csv', res, sample, i);
%     dtp = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Dendrite Length.csv', res, sample, i);
%     posp = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Pt Position.csv', res, sample, i);
%     bboo = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\BoundingBoxOO.csv', res, sample, i);
%     tps = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Terminal Pts.csv', res, sample, i);
%     bps = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Branch Pts.csv', res, sample, i);
%     fps = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\%i\\Filament Dendrite Length.csv', res, sample, i);
%     oup = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\Output Statistics\\Overall_%i.csv', res, sample, i);
%     bup = sprintf('C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\%s\\%s\\Output Statistics\\Branch Classes_%i.csv', res, sample, i);

    ptp = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Pt Distance.csv';
    dtp = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Dendrite Length.csv';
    posp = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Pt Position.csv';
    bboo = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\BoundingBoxOO.csv';
    tps = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Terminal Pts.csv';
    bps = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Branch Pts.csv';
    fps = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Filament Dendrite Length.csv';
    
    oup = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Overall.csv';
    bup = 'C:\\Users\\khans24.CC\\OneDrive - Case Western Reserve University\\Ripla Collab\\RAW_DATA\\tutorial_data\\Branch Classes.csv';
    
    treeArray = treesFromSurpass(ptp, dtp);
    for j = 1:length(treeArray)
        tree = treeArray{j};
        tree.addPointStatisticsFromCSV(posp, {'Pt Position X', 'Pt Position Y', 'Pt Position Z'});
        tree.addTreeStatisticsFromCSV(bboo, {'Filament BoundingBoxOO Length A', 'Filament BoundingBoxOO Length B', 'Filament BoundingBoxOO Length C'});
        tree.addTreeStatisticsFromCSV(tps, {'Filament No. Dendrite Terminal Pts'});
        tree.addTreeStatisticsFromCSV(bps, {'Filament No. Dendrite Branch Pts'});
        tree.addTreeStatisticsFromCSV(fps, {'Filament Dendrite Length (sum)'});
    end
    
   %% Generate tree statistics
   treeStats = zeros(length(treeArray), 4);
   for j = 1:length(treeArray)
       treeStats(j, 1) = treeArray{j}.filamentID;
       treeStats(j, 2) = treeArray{j}.statistics('Filament No. Dendrite Terminal Pts');
       treeStats(j, 3) = treeArray{j}.statistics('Filament No. Dendrite Branch Pts');
       treeStats(j, 4) = treeArray{j}.statistics('Filament Dendrite Length (sum)');
   end
   treeStats = array2table(treeStats, 'VariableNames', {'filament_id', 'terminal_points', 'branch_points', 'complete_length'});
   
   %% Generate other statistics
   lenStats = generateLengthStats(treeArray);
   t1 = join(treeStats, lenStats, 'Keys', 'filament_id');
   % Write branch statistics out to disk, must be done separately
   classifyBranchType(treeArray, 5000, bup);
   writetable(t1, oup);
end