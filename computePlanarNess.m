function planar = computePlanarNess(fp)
%COMPUTEPLANARNESS When passed a filament point, computes the extent of
%planar bifurcation.
%   @param fp: FilamentPoint;
%   @return planar: a scalar value between 0.5 and 1 indicating the extent
%   to which the FilamentPoint contains a planar bifurcation. This is
%   calculated by evaluating the equality of branching angles to each
%   other. 

    angleOne = fp.childrenByReference(1).dendriteStatistics('Branching Angle');
    angleTwo = fp.childrenByReference(2).dendriteStatistics('Branching Angle'); 
    
    % The use of angleOne is arbitrary here, one could use either branching
    % measure and the metric would be the same, notwithstanding some
    % rounding error
    proportion = angleOne / sum([ angleOne, angleTwo ]);
    planar = 1 - (0.5 - proportion);
    
    if planar < 0.5
        error(...
            "Planar is an invalid value, please check function or your stats");
    end