clc
num_sources = input('Enter the number of sources: ');
num_demands = input('Enter the number of demand points: ');
sources = input('Enter the source capacitites in an array: ');
demands = input('Enter the demands in an array: ');
cost_matrix = input('Enter the cost matrix from sources to demand: ');
orig_cost = cost_matrix;
xij = zeros([num_demands, num_sources])

total_demand = sum(demands)
total_supply = sum(sources)
while(total_demand > 0 && total_supply > 0)
    min_cost_i = 1;
    min_cost_j = 1;
    for i = 1: num_sources
        for j = 1: num_demands
            if (cost_matrix(j, i) < cost_matrix(min_cost_j, min_cost_i))
                min_cost_i = i;
                min_cost_j = j;
            end
        end
    end
    xijchanges = 0;
    if(sources(min_cost_i) < demands(min_cost_j))
        xijchanges = sources(min_cost_i);
    else
        xijchanges = demands(min_cost_j);
    end
    xij(min_cost_j, min_cost_i) = xijchanges;
    sources(min_cost_i) = sources(min_cost_i) - xijchanges;
    demands(min_cost_j) = demands(min_cost_j) - xijchanges;
    cost_matrix(min_cost_j, min_cost_i) = 100000;
    total_demand  = total_demand - xijchanges;
    total_supply = total_supply - xijchanges;
end

xij
cost_matrix
total_cost = sum(sum(xij.*orig_cost))