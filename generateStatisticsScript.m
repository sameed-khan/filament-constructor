% This script generates statistics described in Figure 2 of the manuscript from manual filament Imaris data.
% The Overall.csv file will contain the Path Length, Straight Length, Straightness, Span, Complete Length, and Terminal Points metrics for each 
% gland, marked by a Filament ID
% The Branch Classes.csv output file contains the Branch Classes metric for each branching instance across all of the glands for that mouse

addpath("../FilamentConstructor/")  % TODO: replace with path to library where all underlying functions are stored

% This variable configures the number of timepoints you are analyzing overall.
% replace the all-caps fields with the names of the actual folders where your timepoint data is kept
% for example, if you are analyzing Diestrus and GD3.5 timepoints, then replace the fields with
% "Diestrus" and "GD3.5"
timepoints = ["TIMEPOINT_1", "TIMEPOINT_2", "TIMEPOINT_3"];

% Each row corresponds to the available samples for each timepoint
% As the 'samples' variable is constructed below, timepoint 1 has three mice where each of their respective
% folders are labeled "MOUSE_1," "MOUSE_2," and so on
% Replace these names with the appropriate names of the folders where you are keeping each of the sample data for each mouse in
% Add additional names to each row, separated by commas, if you have additional mice for that timepoint. 
% For examle, if, for timepoint 2 you have three mice where you have labeled each of their folders "MOUSE_A","MOUSE_B" and so on then the 
% second row of 'samples' should read '["MOUSE_A", "MOUSE_B", "MOUSE_C"]'
% Do not add a semicolon or any other characters to the end of any of the rows
samples = {
    ["MOUSE_1", "MOUSE_2", "MOUSE_3"]
    ["MOUSE_1"]
    ["MOUSE_1", "MOUSE_2"]
};

for i = 1:length(timepoints)
    % The variable on line 30 is referring to the DATA folder where all of the CSV exports of the 
    % required statistics from Imaris should be kept.
    base_path = "DATA";
    sample_names = samples{i, :};
    for j = 1:length(sample_names)
        % For each of line 38-48 below, ensure that the corresponding CSV file's name in your filesystem
        % exactly matches the name as described in the lines below
        % For example, the CSV file containing the data for the Point Distance metric from Imaris must be 
        % labeled "ptdistance_Detailed.csv" to match the name of the file in your filesystem
        ptp = fullfile(base_path, timepoints(i), sample_names{j}, "ptdistance_Detailed.csv");
        dtp = fullfile(base_path, timepoints(i), sample_names{j}, "dendritelength_Detailed.csv");
        posp = fullfile(base_path, timepoints(i), sample_names{j}, "ptposition_Detailed.csv");
        bboo = fullfile(base_path, timepoints(i), sample_names{j}, "filboundingboxOOlength_Detailed.csv");
        tps = fullfile(base_path, timepoints(i), sample_names{j}, "terminalpoints_Detailed.csv");
        fps = fullfile(base_path, timepoints(i), sample_names{j}, "fildendritelength_Detailed.csv");
        bps = fullfile(base_path, timepoints(i), sample_names{j}, "branchpoints_Detailed.csv");
        
        % These are paths to output files -- they specify where the files will be saved on your system, do not edit these
        oup = fullfile(base_path, timepoints(i), sample_names{j}, "Overall.csv");
        bup = fullfile(base_path, timepoints(i), sample_names{j}, "Branch Classes.csv");


        treeArray = treesFromSurpass(ptp, dtp, 0);
        for k = 1:length(treeArray)
            tree = treeArray{k};
            tree.addPointStatisticsFromCSV(posp, {'Pt Position X', 'Pt Position Y', 'Pt Position Z'}, 0);
            tree.addTreeStatisticsFromCSV(bboo, {'Filament BoundingBoxOO Length A', 'Filament BoundingBoxOO Length B', 'Filament BoundingBoxOO Length C'}, 0);
            tree.addTreeStatisticsFromCSV(tps, {'Filament No. Dendrite Terminal Pts'}, 0);
            tree.addTreeStatisticsFromCSV(bps, {'Filament No. Dendrite Branch Pts'}, 0);
            tree.addTreeStatisticsFromCSV(fps, {'Filament Dendrite Length (sum)'}, 0);
        end
        
       %% Generate tree statistics
       treeStats = zeros(length(treeArray), 4);
       for l = 1:length(treeArray)
           treeStats(l, 1) = treeArray{l}.filamentID;
           treeStats(l, 2) = treeArray{l}.statistics('Filament No. Dendrite Terminal Pts');
           treeStats(l, 3) = treeArray{l}.statistics('Filament No. Dendrite Branch Pts');
           treeStats(l, 4) = treeArray{l}.statistics('Filament Dendrite Length (sum)');
       end
       treeStats = array2table(treeStats, 'VariableNames', {'filament_id', 'terminal_points', 'branch_points', 'complete_length'});
       
       %% Generate other statistics
       lenStats = generateLengthStats(treeArray);
       t1 = join(treeStats, lenStats, 'Keys', 'filament_id');
       % Write branch statistics out to disk, must be done separately
       classifyBranchType(treeArray, 5000, bup);
       writetable(t1, oup);
    end
end
