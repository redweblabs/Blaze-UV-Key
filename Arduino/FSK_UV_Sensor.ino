/*int lowOut = 100;
int highOut = 500;*/

int startTone = 80;
int endTone = 120;

int lowOut = 50;
int highOut = 300;

long dataLength = 50000;

boolean firstReading = true;
float base;

int FSKout = 6;
int FSKin = A5;

int UVOUT = A0;
int REF_3V3 = A1;

int FSKPulseThreshold = 0;

int lastTimeIndex = 0;

int playing = 0;

int data[] = {0, 0, 0, 0, 0, 1, 0, 0};
float measuredUVIntensity;

void setup(){

  pinMode(FSKout, OUTPUT);
  pinMode(FSKin, INPUT);
  Serial.begin(9600);
}

int pulseStarted = false;

void loop(){
   
  getUVReading();
  convertToBinary();
  sendData();
  
}

void getUVReading(){
  
 int uvLevel = averageAnalogRead(UVOUT);
 int refLevel = averageAnalogRead(REF_3V3);
  
  float outputVoltage = 3.3 / refLevel * uvLevel;
  
  if(firstReading){
    base = outputVoltage;
    firstReading = false;
  }
  
  measuredUVIntensity = floor((mapfloat(outputVoltage, base, 2.9, 0.0, 15.0) * 100) / 30);
  
}

void convertToBinary(){
  
  String toBinary = String(int(measuredUVIntensity), BIN);

  Serial.println(toBinary);
  
  int i = toBinary.length();  
  
  for(int u = 7; u >= 0; u -=1){
    
    if(i > 0){
       if(int(toBinary[i - 1]) == 49){
          data[u] = 1;  
        } else if(int(toBinary[i - 1]) == 48){
          data[u] = 0; 
        } 
    } else {
      data[u] = 0;
    }
    
    i -= 1;
    
  }
}

void sendData(){
   
  int lastTime = timing();
  
  int buffPos = 0;
  
  long beginEnd = timing() + dataLength;
  
  while(timing() < beginEnd){
    digitalWrite(FSKout, HIGH);
    delayMicroseconds(startTone);
    digitalWrite(FSKout, LOW);
    delayMicroseconds(startTone);
  }
  
  digitalWrite(FSKout, LOW);
  delay(50);
  
  while(buffPos < 8){
    
     int sendBit = data[buffPos];

     long end = timing() + dataLength;
     
     while(timing() < end){
      
       if(sendBit == 0){
          
          digitalWrite(FSKout, HIGH);
          delayMicroseconds(lowOut);
          digitalWrite(FSKout, LOW);
          delayMicroseconds(lowOut);
          
       } else if(sendBit == 1){
         
          digitalWrite(FSKout, HIGH);
          delayMicroseconds(highOut);
          digitalWrite(FSKout, LOW);
          delayMicroseconds(highOut);
         
       }
     
     }
        
     buffPos += 1;
    
    
  }
  
  digitalWrite(FSKout, LOW);
  delay(50);
  
  long endEnd = timing() + dataLength;
  
  while(timing() < endEnd){
    digitalWrite(FSKout, HIGH);
    delayMicroseconds(endTone);
    digitalWrite(FSKout, LOW);
    delayMicroseconds(endTone); 
  }
  
  delay(1000);
  
}

int averageAnalogRead(int pinToRead){
   
  byte numberOfReadings = 8;
  unsigned int runningValue = 0;
  
  for(int x = 0; x < numberOfReadings; x += 1){
     runningValue += analogRead(pinToRead);
     runningValue /= numberOfReadings; 
  }
  
  return(runningValue);

}

float mapfloat(float x, float in_min, float in_max, float out_min, float out_max){
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; 
}

long timing(){
  return micros();
}