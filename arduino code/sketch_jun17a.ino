int state = 1; // Estado del motor
int angulo_actual = 0; // angulo con el cual se toma la foto
int angulo_de_trabajo; // angulo que gira el motor cuando se le da la orden
int pinOrden; //pin por donde se envía la orden de tomar foto
int pasos =16;
int servoPin=0;
#include <Stepper.h>



Stepper myStepper(pasos, 10, 11, 9, 8);

void setup() {
    Serial.begin(9600); // iniciando la comunicación en serie y definiendo el servo pin como salida
    pinMode (servoPin, OUTPUT);
    myStepper.setSpeed(20);
}

void mover_motor()
{
//    DDRB = B11111110;
//    DDRB = DDRB | B11111100;
    int j = 0;
    
    if(Serial.read() == 'H'){
      
      while(j < 132){
          if(3 - (j % 4) == 0){
              digitalWrite(8,LOW);
              digitalWrite(9,HIGH);
              digitalWrite(10,HIGH);
              digitalWrite(11,HIGH);
          }
          else if(3 - (j % 4) == 1)
          {
              digitalWrite(8,HIGH);
              digitalWrite(9,HIGH);
              digitalWrite(10,LOW);
              digitalWrite(11,HIGH);
          }
          else if( 3 - (j % 4) == 2)
          {
              digitalWrite(8,HIGH);
              digitalWrite(9,LOW);
              digitalWrite(10,HIGH);
              digitalWrite(11,HIGH);
          }
          else
          {
              digitalWrite(8,HIGH);
              digitalWrite(9,HIGH);
              digitalWrite(10,HIGH);
              digitalWrite(11,LOW);
          }
          j++;
          //digitalWrite(12,LOW);
          delay(10);
          } 
          digitalWrite(12, LOW);
          Serial.write("B");
        }
    }

void loop() {
      mover_motor();
}
