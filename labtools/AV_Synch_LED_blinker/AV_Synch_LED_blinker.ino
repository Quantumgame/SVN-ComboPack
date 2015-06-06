// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.




int i=0;
int led = 13;
int IRled = 9;
int duration = 10; //in ms
int interval = 10000; //in ms

void setup() 
{ 
  pinMode(led, OUTPUT);        // initialize the digital pin as an output.
  pinMode(IRled, OUTPUT);        // initialize the digital pin as an output.



} 


void loop() 
{ 
  delay(0); //10 seconds
  for (i=1; i<10; i+=1) //wave n times
  {
    digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
    digitalWrite(IRled, HIGH);   // turn the LED on (HIGH is the voltage level)
    tone(8, 2000);
delay(duration);
    digitalWrite(led, LOW);   // turn the LED on (HIGH is the voltage level)
    digitalWrite(IRled, LOW);   // turn the LED on (HIGH is the voltage level)
    noTone(8);
delay(interval);
  }
 // delay(1800000); //30 minutes 1200000=20 minutes

} 

