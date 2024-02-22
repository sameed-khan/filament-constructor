function equality = isclose(a, b)
% usage: boolean_result = isclose(a, b, tol)
% helper function designed to test equality within a specified range, tol
tol = 0.1;
equality = true;
if (a >= b+tol) || (a <= b-tol)
    equality = false;
end

return
end