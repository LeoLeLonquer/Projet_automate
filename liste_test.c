//1)
int f () {
  int x= 5;
  if (1){
    int x= 23;
  }
}

//=====================
//2)

int f () {
  if (1){
    int x= 23;
  }
}

//======================
//3)
int f () {
  int x= 23;
  if (1) {
    if (0){x=4;}
    if(1){x=7;}
    int y=45;
  }
  int a =2;
  int b= 32;
  int c= a/b;
}

//=======================
//4)

int f () {
  int x= 5;
  while (1){
    int a= 23;
  }
  int b=42;
}

//========================

int f () {
  int x= 5+6+7+8+9;
}
//================
//6)
int f(int a){
  int x=4+5;
}


int main () {
  int a=3+2;
  f(a);
}

//==================
//7)


int main () {
  int a=5;

  while (a==5){
    a=a+1;
  }
}
//===================
//8)

int main () {
  int a=1;

  while (a==5){
    while(a==24){
        a=a+1;
      }
  }
  int b=2;
}
