import java.awt.AWTException;
import java.awt.Point;
import java.awt.Rectangle;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;


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

int COLOR_SQUARE_FG = 0xFFFFFF00;
int COLOR_SQUARE_HINT = 0xFF888800;
int COLOR_NEUTRAL = 0x77FFFFFF;
int COLOR_QUADRANT_HIGHLIGHT = 0x77FF0000;
char quadrant = '\0';

void setup() {
  size(700, 700); // set the size of the window
  noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)

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


  // Highlight the selected quadrant (if arrow key down)
  // if (quadrant != '\0') highlightQuadrant(quadrant);
  if (quadrant != '\0') drawCursor(quadrant);

  // Draw the squares
  drawSquares();
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
  void drawCursor(char quad) {
    Point center;
    fill(COLOR_QUADRANT_HIGHLIGHT);

    switch (quad) {
      case 'w': center = new Point(getButtonLocation(0).x, getButtonLocation(1).y);
                break;
      case 'a': center = new Point(getButtonLocation(3).x, getButtonLocation(6).y);
                break;
      case 's': center = new Point(getButtonLocation(15).x, getButtonLocation(13).y);
                break;
      case 'd': center = new Point(getButtonLocation(5).x, getButtonLocation(9).y);
                break;
      default: return;
    }

    ellipse(center.x, center.y, 20, 20);
  }

  void highlightQuadrant(char quad) {
    fill(COLOR_QUADRANT_HIGHLIGHT);
    Rectangle r1, r2, r3, r4;

    switch (quad) {
      case 'w': r1 = getButtonLocation(0);
                r2 = getButtonLocation(1);
                r3 = getButtonLocation(2);
                r4 = getButtonLocation(4);
                break;
      case 'a': r1 = getButtonLocation(3);
                r2 = getButtonLocation(6);
                r3 = getButtonLocation(7);
                r4 = getButtonLocation(10);
                break;
      case 's': r1 = getButtonLocation(11);
                r2 = getButtonLocation(13);
                r3 = getButtonLocation(14);
                r4 = getButtonLocation(15);
                break;
      case 'd': r1 = getButtonLocation(5);
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


// Handle key presses
  void keyPressed() {
    if ("wasd".indexOf(key) >= 0) {
      quadrant = key;
    } else if (key == CODED) {
      switch (keyCode) {
        case LEFT:   quadrant = 'a'; break;
        case UP:     quadrant = 'w'; break;
        case RIGHT:  quadrant = 'd'; break;
        case DOWN:   quadrant = 's'; break;
      }
    }

    println(quadrant);
  }

  void keyReleased() {
    quadrant = '\0';
  }
