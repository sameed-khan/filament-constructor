function prominenceStatistics = generateProminence(treeArray, bpts1, bpts2, outputPath)
% Calculates prominence based on the two manual boundary method. Consult
% your memory for more information. 
% TODO: ADD UTERINE DIRECTION CONSIDERATION
if nargin < 4
    outputPath = false;
end
boundary1 = readtable(bpts1, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
boundary2 = readtable(bpts2, 'NumHeaderLines', 3, 'VariableNamingRule', 'preserve');
bpts1 = table2array(boundary1(:,{'Position X', 'Position Y', 'Position Z'}));
bpts2 = table2array(boundary2(:,{'Position X', 'Position Y', 'Position Z'}));
prominenceStatistics = zeros(length(treeArray), 2);
for i = 1:length(treeArray)
    tree = treeArray{i};
    bP = [tree.root.statistics('Pt Position X'), tree.root.statistics('Pt Position Y'), tree.root.statistics('Pt Position Z')];
    temp = tree.getExtendedTerminal();
    tP = [temp.statistics('Pt Position X'), temp.statistics('Pt Position Y'), temp.statistics('Pt Position Z')];
    y_bP = bP(2);
%     y_tP = tP(2);
    
    % Find segment under terminal point
%     ptsBeforeTerm_1 = bpts1(bpts1(:,2) < y_tP, :);
%     [~,idx] = min(vecnorm(ptsBeforeTerm_1 - tP, 2, 2));
%     t_pt1 = ptsBeforeTerm_1(idx,:);
%     ptsAfterTerm_1 = bpts1(bpts1(:,2) > y_tP, :);
%     [~,idx] = min(vecnorm(ptsAfterTerm_1 - tP, 2, 2));
%     t_pt2 = ptsAfterTerm_1(idx,:);
%     ptsBeforeTerm_2 = bpts2(bpts2(:,2) < y_tP, :);
%     [~,idx] = min(vecnorm(ptsBeforeTerm_2 - tP, 2, 2));
%     t_pt3 = ptsBeforeTerm_2(idx,:);
%     ptsAfterTerm_2 = bpts2(bpts2(:,2) > y_tP, :);
%     [~,idx] = min(vecnorm(ptsAfterTerm_2 - tP, 2, 2));
%     t_pt4 = ptsAfterTerm_2(idx,:);
    
    % Find segment under beginning point
    ptsBeforeBeg_1 = bpts1(bpts1(:,2) < y_bP, :);
    [~,idx] = min(vecnorm(ptsBeforeBeg_1 - bP, 2, 2));
    b_pt1 = ptsBeforeBeg_1(idx,:);
    ptsAfterBeg_1 = bpts1(bpts1(:,2) > y_bP, :);
    [~,idx] = min(vecnorm(ptsAfterBeg_1 - bP, 2, 2));
    b_pt2 = ptsAfterBeg_1(idx,:);
    ptsBeforeBeg_2 = bpts2(bpts2(:,2) < y_bP, :);
    [~,idx] = min(vecnorm(ptsBeforeBeg_2 - bP, 2, 2));
    b_pt3 = ptsBeforeBeg_2(idx,:);
    ptsAfterBeg_2 = bpts2(bpts2(:,2) > y_bP, :);
    [~,idx] = min(vecnorm(ptsAfterBeg_2 - bP, 2, 2));
    b_pt4 = ptsAfterBeg_2(idx,:);
    
    
    % Calculate actual prominence
    % Prominence on surface under terminal point
%     center1 = [mean([t_pt1(1), t_pt2(1)]), mean([t_pt1(2), t_pt2(2)]), mean([t_pt1(3), t_pt2(3)])];
%     center2 = [mean([t_pt3(1), t_pt4(1)]), mean([t_pt3(2), t_pt4(2)]), mean([t_pt3(3), t_pt4(3)])];
%     [~,idx] = min(vecnorm([center1;center2] - tP, 2, 2));
%     if idx == 1
%         v2 = t_pt2 - t_pt1;
%         v1 = t_pt4 - t_pt3;
%     else
%         v2 = t_pt2 - t_pt1;
%         v1 = t_pt4 - t_pt3;
%     end
%     vrej = v2 - (v2*v1'/(v1*v1'))*v1;
%     vnormal = cross(v2, vrej);
%     vnormal = vnormal ./ norm(vnormal);
%     prominence_terminal = abs(dot(tP - bP, vnormal));
    
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
    prominence_beginning = abs(dot(tP - bP, vnormal)) / norm(tP - bP);
    
    % Append to table
    prominenceStatistics(i,1) = tree.filamentID;
    prominenceStatistics(i,2) = prominence_beginning;
end

% Write to disk
prominenceStatistics = array2table(prominenceStatistics, 'VariableNames', {'filament_id', 'prominence'});
if outputPath
    writetable(prominenceStatistics, outputPath);
end
end