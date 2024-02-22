labels = [1,2,3];
%orients = [-1, 1, 1]; % GD3.5
orients = [1, -1, 1]; % GD3.75, GD4.0, GD4.5
%yB = [0, 27964.1; 0, 38566.1; 0, 65696]; % GD 3.5
%yB = [0, 40200; 0, 11419; 0, 29468]; % GD 3.75
yB = [0, 32900; 0, 24100; 0, 22200]; % GD 4.5
%yB = [0, 70257.6; 0, 84176.6; 0, 84200];
res = '10x';
sample = 'GD4.5';
for i = 1:length(labels)
    ptp = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/TF Pt Position.csv', res, sample, i);
    bboo = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/TF BoundingBoxOO.csv', res, sample, i);
    tps = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/TF Terminal Pts.csv', res, sample, i);
    %b1 = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Boundary.csv', res, sample, i);
    %b2 = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Second Boundary.csv', res, sample, i);
    centerline = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Lumen Approx.csv', res, sample, i);
    oup = sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/Output Statistics/TF Overall_%i.csv', res, sample, i);
    
    %% Terminal points statistic
    tps = readtable(tps, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
    tps = tps(:, {'Filament No. Dendrite Terminal Pts', 'ID'});
    tps.Properties.VariableNames = {'terminal_pts', 'filament_id'};
    % writetable(tps, 'D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/Output Statistics/TF Terminal_%i.csv', res, sample, i);
    
    %% All other statistics
    % prom = generateProminenceThresholdFilaments(ptp, b1, b2, centerline, orients(i), yB(i, :));
    reorient =  generateReorientationThresholdFilaments(ptp, centerline, orients(i), yB(i, :), oup);
    %lens = generateLengthStatsReorientationFilaments(bboo);
    
%     %% Merge all and write to disk
%     t1 = join(prom, reorient, 'Keys', 'filament_id');
%     t2 = join(tps, lens, 'Keys', 'filament_id');
%     t3 = join(t1, t2, 'Keys', 'filament_id');
%     writetable(t3, oup);
end