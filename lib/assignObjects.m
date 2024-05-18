function [childIdx, parentIdx] = assignObjects(childObj, parentObj, linkObj, threshold)
% Function created to abstract the creation process of assigning children
% points to parent points or assigning dendrites to children. 
% @param childObj: In context of child points assigned to parent points,
% this is the Pt Distance value of the children. In context of dendrite
% assignment, this is the same.
% @param parentObj: In context of child points assigned to parent points,
% this is the Pt Distance value of the parent points. In context of
% dendrite assignment to children points, this is the values of the
% dendrites.
% @param linkObj: In context of child points assigned to parent points,
% this is the Dendrite Length value of the dendrite linking the child to
% parent. In the context of dendrite assignment, this is the parent point
% value that the dendrite emerged from to link to the child. 
% @param threshold: scalar double; threshold value defining how closely two
% the values should match.

diffs = childObj - parentObj;
locs = zeros(size(diffs));
for i = 1:length(linkObj)
    temp = diffs - linkObj(i);
    temp = round(temp, 3);
    locs = locs + (temp > -1*threshold & temp < threshold);
    [childIdx, parentIdx] = find(locs);
end

    