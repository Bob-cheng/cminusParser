int inc(int c, int d){
    int a = 2, b = 5, e[10];

    while (a > 0){
        if(a == 1){
            b = 10;
        }
        b = b -1;
        a = a -1;
    }

    if(a == 1 || a == 3){
        c = 3;
    }
    return b;
}
