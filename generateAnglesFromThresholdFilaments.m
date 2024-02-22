function groAngles = generateAnglesFromThresholdFilaments(csvPath, utCSVPath, outputPath)

    if nargin < 4
        outputPath = false;
    end
    
    % Assemble numeric array of uterine line points that will make up the
    % spline curve
    temp = readtable(utCSVPath);
    utLine = zeros(height(temp), 3);
    utLine(:,1) = temp.PositionX;
    utLine(:,2) = temp.PositionY;
    utLine(:,3) = temp.PositionZ;
    utLine = sortrows(utLine,2);
    
    termPoints = readtable(csvPath);
    termPoints = termPoints(strcmp(termPoints.Type, 'Dendrite Terminal'),:);
    fIDS = unique(termPoints.FilamentID);
    groAngles = cell(length(fIDS), 5);
    % Calculate GRO angle by Filament
    for i = 1:length(fIDS)
        %fprintf("Current ID: %i\n", fIDS(i));
        filPoints = termPoints(termPoints.FilamentID == fIDS(i),:);
        pointArr = zeros(height(filPoints), 3);
        pointArr(:,1) = filPoints.PtPositionX;
        pointArr(:,2) = filPoints.PtPositionY;
        pointArr(:,3) = filPoints.PtPositionZ;
        
        % Find beginning pt by grabbing terminal pt closest to lumen line
        [null, dists, null2] = distance2curve(utLine, pointArr, 'spline');
        [minx, min_idx] = min(dists);
        stPoint = [filPoints.PtPositionX(min_idx), filPoints.PtPositionY(min_idx), ...
            filPoints.PtPositionZ(min_idx)];
        
        % Find terminal point by grabbing the greatest Y distance deviant
        dists = zeros(1, height(filPoints));
        for k = 1:length(dists)
            dists(k) = abs(filPoints.PtPositionY(k) - stPoint(2));
        end
        [mx, max_idx] = max(dists);
        tPoint = [filPoints.PtPositionX(max_idx), filPoints.PtPositionY(max_idx), ...
            filPoints.PtPositionZ(max_idx)];
        
        % Find start point of local uterine line segment
        % If y-coord of terminal point is greater than start point, grab
        % the point with the next greatest y-coordinate after the terminal
        % point for utEnd. utStart is the point with the next lowest
        % y-coordinate before the root point. Vice versa if y-coord of
        % terminal point is less than start point
        if tPoint(2) > stPoint(2)
            utPtsGreater = utLine(utLine(:,2) > tPoint(2),:);
            utEnd = utPtsGreater(1,:); % this works since sorted by y-coord
            utPtsLesser = utLine(utLine(:,2) < stPoint(2),:);
            utStart = utPtsLesser(end,:);
        else
            utPtsGreater = utLine(utLine(:,2) > stPoint(2),:);
            utEnd = utPtsGreater(1,:);
            utPtsLesser = utLine(utLine(:,2) < tPoint(2),:);
            utStart = utPtsLesser(end,:);
        end
        
        % Compute lumen angle and populate table
        angle = computeLumenAngle(utStart, utEnd, stPoint, tPoint);
        groAngles{i, 1} = fIDS(i);
        groAngles{i, 2} = angle;
        groAngles{i, 3} = abs(stPoint(2) - utLine(1,2));
        groAngles{i, 4} = stPoint(2);
        groAngles{i, 5} = filPoints.ID(min_idx);
        groAngles{i, 6} = filPoints.ID(max_idx);
    end
    groAngles = cell2table(groAngles, 'VariableNames', {'filament_id', 'lumen_angle', 'y_coord', 'abs_y_coord','beginning_point', 'terminal_point'});
    if outputPath
        writetable(groAngles, outputPath);
    end
end
        