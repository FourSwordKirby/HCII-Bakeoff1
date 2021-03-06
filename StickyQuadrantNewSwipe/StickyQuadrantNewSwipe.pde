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
boolean ignoreMouseMove = true;

void setup() {
  fullScreen();
  // noCursor(); //hides the system cursor if you want
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


  // Highlight the selected quadrant
  drawCursor();

  // Draw the squares
  drawSquares();

  // Used to check if the mouse hits the box
  checkBoxCollision();
}

void checkBoxCollision() {
  if (ignoreMouseMove) return;

  int targetIndex = trials.get(trialNum);
  boolean selected = false;

  for(int i = 0; i < 16; i++){
    Rectangle bounds = getButtonLocation(i);

    if(targetIndex == i)
    {
      if ((mouseX > bounds.x - bounds.width && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y - bounds.height && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
      {
        println("HIT! " + trialNum + " " + (millis() - startTime));
        hits++;
        selected = true;
      }
    }
    else
    {
      if ((mouseX > bounds.x - bounds.width && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y - bounds.height && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
      {
        println("MISSED! " + trialNum + " " + (millis() - startTime));
        misses++;
        selected = true;
      }
    }
  }
  if(selected){
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

    robot.mouseMove(getButtonLocation(4).x, getButtonLocation(7).y);
    ignoreMouseMove = true;

    trialNum++; //Increment trial number
  }
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
    vertex(bounds.x - bounds.width/2, bounds.y - bounds.height/2);
    vertex(bounds.x + bounds.width/2, bounds.y - bounds.height/2);
    vertex(bounds.x + bounds.width/2, bounds.y + bounds.height/2);
    vertex(bounds.x - bounds.width/2, bounds.y + bounds.height/2);
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
  return new Rectangle(x, y, 2 * buttonSize, 2 * buttonSize);
}

// Handle user input
  void keyPressed() {
    ignoreMouseMove = false;

    if (key == 'w' || keyCode == UP)
      robot.mouseMove(getButtonLocation(0).x, getButtonLocation(1).y);
    else if (key == 'a' || keyCode == LEFT)
      robot.mouseMove(getButtonLocation(3).x, getButtonLocation(6).y);
    else if (key == 's' || keyCode == DOWN)
      robot.mouseMove(getButtonLocation(15).x, getButtonLocation(13).y);
    else if (key == 'd' || keyCode == RIGHT)
      robot.mouseMove(getButtonLocation(5).x, getButtonLocation(9).y);
  }

  void drawCursor() {
    Point center = new Point(mouseX, mouseY);
    fill(COLOR_QUADRANT_HIGHLIGHT);
    ellipse(center.x, center.y, 20, 20);
  }
