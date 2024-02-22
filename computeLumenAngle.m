function theta = computeLumenAngle(utStart, utEnd, rPoint, tPoint)
% COMPUTELUMENANGLE Calculate angle between line connecting beginning-end 
% of gland and surface of lumen.
% @param utEnd: 1x3 double vector; XYZ coordinates of uterine centerline
% start point
% @param utEnd: 1x3 double vector; XYZ coordinates of uterine centerline
% end point
% @param rPoint: 1x3 double vector; XYZ coordinates of gland filament
% beginning point
% @param tPoint: 1x3 double vector; XYZ coordinates of gland extreme
% terminal point
% Credit to Dr. Adam Alessio (aalessio@msu.edu), Michigan State University,
% for supplying code and method to calculate gland angle. 

%% Find radius of lumen:
%     vector rejection of vector v2[utStart,rPoint] onto v1 [utStart,utEnd] 
v1 = utEnd-utStart;
v2 = rPoint-utStart;
v3 = v2 - (v2*v1'/(v1*v1'))*v1;
%    Find length of rejected vector (third side of triangle)
radius_lumen = norm(v3);

%% Find point where tPoint to centerline intersects with lumen
%     vector projection of vector v2[utStart,tPoint] onto v1 [utStart,utEnd] 
v1 = utEnd-utStart;
v2 = tPoint-utStart;
vproj = (v2*v1'/(v1*v1'))*v1;  %projected vector
vrej = v2 - vproj;   % rejected vector
C3 = utStart+vproj; % intesection at centerline
G2_check = C3+vrej;  % should be tPoint (centerline intersection+rejected vector)
G2_check = uint8(G2_check);
temp = uint8(tPoint);
if G2_check ~= temp
    disp("G2_check coordinates");
    disp(G2_check)
    disp("tPoint coordinates");
    disp(tPoint);
    error("G2_check not equal to tPoint");
end
%    Identify point 'radius_lumen' along this rejected vector
G3 = C3+radius_lumen*vrej/norm(vrej);  % point where tPoint to centerline intersects with lumen

% Now, rPoint, tPoint, G3 define the three points on the triangle.

%% Find angle between [rPoint,tPoint] and [rPoint,G3]
v1 = tPoint-rPoint;
v2 = G3-rPoint;
cos_t = (v1*v2')/(norm(v1)*norm(v2));
theta = acosd(cos_t); % angle in degrees