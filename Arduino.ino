#include <Servo.h> // Incluye la librería necesaria para el servomotor del freno
#include <SoftwareSerial.h>   // Incluimos la librería  SoftwareSerial
SoftwareSerial BT(10,11); // Define los pines RX y TX del Arduino conectados al Bluetooth (necesario para la función de envío de datos) 
Servo freno; // Crea un objeto para controlar el servomotor del freno


// Variables

// Sensor hall
int ah; // Comprobación de inicio de conmutación en el sensor hall
unsigned long toh=0, tfh, dth, kh=12000, vh, vhmax=200;
// Variables no empleadas
// unsigned long vh2, dvh, aah;

// Anemómetro
int aan; // Comprobación de inicio de conmutación en el anemómetro
unsigned long toa=0, tfa, dta, ka=666667, va, vamax=10000;
// Variables no empleadas
// unsigned long va2, dva, aa;

// Freno
int pos, poso=90, poslims=180, poslimi=90; 


// Programa principal (Main)

// Inicialización
void setup() 
{
  BT.begin(9600); // Inicializamos el puerto serie BT (Para Modo AT 2) (necesario para la función de envío de datos) 
  Serial.begin(9600);
  
  pinMode(2, INPUT); // Asigna el pin 2 al sensor Hall
  pinMode(3, INPUT); // Asigna el pin 3 al anemómetro
  freno.attach(4); // Asigna el pin 4 al servomotor del freno
  
  freno.write(poso); // Coloca el freno en la posición inicial
  
  delay (1000); // Espera 1s antes de iniciar el bucle
}

// Bucle principal
void loop() 
{
  if(digitalRead(3)==HIGH) // Si el anemómetro no detecta conmutación
  {
    aan=1; 
    servo(); // Ejecuta la función de movimiento del freno
  }

    if(digitalRead(2)==HIGH) // Si el sensor hall no detecta conmutación
  {
    ah=1;
    servo(); // Ejecuta la función de movimiento del freno
  }
  
  if(digitalRead(3)==LOW) // Si el anemómetro detecta conmutación
  {
    if(aan==1) // Si la conmutación es detectada justo después de la ausencia de conmutación del anemómetro
    { 
      tfa = millis(); // Guarda el tiempo de la conmutación actual del anemómetro
      dta = tfa-toa; // Calcula el diferencial de tiempo respecto a la conmutación anterior del anemómetro
      toa = millis(); // Guarda el tiempo de la conmutación actual para ser empleado en la siguiente conmutación del anemómetro
          
      if(dta!=0) // Si el diferencial de tiempo del anemómetro no es 0
      {
        va = ka/dta; // Calcula la velocidad del viento
        //dva = va-va2;
        //va2 = va;
        //aa = dva/dta;
      }
      else // Si el diferencial de tiempo del anemómetro es 0
      {
        va = 9999; // Fija una velocidad del viento muy alta
        Serial.print("error va"); // Indica mediante un mensaje en el "Serial" que se ha producido un error en el anemómetro
        //dva = va-va2;
        //va2 = va;
        //aa = 10e6;
      }

      // Indica en el "Serial" la velocidad del viento
      Serial.print("va:");
      Serial.print(va);
      Serial.println('\t');
      
      enviar(1); //Función de envío de datos (desarrollada por Javier Colinas Cano)
    }
    
    aan=0; // Asegura que no se vuelva a calcular el diferencial de tiempo hasta la siguiente conmutación real del anemómetro

    servo(); // Ejecuta la función de movimiento del freno
  }

  if(digitalRead(2)==LOW) // Si el sensor hall detecta conmutación
  {
    if(ah==1) // Si la conmutación es detectada justo después de la ausencia de conmutación del sensor hall
    { 
      tfh = millis(); // Guarda el tiempo de la conmutación actual del sensor hall
      dth = tfh-toh; // Calcula el diferencial de tiempo respecto a la conmutación anterior del sensor hall
      toh = millis(); // Guarda el tiempo de la conmutación actual para ser empleado en la siguiente conmutación del sensor hall
          
      if(dth!=0) // Si el diferencial de tiempo del sensor hall no es 0
      {
        vh = kh/dth; // Calcula la velocidad angular de la turbina
        //dvh = vh-vh2;
        //vh2 = vh;
        //aah = dvh/dth;
      }
      else // Si el diferencial de tiempo del sensor hall es 0
      {
        vh = 199; // Fija una velocidad de la turbina muy alta
        Serial.print("error vh");  // Indica mediante un mensaje en el "Serial" que se ha producido un error en el sensor hall
        //dvh = vh-vh2;
        //vh2 = vh;
        //aah = 10e6;     
      }
      
      // Indica en el "Serial" la velocidad angular de la turbina
      Serial.print("vh:");
      Serial.print(vh);
      Serial.println('\t');
      
      enviar(2); //Función de envío de datos (desarrollada por Javier Colinas Cano)
    }
    
    ah=0; // Asegura que no se vuelva a calcular el diferencial de tiempo hasta la siguiente conmutación real del sensor hall

    servo(); // Ejecuta la función de movimiento del freno
  }
}


// Función de movimiento del freno
void servo()
{
  pos = freno.read(); // Detecta la posición actual del servomotor
  
  if((va>=vamax || vh>=vhmax) && pos<poslims) // Si la velocidad del viento o la velocidad angular de la turbina superan o igualan los valores límite establecidos y la posición del servomotor no es la de frenado
  {
    // pos +=1; Inicialmente se encotraba así, por ello el servomotor tenía problemas puesto que había perturbaciones en su movimiento y en el par.
    pos = poslims; // El servomotor se sitúa en posición de frenado. Javier Colinas Cano sugirió este cambio y ahora funciona corréctamente.
  }

  if(va<vamax && vh<vhmax && pos>poslimi) // Si la velocidad del viento y la velocidad angular de la turbina son inferiores a los valores límite establecidos y la posición del servomotor no es la de máxima apertura
  {
    // pos -=1;
    pos = poslimi; // El servomotor se sitúa en posición de apertura
  }
  
  freno.write(pos); // Envía la señal correspondiente al servomotor
}


//Función de envío de datos (desarrollada por Javier Colinas Cano)
void enviar(int e)//esta función recibe un 1 o un 2 según si el dato a enviar es del anemómetro o del sensor de efecto hall respectivamente.
{
  //El módulo bluetooth HC-05 solo puede enviar datos que ocupen 8 bits como máximo, por tanto, para poder enviar los datos mayores se usarán variables auxiliares para permitir el envío de dato completo.
  static int d;
  static int f;
  if (e==1)
  {
    f=tfa>>16;
    d=tfa>>8;
    BT.write(65);//se envía un número que al ser recibido en matlab se lee según el código ASCII y se traduce como una A el 65 y una H el 72, haciendo referencia a los datos recibidos del anemómetro y del sensor de efecto Hall respectivamente.
    BT.write(f);
    f = 0; //se actualizan las variables para evitar posibles errores.
    BT.write(d);
    d = 0;
    BT.write(tfa);
  }
  else
  {
    f=tfh>>16;
    d=tfh>>8;
    BT.write(72);
    BT.write(f);
    f = 0;
    BT.write(d);
    d = 0;
    BT.write(tfh);
  }
}
