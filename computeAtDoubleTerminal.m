function bIndex = computeAtDoubleTerminal(fp)
%COMPUTEATDOUBLETERMINAL This function handles the case where both children
%of a branch point are terminal points, in which case the classification of
%lateral branch or planar bifurcation relies solely on branching angles. 
%
%   @param fp: FilamentPoint;
%   @return bIndex: a scalar value that quantifies the lateral branch-ness
%   or planar bifurcation-ness of the FilamentPoint.

%% Computing lateral branching value
    angleOne = fp.childrenByReference(1).dendriteStatistics('Branching Angle');
    angleTwo = fp.childrenByReference(2).dendriteStatistics('Branching Angle');
    devianceFrom90 = abs(90 - (abs(angleOne - angleTwo)))/90;
    preLateral = 1 - devianceFrom90;
%% Computing planar bifurcation value
    proportion = angleOne / sum([ angleOne, angleTwo ]);
    prePlanar = 1 - proportion;
%% Figure out which classification of branching it is
    if preLateral > prePlanar
        bIndex = computeLateralNess(fp);
    else
        bIndex = computePlanarNess(fp);
    end
end