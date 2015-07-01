a = rand(1,1);
b = rand(1,1);
c = rand(1,1);
x = [a, b, c, c, c, c, c, c, c; b, a, c, c, c, c, c, c, c;c, c, a, b, b, b, c, c, c;
    c, c, b, a, b, b, c, c, c; c, c, b, b, a, b, c, c, c; c, c, b, b, b, a, c, c, c;
    c, c, c, c, c, c, a, b, b; c, c, c, c, c, c, b, a, b; c, c, c, c, c, c, b, b, a]

inv(x)
