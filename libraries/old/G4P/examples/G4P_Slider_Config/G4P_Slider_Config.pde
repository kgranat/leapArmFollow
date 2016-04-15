/**
 * This program demonstrates the various configuration options 
 * available for the slider control (GSlider).
 * 
 * The only thing not set is the range limits. By default the 
 * slider returns values in the range 0.0 to 1.0 inclusive. 
 * Use setLimits() to set your own range.
 * 
 * @author Peter Lager
 *
 */
 
import g4p_controls.*;

GSlider sdr;
int bgcol = 128;

public void setup() {
  size(500, 360);
  G4P.setCursor(CROSS);
  sdr = new GSlider(this, 55, 80, 200, 100, 15);
  makeSliderConfigControls();
}

public void draw() {
  background(bgcol);
  fill(227, 230, 255);
  noStroke();
  rect(width - 190, 0, 200, height);
  rect(0, height - 84, width - 190, 84);
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == sdr)  // The slider being configured?
    println(sdr.getValueS() + "    " + event);    
  if (slider == sdrEasing)
    sdr.setEasing(slider.getValueF());    
  else if (slider == sdrNbrTicks)
    sdr.setNbrTicks(slider.getValueI());    
  else if (slider == sdrBack)
    bgcol = slider.getValueI();
}

public void handleKnobEvents(GValueControl knob, GEvent event) { 
  if (knbAngle == knob)
    this.sdr.setRotation(knbAngle.getValueF(), GControlMode.CENTER);
}

public void handleButtonEvents(GButton button, GEvent event) { 
  if (button.tagNo >= 1000)
    sdr.setLocalColorScheme(button.tagNo - 1000);
  else if (btnMakeCode == button)
    placeCodeOnClipboard();
}


public void handleToggleControlEvents(GToggleControl option, GEvent event) {
  if (option == optLeft)
    sdr.setTextOrientation(G4P.ORIENT_LEFT);
  else if (option == optRight)
    sdr.setTextOrientation(G4P.ORIENT_RIGHT);
  else if (option == optTrack)
    sdr.setTextOrientation(G4P.ORIENT_TRACK);
  else if (option == cbxOpaque)
    sdr.setOpaque(option.isSelected());
  else if (option == cbxValue)
    sdr.setShowValue(option.isSelected());
  else if (option == cbxShowTicks)
    sdr.setShowTicks(option.isSelected());
  else if (option == cbxLimits)
    sdr.setShowLimits(option.isSelected());
  else if (option == cbxSticky)
    sdr.setStickToTicks(option.isSelected());
}


private void placeCodeOnClipboard() {
  StringBuilder s = new StringBuilder();
  s.append("// Generated by the GKnob example program\n\n");
  s.append("import g4p_controls.*;\n\n");
  s.append("GSlider sdr; \n\n");
  s.append("void setup() { \n");
  s.append("  size(300, 300); \n");
  s.append("  sdr = new GSlider(this, 55, 80, 200, 100, 15); \n");
  s.append("  // Some of the following statements are not actually\n");
  s.append("  // required because they are setting the default value. \n");
  s.append("  sdr.setLocalColorScheme(" + sdr.getLocalColorScheme() + "); \n");
  s.append("  sdr.setOpaque(" + sdr.isOpaque() + "); \n");
  s.append("  sdr.setValue(" + sdr.getValueF() + "); \n");
  s.append("  sdr.setNbrTicks(" + sdr.getNbrTicks() + "); \n");
  s.append("  sdr.setShowLimits(" + sdr.isShowLimits() + "); \n");
  s.append("  sdr.setShowValue(" + sdr.isShowValue() + "); \n");
  s.append("  sdr.setShowTicks(" + sdr.isShowTicks() + "); \n");
  s.append("  sdr.setStickToTicks(" + sdr.isStickToTicks() + "); \n");
  s.append("  sdr.setEasing(" + sdr.getEasing() + "); \n");
  s.append("  sdr.setRotation(" + knbAngle.getValueF() + ", GControlMode.CENTER); \n");
  s.append("}   \n\n");
  s.append("void draw(){ \n");
  s.append("  background(" + bgcol + "); \n");
  s.append("} \n");
  if (GClip.copy(s.toString()))
    println("Paste code into empty Processing sketch");
  else
    System.err.println("UNABLE TO ACCESS CLIPBOARD");
}
