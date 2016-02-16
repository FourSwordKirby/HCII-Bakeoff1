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
int SWIPE_RESET_FRAMES = 8; // Number of frames to wait before 'ending' a swipe
Point swipeOrigin = null; // null if no swipe
int swipelessFrameCount = 0; // current swipe frame count
boolean ignoreMouseMove = false;
boolean firstSwipe = false;
int[][] TARGETS_BY_QUADRANT = { // Hardcode targets by our diagnol quadrants
      {0, 1, 2, 4},
      {3, 6, 7, 10},
      {5, 8, 9, 12},
      {11, 13, 14, 15},
    };
int quadrant = 4; // 0 = up, 1 = left, 2 = right, 3 = down
int direction = -1;

void setup() {
  fullScreen();
  noCursor(); //hides the system cursor if you want
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
  println("quadrant num: " + quadrant);
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


  // Highlight the selected quadrant
  drawCursor();

  // Draw the squares
  drawSquares();

  // Update swipe data
  updateSwipe();
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
  int[] diamondX = {4, 3, 5, 2, 4, 6, 1, 3, 5, 7, 2, 4, 6, 3, 5, 4};
  int[] diamondY = {1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 7};
  int x = diamondX[i] * (padding + buttonSize);// + margin;
  int y = diamondY[i] * (padding + buttonSize);// + margin;
  return new Rectangle(x, y, buttonSize, buttonSize);
}

// Extra styling
  void drawCursor() {
      Point center;
      fill(COLOR_QUADRANT_HIGHLIGHT);

      switch (quadrant) {
        case 0:
          center = new Point(getButtonLocation(0).x, getButtonLocation(1).y);
          break;
        case 1:
          center = new Point(getButtonLocation(3).x, getButtonLocation(6).y);
          break;
        case 3:
          center = new Point(getButtonLocation(15).x, getButtonLocation(13).y);
          break;
        case 2:
          center = new Point(getButtonLocation(5).x, getButtonLocation(9).y);
          break;
        case 4: 
          center = new Point(getButtonLocation(4).x, getButtonLocation(7).y);
          break;
        default: return;
      }

      ellipse(center.x, center.y, 20, 20);
    }
  
  void highlightQuadrant() {
    fill(COLOR_QUADRANT_HIGHLIGHT);
    Rectangle r1, r2, r3, r4;

    switch (quadrant) {
      case 0: r1 = getButtonLocation(0);
                r2 = getButtonLocation(1);
                r3 = getButtonLocation(2);
                r4 = getButtonLocation(4);
                break;
      case 1: r1 = getButtonLocation(3);
                r2 = getButtonLocation(6);
                r3 = getButtonLocation(7);
                r4 = getButtonLocation(10);
                break;
      case 3: r1 = getButtonLocation(11);
                r2 = getButtonLocation(13);
                r3 = getButtonLocation(14);
                r4 = getButtonLocation(15);
                break;
      case 2: r1 = getButtonLocation(5);
                r2 = getButtonLocation(8);
                r3 = getButtonLocation(9);
                r4 = getButtonLocation(12);
                break;
      default: return;
    }

    beginShape();
    vertex(r4.x, r4.y + r4.height / 2);
    vertex(r2.x - r2.width / 2, r2.y);
    vertex(r1.x, r1.y - r1.height / 2);
    vertex(r3.x + r3.width / 2, r3.y);
    endShape(CLOSE);
  }

  int dir2quad(float angle){
    int dir = 90 * (int)Math.round(angle / 90);
    switch (dir) {
      case -180:
      case 180: return 0;
      case -90: return 1;
      case 90: return 2;
      case 0: return 3;
    }
    return -1;
  }
  
// Handle user input
  void keyPressed() {
    if (key == CODED){
      if (keyCode == SHIFT){
        firstSwipe = false;
        quadrant = 4;
      }
    }
  }


  void updateSwipe() {
    if (swipeOrigin != null && mouseX == pmouseX && mouseY == pmouseY) {
      if (swipelessFrameCount < SWIPE_RESET_FRAMES) {
        swipelessFrameCount++; // Wait a number of frames to reset swipe
      } else {
        float angle = degrees(atan2(mouseX - swipeOrigin.x, mouseY - swipeOrigin.y));
        firstSwipe = !firstSwipe;
        if (firstSwipe){ 
          quadrant = dir2quad(angle);
        }
        else{ //we're on the 2nd swipe
          direction = dir2quad(angle);
          handleSwipe(direction);
          quadrant = 4;
        }
        swipelessFrameCount = 0;
        swipeOrigin = null;

        // Reset mouse so we don't hit edge of screen after multiple swipes
        ignoreMouseMove = true;
        robot.mouseMove(width / 2, height / 2);
      }
    }
  }

  void handleSwipe(int dir) {
    if (direction == -1) return; 
    // if task is over, just return
    if (trialNum >= trials.size()) return;
  
    // check if first click, if so, start timer
    if (trialNum == 0) startTime = millis();
  
    // check if final click
    if (trialNum == trials.size() - 1) {
      finishTime = millis();
      // write to terminal some output:
      println("Hits: " + hits);
      println("Misses: " + misses);
      println("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%");
      println("Total time taken: " + (finishTime-startTime) / 1000f + " sec");
      println("Average time for each button: " + ((finishTime-startTime) / 1000f)/(float)(hits+misses) + " sec");
    }
  
    if (TARGETS_BY_QUADRANT[quadrant][direction] == trials.get(trialNum)){
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++; 
    }
    else {
      System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
      misses++;
    }
    trialNum++; //Increment trial number
  }


  void mouseMoved() {
    if (ignoreMouseMove)
      ignoreMouseMove = false;
    else if (swipeOrigin == null)
      // Fresh swipe, save origin pos
      swipeOrigin = new Point(mouseX, mouseY);
  }