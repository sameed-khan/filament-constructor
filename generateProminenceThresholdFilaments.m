function prominence = generateProminenceThresholdFilaments(posPath, boundaryOne, boundaryTwo, centerLine, orient, yBounds, outputPath)
% Orient: +1 if cervix is at high Y-end, -1 if opposite
% yBounds: 1x2 matrix containing the minimum and maximum y-values of file

addpath D:/Documents/MATLAB/utils
if nargin < 7
    outputPath = false;
end

% Read in uterine centerline approximation
utLine = readtable(centerLine, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
utLine = table2array(utLine(:, {'Position X', 'Position Y', 'Position Z'}));
utLine = sortrows(utLine,2);


% Read in two boundaries
bpts1 = readtable(boundaryOne, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
bpts1 = table2array(bpts1(:, {'Position X', 'Position Y', 'Position Z'}));
bpts1 = sortrows(bpts1,2);
bpts1(1, 2) = yBounds(1);
bpts1(end, 2) = yBounds(2);

bpts2 = readtable(boundaryTwo, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
bpts2 = table2array(bpts2(:, {'Position X', 'Position Y', 'Position Z'}));
bpts2 = sortrows(bpts2,2);
bpts2(1, 2) = yBounds(1);
bpts2(end, 2) = yBounds(2);

% Get terminal points only
termPoints = readtable(posPath, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
termPoints = termPoints(strcmp(termPoints.Type, 'Dendrite Terminal'),:);
fIDS = unique(termPoints.FilamentID);
prominence = zeros(length(fIDS), 2);
% Calculate GRO angle by Filament
for i = 1:length(fIDS)
    %fprintf("Current ID: %i\n", fIDS(i));
    filPoints = termPoints(termPoints.FilamentID == fIDS(i),{'Pt Position X', 'Pt Position Y', 'Pt Position Z'});
    pointArr = table2array(filPoints);
    
    % Find beginning pt by grabbing terminal pt closest to lumen line
    [~, dists, ~] = distance2curve(utLine, pointArr, 'spline');
    [~, min_idx] = min(dists);
    bP = pointArr(min_idx,:);

    % Find terminal point by grabbing pt with furthest distance
    [~, max_idx] = max(vecnorm(pointArr - bP, 2, 2));
    tP = pointArr(max_idx,:);
    
    % Compute prominence - find segments under beginning point
    % disp(fIDS(i));
    ptsBeforeBeg_1 = bpts1(bpts1(:,2) < bP(2), :);
    b_pt1 = ptsBeforeBeg_1(end,:); % Sorted by y, thus last is closest
    
    ptsAfterBeg_1 = bpts1(bpts1(:,2) > bP(2), :);
    b_pt2 = ptsAfterBeg_1(1,:);
    
    ptsBeforeBeg_2 = bpts2(bpts2(:,2) < bP(2), :);
    b_pt3 = ptsBeforeBeg_2(end,:);
    
    ptsAfterBeg_2 = bpts2(bpts2(:,2) > bP(2), :);
    b_pt4 = ptsAfterBeg_2(1,:);

    % Prominence on surface under beginning point
    center1 = [mean([b_pt1(1), b_pt2(1)]), mean([b_pt1(2), b_pt2(2)]), mean([b_pt1(3), b_pt2(3)])];
    center2 = [mean([b_pt3(1), b_pt4(1)]), mean([b_pt3(2), b_pt4(2)]), mean([b_pt3(3), b_pt4(3)])];
    [~,idx] = min(vecnorm([center1;center2] - bP, 2, 2));
    if idx == 1
        v2 = b_pt2 - b_pt1;
        v1 = b_pt4 - b_pt3;
    else
        v2 = b_pt2 - b_pt1;
        v1 = b_pt4 - b_pt3;
    end
    vrej = v2 - (v2*v1'/(v1*v1'))*v1;
    vnormal = cross(v2, vrej);
    vnormal = vnormal ./ norm(vnormal);
    prominenceValue = abs(dot(tP - bP, vnormal)) / norm(tP - bP);
    
    % Calculate appropriate y-value depending on cervix placement on y-axis
    if ~orient
        yVal = (bP(2) - yBounds(2))*-1;
    else
        yVal = bP(2);
    end
    prominence(i,1) = fIDS(i);
    prominence(i,2) = prominenceValue;
end
prominence = array2table(prominence, 'VariableNames', {'filament_id', 'prominence'});
if outputPath
    writetable(prominence, outputPath);
end
end