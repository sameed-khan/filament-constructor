function lateral = computeLateralNess(fp)
%COMPUTELATERALNESS Computes the extent of lateral branching for a given
%FilamentPoint
%   @param fp: FilamentPoint;
%   @param lateral: scalar; a number between 0 and 0.5 that indicates the
%   degree to which the FilamentPoint contains a lateral branch. A value of
%   0 indicates a perfect lateral branch, while a value closer to 0.5
%   describes branching angles that are equal - similar to a planar
%   bifurcation. 

    angleOne = fp.childrenByReference(1).dendriteStatistics('Branching Angle');
    angleTwo = fp.childrenByReference(2).dendriteStatistics('Branching Angle');
    devianceFrom90 = abs(90 - (abs(angleOne - angleTwo)))/90;
    lateral = devianceFrom90*0.5;
end
    