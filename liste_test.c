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
