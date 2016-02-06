import java.awt.AWTException;
import java.awt.Point;
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
Robot robot; //initalized in setup 

int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
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
  
  mousePoint  = center;
}

boolean upKeyPressed = false;
boolean downKeyPressed = false;
boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
Point mousePoint;

Point center = new Point(getButtonLocation(0).x, getButtonLocation(6).y);
Point center1 = new Point(getButtonLocation(0).x, getButtonLocation(1).y);
Point center2 = new Point(getButtonLocation(3).x, getButtonLocation(6).y);
Point center3 = new Point(getButtonLocation(15).x, getButtonLocation(13).y);
Point center4 = new Point(getButtonLocation(5).x, getButtonLocation(9).y);

ArrayList<Point> swipeBuffer = new ArrayList<Point>();

void draw()
{
  background(0); //set background to black

  //drawing the highlighted areas
  if(upKeyPressed){
    fill(255, 0, 0, 128);
    Rectangle pos1 = getButtonLocation(0);
    Rectangle pos2 = getButtonLocation(1);
    Rectangle pos3 = getButtonLocation(2);
    Rectangle pos4 = getButtonLocation(4);

    beginShape();
    vertex(pos4.x, pos4.y + pos4.height/2);
    vertex(pos2.x - pos2.width/2, pos2.y);
    vertex(pos1.x, pos1.y - pos1.height/2);
    vertex(pos3.x + pos3.width/2, pos3.y);
    endShape(CLOSE);
  }
  if(leftKeyPressed){
    fill(255, 0, 0, 128);
    Rectangle pos1 = getButtonLocation(3);
    Rectangle pos2 = getButtonLocation(6);
    Rectangle pos3 = getButtonLocation(7);
    Rectangle pos4 = getButtonLocation(10);

    beginShape();
    vertex(pos4.x, pos4.y + pos4.height/2);
    vertex(pos2.x - pos2.width/2, pos2.y);
    vertex(pos1.x, pos1.y - pos1.height/2);
    vertex(pos3.x + pos3.width/2, pos3.y);
    endShape(CLOSE);
  }
  if(downKeyPressed){
    fill(255, 0, 0, 128);
    Rectangle pos1 = getButtonLocation(11);
    Rectangle pos2 = getButtonLocation(13);
    Rectangle pos3 = getButtonLocation(14);
    Rectangle pos4 = getButtonLocation(15);

    beginShape();
    vertex(pos4.x, pos4.y + pos4.height/2);
    vertex(pos2.x - pos2.width/2, pos2.y);
    vertex(pos1.x, pos1.y - pos1.height/2);
    vertex(pos3.x + pos3.width/2, pos3.y);
    endShape(CLOSE);
  }
  if(rightKeyPressed){
    fill(255, 0, 0, 128);
    Rectangle pos1 = getButtonLocation(5);
    Rectangle pos2 = getButtonLocation(8);
    Rectangle pos3 = getButtonLocation(9);
    Rectangle pos4 = getButtonLocation(12);

    beginShape();
    vertex(pos4.x, pos4.y + pos4.height/2);
    vertex(pos2.x - pos2.width/2, pos2.y);
    vertex(pos1.x, pos1.y - pos1.height/2);
    vertex(pos3.x + pos3.width/2, pos3.y);
    endShape(CLOSE);
  }

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
  
  //draw the target point
  fill(255, 0, 0, 200); // set fill color to translucent red
  ellipse(mousePoint.x, mousePoint.y, 20, 20); //draw user cursor as a circle with a diameter of 20

  //draw the squares
  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    fill(0, 255, 255); // if so, fill cyan
  else
    fill(200); // if not, fill gray

  beginShape();
  vertex(bounds.x, bounds.y - bounds.height/2);
  vertex(bounds.x - bounds.width/2, bounds.y);
  vertex(bounds.x, bounds.y + bounds.height/2);
  vertex(bounds.x + bounds.width/2, bounds.y);
  endShape(CLOSE);
}

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
  int[] diamondX = {4, 3, 5, 2, 4, 6, 1, 3, 5, 7, 2, 4, 6, 3, 5, 4};
  int[] diamondY = {1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 7};
   int x = diamondX[i] * (padding + buttonSize);// + margin;
   int y = diamondY[i] * (padding + buttonSize);// + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
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

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x - bounds.width && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y - bounds.height && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
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

void mouseMoved()
{
  processSwipe();
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}


int threshold = 150;
public void processSwipe()
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  //propogate array full of values of mouse position
  if(upKeyPressed || leftKeyPressed || downKeyPressed || rightKeyPressed)
  {
    if(swipeBuffer.size() > 3)
      swipeBuffer.remove(0);
    swipeBuffer.add(new Point(mouseX, mouseY));
  }
  else{
    //maybe make this code later determine what direction you're swiping in and highlight the correct square
    return;
  }
  System.out.println(swipeBuffer.size());
 
  int targetIndex = -1;
  if(swipeBuffer.size() == 3){
    int xMin = swipeBuffer.get(0).x;
    int yMin = swipeBuffer.get(0).y;
    int xMax = swipeBuffer.get(swipeBuffer.size()-1).x;
    int yMax = swipeBuffer.get(swipeBuffer.size()-1).y;

    if(xMax -xMin > threshold){
      if(upKeyPressed){
        targetIndex = 3;
      }
      if(leftKeyPressed){
        targetIndex = 7;        
      }
      if(downKeyPressed){
        targetIndex = 14;
      }
      if(rightKeyPressed){
        targetIndex = 9;        
      }
    }
    if(yMax - yMin > threshold){
      if(upKeyPressed){
        targetIndex = 4;
      }
      if(leftKeyPressed){
        targetIndex = 10;
      }
      if(downKeyPressed){
        targetIndex = 15;
      }
      if(rightKeyPressed){
        targetIndex = 12;
      }
    }
    if(xMin -xMax > threshold){
      if(upKeyPressed){
         targetIndex = 2;
      }
      if(leftKeyPressed){
        targetIndex = 8;
      }
      if(downKeyPressed){
        targetIndex = 13;
      }
      if(rightKeyPressed){
        targetIndex = 8;
      }
    }
    if(yMin -yMax > threshold){
      if(upKeyPressed){
         targetIndex = 1;
      }
      if(leftKeyPressed){
        targetIndex = 5;
      }
      if(downKeyPressed){
        targetIndex = 11;
      }
      if(rightKeyPressed){
        targetIndex = 5;
      }
    }
  }

  if(targetIndex != -1)
  {
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
    
    if(targetIndex == trials.get(trialNum)){
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++; 
    } 
    else
    {
      System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
      misses++;
    }
    trialNum++; //Increment trial number
    swipeBuffer = new ArrayList<Point>();
  }
}

void keyPressed() 
{
  swipeBuffer = new ArrayList<Point>();
  
  if(key == 'w'){
    leftKeyPressed = false;
    downKeyPressed = false;
    rightKeyPressed = false;
    upKeyPressed = true;
    mousePoint = center1;
  }
  if(key == 'a'){
    upKeyPressed = false;
    downKeyPressed = false;
    rightKeyPressed = false;
    leftKeyPressed = true;
    mousePoint = center2;
  }
  if(key == 's'){
    leftKeyPressed = false;
    upKeyPressed = false;
    rightKeyPressed = false;
    downKeyPressed = true;
    mousePoint = center3;
  }
  if(key == 'd'){
    leftKeyPressed = false;
    downKeyPressed = false;
    upKeyPressed = false;
    rightKeyPressed = true;
    mousePoint = center4;
  }
}

void keyReleased()
{
  if(key == 'w' && upKeyPressed){
     upKeyPressed = false;
     mousePoint = center;
  }
  if(key == 'a' && leftKeyPressed){
     leftKeyPressed = false;
     mousePoint = center;
  }
  if(key == 's' && downKeyPressed){
     downKeyPressed = false;
     mousePoint = center;
  }
  if(key == 'd' && rightKeyPressed){
     rightKeyPressed = false;
     mousePoint = center;
  }
}