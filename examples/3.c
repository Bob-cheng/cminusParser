struct MyStruct
{
    int a,c;
    float b;
} ab;

struct MyStruct2
{
    int a2,c2;
    float b2;
} ab2;
int inc(int aa, int ac, float cc) 
{
int i=0,j=2,k[10][1];
int kk[12][2];
kk=k;
i = i + 1;
return i;
}


int mymain(float aaa, struct MyStruct bbb, float abc[12],struct MyStruct bbb2){
    int ccc=1;
    ccc = read();
    write(ccc);
    ab = bbb2;
    ccc = ab.a;
    aaa = abc[10];
    ab = ab2;
    ccc = inc(1,3,1.5);
    if(ccc == 1){
        return 0.0;
    }else{
        return 1.0;
    }

}