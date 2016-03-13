// WHEEL OF JUSTICE GAME
// coded sexily by Grayson Earle of the Illuminator Art Collective
// made for the New York Civil Liberties Union

// osc stuff
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

// notes: there are 16 slices so 2PI / 16 gives the angular area for each piece = .3926990817

// syphon stuff
import codeanticode.syphon.*;
SyphonServer server;

// graphics context for Syphon
PGraphics canvas;

PImage wheel;
PImage arrow;

// rotation
float rot = 0;
float normalRot = 0;  // rotation after modulo
float a = 0;  // acceleration
float d = .0005;  // de-acceleration global value

// states of game play
int STATE = 0;
final int START = 0;      // ready for a spin
final int SPIN  = 1;      // get rotation speed based on wii throw
final int SPINNING = 2;   // spin, dammit!
final int DECISION = 3;   // land on a decision, pop up text

PFont font100;

// game vars
float spinThreshold = .5;  // how hard they must flick wiimote

void setup() {
  size(960, 540, OPENGL);

  canvas = createGraphics(1920, 1080, OPENGL);

  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "WOJ");

  // load in wheel image and arrow indicator image
  wheel = loadImage("wheel.png");
  arrow = loadImage("arrow.png");

  // load in fonts
  font100 = loadFont("mont100.vlw");

  // starting properties for graphics context
  canvas.beginDraw();
  canvas.smooth();
  canvas.background(0);
  canvas.imageMode(CENTER);
  canvas.textFont(font100, 100);
  canvas.endDraw();

  /* start oscP5, listening for incoming messages at port  */
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw() {

  switch(STATE) {
  case START:
    canvas.beginDraw();
    canvas.background(0);
    canvas.translate(canvas.width/2, canvas.height/2);
    // Display starting text
    canvas.fill(255);
    canvas.textSize(180);
    canvas.textAlign(CENTER);
    canvas.text("Press A to begin", 0, 0);
    canvas.endDraw();
    break;
  case SPIN:
    canvas.beginDraw();
    canvas.background(0);

    // draw the text
    canvas.fill(255);
    canvas.textSize(90);
    canvas.textAlign(CENTER);
    canvas.text("Spin the Wheel", canvas.width/3*2.2, canvas.height/2-60);
    canvas.text("of Justice", canvas.width/3*2.2, canvas.height/2+60);
    canvas.text("using the wiimote!", canvas.width/3*2.2, canvas.height/2+180);

    // draw the wheel
    canvas.translate(canvas.width/4, canvas.height/2+20);
    canvas.rotate(rot);
    canvas.image(wheel, 0, 0);

    canvas.endDraw();
    break;
  case SPINNING:

    // rotate
    rot += a;

    canvas.beginDraw();
    canvas.background(0);
    canvas.translate(canvas.width/4, canvas.height/2+20);

    // draw the wheel
    canvas.pushMatrix();
    canvas.rotate(rot);
    canvas.image(wheel, 0, 0);
    canvas.popMatrix();

    // draw the indicator
    canvas.image(arrow, 0, -475);

    canvas.endDraw();

    // slow down rotation
    if (a > 0) {
      // still going...
      a -= d;
    } 

    // if acceleration has slowed enough, advance round
    if (a < .008) {
      a = 0;
      // advance state
      STATE++;
    }
    break;

  case DECISION:

    normalRot = rot % TWO_PI;

    // set up canvas for drawing text
    canvas.beginDraw();
    canvas.textAlign(LEFT);

    // load in dummy text image
    PImage textImg = loadImage("jail.png");

    float xPos = canvas.width/2;
    float yPos = canvas.height/2 - 400;

    // check position for appropriate text popup
    if ( normalRot < .3926990817 && normalRot > 0) {
      // EVICTION
      textImg = loadImage("eviction.png");
      //canvas.text("YOU'VE BEEN EVICTED", xPos, yPos); 
      //println("eviction");
    }
    if ( normalRot < .3926990817 * 2 && normalRot > .3926990817) {
      // IGNORED
      textImg = loadImage("ignored.png");
      //canvas.text("YOU'VE BEEN IGNORED", xPos, yPos); 
      //println("ignored");
    }
    if ( normalRot < .3926990817 * 3 && normalRot > .3926990817 * 2) {
      // PARENT TRAP
      textImg = loadImage("parenttrap.png");
      //println("parent trap");
    }
    if ( normalRot < .3926990817 * 4 && normalRot > .3926990817 * 3) {
      // KIDS TAKEN
      textImg = loadImage("kidstaken.png");
      //println("kids taken");
    }
    if ( normalRot < .3926990817 * 5 && normalRot > .3926990817 * 4) {
      // GO TO JAIL
      textImg = loadImage("jail.png");
      //canvas.text("YOU GO TO JAIL", xPos, yPos); 
      //println("go to jail");
    }
    if ( normalRot < .3926990817 * 6 && normalRot > .3926990817 * 5) {
      // LOCKED UP
      textImg = loadImage("lockedup.png");
      //canvas.text("YOU'VE BEEN LOCKED UP", xPos, yPos); 
      //println("locked up");
    }
    if ( normalRot < .3926990817 * 7 && normalRot > .3926990817 * 6) {
      // $$$
      textImg = loadImage("money.png");
      //println("$$$");
    }
    if ( normalRot < .3926990817 * 8 && normalRot > .3926990817 * 7) {
      // HEARTBROKEN
      textImg = loadImage("heartbroken.png");
      //println("heartbroken");
    }
    if ( normalRot < .3926990817 * 9 && normalRot > .3926990817 * 8) {
      // LOSE A TURN
      textImg = loadImage("loseturn.png");
      //canvas.text("YOU LOSE A TURN", xPos, yPos); 
      //println("lose a turn");
    }
    if ( normalRot < .3926990817 * 10 && normalRot > .3926990817 * 9) {
      // SPIN AGAIN
      textImg = loadImage("spin.png");
      //canvas.text("SPIN AGAIN", xPos, yPos); 
      //println("spin again");
    }
    if ( normalRot < .3926990817 * 11 && normalRot > .3926990817 * 10) {
      // RACISM
      textImg = loadImage("racism.png");
      //println("racism");
    }
    if ( normalRot < .3926990817 * 12 && normalRot > .3926990817 * 11) {
      // SILENCED
      textImg = loadImage("silenced.png");
      ///println("silenced");
    }
    if ( normalRot < .3926990817 * 13 && normalRot > .3926990817 * 12) {
      // HOMELESS
      textImg = loadImage("homeless.png");
      //println("homeless");
    }
    if ( normalRot < .3926990817 * 14 && normalRot > .3926990817 * 13) {
      // DEATH
      textImg = loadImage("death.png");
      //println("death");
    }
    if ( normalRot < .3926990817 * 15 && normalRot > .3926990817 * 14) {
      // $$$
      textImg = loadImage("money.png");
      //println("$$$");
    }
    if ( normalRot < .3926990817 * 16 && normalRot > .3926990817 * 15) {
      // RUINED
      textImg = loadImage("ruined.png");
      //println("ruined");
    }
    if ( normalRot < .3926990817 * 17 && normalRot > .3926990817 * 16) {
      // EVICTION
      textImg = loadImage("eviction.png");
      //println("eviction");
    }
    if ( normalRot < .3926990817 * 18 && normalRot > .3926990817 * 17) {
      // IGNORED
      textImg = loadImage("ignored.png");
      //println("ignored");
    }
    if ( normalRot < .3926990817 * 19 && normalRot > .3926990817 * 18) {
      // PARENT TRAP
      textImg = loadImage("parenttrap.png");
      //println("parent trap");
    }
    if ( normalRot < .3926990817 * 20 && normalRot > .3926990817 * 19) {
      // KIDS TAKEN
      textImg = loadImage("kidstaken.png");
      //println("kids taken");
    }

    // display the text image
    canvas.image(textImg, canvas.width - canvas.width/4, canvas.height/2);

    canvas.endDraw();
    break;
  }

  // show image (if you wanna)
  image(canvas, 0, 0, canvas.width/2, canvas.height/2);

  // out to syphon
  server.sendImage(canvas);
}

void keyPressed() {
  // spin it
  a = .3;  // set acceleration based on wii throw, .3 is maybe the highest it should go
  if (STATE < 3) {
    // advance state
    STATE++;
  }
}


void oscEvent(OscMessage theOscMessage) {
  // is this an acceleration?
  if (theOscMessage.checkAddrPattern("/wii/1/accel/pry/3")==true) {
    if (theOscMessage.get(0).floatValue() > spinThreshold) {
      if (STATE == 1) {
        // advance state
        STATE++;

        // set acceleration to wii throw strength
        a = theOscMessage.get(0).floatValue() / 2;
      }
    }
  }
  // is it the A button pressed?
  if (theOscMessage.checkAddrPattern("/wii/1/button/A")==true) {
    if (STATE == 0) {
      // advance state
      STATE++;
    } else if (STATE == 3) {
      // decision of wheel is shown... reset to spin
      STATE = 1;
    }
  }

  float secondValue = theOscMessage.get(0).floatValue();
  //println(theOscMessage.get(0).floatValue());
  //println(theOscMessage.get(1).intValue());

  //if(secondValue > .5)
  //println(secondValue);
}

