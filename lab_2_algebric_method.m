%Taking the input
m = input('Enter the number of constraints:');
n = input('Enter the number of variables: ');
A = input('Enter the coefficient matrix: ');
b = input('Enter the rhs matrix: ');
C = input('Enter the coefficients for z: ');

%further be used in the creation of basis matrix
indexes = nchoosek(1 :n, m);
for i = 1: nchoosek(n, m)
    for j = 1 : 2
        fprintf("%d ", indexes(i, j))
    end
    fprintf("\n")
end

result = 0; %optimized value
feasible_solution = []; %set of feasible solution
y = []; %value of x which optimizes the function

%creating basis matrix and solving simultaneously
for i = 1 : nchoosek(n, m)
    B = []; % B is the basis matrix
    for j = 1 : m
        adder = []; % it is the matrix (1*m) which will be added m times to form basis matrix
        for k = 1 : m
            adder = [adder; A(k, indexes(i, j))];
        end
        B = [B adder];
    end
    X = inv(B)*b;
    if X >= 0
        feasible_solution = [feasible_solution X];
        % set of feasible solution

        %finding the optimized value for the function
        this_result = 0;
        for j = 1:m
            this_result = this_result + X(j)*C(indexes(i, j));
        end
        if this_result > result
            result = this_result;
            y = X;
        end
        %result is the current optimized value

    end
end
feasible_solution
fprintf('The optimized value is %f\n', result);
fprintf('The value is optimized at:');
y