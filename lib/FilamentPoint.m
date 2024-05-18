classdef FilamentPoint < handle
    %FILAMENTPOINT (FP) Component of FilamentTree, represents Imaris Filament point.
    %   Point serves as a MATLAB class equivalent for a point on an Imaris
    %   Filaments object. It contains a structure that can hold statistics
    %   as well as being identifiable by its Imaris ID. The critical
    %   difference is that FilamentPoint also contains information about
    %   its parent and child points, allowing for data analysis questions
    %   premised on the relation of points and edges in a Filaments graph
    %   to each other as opposed to being separate. 
    
    properties
        id; % Imaris ID of this FilamentPoint (FP)
        statistics; % statistics values for this point
        parent; % reference to parent FP
        childrenById; % array of children FP Imaris IDs
        childrenByReference; % array of children FP instances
        dendriteId; % ID of the preceding dendrite connected to this FP
        dendriteStatistics; 
    end
    
    methods
        function obj = FilamentPoint(id)
            if (nargin == 0)
                obj.id = NaN;
            else
                obj.id = id;
                obj.statistics = containers.Map();
                obj.parent = 'NULL';
                obj.childrenById = [];
                obj.childrenByReference = [];
                obj.dendriteId = 0;
                obj.dendriteStatistics = containers.Map();                
            end
        end
        function height = getHeight(obj)
            % Finds the maximum depth of this node, useful for assessing
            % the relative developmental complexity of branches emerging
            % from this node 
            if isempty(obj.childrenByReference)
                height = 1;
                return
            else
                depths = zeros(1, length(obj.childrenByReference));
                for i = 1:length(obj.childrenByReference)
                    child = obj.childrenByReference(i);
                    depths(i) = child.getHeight();
                end
                height = 1 + max(depths);
            end
        end
        function childHeights = getChildHeights(obj)
            % Returns an n x 2 cell array with the first column listing the
            % IDs of the dendrite branch and the second column listing the
            % heights of the node following that branch. Height in the
            % FilamentTree context refers to the number of branch points
            % between the current node and any terminal point. Can be used
            % to assess whether a branch branches into a new structure or
            % branches into a terminal point thereafter.
            
            childHeights = cell(length(obj.childrenByReference), 2);
            for i = 1:length(obj.childrenByReference)
                child = obj.childrenByReference(i);
                childHeights{i, 1} = child.id;
                childHeights{i, 2} = child.getHeight();
            end
        end
        function nodeDegree = getDegree(obj)
            % Calculates the degree (number of children) this node has
            nodeDegree = 0;
            if isempty(obj.childrenByReference)
                return
            else
                for i = 1:length(obj.childrenByReference)
                    child = obj.childrenByReference(i);
                    nodeDegree = nodeDegree + child.getDegree();
                end
                nodeDegree = nodeDegree + length(obj.childrenByReference);
            end
        end
        function boolTerminal = isTerminal(obj)
            % Returns true if this point is a terminal point
            boolTerminal = isempty(obj.childrenByReference);
        end
        function addPointStat(obj, name, value)
            % Add a statistic value for this point
            % name: the name of the statistic ('branching angle', etc)
            % value: the value of the statistic
            obj.statistics(name) = value;
        end
        function addDendriteStat(obj, name, value)
            % Add a statistic value for this point's preceding dendrite
            % name: the name of the dendrite statistic ('length', etc)
            % value: the value of the statistic            
            obj.dendriteStatistics(name) = value;
        end
        function addChild(obj, child)
            % Add a child to this node
            % child: the actual child FilamentPoint object
            % child_id: the Imaris ID of the child object
            obj.childrenByReference = [obj.childrenByReference child];
            obj.childrenById = [obj.childrenById child.id];
        end
        % Operator overloading
        % <, > operators refer to node height. A FilamentPoint is greater
        % than another if it is higher up in the tree (closer to root)
        % = operator refers to id. If two filament points share the same
        % filament ID, they are the same point.
        function tf = lt(obj1, obj2)
            if obj1.getHeight() < obj2.getHeight()
                tf = true;
            else
                tf = false;
            end
        end
        function tf = gt(obj1, obj2)
            if obj1.getHeight() > obj2.getHeight()
                tf = true;
            else
                tf = false;
            end
        end
        function tf = eq(obj1, obj2)
            if obj1.id == obj2.id
                tf = true;
            else
                tf = false;
            end
        end
    end
end

