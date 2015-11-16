//The Leapmotion DSK is now included when you so a normal leapmotion install and run the leap motion controller



import de.voidplus.leapmotion.*;  //import leap motion library to interface with leapmotion sdk
import processing.serial.*; //import serial library to communicate with the ArbotiX


Serial sPort;            //serial object 
LeapMotion leap;
PVector hand_stabilized;
int trip = 0;//trips whe a finder is detected
int fistState = 0;//0 when nothing is present, 1 when 2-3 fingers, 2 for a hand, 3 for a fist
int fistStateLast = 0;//0 when nothing is present, 1 when a fist is present, 2 when a hand is present, but so are fingers (not-a-fist)
int locked = 1;//set to 1 when we lock in the coordinates withg a 'fist' gesture
int fingerTrip = 1;//trip for determining whrn the fingervs fist occured
int fistTrip = 0;
long prevMillis = 0;
long currMillis = 0;
int update = 33;//ms between update
int bufferCount =0;
int bufferCount2 =0;
 float   hand_yaw ;
 float   hand_roll;
 float   hand_pitch ;
 int gripperTrip;
 int gripperCount = 0;
 
 int fistCount = 0;
 int twoFingerCount = 0;
 int fiveFingerCount = 0;
 int noLeapCount = 0;
 int fistFlag =0;
 
 
 
 int tmpWrist;
 int wristFlag = 0;
 float twoPointDiff =0; 
PVector startPos = new PVector(0,0,0); //starting hand position, relative to which motion will work
float startRoll = 0;
float startPitch = 0;

 int gripperMode = 0;
 int wristMode = 0;
 int lastFingers = -1;
 //int tempFingers = 0;
 int stabalizedFingers =-1;
 int handRead = 0;
 int fiveRead = 0; //set to 1 the first time a fist is seen - this initlaializes the arm moving 
  
  PVector[] fingerPos = new PVector[5];
  
  int[][] fingerReadings = {
                      {0,0,0,0,0},
                      {0,0,0,0,0},
                      {0,0,0,0,0},
                      {0,0,0,0,0},
                      {0,0,0,0,0},
                      {0,0,0,0,0}
                      };
                      
   float[] fingersAvg = {0,0,0,0,0,0};      

//xyz readings
int[][] posReadings = {
                         {0,0,0,0,0},
                         {0,0,0,0,0},
                         {0,0,0,0,0},
  
                        };

int[] posAvg = {0,0,0};
   
 
//Make sure to cast values (127) via byte(), or else we get into unsigned byte territory

  int xVal = 512;
  int yVal = 250;
  int zVal = 250;
  int wristVal = 512;
  int gripperVal = 512;
  int wristAngleVal = 90;
  int deltaVal = 20;
  
  int xValTmp = 256;
  int yValTmp = 250;
  int zValTmp = 250;
  int wristValTmp = 512;
  int gripperValTmp = 512;
  int wristAngleValTmp = 90;
  int deltaValTmp = 125;


  byte[] xValBytes = intToBytes(xVal);
  byte[] yValBytes = intToBytes(yVal);
  byte[] zValBytes =  intToBytes(zVal);
  byte[] wristRotValBytes =  intToBytes(wristVal);
  byte[] wristAngleValBytes =  intToBytes(wristAngleVal);
  byte[] gripperValBytes =  intToBytes(gripperVal);
  byte[] deltaValBytes =  intToBytes(deltaVal);
  byte[] extValBytes = {0,0};
  byte buttonByte = 0;

void setup(){
  size(800, 500);
  background(255);
  noStroke(); fill(50);
  // ...
    
  leap = new LeapMotion(this);
  //sPort = new Serial(this, "COM139 ", 38400);
  
  
  sPort = new Serial(this, "/dev/tty.usbserial-A501RW77", 38400);
 // sPort = new Serial(this, "/dev/tty.usbserial-A501RVZV", 38400);
  prevMillis = millis();
}

void draw()
{
  background(255);
   
  handRead = 0; 
  for(Hand hand : leap.getHands())
  {
    hand_stabilized  = hand.getStabilizedPosition();
    handRead = 1;
    
    hand_roll        = hand.getRoll();
    hand_pitch       = hand.getPitch();
    /*
   
    hand_yaw         = hand.getYaw();
    */
    
    // FINGERS
    int fingers = 0;
    
    for(Finger finger : hand.getFingers())
    {
      
      fingerPos[fingers] = finger.getStabilizedPosition();
      fingers++;
    }
    
    
    shiftAvg();//shift the average back one
    
    
    
    
    
    //update last reading
    for(int j = 0; j <6; j++)
    {
      if (fingers == j)
      {
        
        fingerReadings[j][4] = 1;
      }
      else
      {
        
        fingerReadings[j][4] = 0;
        
      }
      
    }
    
        
    
    
    
    //sum aveage 
    
    for(int j = 0; j <6; j++)
    {
      fingersAvg[j] = 0;    
      for(int k=0; k <5; k++)
      {
        fingersAvg[j] = fingersAvg[j] + fingerReadings[j][k] ;
      }
      fingersAvg[j] = fingersAvg[j]/5;
     // println(fingersAvg[j]);      
    
    }
   // println("______________");
    
  //if the average hits '1' then there
  if(fingersAvg[5] == 1 & fiveRead ==0)
  {
     fiveRead =1; 
     startPos = hand_stabilized;
     println("FIVE!!");
     gripperMode = 0;
     wristFlag = 0;
  }
  if(fingersAvg[0] == 1 & fiveRead ==1)
  {
     fiveRead =0; 
     println("FIVE0000!!");
     gripperMode = 0;
     wristFlag = 0;
  }
  
  
     gripperMode = 0;
  if(fingersAvg[2] == 1 )
  {
    
     println("GRIP!!");
     
    float xd = fingerPos[0].x-fingerPos[1].x;
    float yd = fingerPos[0].y-fingerPos[1].y;
    float zd = fingerPos[0].z-fingerPos[1].z; 
    twoPointDiff = pow((xd*xd+yd*yd+zd*zd),.5);
    
    //println(twoPointDiff);
     fiveRead =0; 
     gripperMode = 1;
     wristFlag = 0;
    
  }
  
  wristMode = 0;
  /*
  if(fingersAvg[4] == 1 )
  {
    
    if(wristFlag ==0)
    {
      startRoll = hand_roll;
     wristFlag = 1; 
    }
    
     println("WRIST!!");
     float test = hand_roll - startRoll;
    println("Roll:" + test);
   // println(hand_pitch);
    
     fiveRead =0; 
    wristMode = 1;
    
    
  }
  
  */


    
  }//end hand?
  
  
  
  
  
  
  currMillis = millis();
   
  // println("moo " + currMillis + " " + fistState+ " " + fistStateLast);   
  //  if ((currMillis - prevMillis > update) & !(fistState == 2 & fistStateLast ==0 )  & !(fistStateLast == 0 & fistState == 0)  )
  if ((currMillis - prevMillis > update) & (fiveRead ==1 | gripperMode == 1| wristMode == 1))
  {
    
    if(gripperMode == 0 & wristMode == 0) 
    {
      xValTmp = int(map(hand_stabilized.x, 0, 900, -300,300));
      yValTmp = int(map(hand_stabilized.z, 10, 75, 50,350));
      zValTmp = int(map(hand_stabilized.y, 450, 100, 75,350));
   // } 

//echo zValTmp;

//zValTmp = 200;
    //yValTmp = int(map(hand_stabilized.z, 10, 75, 50,350)); 
    //=byte( 127 + mappedZ );
       
      if(abs(zValTmp - zVal) > 15)
      {
        zVal = zValTmp;
       // println("zup");
      }
      
      if(abs(xValTmp - xVal) > 15)
      {
        xVal = xValTmp;
        //println("xup");
      }  
        
      if(abs(yValTmp - yVal) > 3)
      {
        yVal = yValTmp;
        //println("yup");
      }
      
      
      xVal = xVal +512;

    }

  if(gripperMode == 1)
  {
    
    twoPointDiff = max(twoPointDiff,40);
    twoPointDiff = min(twoPointDiff,110);

    gripperVal = int(map(((twoPointDiff)), 40, 110, 0, 512)); 
    println(gripperVal);
  }

if(wristMode == 1 & (abs(hand_roll-startRoll) > 5 ) )
{
  
   // wristVal = int(map((hand_roll-startRoll), -10, 10, 0, 1024));
    wristVal = wristVal +int((hand_roll-startRoll));
    wristVal = max(wristVal,0);
    wristVal = min(wristVal,1023);
    println(wristVal);
}





/*
int[] reactorNormalX = {0,-300,300};
int[] reactorNormalY = {200,50,350};
int[] reactorNormalZ = {200,20,250};
int[] reactorNormalWristAngle = {0,-90,90};
int[] reactorWristRotate = {0,-512,511};
int[] reactorGripper = {256,0,512};
int[] reactor90X = {0,-300,300};
int[] reactor90Y = {150,20,140};
int[] reactor90Z = {30,10,150};
int[] reactor90WristAngle = {-90,-90,-45};
int[] reactorBase = {512,0,1023};
int[] reactorBHShoulder = {512,205,810};
int[] reactorBHElbow = {512,210,900};
int[] reactorBHWristAngle = {512,200,830};
int[] reactorBHWristRot = {512,0,1023};

*/

    
   // println(xVal + " " + yVal + " " + zVal + " " );

   
//zValTmp = 200;  
//zVal = 200;    
//yValTmp = 200;  
//yVal = 200;    
//xValTmp = 0;
//xVal = 0;



//
    xValBytes = intToBytes(xVal);
    yValBytes = intToBytes(yVal);
    zValBytes =  intToBytes(zVal);
    wristRotValBytes =  intToBytes(wristVal);
    wristAngleValBytes =  intToBytes(wristAngleVal);
    gripperValBytes =  intToBytes(gripperVal);
    deltaValBytes =  intToBytes(deltaVal); 
    sPort.clear();
    sPort.write(0xff);          //header
    sPort.write(xValBytes[1]); //X Coord High Byte
    sPort.write(xValBytes[0]); //X Coord Low Byte
    
    sPort.write(yValBytes[1]); //Y Coord High Byte
    sPort.write(yValBytes[0]); //Y Coord Low Byte
    
    sPort.write(zValBytes[1]); //Z Coord High Byte
    sPort.write(zValBytes[0]); //Z Coord Low Byte
    
     // println("mid write"+ millis());
    sPort.write(wristAngleValBytes[1]); //Wrist Angle High Byte
    sPort.write(wristAngleValBytes[0]); //Wrist Angle Low Byte
    
    sPort.write(wristRotValBytes[1]); //Wrist Rotate High Byte
    sPort.write(wristRotValBytes[0]); //Wrist Rotate Low Byte
    
    sPort.write(gripperValBytes[1]); //Gripper High Byte
    sPort.write(gripperValBytes[0]); //Gripper Low Byte
    
    
    
    sPort.write(deltaValBytes[0]); //Delta Low Byte
    
    sPort.write(buttonByte); //Button byte
    
    sPort.write(extValBytes[0]); //Extended instruction
    
    
    sPort.write((char)(255 - (xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+deltaValBytes[0] + buttonByte+extValBytes[0])%256));  //checksum
  
    prevMillis = currMillis;
  }//end serial packets 
}
void waitForArm()
{
  while(1==1)
  {
    byte[] inBuffer = new byte[1];
   inBuffer[0] = 0;
 
   while(sPort.available() > 0)
   {
      inBuffer = sPort.readBytes();
      sPort.readBytes(inBuffer);
      println(inBuffer[0]);
      if(inBuffer[0] == 70)
       {
        println("return");
        return; 
       }
   }
  }
  
}



void shiftAvg()
{
  
  
    
    
    
    
  
     // println("ff------------------");
    for(int j = 0; j <6; j++)
    {
          
      for(int k=0; k <4; k++)
      {
        
        fingerReadings[j][k] = fingerReadings[j][k+1] ;
        //print(fingerReadings[j][k]);
       // print("-");
      }
     // println("");
      
    
    }
  
      //println("ff------------------");
      
  
}

byte[] intToBytes(int convertInt)
{
  byte[] returnBytes = new byte[2]; // array that holds the returned data from the registers only 
  byte mask = byte(0xff);
  returnBytes[0] =byte(convertInt & mask);//low byte
  returnBytes[1] =byte((convertInt>>8) & mask);//high byte
  return(returnBytes);
  
}



