function ind = get_index(num, row)

ind = [];

if num == 1
    if row == 1;
        ind = 1;
    end
end

if num ~= 1
    tmp = (1 + row)*row/2;
    step = row;
    while tmp <= num
        ind = [ind, tmp];
        tmp = tmp + step;
        step = step + 1;
    end
end

if row ~= 1
    tmpNum = row -1;
    tmp = (row -2)*(row-1)/2+1;
    ind2 = tmp:1:tmp+tmpNum-1;
    ind = [ind, ind2];
end

end