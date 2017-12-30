struct MyStruct
{
    int a,c;
    float b;
} ab;
int inc(int aa, int ac, float cc) 
{
int i=0,j=2,k[10][1];
float kk[12];
cc = kk[1];
i = i + 1;
return i;
}

int mymain(float aaa, struct MyStruct bbb, float abc[12]){
    int ccc=1;
    ccc = bbb.a;
    aaa = abc[10];
    ccc = inc(1,3,1.5);
    if(ccc == 1){
        return 0.0;
    }else{
        return 1.0;
    }

}