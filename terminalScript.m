labels = [1,2,3];
res='10x';
sample='Guinea Pig';
for i = 1:length(labels)
    tb = readtable(...
    sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/%i/Terminal Pts_%i.csv',res,sample,labels(i), labels(i)));
    tb = tb(:,{'FilamentNo_DendriteTerminalPts', 'ID'});
    tb.Properties.VariableNames = {'terminal_pts', 'filament_id'};
    writetable(tb, sprintf('D:/Documents/Arora Lab Stuff/RAW_DATA/%s/%s/Output Statistics/Terminal_%i.csv', res,sample,i));
end