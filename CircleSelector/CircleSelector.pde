import java.awt.AWTException;
import java.awt.Point;
import java.awt.Rectangle;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import java.awt.Robot;


//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
int numRepeats = 1; //sets the number of times each button repeats in the test
Robot robot; //initalized in setup

int COLOR_SQUARE_FG = 0xFFFFFF00; // Current target color
int COLOR_SQUARE_HINT = 0xFF888800; // Up next target
int COLOR_NEUTRAL = 0x77FFFFFF; // Inactive targets
int COLOR_QUADRANT_HIGHLIGHT = 0x77FF0000; // For 'false cursor' dot in quadrants
int SWIPE_RESET_FRAMES = 1; // Number of frames to wait before 'ending' a swipe
int[][] TARGETS_BY_QUADRANT = { // Hardcode targets by our diagnol quadrants
  {0, 1, 2, 4},
  {3, 6, 7, 10},
  {5, 8, 9, 12},
  {11, 13, 14, 15},
};
int quadrant = 0; // 0 = up, 1 = left, 2 = right, 3 = down
Point swipeOrigin = null; // null if no swipe
int swipelessFrameCount = 0; // current swipe frame count
boolean ignoreMouseMove = false;

int trueX;
int trueY;

void setup() {
  fullScreen();
  //noCursor(); //hides the system cursor if you want
  //size(1000, 1000); // set the size of the window
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot();
  } catch (AWTException e) {
    e.printStackTrace();
  }

  ignoreMouseMove = true;
  robot.mouseMove(width / 2, height / 2);

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  // generate list of targets and randomize the order
  for (int i = 0; i < 16; i++)
    // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  println("trial order: " + trials);
}

void draw() {
  background(0); //set background to black

  // Check to see if test is over
  if (trialNum >= trials.size()) {
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

  // Display trial number
  fill(255); text((trialNum + 1) + " of " + trials.size(), 40, 20);

  // Draw the squares
  drawSquares();

  //Get selected square
  drawSelectedPosition();

  // update hints
  //drawNextMoves();

  // Separate quadrants
  /*
  stroke(COLOR_QUADRANT_HIGHLIGHT);
  strokeWeight(10);
  line(getButtonLocation(6).x, getButtonLocation(0).y, getButtonLocation(9).x, getButtonLocation(15).y);
  line(getButtonLocation(9).x, getButtonLocation(0).y, getButtonLocation(6).x, getButtonLocation(15).y);
  noStroke();
  */
}

void drawSquares() {
  for (int i = 0; i < 16; i++) {
    Rectangle bounds = getButtonLocation(i);

    if (trials.get(trialNum) == i) // see if current button is the target
      fill(COLOR_SQUARE_FG);
    else if (trialNum + 1 < trials.size() && trials.get(trialNum + 1) == i)
      fill(COLOR_SQUARE_HINT);
    else
      fill(COLOR_NEUTRAL);

    beginShape();
    vertex(bounds.x, bounds.y - bounds.height/2);
    vertex(bounds.x - bounds.width/2, bounds.y);
    vertex(bounds.x, bounds.y + bounds.height/2);
    vertex(bounds.x + bounds.width/2, bounds.y);
    endShape(CLOSE);
  }
}

// For a given button ID, what is its location and size
// Probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) {
  float radius = 3;
  int marginX = 600;
  int marginY = 400;

  
  double[] diamond = {0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5, 270, 295.5, 315, 337.5};
  double angle = Math.toRadians(diamond[i]);
  
  int x = (int)(Math.cos(angle) * radius * (padding + buttonSize)) + marginX;
  int y = (int)(Math.sin(angle) * radius * (padding + buttonSize)) + marginY;
  return new Rectangle(x, y, buttonSize, buttonSize);
}

// Extra styling
  void drawSelectedPosition() {
    Point origin = new Point(getButtonLocation(4).x, getButtonLocation(0).y);

    int threshold = 75;

    float angle = degrees(atan2(mouseX - origin.x, mouseY - origin.y));
    float distance = sqrt((mouseX-origin.x) * (mouseX-origin.x) + (mouseY - origin.y) * (mouseY - origin.y));
    
    if(distance > threshold)
    {
      int index = angleToDirection(angle);
    
      trueX = getButtonLocation(index).x;
      trueY = getButtonLocation(index).y;
    }else {
      trueX = origin.x;
      trueY = origin.y;
    }

    fill(COLOR_QUADRANT_HIGHLIGHT);
    ellipse(trueX, trueY, 20, 20);
  }

int angleToDirection(float angle) {
    println(angle);
    float cardinal = 22.5 * Math.round((angle) / 22.5);
    int retIndex = int(cardinal / -22.5);
    
    println(retIndex);
    switch (retIndex) {
      case 8: return 12;
      case -8: return 12;
      case -7: return 13;
      case -6: return 14;
      case -5: return 15;
      default: return retIndex + 4;
  }
}


//Handle user input
  void keyPressed() {
    if ("wads".indexOf(key) >= 0) {
      quadrant = "wads".indexOf(key);
    } else if (key == CODED) {
      switch (keyCode) {
        case UP:     quadrant = 0; break;
        case LEFT:   quadrant = 1; break;
        case RIGHT:  quadrant = 2; break;
        case DOWN:   quadrant = 3; break;
      }
    }
  }

void keyReleased() // test to see if hit was in target!
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

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((trueX == bounds.x) && (trueY == bounds.y)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number
}