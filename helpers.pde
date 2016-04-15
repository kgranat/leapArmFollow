


/******************************************************
 *  printlnDebug()
 *
 *  function used to easily enable/disable degbugging
 *  enables/disables debugging to the console
 *  prints a line to the output
 *
 *  Parameters:
 *    String message
 *      string to be sent to the debugging method
 *    int type
 *        Type of event
 *         type 0 = normal program message
 *         type 1 = GUI event
 *         type 2 = serial packet 
 *  Globals Used:
 *      boolean debugGuiEvent
 *      boolean debugConsole
 *      boolean debugFile
 *      PrintWriter debugOutput
 *      boolean debugFileCreated
 *  Returns: 
 *    void
 ******************************************************/
void printlnDebug(String message, int type)
{
  if (debugConsole == true)
  {
    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {
      println(message);
    }
  }

  if (debugFile == true)
  {

    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {

      if (debugFileCreated == false)
      {
        //debugOutput = createWriter("debugArmLink.txt");
        //debugOutput.println("Started at "+ day() +"-"+ month() +"-"+ year() +" "+ hour() +":"+ minute() +"-"+ second() +"-"); 
        //debugFileCreated = true;
      }


      //debugOutput.println(message);
    }
  }
}

//wrapper for printlnDebug(String, int)
//assume normal behavior, message type = 0
void printlnDebug(String message)
{
  printlnDebug(message, 0);
}


/******************************************************
 *  printlnDebug()
 *
 *  function used to easily enable/disable degbugging
 *  enables/disables debugging to the console
 *  prints normally to the output
 *
 *  Parameters:
 *    String message
 *      string to be sent to the debugging method
 *    int type
 *        Type of event
 *         type 0 = normal program message
 *         type 1 = GUI event
 *         type 2 = serial packet 
 *  Globals Used:
 *      boolean debugGuiEvent
 *      boolean debugConsole
 *      boolean debugFile
 *      PrintWriter debugOutput
 *      boolean debugFileCreated
 *  Returns: 
 *    void
 ******************************************************/
void printDebug(String message, int type)
{
  if (debugConsole == true)
  {
    if ((type == 1 & debugGuiEvent == true)  || type == 2)
    {
      print(message);
    }
  }

  if (debugFile == true)
  {

    if ((type == 1 & debugGuiEvent == true) || type == 0 || type == 2)
    {

      //if (debugFileCreated == false)
      //{
      //  debugOutput = createWriter("debugArmLink.txt");

      //  debugOutput.println("Started at "+ day() +"-"+ month() +"-"+ year() +" "+ hour() +":"+ minute() +"-"+ second() ); 

      //  debugFileCreated = true;
      //}


      //debugOutput.print(message);
    }
  }
}

//wrapper for printlnDebug(String, int)
//assume normal behavior, message type = 0
void printDebug(String message)
{
  printDebug(message, 0);

}


void handleConnect()
{
   if (connectFlag ==1)
  {
    //check to make sure serialPortSelected is not -1, -1 means no serial port was selected. Valid port indexes are 0+
    if (selectedSerialPort > -1)
    {    
      //try to connect to the port at 38400bps, otherwise show an error message
      try
      {
        sPorts[selectedSerialPort] =  new Serial(this, Serial.list()[selectedSerialPort], 38400);
      }
      catch(Exception e)
      {
        printlnDebug("Error Opening Serial Port"+serialList.getSelectedText());
        sPorts[selectedSerialPort] = null;
       genericMessageDialog("Arm Error", "Unable to open selected serial port" + serialList.getSelectedText(), G4P.WARNING);

      }
    }
      if(selectedSerialPort != -1)
      {
        //check to see if the serial port connection has been made
        if (sPorts[selectedSerialPort] != null)
        {
    
          //try to communicate with arm
          if (checkArmStartup() == true)
          {       
            //disable connect button and serial list
            connectButton.setEnabled(false);
            connectButton.setAlpha(128);
            serialList.setEnabled(false);
            serialList.setAlpha(128);
            autoConnectButton.setEnabled(false);
            autoConnectButton.setAlpha(128);
            //enable disconnect button
            disconnectButton.setEnabled(true);
            disconnectButton.setAlpha(255);
    
           
            
            controlPanel.setVisible(true);
            controlPanel.setEnabled(true);
          
            
            delayMs(100);//short delay 
            setCartesian();
            statusLabel.setText("Connected");
          }
    
          //if arm is not found return an error
          else  
          {
            sPorts[selectedSerialPort].stop();
            //      sPorts.get(selectedSerialPort) = null;
            sPorts[selectedSerialPort] = null;
            printlnDebug("No Arm Found on port "+serialList.getSelectedText()) ;
    
            //displayError("No Arm found on serial port" + serialList.getSelectedText() +". Make sure power is on and the arm is connected to the computer.", "http://learn.trossenrobotics.com/arbotix/8-advanced-used-of-the-tr-dynamixel-servo-tool");
             genericMessageDialog("Arm Error", "No Arm found on serial port" + serialList.getSelectedText() +". <br /> Make sure power is on and the arm is connected to the computer.", G4P.WARNING);
            
            statusLabel.setText("Not Connected");
          }
      }
    }

    connectFlag = 0;
  }
}

void handleDisconnect()
{

  if (disconnectFlag == 1)
  {
    
    autoUpdateCheckbox.setSelected(false);
    putArmToSleep();
    //TODO: call response & check

    ///stop/disconnect the serial port and set sPort to null for future checks
    sPorts[armPortIndex].stop();   
    sPorts[armPortIndex] = null;

    //enable connect button and serial port 
    connectButton.setEnabled(true);
    connectButton.setAlpha(255);
    serialList.setEnabled(true);
    serialList.setAlpha(255); 
    autoConnectButton.setEnabled(true);
    autoConnectButton.setAlpha(255);

    //disable disconnect button
    disconnectButton.setEnabled(false);
    disconnectButton.setAlpha(128);
    //disable & set invisible control and mode panel
    controlPanel.setVisible(false);
    controlPanel.setEnabled(false); 
   
    
    wristPanel.setVisible(false);
    wristPanel.setEnabled(false);

   

    //set arm/mode/orientation to default
    currentMode = 0;
    currentArm = 0;
    currentOrientation = 0;

   

    disconnectFlag = 0;
    statusLabel.setText("Not Connected");
  }




}

void handleAutoConnect()
{
if (autoConnectFlag == 1)
  {


    //disable connect button and serial list
    connectButton.setEnabled(false);
    connectButton.setAlpha(128);
    serialList.setEnabled(false);
    serialList.setAlpha(128);
    autoConnectButton.setEnabled(false);
    autoConnectButton.setAlpha(128);
    //enable disconnect button
    disconnectButton.setEnabled(true);
    disconnectButton.setAlpha(255);

    //for (int i=0;i<Serial.list().length;i++) //scan from bottom to top
    //scan from the top of the list to the bottom, for most users the ArbotiX will be the most recently added ftdi device
    for (int i=Serial.list ().length-1; i>=0; i--) 
    {
      println("port"+i);
      //try to connect to the port at 38400bps, otherwise show an error message
      try
      {
        sPorts[i] = new Serial(this, Serial.list()[i], 38400);
      }
      catch(Exception e)
      {
        printlnDebug("Error Opening Serial Port "+Serial.list()[i] + " for auto search");
        sPorts[i] = null;
      }
    }//end interating through serial list

    //try to communicate with arm
    if (checkArmStartup() == true)
    {
      printlnDebug("Arm Found from auto search on port "+Serial.list()[armPortIndex]) ;

      //enable & set visible control and mode panel, enable disconnect button
     
      
      controlPanel.setVisible(true);
      controlPanel.setEnabled(true);
    
 
      disconnectButton.setEnabled(true);
      delayMs(200);//shot delay 
      setCartesian();

      statusLabel.setText("Connected");

      //break;
    }

    //if arm is not found return an error
    else  
    {
      //enable connect button and serial port 
      connectButton.setEnabled(true);
      connectButton.setAlpha(255);
      serialList.setEnabled(true);
      serialList.setAlpha(255); 
      autoConnectButton.setEnabled(true);
      autoConnectButton.setAlpha(255);

      //disable disconnect button
      disconnectButton.setEnabled(false);
      disconnectButton.setAlpha(128);
      //disable & set invisible control and mode panel

      //displayError("No Arm found using auto seach. Please check power and connections", "");
      
      genericMessageDialog("Arm Not Found", "No Arm found using auto seach. <br />Please check power and connections.", G4P.WARNING);
        
      
      statusLabel.setText("Not Connected");
    }
    //stop all serial ports without an arm connected 
    for (int i=0; i<numSerialPorts; i++) 
    {      
      //if the index being scanned is not the index of an port with an arm connected, stop/null the port
      //if the port is already null, then it was never opened
      if (armPortIndex != i & sPorts[i] != null)
      {
        printlnDebug("Stopping port "+Serial.list()[i]) ;
        sPorts[i].stop();
        sPorts[i] = null;
      }
    }


    autoConnectFlag = 0;
  }



}