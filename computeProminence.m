function prominence = computeProminence (curvePoint, rPoint, tPoint)
% COMPUTEPROMINENCE Calculate the prominence (the "extension" of the gland
% away from the uterine lumen) formalized as the scalar projection of the
% vector extending from the beginning point onto its terminal point onto the
% vector extending from the uterine lumen to the beginning point
% @param curvePoint 1x3 double vector; YZ coordinates of closest point on
% spline approximating lumen
% @param rPoint 1x3 double vector; YZ coordinates of gland Filament
% beginning point
% @param tPoint 1x3 double vector; YZ coordinates of gland Filament
% furthest extended (on the Y-axis) terminal point

v1 = tPoint - rPoint; % vector from terminal to root
v2 = rPoint - curvePoint; % vector from terminal to lumen
prominence = abs(dot(v1, v2) / norm(v2));