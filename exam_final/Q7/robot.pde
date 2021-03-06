/**
 * Andrew Barba
 * Tablelist (https://www.tablelist.com) Robot
 * Note: The object is my companies logo... not exactly a robot
 *
 * December 13, 2015
 * CS4300
 *
 * HINT: Try clicking along the green progress bar...
 */

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

// Window Constants
int WINDOW_WIDTH = 980;
int WINDOW_HEIGHT = 620;
int FRAME_RATE = 60;

// Background Constants
float GROUND_HEIGHT = 200;
float PROGRESS_HEIGHT = 4;
float PROGRESS_INDICATOR_HEIGHT = 8;

// Audio Constants
String MAIN_AUDIO_TRACK = "what_do_you_mean.mp3";
float TRACK_LENGTH = 203; // in seconds

// Audio
Minim minim;
AudioPlayer player;
AudioInput input;

/******************************************************************************/
/* Setup
/******************************************************************************/

void setup()
{
  // setup background
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  smooth();
  frameRate(FRAME_RATE);

  // setup audio
  setupMusic();

  // start music
  playMusic(MAIN_AUDIO_TRACK);
}

/******************************************************************************/
/* Drawing
/******************************************************************************/

float START_X = (WINDOW_WIDTH / 2.0);
float START_Y = WINDOW_HEIGHT - GROUND_HEIGHT;

float lastX = START_X;
float lastY = START_Y;

void draw() {

  // continuously draw our background
  drawBackground();

  // continuously draw our robot
  lastX = lastX + ((mouseX - lastX) * 0.00025);
  lastY = lastY + ((mouseY - lastY) * 0.00025);
  drawRobot(lastX, lastY);
}

/******************************************************************************/
/* Music
/******************************************************************************/

void setupMusic() {
  minim = new Minim(this);
  input = minim.getLineIn();
}

void playMusic(String track) {
  player = minim.loadFile(track);
  player.play();
}

void playFromTime(float time) {
  player.play((int)(time * 1000));
}

void stopMusic() {
  player.close();
}

void mouseClicked() {
  float threshold = 10;
  float top = (WINDOW_HEIGHT - GROUND_HEIGHT) + threshold;
  float bottom = (WINDOW_HEIGHT - GROUND_HEIGHT) - threshold;

  // check if they clicked the progress bar
  if (mouseY < top && mouseY > bottom) {
    float progress = mouseX / (float)WINDOW_WIDTH;
    float time = TRACK_LENGTH * progress;
    playFromTime(time);
  }
}

/******************************************************************************/
/* Time
/******************************************************************************/

float time() {
  return player.position() / 1000.0;
}

float complete() {
  return time() / TRACK_LENGTH;
}

/******************************************************************************/
/* Colors
/******************************************************************************/

float COLOR_WHITE = 255;
float COLOR_GRAY = 125;
float COLOR_LIGHT_GRAY = 198;

void fillWhite() {
  fill(COLOR_WHITE, COLOR_WHITE, COLOR_WHITE);
}

void fillPrimaryGreenColor() {
  fill(40, 192, 179);
}

void fillGrayColor() {
  fill(COLOR_GRAY, COLOR_GRAY, COLOR_GRAY);
}

void fillLightGrayColor() {
  fill(COLOR_LIGHT_GRAY, COLOR_LIGHT_GRAY, COLOR_LIGHT_GRAY);
}

/******************************************************************************/
/* Background
/******************************************************************************/

void drawBackground() {

  // solid color
  background(38);

  // ground
  fillGrayColor();
  rect(0, WINDOW_HEIGHT - GROUND_HEIGHT, WINDOW_WIDTH, GROUND_HEIGHT);

  // draw progress line
  fillPrimaryGreenColor();
  rect(
    0,
    WINDOW_HEIGHT - GROUND_HEIGHT - PROGRESS_HEIGHT,
    WINDOW_WIDTH * complete(),
    PROGRESS_HEIGHT
  );

  // draw circle on progress line
  fillPrimaryGreenColor();
  ellipse(
    WINDOW_WIDTH * complete(),
    WINDOW_HEIGHT - GROUND_HEIGHT - (PROGRESS_HEIGHT / 2.0),
    PROGRESS_INDICATOR_HEIGHT + abs(4 * sin(time() * 4)),
    PROGRESS_INDICATOR_HEIGHT + abs(4 * sin(time() * 4))
  );
}

/******************************************************************************/
/* Robot
/******************************************************************************/

void drawRobot(float x, float y) {
  float time = time();
  float SCALE = 0.6;

  // start fills
  noStroke();

  if ((time >= 61 && time <= 77) || (time >= 123 && time <= 138) || (time >= 168 && time <= 200)) {
    fill(abs(sin(time)) * random(255), abs(sin(time)) * random(255), abs(sin(time)) * random(255));
  } else {
    fillWhite();
  }

  // offset x
  x = x - (300 * SCALE);
  y = y - (160 * SCALE);

  // top
  rect(x, y, 600 * SCALE, 102 * SCALE);

  // left leg
  pushMatrix();
  translate((100 * SCALE) + x, y + (50 * SCALE));
  rotate(0.5 * sin(time * twerkSpeed(time)));
  rect(0, 0, 102 * SCALE, (240 * SCALE) - (50 * SCALE));
  popMatrix();

  // right leg
  pushMatrix();
  translate((390 * SCALE) + x, y + (50 * SCALE));
  rotate(-0.5 * sin(time * twerkSpeed(time)));
  rect(0, 0, 102 * SCALE, (240 * SCALE) - (50 * SCALE));
  popMatrix();
}

float twerkSpeed(float time) {

  if (time >= 15.0 && time <= 47) {
    return 2.0;
  }

  if (time >= 77.0 && time <= 94) {
    return 3.0;
  }

  if (time >= 168.0 && time <= 200) {
    return 4.0;
  }

  return 1.0;
}
