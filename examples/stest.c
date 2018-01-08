struct myst{
    int sta;
    int stb[10];
};

int fact(int n)
{
if (n == 1)
    return n;
else
    return (n * fact(n - 1));
}

int inc(int c, int d){
    int a = 2, b = 5, e[10];
    struct myst stst, ststarr[5];
    b = stst.sta;
    ststarr[1].stb[2] = 5;
    d = read();
    c = e[2];
    e[9] = 5;
    while (a > 0){
        if(!(a==1)){
            b = 10;
            c = fact(c);
        }
        b = b -1;
        a = a -1;
    }

    if(a == 1 || a == 3 && b == 3){
        c = 3;
    }else{
        c = 4;
        write(c);
    }
    return b;
}
