import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
int hit = 0;
int xPosCursor = 0;
int yPosCursor = 0;
int xLastPosCursor = 0;
int yLastPosCursor = 0;
int xPosTarget;
int yPosTarget;
int lastCurTime;
int curTime = 0;
Robot robot; //initalized in setup 

int COLOR_SQUARE_FG = 0xFFFFFF00; // Current target color
int COLOR_SQUARE_HINT = 0x44888800; // Up next target
int COLOR_SQUARE_SELECTED = 0xFF00AAFF;
int COLOR_NEUTRAL = 0x77FFFFFF; // Inactive targets
int COLOR_QUADRANT_HIGHLIGHT = 0x77FF0000; // For 'false cursor' dot in quadrants

int numRepeats = 3; //sets the number of times each button repeats in the test
int numParticipant = 1;
int trueX = 0;
int trueY = 0;

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(120);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + (finishTime-startTime) / 1000f + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec", width / 2, height / 2 + 100);      
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  initTruePoint();

  //fill(255, 0, 0, 200); // set fill color to translucent red
  //ellipse(trueX, trueY, 20, 20); //draw user cursor as a circle with a diameter of 20
  
  textFont(createFont("Arial", 12)); //sets the font to Arial size 16
  fill(255); text("Use spacebar to select target.", width / 2, height - 50);
  fill(255); text("Upcoming target's background is highlighted in yellow.", width / 2, height - 30);
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
}

void initTruePoint()
{
  for(int i = 0; i < 16; i++){
    Rectangle bounds = getButtonLocation(i);
    
    if ((mouseX > bounds.x - bounds.width && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y - bounds.height && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
    {
      trueX = bounds.x;
      trueY = bounds.y;
    }
  }
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output:
    println("Hits: " + hits);
    println("Misses: " + misses);
    println("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%");
    println("Total time taken: " + (finishTime-startTime) / 1000f + " sec");
    println("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec");
  }
  curTime = millis() - lastCurTime;
  lastCurTime = millis();
 //check to see if mouse cursor is inside button 
  if (isTargetSelected(trials.get(trialNum))) // test to see if hit was within bounds
  {
    hit = 1; // success; 1 is true
    hits++; 
  } 
  else
  {
    hit = 0; // fail; 0 is false
    misses++;
  }
  // for each turn. must print: a) trial num; b) which participant 
  // c) x position of cursor at beg of trial 
  // d) y pos of cursor at beg of trial e) x pos of center of target 
  // f) y pos of center of target g) width of target h) time taken i) hit or miss
  System.out.println(trialNum + ", " + numParticipant + ", " + xLastPosCursor + ", " + 
  yLastPosCursor + ", " + xPosTarget + ", " + yPosTarget + ", " + buttonSize + ", " 
  + curTime + ", " + hit);
  trialNum++; //Increment trial number
}  


boolean isTargetSelected(int target) 
{
  Rectangle bounds = getButtonLocation(target);
  xPosTarget = bounds.x + (buttonSize/2); //finding xPos of center of target
  yPosTarget = bounds.y + (buttonSize/2); //finding yPos of center of  target
  xLastPosCursor = xPosCursor;
  yLastPosCursor = yPosCursor;
  xPosCursor = mouseX; //finding x pos of the cursor at beg of next trial
  yPosCursor = mouseY; //finding y pos of the cursor at beginning of next trial
  return (trueX == bounds.x) && (trueY == bounds.y);
}

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);
  
  // highlight the background of the next square
  if (trialNum + 1 < trials.size() && trials.get(trialNum + 1) == i) {
    fill(COLOR_SQUARE_HINT);
    rect(bounds.x, bounds.y, bounds.width*2, bounds.height*2);
  }

  if (isTargetSelected(i)) fill(COLOR_SQUARE_SELECTED);
  else if (trials.get(trialNum) == i) fill(COLOR_SQUARE_FG);
  else fill(COLOR_NEUTRAL);

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void keyPressed() 
{
  if (key == ' ') mousePressed();
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
}