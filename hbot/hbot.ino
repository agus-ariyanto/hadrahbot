int ch1a = 12;
int ch1b = 11;
int ch2a = 10;
int ch2b = 6;
int ch3a = 5;
int ch3b = 4;
int ch4a = 3;
int ch4b = 2;

int inbytes[8] = {'0', '0', '0', '0', '0', '0', '0', '0'};

//int step[3]={60,80,120};
//unsigned long timenow=0;

void setup() {
  // put your setup code here, to run once:

  pinMode(ch1a, OUTPUT);
  pinMode(ch1b, OUTPUT);

  pinMode(ch2a, OUTPUT);
  pinMode(ch2b, OUTPUT);

  pinMode(ch3a, OUTPUT);
  pinMode(ch3b, OUTPUT);

  pinMode(ch4a, OUTPUT);
  pinMode(ch4b, OUTPUT);

  off();
  //115200,9600
  Serial.begin(115200);
  delay(500);
  Serial.write("ready");
}

void off() {
  for (int i = 0; i < 8; i++) {
    inbytes[i] = '0';
  }
  digitalWrite(ch1a, LOW);
  digitalWrite(ch1b, LOW);

  digitalWrite(ch2a, LOW);
  digitalWrite(ch2b, LOW);

  digitalWrite(ch3a, LOW);
  digitalWrite(ch3b, LOW);

  digitalWrite(ch4a, LOW);
  digitalWrite(ch4b, LOW);
}

void play() {
  if (inbytes[0] =='1') digitalWrite(ch1a, HIGH);
  if (inbytes[1] =='1') digitalWrite(ch1b, HIGH);
  if (inbytes[2] =='1') digitalWrite(ch2a, HIGH);
  if (inbytes[3] =='1') digitalWrite(ch2b, HIGH);
  if (inbytes[4] =='1') digitalWrite(ch3a, HIGH);
  if (inbytes[5] =='1') digitalWrite(ch3b, HIGH);
  if (inbytes[6] =='1') digitalWrite(ch4a, HIGH);
  if (inbytes[7] =='1') digitalWrite(ch4b, HIGH);
}
void stop(int s) {
  if (inbytes[0] == s) digitalWrite(ch1a, LOW);
  if (inbytes[1] == s) digitalWrite(ch1b, LOW);
  if (inbytes[2] == s) digitalWrite(ch2a, LOW);
  if (inbytes[3] == s) digitalWrite(ch2b, LOW);
  if (inbytes[4] == s) digitalWrite(ch3a, LOW);
  if (inbytes[5] == s) digitalWrite(ch3b, LOW);
  if (inbytes[6] == s) digitalWrite(ch4a, LOW);
  if (inbytes[7] == s) digitalWrite(ch4b, LOW);
}

void test() {
  digitalWrite(ch1a, HIGH);
  digitalWrite(ch1b, HIGH);
  delay(500);
  digitalWrite(ch2a, HIGH);
  digitalWrite(ch2b, HIGH);
  delay(500);
  digitalWrite(ch3a, HIGH);
  digitalWrite(ch3b, HIGH);
  delay(500);
  digitalWrite(ch4a, HIGH);
  digitalWrite(ch4b, HIGH);
  delay(500);
}
void loop() {
  int i = 0;
  while (Serial.available()) {
    inbytes[i] = Serial.read();
    i++;
    if (i > 8) i = 0;
  }
  play();
  delay(60);
  off();
}
