clc

                    %Inputing as given
n = input('Enter the number of variables: ');
m = input('Enter the number of constraints: ');

lt = input('Enter the number of less-than constraints: ');
gt = input('Enter the number of greater-than constraints: ');
eq = input('Enter the number of equal to constraints: ');

lt_cons = input('\nEnter the coefficients of less-than constraints in matrix form: ');
lt_rhs = input('Enter the RHS of less-than constraints in column vector form: ');

gt_cons = input('\nEnter the coefficients of greater-than constraints in matrix form: ');
gt_rhs = input('Enter the RHS of greater than constraints in column vector form: ');

eq_cons = input('\nEnter the coefficients of equal to constraints in matrix form: ');
eq_rhs = input('Enter the RHS of equal to constraints in column vector form: ');

A = [];
b = [];
if(lt)
    A = [A; lt_cons];
    b = [b; lt_rhs];
end
if(gt)
    A = [A; gt_cons];
    b = [b; gt_rhs];
end
if(eq)
    A = [A; eq_cons];
    b = [b; eq_rhs];
end

minimization = input('\nEnter 0 if the probelem is maximization type or Enter 1 if the problem is minimization type: ');

c = input('\nEnter the coefficients of the objective function: ');
c_phase1 = zeros(1, n);
                        
if (minimization == 1)
    c = -1*c;
end
%converting it to maximization type

%adding surplus variables to A
for i  = lt+1: lt+gt
    adder = [];
    for j = 1: m
        if (j == i)
            adder = [adder; -1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0];
    c_phase1 = [c_phase1 0];
end

%adding slack variables to A
for i  = 1: lt
    adder = [];
    for j = 1: m
        if (j == i)
            adder = [adder; 1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0];
    c_phase1 = [c_phase1 0];
end

%adding artificial variables to A
for i  = lt+1: lt+gt
    adder = [];
    for j = 1: m
        if (j == i)
            adder = [adder; 1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c -1];
    c_phase1 = [c_phase1 -1];
end

%adding artificial variables to A
for i  = lt+gt+1: lt+eq+gt
    adder = [];
    for j = 1: m
        if (j == i)
            adder = [adder; 1];
        else
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c -1];
    c_phase1 = [c_phase1 -1];
end

fprintf('\nThe matrix A after adding slack, surplus and artificial variables is');
A
fprintf('The objective function after adding slack, surplus, and artificial variables is');
c

                        %Start of phase1
           
fprintf('Start of phase 1: ');
B_columns = n+lt+eq+2*gt-m+1: n+lt+eq+2*gt;
%the columns of A which will form the basic matrix
fprintf('\nThe objective function for phase 1 is: ');
c_phase1

Basic_matrix = A(1:m, B_columns);
fprintf('\nThe first basic matrix is: ');
Basic_matrix

X_b = inv(Basic_matrix)*b;

%Creating the first simplex matrix
Simplex = [X_b];
for i = 1: n+lt+eq+2*gt
    Simplex = [Simplex inv(Basic_matrix)*A(:, i)];
end

%adding zj - cj to Simplex table
last_row_table = c_phase1(B_columns)*X_b;
for i = 1: lt+eq+2*gt+n
    last_row_table = [last_row_table c_phase1(B_columns)*Simplex(:,i+1) - c_phase1(i)];
end
Simplex = [Simplex; last_row_table];
fprintf('The first table is: ');
Simplex

                            %iterations performed for phase 1
iterate = 1;
while ((Simplex(m+1, 1) ~= 0) && iterate)

    min_bottom_index = 2;
    for i = 3: n+lt+eq+2*gt+1
        if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
            min_bottom_index = i;
        end
    end

                        %infeasible solution
    if(Simplex(m+1, min_bottom_index) >= 0)
        fprintf('\nThe LPP is infeasible. \nIt has no feasible solution.');
        iterate = 0;
    else
                        %unbounded solution
        for i = 2: n+lt+2*gt+eq+1
            if (Simplex(m+1, i) < 0)
                positive_found = 0;
                for j = 1: m
                    if (Simplex(j, i) > 0)
                        positive_found = 1;
                    end
                end
                if (positive_found == 0)
                    fprintf('The solution to this problem is unbounded\n');
                    iterate = 0;
                end
            end
        end
    end

                        %go to next iteration
    if iterate
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
    
        Basic_matrix = A(1:m, B_columns);% new basic matrix
        X_b = inv(Basic_matrix)*b;

        Simplex = X_b;
        for i = 1:lt+2*gt+eq+n
            Simplex = [Simplex inv(Basic_matrix)*A(1:m, i)];
        end

        last_row_table = c_phase1(B_columns)*X_b;
        for i = 1: lt+eq+2*gt+n
            last_row_table = [last_row_table c_phase1(B_columns)*Simplex(:, i+1) - c_phase1(i)];
        end
        Simplex = [Simplex; last_row_table];

        fprintf('The new basic matrix is: ');
        Basic_matrix
        fprintf('The new Simplex table is: ');
        Simplex
    end
end
fprintf('End of Phase 1.');

                            %Proceeding to phase 2
fprintf('\nStart of phase 2: ');
if(iterate)
                            %means the solution is yet to be found
    Simplex = X_b;
    for i = 1:lt+2*gt+eq+n
        Simplex = [Simplex inv(Basic_matrix)*A(1:m, i)];
    end

    last_row_table = c(B_columns)*X_b;
    for i = 1: lt+eq+2*gt+n
        last_row_table = [last_row_table c(B_columns)*Simplex(:, i+1) - c(i)];
    end
    Simplex = [Simplex; last_row_table];

    fprintf('\nThe new Simplex table corresponding to phase 2 is: ');
    Simplex

                       %checking whether further iteration needs to proceed
    min_bottom_index = 2;
    for i = 3: n+lt+eq+2*gt+1
        if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
            min_bottom_index = i;
        end
    end

    if(Simplex(m+1, min_bottom_index) >= 0.0)
        fprintf('The optimal solution is corresponding to:\n');
        for i = 1: m
            fprintf('x%d = %d\n', B_columns(i), X_b(i));
        end
        fprintf('\nThe solution is: ');
        if(minimization)
            Simplex(m+1, 1) = Simplex(m+1, 1)*(-1);
        end
        Simplex(m+1, 1)
        iterate = 0;
    else
        for i = 2: n+lt+2*gt+eq+1
            if (Simplex(m+1, i) < 0)
                positive_found = 0;
                for j = 1: m
                    if (Simplex(j, i) > 0)
                        positive_found = 1;
                    end
                end
                if (positive_found == 0)
                    fprintf('The solution to this problem is unbounded\n');
                    iterate = 0;
                end
            end
        end
    end

                                %iterations for phase 2
    while iterate
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
    
        Basic_matrix = A(1:m, B_columns);% new basic matrix
        X_b = inv(Basic_matrix)*b; %new X vector
    
        Simplex = [X_b];
        for i = 1:lt+2*gt+eq+n
            Simplex = [Simplex inv(Basic_matrix)*A(1:m, i)];
        end
    
        adder = [c(B_columns)*X_b];
        for i = 1: lt+2*gt+eq+n
            adder = [adder c(B_columns)*Simplex(1:m, i+1) - c(i)];
        end
        Simplex = [Simplex; adder];
    
        fprintf('The new basic matrix is:');
        Basic_matrix
        fprintf('The new Simplex matrix is: ');
        Simplex
    
        min_bottom_index = 2;
        for i = 3: n+lt+eq+2*gt+1
            if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
                min_bottom_index = i;
            end
        end
        
        %finding the min_bottom index, and checking if to go to next iteration
        if(Simplex(m+1, min_bottom_index) >= -0)
            fprintf('The optimal solution is corresponding to:\n');
            for i = 1: m
                fprintf('x%d = %d\n', B_columns(i), X_b(i));
            end
            fprintf('\nThe solution is: ');
            if(minimization == 1)
                Simplex(m+1, 1) = Simplex(m+1, 1)*(-1);
            end
            Simplex(m+1, 1)
            iterate = 0;
        else
            for i = 2: n+lt+2*gt+eq+1
                if (Simplex(m+1, i) < 0)
                    positive_found = 0;
                    for j = 1: m
                        if (Simplex(j, i) > 0)
                            positive_found = 1;
                        end
                    end
                    if (positive_found == 0)
                        fprintf('The solution to this problem is unbounded\n');
                        iterate = 0;
                    end
                end
            end
        end
    
    end %end of while loop
end
fprintf('\nEnd of phase 2');