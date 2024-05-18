timepoints = ["TIMEPOINT_1", "TIMEPOINT_2", "TIMEPOINT_3"];
samples = {
    ["MOUSE_1", "MOUSE_2", "MOUSE_3"]
    ["MOUSE_1"]
    ["MOUSE_1", "MOUSE_2"]
};

% The below matrix stores the boundaries of the y-dimension of the Imaris scene
% for each of the mice that are being evaluated.
% The rows belong to each timepoint while the columns belong to each sample
% Mark all cells where you don't have a mouse for that timepoint with -1
% In the sample data provided here, TIMEPOINT_2 only has one mouse hence why the 
% latter two columns have -1.
yBounds = [ 
%   MSE_1, MSE_2, MSE_3       
    27964, 38566, 65696; % TIMEPOINT_1
    40200, 0, 0;       % TIMEPOINT_2
    70257, 84176, 0     % TIMEPOINT_3
];

% orients denotes whether the higher y-value is toward the direction of the cervix or not.
% if the cervix is located nearer to y-value 0 in the Imaris scene then the value should be -1, otherwise 1.
% The ordering of this matrix is the same as yBounds; absent mice are also replaced with a 0 
orients = [
    1, -1, 1;
    -1, 0, 0;
    1, 1, 0
];
for i = 1:length(timepoints)
    base_path = "DATA"
    sample_names = samples{i, :};
    for j = 1:length(sample_names)
        % The CSV files where the Imaris output statistics are stored should be named exactly
        % like the filenames in the quotes below (lines 35-38)
        ptp = fullfile(base_path, timepoints(i), sample_names{j}, "TF Pt Position.csv");
        bboo = fullfile(base_path, timepoints(i), sample_names{j}, "TF BoundingBoxOO.csv");
        tps = fullfile(base_path, timepoints(i), sample_names{j}, "TF Terminal Pts.csv");
        centerline = fullfile(base_path, timepoints(i), sample_names{j}, "Lumen Approx.csv");
        b1 = fullfile(base_path, timepoints(i), sample_names{j}, "Boundary.csv");
        b2 = fullfile(base_path, timepoints(i), sample_names{j}, "Second Boundary.csv");

        % These are the output paths, do not edit this
        prom = generateProminence(ptp, b1, b2, centerline, orients(i,j), yB(i, :), oup);
        reorient =  generateReorientation(ptp, centerline, orients(i,j), yB(i, :), oup);
    end
end
