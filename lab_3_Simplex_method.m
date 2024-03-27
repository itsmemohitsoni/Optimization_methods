n = input('Enter the number of variables: ');
m = input('Enter the number of constraints: ');
lt = input('Enter the number of less than or equal to constraints: ');
eq = input('Enter the number of equality constraints: ');
gt = input('Enter the number of greater than or equal to constraints: ');

A = input('Enter the constraint matrix A as per chronological order: ');
b = input('Enter the column matrix b: ');
c = input('Enter the maximizer matrix: ');

%adding slack variables to matrix A
for i = 1: lt
    adder = [];
    for j = 1: m
        if (i == j)
            adder = [adder; 1];
        else 
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0]; %corresponding to slack variables
end

for i = lt+eq+1 : lt+eq+gt
    adder = [];
    for j = 1: m
        if (i == j)
            adder = [adder; -1];
        else 
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0]; %corresponding to slack variables
end

B_columns = [lt+gt+n+eq-m+1 : lt+gt+n+eq]; %columns of basic matrix
B = [A(1:m, lt+gt+n+eq-m+1: lt+gt+n+eq)]; %basic matrix

fprintf('\nThe basic matrix is:');
B

Simplex = [];
C_b = [c(B_columns)];

X = [inv(B)*b]; % equivalent to inv(B)*C_b
Simplex = [Simplex X];
for i = 1: n+lt+gt+eq
    Simplex = [Simplex inv(B)*A(1:m, i)];
end

adder = [C_b*X];
for i = 1: n+lt+gt+eq
    adder = [adder C_b*Simplex(1:m, i+1) - c(i)];%since first column is of X
end
Simplex = [Simplex; adder];

fprintf('The Simplex matrix is:');
Simplex % a matrix of size (m+1)*(n+lt+gt+eq+1);

min_bottom_index = 2;
for i = 3: n+lt+eq+gt+1
    if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
        min_bottom_index = i;
    end
end

%finding the min_bottom index, and checking if to go to next iteration
iteration = 1;
if(Simplex(m+1, min_bottom_index) >= 0)
    fprintf('The optimal solution is corresponding to:');
    X
    fprintf('The solution is:');
    Simplex(m+1, 1);
    iteration = 0;
else
    for i = 2: n+lt+gt+eq+1
        if (Simplex(m+1, i) < 0)
            positive_found = 0;
            for j = 1: m
                if (Simplex(j, i) > 0)
                    positive_found = 1;
                end
            end
            if (positive_found == 0)
                fprintf('The solution to this problem is unbounded\n');
                iteration = 0;
            end
        end
    end
end

while iteration
    min_divider_index = 1;
    min_val = 100000;
    for i = 1:m
        if (Simplex(i, min_bottom_index) > 0)
            if (Simplex(i, 1)/Simplex(i, min_bottom_index) < min_val)
                min_divider_index = i;
                min_val = Simplex(i, 1)/Simplex(i, min_bottom_index);
            end
        end
    end

    B_columns(min_divider_index) = min_bottom_index -1;
    % the new basic matrix will have the min_bottom_index^th column of A

    B = A(1:m, B_columns);% new basic matrix
    C_b(min_divider_index) = c(min_bottom_index - 1); %new C_b
    X = inv(B)*b; %new X vector

    Simplex = [X];
    for i = 1:lt+gt+eq+n
        Simplex = [Simplex inv(B)*A(1:m, i)];
    end

    adder = [C_b*X];
    for i = 1: lt+gt+eq+n
        adder = [adder C_b*Simplex(1:m, i+1) - c(i)];
    end
    Simplex = [Simplex; adder];

    fprintf('The new basic matrix is:');
    B
    fprintf('The new Simplex matrix is: ');
    Simplex

    min_bottom_index = 2;
    for i = 3: n+lt+eq+gt+1
        if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
            min_bottom_index = i;
        end
    end
    
    %finding the min_bottom index, and checking if to go to next iteration
    if(Simplex(m+1, min_bottom_index) >= 0)
        fprintf('The optimal solution is corresponding to:');
        X
        fprintf('The solution is:');
        Simplex(m+1, 1)
        iteration = 0;
    else
        for i = 2: n+lt+gt+eq+1
            if (Simplex(m+1, i) < 0)
                positive_found = 0;
                for j = 1: m
                    if (Simplex(j, i) > 0)
                        positive_found = 1;
                    end
                end
                if (positive_found == 0)
                    fprintf('The solution to this problem is unbounded\n');
                    iteration = 0;
                end
            end
        end
    end

end %end of while loop