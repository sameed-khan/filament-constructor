function distance = pointToLineDistance(pt, v1, v2)
% Copied directly from MATLAB Support Staff answer, see 
% https://www.mathworks.com/matlabcentral/answers/95608-is-there-a-function-in-matlab-that-calculates-the-shortest-distance-from-a-point-to-a-line#answer_104961
   a = v1 - v2;
   b = pt - v2;
   distance = norm(cross(a,b)) / norm(a);
end