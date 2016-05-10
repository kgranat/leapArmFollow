/***********************************************************************************
 *  }--\     Leap Arm        /--{
 *      |                    |
 *   __/      \__/           \__
 *  |__|      [__]           |__|
 *
 *  gui.pde
 *  
 *  This file has all of the variables and functions regarding the gui.
 *  See 'ArmControl.pde' for building this application.
 *
 *
 * The following variables are named for Cartesian mode -
 * however the data that will be held/sent will vary based on the current IK mode
 ****************************************************************************
 * Variable name | Cartesian Mode | Cylindrcal Mode | Backhoe Mode          |
 *_______________|________________|_________________|_______________________|
 *   x           |   x            |   base          |   base joint          |
 *   y           |   y            |   y             |   shoulder joint      |
 *   z           |   z            |   z             |   elbow joint         |
 *   wristAngle  |  wristAngle    |  wristAngle     |   wrist angle joint   |
 *   wristRotate |  wristeRotate  |  wristeRotate   |   wrist rotate jount  |
 *   gripper     |  gripper       |  gripper        |   gripper joint       |
 *   delta       |  delta         |  delta          |   n/a                 |
********************************************************************************/



//settings panel
GPanel settingsPanel;//various settings for the program
//setup panel
GPanel setupPanel; //panel to hold setup data
GDropList serialList; //drop down to hold list of serial ports
GButton connectButton,disconnectButton,autoConnectButton; //buttons for connecting/disconnecting and auto seeach
GPanel wristPanel; //panel to hold current wrist buttons
GPanel controlPanel; 
GCheckbox autoUpdateCheckbox;   //checkbox to enable auto-update mode
GButton updateButton;           //button to manually update
GButton orient90Button, orientStraightButton; //buttons to chage IK mode

GLabel statusLabel;

GButton emergencyStopButton;
GLabel startButton;

GLabel leapXLabel, leapYLabel, leapZLabel;

GLabel armXLabel, armYLabel, armZLabel;

GTextField leapXText, leapYText, leapZText;
GTextField armXText, armYText, armZText;

// **********************Setup GUI functions

public void setupPanel_click(GPanel source, GEvent event) { 
  printlnDebug("setupPanel - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} 

//Called when a new serial port is selected
public void serialList_click(GDropList source, GEvent event) 
{
  printlnDebug("serialList - GDropList event occured: item #" + serialList.getSelectedIndex() + " " + System.currentTimeMillis()%10000000, 1 );
  
  
  selectedSerialPort = serialList.getSelectedIndex()-1; //set the current selectSerialPort corresponding to the serial port selected in the menu. Subtract 1 to offset for the fact that the first item in the list is a placeholder text/title 'Select Serial Port'
  printlnDebug("Serial port at position " +selectedSerialPort+ " chosen");
} 

//called when the connect button is pressed
public void connectButton_click(GButton source, GEvent event) 
{
  printlnDebug("connectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1);
 


  statusLabel.setText("Connecting...");
  connectFlag = 1;
} 

//disconnect from current serial port and set GUI element states appropriatley
public void disconnectButton_click(GButton source, GEvent event) 
{
  printlnDebug("disconnectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1);
  
  
    statusLabel.setText("Disconnecting...");
  disconnectFlag = 1;
} 



//scan each serial port and querythe port for an active arm. Iterate through each port until a 
//port is found or the list is exhausted
public void autoConnectButton_click(GButton source, GEvent event) 
{
  printlnDebug("autoConnectButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );


    statusLabel.setText("Scanning...");
  autoConnectFlag = 1;
}



public void wristPanel_click(GPanel source, GEvent event) 
{ 
  printlnDebug("wristPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} 

//change mode data when button to straigten gripper angle is pressed
public void orientStraightButton_click(GButton source, GEvent event) 
{ 
  printlnDebug("armstraight - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
  
setOrientStraight();

} 
public void setOrientStraight()
{  
  
  
  //DEPRECATED armStraightButton.setAlpha(255);
  //DEPRECATED arm90Button.setAlpha(128);
  
  
  orient90Button.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  orientStraightButton.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  
  currentOrientation = 1;
  setPositionParameters();
  changeArmMode();

}

//change mode data when button to move  gripper angle to 90 degrees is pressed
public void orient90Button_click(GButton source, GEvent event) 
{
  printlnDebug("arm90 - GCheckbox event occured " + System.currentTimeMillis()%10000000, 1 );
      setOrient90();

} 


public void setOrient90()
{
  
  //statusLabel.setText("Changing Mode...");
  

  
  //DEPRECATED armStraightButton.setAlpha(128);
  //DEPRECATED arm90Button.setAlpha(255);
  
  
  orient90Button.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  orientStraightButton.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  
  currentOrientation = 2;
  setPositionParameters();
  changeArmMode();
  updateFlag = true;//set update flag to signal sending an update on the next cycle

}







//process when manual update button is pressed
public void updateButton_click(GButton source, GEvent event) 
{
  printlnDebug("updateButton - GButton event occured " + System.currentTimeMillis()%10000000, 1 );
  
  updateFlag = true;//set update flag to signal sending an update on the next cycle
  updateOffsetCoordinates();//update the coordinates to offset based on the current mode

  printlnDebug("X:"+xCurrentOffset+" Y:"+yCurrentOffset+" Z:"+zCurrentOffset+" Wrist Angle:"+wristAngleCurrentOffset+" Wrist Rotate:"+wristRotateCurrentOffset+" Gripper:"+gripperCurrentOffset+" Delta:"+deltaCurrentOffset);
}



//**********************Control GUI functions
public void controlPanel_click(GPanel source, GEvent event) { //_CODE_:controlPanel:613752:
  printlnDebug("controlPanel - GPanel event occured " + System.currentTimeMillis()%10000000, 1 );
} //_CODE_:controlPanel:613752:






  




//public void emergencyStopButton_click(GButton source, GEvent event) 
//{
//  sendCommanderPacket(0, 0, 0, 0, 0, 0, 0, 0, 17);    //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '17' is the extended byte that will stop the arm
//  updateFlag = false;
//  autoUpdateCheckbox.setSelected(false);
//  emergencyStopMessageDialog();
  
//}

  
//public void startButton_click(GButton source, GEvent event) 
//{
//  sendCommanderPacketWithCheck(xVal, yVal, zVal, wristAngleVal, wristVal, gripperVal, deltaVal, 0, 0);   //send a commander style packet - the first 8 bytes are inconsequntial, only the last byte matters. '17' is the extended byte that will stop the arm
//  updateFlag = false;
//  autoUpdateCheckbox.setSelected(false);
//  //emergencyStopMessageDialog();
  
//}


// Create all the GUI controls. 
public void createGUI() {
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(8);
  G4P.setCursor(ARROW);


  if (frame != null)
    surface.setTitle("Leap Arm " + programVersion);


//Setup

  setupPanel = new GPanel(this, 5, 480, 465, 50, "Setup Panel");
  setupPanel.setText("Setup Panel");
  setupPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  setupPanel.setOpaque(true);
  setupPanel.addEventHandler(this, "setupPanel_click");
  //setupPanel.setDraggable(false);
  setupPanel.setCollapsible(false);
  
  
  


  serialList = new GDropList(this, 5, 24, 200, 200, 10);
  //serialList.setItems(loadStrings("list_700876"), 0);
  serialList.addEventHandler(this, "serialList_click");
  serialList.setFont(new Font("Dialog", Font.PLAIN, 9));  
  serialList.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  connectButton = new GButton(this, 215, 24, 75, 20);
  connectButton.setText("Connect");
  connectButton.addEventHandler(this, "connectButton_click");
  connectButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  disconnectButton = new GButton(this, 300, 24, 75, 20);
  disconnectButton.setText("Disconnect");
  disconnectButton.addEventHandler(this, "disconnectButton_click");
  disconnectButton.setLocalColorScheme(GCScheme.CYAN_SCHEME);

  disconnectButton.setEnabled(false);
  disconnectButton.setAlpha(128);

  autoConnectButton = new GButton(this, 385, 24, 75, 20);
  autoConnectButton.setText("Auto Search");
  autoConnectButton.addEventHandler(this, "autoConnectButton_click");
  autoConnectButton.setLocalColorScheme(GCScheme.PURPLE_SCHEME);


  setupPanel.addControl(serialList);
  setupPanel.addControl(connectButton);
  setupPanel.addControl(disconnectButton);
  setupPanel.addControl(autoConnectButton);



//wrist angle
  wristPanel = new GPanel(this, 310, 690, 160, 38, "Wrist Panel");
  wristPanel.setText("Wrist Panel");
  wristPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  wristPanel.setOpaque(true);
  wristPanel.addEventHandler(this, "wristPanel_click");
  //modePanel.setDraggable(false);
  wristPanel.setCollapsible(false);
  


//  wristPanel.addControl(orientStraightButton);
//  wristPanel.addControl(orient90Button);
  wristPanel.setVisible(false);
  wristPanel.setEnabled(false);



//control
  controlPanel = new GPanel(this, 5, 535, 350, 475, "Control Panel");
  controlPanel.setText("Control Panel");
  controlPanel.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  controlPanel.setOpaque(true);
  controlPanel.addEventHandler(this, "controlPanel_click");
  //controlPanel.setDraggable(false);
  controlPanel.setCollapsible(false);
  
  controlPanel.setVisible(false);
  controlPanel.setEnabled(false);
  
  

  



  
  
  


//400 470
  //updateButton = new GButton(this, 5, 420, 100, 50);
  //updateButton.setText("Update");
  //updateButton.addEventHandler(this, "updateButton_click");
  //updateButton.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  //updateButton.setFont(new Font("Dialog", Font.PLAIN, 20));  

 

  autoUpdateCheckbox = new GCheckbox(this, 105, 3000, 100, 20);
  autoUpdateCheckbox.setOpaque(false);
  autoUpdateCheckbox.addEventHandler(this, "autoUpdateCheckbox_change");
  autoUpdateCheckbox.setText("Auto Update");
 
 
  
  
  //emergencyStopButton = new GButton(this, 5, 440, 150, 30);
  //emergencyStopButton.setText("EMERGENCY STOP");
  //emergencyStopButton.addEventHandler(this, "emergencyStopButton_click"); 
  //emergencyStopButton.setLocalColorScheme(GCScheme.RED_SCHEME);
 
  startButton = new GLabel(this, 90, 200, 200, 100);
  startButton.setText("Press Space Bar to Stop");
  //startButton.addEventHandler(this, "emergencyStopButton_click"); 
  startButton.setLocalColorScheme(GCScheme.RED_SCHEME);
  startButton.setFont(new Font("Dialog", Font.PLAIN, 20));

  
  leapXLabel = new GLabel(this, 5, 25, 70, 35);
  leapXLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  leapXLabel.setText("Leap X:");
  leapXLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  leapXText = new GTextField(this, 90, 30, 60, 20, G4P.SCROLLBARS_NONE);
  leapXText.setText("0");
  leapXText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  leapXText.setOpaque(true);
  
  leapYLabel = new GLabel(this, 5, 60, 70, 35);
  leapYLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  leapYLabel.setText("Leap Y:");
  leapYLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  leapYText = new GTextField(this, 90, 60, 60, 20, G4P.SCROLLBARS_NONE);
  leapYText.setText("0");
  leapYText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  leapYText.setOpaque(true);
  
  leapZLabel = new GLabel(this, 5, 85, 70, 35);
  leapZLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  leapZLabel.setText("Leap Z:");
  leapZLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  leapZText = new GTextField(this, 90,90, 60, 20, G4P.SCROLLBARS_NONE);
  leapZText.setText("0");
  leapZText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  leapZText.setOpaque(true);
  
  
  armXLabel = new GLabel(this, 5, 115, 100, 35);
  armXLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  armXLabel.setText("Pincher X:");
  armXLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  armXText = new GTextField(this, 100, 125, 60, 20, G4P.SCROLLBARS_NONE);
  armXText.setText("0");
  armXText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  armXText.setOpaque(true);
  
  armYLabel = new GLabel(this, 5, 140, 100, 35);
  armYLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  armYLabel.setText("Pincher Y:");
  armYLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  armYText = new GTextField(this, 100, 150, 60, 20, G4P.SCROLLBARS_NONE);
  armYText.setText("0");
  armYText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  armYText.setOpaque(true);
  
  armZLabel = new GLabel(this, 5, 170, 100, 35);
  armZLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  armZLabel.setText("Pincher Z:");
  armZLabel.setFont(new Font("Dialog", Font.PLAIN, 18)); 
  
  armZText = new GTextField(this, 100,175, 60, 20, G4P.SCROLLBARS_NONE);
  armZText.setText("0");
  armZText.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  armZText.setOpaque(true);
  
  
  
  
//  leapXText.addEventHandler(this, "xTextField_change");
  
  
  //controlPanel.addControl(xTextField);
  
   //controlPanel.addControl(emergencyStopButton);
   controlPanel.addControl(startButton);
   controlPanel.addControl(autoUpdateCheckbox);
   controlPanel.addControl(leapXLabel);
   controlPanel.addControl(leapXText);
   controlPanel.addControl(leapYLabel);
   controlPanel.addControl(leapYText);
   controlPanel.addControl(leapZLabel);
   controlPanel.addControl(leapZText);
   controlPanel.addControl(armXLabel);
   controlPanel.addControl(armXText);
   controlPanel.addControl(armYLabel);
   controlPanel.addControl(armYText);
   controlPanel.addControl(armZLabel);
   controlPanel.addControl(armZText);
   



//settings
  settingsPanel = new GPanel(this, 10, 280, 230, 230, "Settings Panel");
  settingsPanel.setText("Error Panel");
  settingsPanel.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  settingsPanel.setOpaque(true);
  settingsPanel.setVisible(false);
  settingsPanel.addEventHandler(this, "settingsPanel_Click");
  //settingsPanel.setDraggable(false);
  settingsPanel.setCollapsible(false);
  
  
  


  statusLabel = new GLabel(this, 300, 25, 170, 25);
  statusLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
 // statusLabel.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  statusLabel.setText("Not Connected");
  statusLabel.setFont(new Font("Dialog", Font.PLAIN, 20)); 
//  statusLabel.setOpaque(false);




}


public void genericMessageDialog(String title, String message, int mtype) {
  //// Determine message type
  //int mtype;
  //switch(md_mtype) {
  //default:
  //case 0: 
  //  mtype = G4P.PLAIN; 
  //  break;
  //case 1: 
  //  mtype = G4P.ERROR; 
  //  break;
  //case 2: 
  //  mtype = G4P.INFO; 
  //  break;
  //case 3: 
  //  mtype = G4P.WARNING; 
  //  break;
  //case 4: 
  //  mtype = G4P.QUERY; 
  //  break;
  //}
 // String message = "Your Arms's servos should now be disabled. If your arm has been damaged or cannot be moved, unplug power immediately. Setting a new arm move, position, or disconnecting the program will re-active your arm is power is plugged in.";
  //String title = "Emergency Stop";
  G4P.showMessage(this, message, title, mtype);
}




void setPositionParameters()
{
  
  armParam0X = new int[][]{pincherNormalX,reactorNormalX,widowNormalX,widowNormalX, snapperNormalX};
  armParam0Y = new int[][]{pincherNormalY,reactorNormalY,widowNormalY,widowNormalY, snapperNormalY};
  armParam0Z = new int[][]{pincherNormalZ,reactorNormalZ,widowNormalZ,widowNormalZ, snapperNormalZ};
  armParam0WristAngle = new int[][]{pincherNormalWristAngle,reactorNormalWristAngle,widowNormalWristAngle, widowNormalWristAngle, snapperNormalWristAngle};
  
  armParam90X = new int[][]{pincher90X,reactor90X,widow90X, widow90X, snapper90X};
  armParam90Y = new int[][]{pincher90Y,reactor90Y,widow90Y,widow90Y, snapper90Y};
  armParam90Z = new int[][]{pincher90Z,reactor90Z,widow90Z,widow90Z, snapper90Z};
  armParam90WristAngle = new int[][]{pincher90WristAngle,reactor90WristAngle,widow90WristAngle,widow90WristAngle, snapper90WristAngle};
  
  armParam0WristRotate = new int[][]{pincherWristRotate,reactorWristRotate,widowWristRotate,widowWristRotate, snapperWristRotate};
  armParamGripper = new int[][]{pincherGripper,reactorGripper,widowGripper,widowGripper, snapperGripper};
  
  
             
   
      switch(currentOrientation)
      {
        //straight
        case 1:        
  
        
        arrayCopy(armParam0X[currentArm-1], xParameters);
        arrayCopy(armParam0Y[currentArm-1], yParameters);
        arrayCopy(armParam0Z[currentArm-1], zParameters);
        arrayCopy(armParam0WristAngle[currentArm-1], wristAngleParameters);
        arrayCopy(armParam0WristRotate[currentArm-1], wristRotateParameters);
        arrayCopy(armParamGripper[currentArm-1], gripperParameters);
        break;
  
        //90 degrees
        case 2:
  
        arrayCopy(armParam90X[currentArm-1], xParameters);
        arrayCopy(armParam90Y[currentArm-1], yParameters);
        arrayCopy(armParam90Z[currentArm-1], zParameters);
        arrayCopy(armParam90WristAngle[currentArm-1], wristAngleParameters);
        arrayCopy(armParam0WristRotate[currentArm-1], wristRotateParameters);
        arrayCopy(armParamGripper[currentArm-1], gripperParameters);
        
        break;
      }
  
  


}//end set postiion parameters


// G4P code for message dialogs
public void emergencyStopMessageDialog() {
  String message = "Your Arms's servos should now be disabled. <br />If your arm has been damaged or cannot be moved, unplug power immediately.<br /> Setting a new arm move, position, or disconnecting the program will re-active your arm is power is plugged in.";
  String title = "Emergency Stop";
  //snapper vs everything else
  if(currentArm == 5)
  {
      message= "Your Arms's servos should now be disabled. <br />If your arm has been damaged or cannot be moved, unplug power immediately.<br /> You will need to disconnect the program and reset your arm before continuing";
  
  }
  G4P.showMessage(this, message, title, G4P.WARNING);
  
    
}



public void setCartesian()
{
  
  
  //set wrist angle orientation if not defined
  if (currentOrientation == 0)
  {
    currentOrientation =1;
  }
  

  currentMode = 1;//set mode data
  setPositionParameters();//set parameters in gui and working vars
  changeArmMode();//change arm mode
  updateFlag = true;//set update flag to signal sending an update on the next cycle
}