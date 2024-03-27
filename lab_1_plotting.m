C = input('Enter the matrix C: ');
A = input('Enter the matrix A: ');
b = input('Enter the matrix b: ');
n = 3;
syms x1 x2

X = linprog(-1*C, A, b);
X

for i = 1:n
    hold on
    ezplot(A(i,1)*x1 + A(i,2)*x2 == b(i),[0,10,0,10]);
    hold off
end
hold on
ezplot(C(1,1)*x1 + C(1,2)*x2 == 8,[0,10,0,10]);
ezplot(C(1,1)*x1 + C(1,2)*x2 == 16,[0,10,0,10]);
ezplot(C(1,1)*x1 + C(1,2)*x2 == 12,[0,10,0,10]);
hold off
