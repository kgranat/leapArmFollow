/***********************************************************************************
 *  }--\     Leap Arm        /--{
 *      |                    |
 *   __/      \__/           \__
 *  |__|      [__]           |__|
 *
 *
 *
 *
 *    Requirements:
 *
 *
 *
 ************************************************************************************/

import de.voidplus.leapmotion.*;  //import leap motion library to interface with leapmotion sdk
import processing.serial.*; //import serial library to communicate with the ArbotiX -M
import g4p_controls.*;      //import g4p library for GUI elements
import java.awt.Font;       //import font


Serial sPort;            //serial object 
LeapMotion leap;          //leap motion object


int numSerialPorts = Serial.list().length;                 //Number of serial ports available at startup
String[] serialPortString = new String[numSerialPorts+1];  //string array to the name of each serial port - used for populating the drop down menu
int selectedSerialPort;                                    //currently selected port from serialList drop down
Serial[] sPorts = new Serial[numSerialPorts];  //array of serial ports, one for each avaialable serial port.
int armPortIndex = -1; //the index of the serial port that an arm is currently connected to(relative to the list of avaialble serial ports). -1 = no arm connected


boolean debugConsole = true;      //change to 'false' to disable debuging messages to the console, 'true' to enable 
boolean debugFile = false;        //change to 'false' to disable debuging messages to a file, 'true' to enable

boolean debugGuiEvent = true;     //change to 'false' to disable GUI debuging messages, 'true' to enable
boolean debugSerialEvent = false;     //change to 'false' to disable GUI debuging messages, 'true' to enable
boolean debugFileCreated  = false;  //flag to see if the debug file has been created yet or not

int packetRepsonseTimeout = 5000;      //time to wait for a response from the ArbotiX Robocontroller / Arm Link Protocol
int startupWaitTime = 10000;    //time in ms for the program to wait for a response from the ArbotiX


  //holds the data from the last packet sent
  int lastX;
  int lastY;
  int lastZ;
  int lastWristangle;
  int lastWristRotate;
  int lastGripper;
  int lastButton;
  int lastExtended;
  int lastDelta;
   
   
   
int connectFlag = 0;
int disconnectFlag = 0;
int autoConnectFlag = 0;

boolean updateFlag = false;     //trip flag, true when the program needs to send a serial packet at the next interval, used by both 'update' and 'autoUpdate' controls
int updatePeriod = 33;          //minimum period between packet in Milliseconds , 33ms = 30Hz which is the standard for the commander/arm link protocol


int currentArm = 0;          //ID of current arm. 1 = pincher, 2 = reactor, 3 = widowX, 5 = snapper
int currentMode = 0;         //Current IK mode, 1=Cartesian, 2 = cylindrical, 3= backhoe
int currentOrientation = 0;  //Current wrist oritnation 1 = straight/normal, 2=90 degrees



PVector hand_stabilized;
PVector hand_raw;
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

  int Leapx;
  int Leapy;
  int Leapz;
  
  int LeapTmpx;
  int LeapTmpy;
  int LeapTmpz;

  int xValold;
  int yValold;
  int zValold;
  
  byte[] xValBytes = intToBytes(xVal);
  byte[] yValBytes = intToBytes(yVal);
  byte[] zValBytes =  intToBytes(zVal);
  byte[] wristRotValBytes =  intToBytes(wristVal);
  byte[] wristAngleValBytes =  intToBytes(wristAngleVal);
  byte[] gripperValBytes =  intToBytes(gripperVal);
  byte[] deltaValBytes =  intToBytes(deltaVal);
  byte[] extValBytes = {0,0};
  byte buttonByte = 0;

void setup()
{
  //make window
  size(1000, 1000, JAVA2D);
  
   createGUI();   //draw GUI components defined in gui.pde

  //Build Serial Port List
  serialPortString[0] = "Serial Port";   //first item in the list will be "Serial Port" to act as a label
  //iterate through each avaialable serial port  
  for (int i=0; i<numSerialPorts; i++) 
  {
    serialPortString[i+1] = Serial.list()[i];  //add the current serial port to the list, add one to the index to account for the first item/label "Serial Port"
  }
  serialList.setItems(serialPortString, 0);  //add contents of srialPortString[] to the serialList GUI    



  
  //init leapmotion object
  leap = new LeapMotion(this);

  prevMillis = millis();
}//end setup

void draw()
{
  
  background(205,128,128);//draw background color
 
  handleConnect();
  handleDisconnect();
  handleAutoConnect();
  
  
  handRead = 0; //start by assuming no hand has been read
  
  //read each hand
  for(Hand hand : leap.getHands())
  {
    
    hand.draw();
    
    hand_stabilized  = hand.getStabilizedPosition();  //get position -stabalized? What kind of filtering does this use?
    hand_raw = hand.getPosition();
    
    handRead = 1;

    //get pitch and roll
    hand_roll        = hand.getRoll();
    hand_pitch       = hand.getPitch();
    /*
   
    hand_yaw         = hand.getYaw();
    */
    
    // FINGERS
    int fingers = 0;//assume 0 fingers
    for(Finger finger : hand.getFingers())
    {
      //add one for each finger we find
      fingerPos[fingers] = finger.getStabilizedPosition();
      fingers++;
    }
       
    shiftAvg();//shift the average back one
    
    
    //update last reading
    //not sure what I was doing here
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
    
    
   
    
    
    
    //sum average
    //again, what am I doing?
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
     //println("FIVE!!");
     //gripperMode = 0;
     wristFlag = 0;
  }
  if(fingersAvg[0] == 1 & fiveRead ==1)
  {
     fiveRead =0; 
    // println("FIVE0000!!");
     //gripperMode = 0;
     wristFlag = 0;
  }
  
  
     //gripperMode = 0;
  if(fingersAvg[2] == 1 )
  {
    
     //println("GRIP!!");
     
    float xd = fingerPos[0].x-fingerPos[1].x;
    float yd = fingerPos[0].y-fingerPos[1].y;
    float zd = fingerPos[0].z-fingerPos[1].z; 
    twoPointDiff = pow((xd*xd+yd*yd+zd*zd),.5);
    
    //println(twoPointDiff);
     fiveRead =0; 
     
  
  wristMode = 0;
      
  }//end hand?
 
    currMillis = millis(); //get the time
  
    //store xyz away
    xValold = xVal;
    yValold = yVal;
    zValold = zVal;
  
    //should we be doing something here incase another hand shows up?
    //also, shouldn't all of this be in the hand:hand for loop?
    //LeapTmpx =int(hand_raw.x);
    //LeapTmpy =int(hand_raw.y);
    //LeapTmpz =int(hand_raw.z);
    LeapTmpx =int(hand_stabilized.x);
    LeapTmpy =int(hand_stabilized.y);
    LeapTmpz =int(hand_stabilized.z);
      
    //leapXText.setText(Integer.toString(int(hand_raw.x)));  
    //leapYText.setText(Integer.toString(int(hand_raw.y)));  
    //leapZText.setText(Integer.toString(int(hand_raw.z)));  
    leapXText.setText(Integer.toString(LeapTmpx));  
    leapYText.setText(Integer.toString(LeapTmpy));  
    leapZText.setText(Integer.toString(LeapTmpz));  
      
      //deabands
      if(abs(LeapTmpz - Leapz) > 15)
      {
       Leapz = LeapTmpz;
        //println("zup");
      }
      
      if(abs(LeapTmpx - Leapx) > 15)
      {
         Leapx = LeapTmpx;
       // println("xup");
      }  
        
      if(abs(LeapTmpy - Leapy) > 3)
      {
        Leapy = LeapTmpy;
        //println("yup");
      }
      
      
      
      
       //generate xyz values from leapmotion values
        xVal = int(map(Leapx, 0, 1000, xParameters[1],xParameters[2]));
        yVal = int(map(Leapz, -20, 80, yParameters[1],yParameters[2]));
        zVal = int(map(Leapy, 832, 200, zParameters[1],zParameters[2]));
        print("y");
        
 
       if (xVal<xParameters[1] || xVal>xParameters[2]){
       xVal = xValold;
       }
       
       if (yVal<yParameters[1] || yVal>yParameters[2]){
       yVal = yValold;
      
       }
       
       if (zVal<zParameters[1] || zVal>zParameters[2]){
         
         
       zVal = zValold;
       }
       
       xVal = xVal +512;
       
       
        Leapx = int(hand_stabilized.x);
        Leapy = int(hand_stabilized.y);
        Leapz = int(hand_stabilized.z); 
       
       
     // if (sqrt((((xVal-xValold)^2)+((yVal-yValold)^2)+((zVal-zValold)^2))) > 10){
        
        //println("large movement");
      //}
      
      //deltaVal = int(sqrt((((xVal-xValold)^2)+((yVal-yValold)^2)+((zVal-zValold)^2)))*25 + 10); 
      
      
      
       // println(xVal);
        
    
     
      
      
   
   float handRad = hand.getSphereRadius();
       if ( handRad < 50 ){
        gripperVal = 0;
      
        }
      else{
        gripperVal = 450;
          }
     
     //gripperMode = 1;
     wristFlag = 0;
    
  }
  
 
 gripperMode=1;
  if ((currMillis - prevMillis > update) & (fiveRead ==1 | gripperMode == 1| wristMode == 1))
  {
    
    if(gripperMode == 0 & wristMode == 0) 
    {
      
      
   

    }

  if(gripperMode == 1)
  {
    
    twoPointDiff = max(twoPointDiff,40);
    twoPointDiff = min(twoPointDiff,110);

   // gripperVal = int(map(((twoPointDiff)), 40, 110, 0, 512)); 
    //println(gripperVal);
  }

if(wristMode == 1 & (abs(hand_roll-startRoll) > 5 ) )
{
  
   // wristVal = int(map((hand_roll-startRoll), -10, 10, 0, 1024));
    wristVal = wristVal +int((hand_roll-startRoll));
    wristVal = max(wristVal,0);
    wristVal = min(wristVal,1023);
   // println(wristVal);
}

    xValBytes = intToBytes(xVal);
    yValBytes = intToBytes(yVal);
    zValBytes =  intToBytes(zVal);
    wristRotValBytes =  intToBytes(wristVal);
    wristAngleValBytes =  intToBytes(wristAngleVal);
    gripperValBytes =  intToBytes(gripperVal);
    deltaValBytes =  intToBytes(deltaVal); 
    
  if (keyPressed) {
    if (key == 'm') {
      
     sendCommanderPacketWithCheck(xVal, yVal, zVal, wristAngleVal, wristVal, gripperVal, deltaVal, 0, 0);

    
    //sPort.clear();
    //sPort.write(0xff);          //header
    //sPort.write(xValBytes[1]); //X Coord High Byte
    //sPort.write(xValBytes[0]); //X Coord Low Byte
    ////println(xValBytes[1]);
    ////println(xValBytes[0]);
    

    //sPort.write(yValBytes[1]); //Y Coord High Byte
    //sPort.write(yValBytes[0]); //Y Coord Low Byte
    
    //sPort.write(zValBytes[1]); //Z Coord High Byte
    //sPort.write(zValBytes[0]); //Z Coord Low Byte
    
    // // println("mid write"+ millis());
    //sPort.write(wristAngleValBytes[1]); //Wrist Angle High Byte
    //sPort.write(wristAngleValBytes[0]); //Wrist Angle Low Byte
    
    //sPort.write(wristRotValBytes[1]); //Wrist Rotate High Byte
    //sPort.write(wristRotValBytes[0]); //Wrist Rotate Low Byte
    
    //sPort.write(gripperValBytes[1]); //Gripper High Byte
    //sPort.write(gripperValBytes[0]); //Gripper Low Byte
    
    
    
    //sPort.write(deltaValBytes[0]); //Delta Low Byte
    
    //sPort.write(buttonByte); //Button byte
    
    //sPort.write(extValBytes[0]); //Extended instruction
    
    
    //sPort.write((char)(255 - (xValBytes[1]+xValBytes[0]+yValBytes[1]+yValBytes[0]+zValBytes[1]+zValBytes[0]+wristAngleValBytes[1]+wristAngleValBytes[0]+wristRotValBytes[1]+wristRotValBytes[0]+gripperValBytes[1]+gripperValBytes[0]+deltaValBytes[0] + buttonByte+extValBytes[0])%256));  //checksum
  
    prevMillis = currMillis;
     }
  }
  
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
      //println(inBuffer[0]);
      if(inBuffer[0] == 70)
       {
        //println("return");
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