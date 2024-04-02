clc
num_sources = input('Enter the number of sources: ');
num_demands = input('Enter the number of demand points: ');
sources = input('Enter the source capacitites in an array: ');
demands = input('Enter the demands in an array: ');
cost_matrix = input('Enter the cost matrix from sources to demand: ');

orig_cost = cost_matrix;
xij_matrix = zeros([num_demands, num_sources]);
total_supply = sum(sources)
total_demand = sum(demands)

row_min_min2_difference = zeros([1, num_sources]);
columns_min_min2_difference = zeros([1, num_demands]);

while (total_supply && total_demand)
    for i = (1: num_demands)
        if(row_min_min2_difference(i) ~= -1)
            sorted_this_row = sort(cost_matrix(i, :));
            row_min_min2_difference(i) = sorted_this_row(2) - sorted_this_row(1);
        end
    end
    
    for i = (1: num_sources)
        if(columns_min_min2_difference(i) ~= -1)
            sorted_this_row = sort(cost_matrix(:, i));
            columns_min_min2_difference(i) = sorted_this_row(2) - sorted_this_row(1);
        end
    end
    
    row_diff_max = max(row_min_min2_difference);
    col_diff_max = max(columns_min_min2_difference);
    row_diff_is_max = 1;
    if(col_diff_max > row_diff_max)
        row_diff_is_max = 0;
    end
    
    if(row_diff_is_max) % if the max difference is from the row's diff
        [xxx, max_index] = max(row_min_min2_difference);
        [xxx, min_cost_index] = min(cost_matrix(max_index, :));
    
        xij_value = min(sources(min_cost_index), demands(max_index));
        xij_matrix(max_index, min_cost_index) = xij_value;
        sources(min_cost_index) = sources(min_cost_index) - xij_value;
        demands(max_index) = demands(max_index) - xij_value;
        total_demand = total_demand - xij_value;
        total_supply = total_supply - xij_value;
    
        
        if(sources(min_cost_index) < demands(max_index))
            columns_min_min2_difference(min_cost_index) = -1;
            cost_matrix(:, min_cost_index) = 10000;
            % the complete row is deleted i.e. all elements gets very high cost
        else 
            row_min_min2_difference(max_index) = -1;
            cost_matrix(max_index, :) = 10000;
            % the complete column is deleted i.e. all elements gets very high cost
        end
    else %if the max difference is from the column difference
        [xxx, max_index] = max(columns_min_min2_difference);
        [xxx, min_cost_index] = min(cost_matrix(:, max_index));
    
        xij_value = min(sources(max_index), demands(min_cost_index));
        xij_matrix(min_cost_index, max_index) = xij_value;
        sources(max_index) = sources(max_index) - xij_value;
        demands(min_cost_index) = demands(min_cost_index) - xij_value;
        total_demand = total_demand - xij_value;
        total_supply = total_supply - xij_value;
    
        if(sources(max_index) < demands(min_cost_index))
            cost_matrix(:, max_index) = 10000;
            columns_min_min2_difference(max_index) = -1;
            % the complete row is deleted i.e. all elements gets very high cost
        else
            row_min_min2_difference(min_cost_index) = -1;
            cost_matrix(min_cost_index, :) = 10000;
            % the complete column is deleted i.e. all elements gets very high cost
        end
    end
    
    fprintf('The current X matrix is ');
    xij_matrix

end

final_X_matrix = xij_matrix
Total_cost = sum(sum(xij_matrix.*orig_cost))
% denotes the optimal value of the function