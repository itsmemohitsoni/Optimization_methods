clc
cost_matrix = input('Enter the cost matrix: ');
[n, m] = size(cost_matrix);
while (m < n)
    cost_matrix = [cost_matrix zeros(n ,1)];
    m = m+1;
end
while(n < m)
    cost_matrix = [cost_matrix; zeros(1, m)];
    n = n+1;
end
const_cost_matrix = cost_matrix; % it won't be changed during operations

row_minimums = zeros(1, n);
for i = 1:n
    row_min = min(cost_matrix(i, :));
    for j = 1:n
        cost_matrix(i, j) = cost_matrix(i, j) - row_min;
    end
    row_minimums(i) = row_min;
end

column_minimums = zeros(1, n);
for i = 1:n
    col_min = min(cost_matrix(:, i));
    for j = 1: n
        cost_matrix(j, i) = cost_matrix(j, i) - col_min;
    end
    column_minimums(i) = col_min;
end

fprintf('\nAfter the first step, the Cost matrix is: \n');
disp(cost_matrix);

while (1) %loop breaks when number of independent zeros  = n
    marked_row = zeros(1, n);
    marked_col = zeros(1, n);

    zeros_in_matrix = zeros_mat(cost_matrix, n);
    duplicate_matrix = cost_matrix;

    while(zeros_in_matrix > 0) % here, we generate more zeros in the matrix if independent zeros are less than n
        column_zeros = zeros(1, n);
        row_zeros = zeros(1, n);
         
        %to calculate the number of zeros in each row and each column
        for i = 1: n
            for j = 1:n
                if(duplicate_matrix(i, j) == 0)
                    column_zeros(j) = column_zeros(j) + 1;
                    row_zeros(i) = row_zeros(i) + 1;
                end
            end
        end
    
        row_has_maximum_zeros = 1;
        if(max(column_zeros) > max(row_zeros))
            row_has_maximum_zeros = 0;
        end
    
        %if the maximun zeros are in a row, it will be marked
        if(row_has_maximum_zeros)
            [max_zeros_count, max_zero_index] = max(row_zeros);
            marked_row(max_zero_index) = 1;
            for j = 1:n
                duplicate_matrix(max_zero_index, j) = -1;
            end
            zeros_in_matrix = zeros_in_matrix - max_zeros_count;
        else
            [max_zeros_count, max_zero_index] = max(column_zeros);
            marked_col(max_zero_index) = 1;
            for i = 1:n
                duplicate_matrix(i, max_zero_index) = -1;
            end
            zeros_in_matrix = zeros_in_matrix - max_zeros_count;
        end
    end
    if(n == (sum(marked_col) + sum(marked_row)))
        fprintf('The optimal value of row-parameters U is: \n');
        disp(row_minimums);
        fprintf('The optimal value of column-parameters V is: \n');
        disp(column_minimums);
        fprintf('The Optimal Assignment Cost value using Hungarian method is: %d\n\n', (sum(column_minimums) + sum(row_minimums)));
        break;
    else
        min_unmarked_val = 10000;
        %calculating minimum unmarked values -> s
        for i = 1:n
            for j = 1:n
                if(~marked_row(i) && ~marked_col(j))
                    min_unmarked_val = min(min_unmarked_val, cost_matrix(i, j));
                end
            end
        end
    
        %updating cost matrix from C2 to C3
        for i = 1:n
            for j =1:n
                if(marked_row(i) && marked_col(j))
                    cost_matrix(i, j) = cost_matrix(i, j) + min_unmarked_val;
                end
                if(~marked_row(i) && ~marked_col(j))
                    cost_matrix(i, j) = cost_matrix(i, j) - min_unmarked_val;
                end
            end
        end
    
        for i = 1:n
            if(marked_row(i))
                row_minimums(i) = row_minimums(i) - min_unmarked_val;
            end
        end
    
        for j = 1:n
            if(~marked_col(j))
                column_minimums(j) = column_minimums(j) + min_unmarked_val;
            end
        end
        fprintf('Updated cost matrix in generating independent zeros: \n')
        disp(cost_matrix);
    end      
end


assigned_ones = 0;
assignment_matrix = zeros(n, n);
while(assigned_ones < n)
    column_zeros = zeros(1, n);
    row_zeros = zeros(1, n);
    for i = 1:n
        for j = 1:n
            if(cost_matrix(i, j) == 0)
                column_zeros(j) = column_zeros(j) + 1;
                row_zeros(i) = row_zeros(i) + 1;
            end
        end
    end
    
    for i = 1:n
        if(column_zeros(i) == 0)
            column_zeros(i) = 1000;
        end
        if(row_zeros(i) == 0)
            row_zeros(i) = 1000;
        end
    end %since after filling a particular row or column 
    
    row_has_minimum_zeros = 1;
    if(min(column_zeros) < min(row_zeros))
        row_has_minimum_zeros = 0;
    end
    
    if(row_has_minimum_zeros)
        [min_zeros_val, min_zeros_index] = min(row_zeros);
        for j = 1:n 
            if(cost_matrix(min_zeros_index, j) == 0)
                assignment_matrix(min_zeros_index, j) = 1;
                assigned_ones = assigned_ones + 1;
                
                cost_matrix(min_zeros_index, :) = -1;
                cost_matrix(:, j) = -1;
                break;
            end
        end
    else
        [min_zeros_val, min_zeros_index] = min(column_zeros);
        for i = 1: n
            if(cost_matrix(i, min_zeros_index) == 0)
                assignment_matrix(i, min_zeros_index) = 1;
                assigned_ones = assigned_ones + 1;

                cost_matrix(:, min_zeros_index) = -1;
                cost_matrix(i, :) = -1;
                break;
            end
        end
    end
end

fprintf('The Assignment matrix is: \n');
disp(assignment_matrix);

%since the assignment matrix will have only n basic cells
assignment_matrix(1, :) = 1;
%now the assignment matrix will have 2n-1 basic cells
ui_transportation = zeros(1, n);
vi_transportation = const_cost_matrix(1, :);
%to calculate ui_transportation
for i = 2:n 
    for j = 1: n
        if(assignment_matrix(i, j))
            ui_transportation(i) = const_cost_matrix(i, j) - vi_transportation(j);
        end
    end
end

fprintf('The value of dual variable U using transportation method is: \n');
disp(ui_transportation);
fprintf('The value of dual variable V using transportation method is: \n')
disp(vi_transportation);
fprintf('The optimal value from sum of U and V from transportation method is:  %d\n\n', sum(ui_transportation)+sum(vi_transportation))

%to calculate the current number of zeros in the cost matrix
function zeros_in_matrix = zeros_mat(matrix, n)
    zeros_in_matrix = 0;
    for i = 1: n
        for j = 1: n
            if(matrix(i, j) == 0)
                zeros_in_matrix = zeros_in_matrix+1;
            end
        end
    end
end