clc

n = input('Enter the number of variables: ');
m = input('Enter the number of constraints: ');
lt = input('Enter the number of less than or equal to constraints: ');
eq = input('Enter the number of equality constraints: ');
gt = input('Enter the number of greater than or equal to constraints: ');

A = input('Enter the constraint matrix A as per chronological order: ');
b = input('Enter the column matrix b: ');
c = input('Enter the objective matrix: ');

for i = 1:lt %slack variables addition
    adder = [];
    for j = 1:m
        if(i == j)
            adder = [adder; 1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0];
end

for i = lt+eq+1:lt+eq+gt %surplus variables addition
    adder = [];
    for j = 1:m
        if(i == j)
            adder = [adder; -1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0];
end

for i = 1+lt:lt+eq+gt %artificial variables addition
    adder = [];
    for j = 1:m
        if(i == j)
            adder = [adder; 1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c -100];
end

basic_columns = [n+1 : n+m];
B = A(:, basic_columns);

X = inv(B)*b;
Simplex = X;
for i = 1: n+lt+eq+2*gt
    Simplex = [Simplex inv(B)*A(:, i)];
end

zj_cj = [c(basic_columns)*X];
for i = 1:n+lt+eq+2*gt
    zj_cj = [zj_cj c(basic_columns)*Simplex(:, i+1) - c(i)];
end
Simplex = [Simplex; zj_cj];
Simplex

min_row_index = 1;
for i = 2: m
    if (Simplex(i, 1) < Simplex(min_row_index, 1))
        min_row_index = i;
    end
end

iterate = 1;
if(Simplex(min_row_index, 1) >= 0)
    fprintf('Current solution is optimal\n');
    Simplex(m+1, 1)
    iterate = 0;
else
    for i = 1:m
        if(Simplex(i, 1) < 0)
            negative_found  = 0;
            for j = 2: n+lt+eq+2*gt+1
                if(Simplex(i, j) < 0)
                    negative_found = 1;
                end
            end
            if(negative_found == 0)
                iterate = 0;
                fprintf('The solution to the problem is unbounded\n');
            end
        end
    end
end

while iterate
    max_ratio_index = 2;
    for i = 3: n+lt+eq+2*gt+1
        if(Simplex(min_row_index, i) < 0)
            if(Simplex(m+1, i)/Simplex(min_row_index, i) > Simplex(m+1, max_ratio_index)/Simplex(min_row_index, max_ratio_index))
                max_ratio_index = i;
            end
        end
    end
    
    basic_columns(min_row_index) = max_ratio_index-1;
    B = A(:, basic_columns);

    X = inv(B)*b;
    Simplex = X;
    for i = 1: n+lt+eq+2*gt
        Simplex = [Simplex inv(B)*A(:, i)];
    end
    
    zj_cj = [c(basic_columns)*X];
    for i = 1:n+lt+eq+2*gt
        zj_cj = [zj_cj c(basic_columns)*Simplex(:, i+1) - c(i)];
    end
    Simplex = [Simplex; zj_cj];
    Simplex
    
    min_row_index = 1;
    for i = 2: m
        if (Simplex(i, 1) < Simplex(min_row_index, 1))
            min_row_index = i;
        end
    end
    
    iterate = 1;
    if(Simplex(min_row_index, 1) >= 0)
        fprintf('Current solution is optimal\n');
        Simplex(m+1, 1)
        iterate = 0;
    else
        for i = 1:m
            if(Simplex(i, 1) < 0)
                negative_found  = 0;
                for j = 2: n+lt+eq+2*gt+1
                    if(Simplex(i, j) < 0)
                        negative_found = 1;
                    end
                end
                if(negative_found == 0)
                    iterate = 0;
                    fprintf('The solution to the problem is unbounded\n');
                end
            end
        end
    end
end