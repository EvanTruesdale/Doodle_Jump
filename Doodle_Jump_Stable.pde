import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import java.io.OutputStreamWriter;
import java.io.InputStreamReader;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileInputStream;

import processing.sound.*;

Context context;
SensorManager manager;
Sensor accelerometer;
Sensor magnetometer;
Sensor gameRotation;
OrientationListener listener;

Player player;
Platform_Generator generator;

// PLAYER IMAGES (pixilart.com)
PImage player_up;
PImage player_down;
PImage player_forward;
PImage player_up_left;
PImage player_down_left;
PImage player_left;
PImage player_up_right;
PImage player_down_right;
PImage player_right;

// PLATFORM IMAGES
PImage platform_normal;
PImage platform_long;
PImage platform_spring;
PImage platform_disappearing;

// BACKGROUND IMAGES
PImage background;

// SOUND EFFECTS
SoundFile bounce_normal;
SoundFile bounce_spring;

// GAME STATE CONSTANTS
final int GAME_STATE_START_MENU = 0;
final int GAME_STATE_PLAY = 1;
final int GAME_STATE_DEAD = 2;

// PLATFORM TYPE CONSTANTS
final int PLATFORM_TYPE_NORMAL = 0;
final int PLATFORM_TYPE_LONG = 1;
final int PLATFORM_TYPE_SPRING = 2;
final int PLATFORM_TYPE_DISAPPEARING = 3;
final int PLATFORM_TYPE_BOTTOM = 4;

// GAME STATE VARIABLES
float theta = 0;
int gameState = GAME_STATE_START_MENU;
int prev_highscore;
boolean fileCheck = false;
boolean highscoreRun = false;
File highscoreFile;
PFont font = createFont("SansSerif-Bold", 90 * displayDensity);
int y = 0;

void setup() {
  
  fullScreen(P2D);
  orientation(PORTRAIT);
  
  player = new Player();
  generator = new Platform_Generator();
  
  // SETUP ORIENTATION SENSOR
  context = getActivity();
  manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
  accelerometer = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  magnetometer = manager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
  gameRotation = manager.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);
  listener = new OrientationListener();
  manager.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_GAME);
  manager.registerListener(listener, magnetometer, SensorManager.SENSOR_DELAY_GAME);
  
  // DOWNLOAD IMAGES
  player_up = loadImage("Android_Jumper_Up.png");
  player_down = loadImage("Android_Jumper_Down.png");
  player_forward = loadImage("Android_Jumper_Forward.png");
  player_up_left = loadImage("Android_Jumper_Up_Left.png");
  player_down_left = loadImage("Android_Jumper_Down_Left.png");
  player_left = loadImage("Android_Jumper_Left.png");
  player_up_right = loadImage("Android_Jumper_Up_Right.png");
  player_down_right = loadImage("Android_Jumper_Down_Right.png");
  player_right = loadImage("Android_Jumper_Right.png");
  
  platform_normal = loadImage("Platform_Normal.png");
  platform_long = loadImage("Platform_Long.png");
  platform_spring = loadImage("Platform_Spring.png");
  platform_disappearing = loadImage("Platform_Disappearing.png");
  
  background = loadImage("Background - Stage 4.png");
    
  // SETUP FILE
  highscoreFile = new File(context.getFilesDir(), "highscore.txt");
  
  // SOUND FILES
  bounce_normal = new SoundFile(this, "bounce_normal.mp3");
  bounce_spring = new SoundFile(this, "bounce_spring.mp3");
  
}

void draw() {
  
  // START MENU
  if (gameState == GAME_STATE_START_MENU) {
    background(255);
    imageMode(CORNER);
    image(background, 0, int(y), width, height);
    image(background, 0, int(y - height), width, height);
    y += 1*displayDensity;
    if (y >= height) {
      y = 0;
    }
  
    textFont(font);
    rectMode(CENTER);
    fill(0);
    stroke(255);
    strokeWeight(10);
    rect(width/2, height/2, 150*displayDensity, 80*displayDensity, 20*displayDensity, 20*displayDensity, 20*displayDensity, 20*displayDensity);
    fill(255);
    textAlign(CENTER, CENTER);
    text("START", width/2, height/2);
    textAlign(CENTER, TOP);
    text("ANDROID BOUNCE", width/2, 50*displayDensity);
    
    if (mousePressed && mouseX > width/2 - 90*displayDensity && mouseX < width/2 + 90*displayDensity && mouseY > height/2 - 40*displayDensity && mouseY < height/2 + 40*displayDensity) {
      gameState = GAME_STATE_PLAY;
    }
  }
  
  // GAMEPLAY
  if (gameState == GAME_STATE_PLAY) {
    background(255);
    imageMode(CORNER);
    int s = 10;
    image(background, 0, ( player.max_height/s % height ), width, height);
    image(background, 0, ( player.max_height/s % height ) - height, width, height);
    
    player.update();
    generator.update();
    generator.display();
    player.display();
  }
  
  // DEATH SCREEN
  else if (gameState == GAME_STATE_DEAD) {
    background(255);
    imageMode(CORNER);
    image(background, 0, 0, width, height);
    
    if (!fileCheck) {
      prev_highscore = int(readHighscore());
      if (prev_highscore < int(player.max_height/100)) {
        writeHighscore(str(int(player.max_height/100)));
        highscoreRun = true;
      } else {
        highscoreRun = false;
      }
      fileCheck = true;
    }
    
    fill(255);
    textAlign(CENTER, CENTER);
    if (highscoreRun) {
      text("HIGHSCORE!", width/2, height/2-30*displayDensity);
      text("New Highscore: " + str(int(player.max_height/100)), width/2, height/2-70*displayDensity);
    } else {
      text("NICE TRY, KID", width/2, 50*displayDensity);
      text("Score: " + str(int(player.max_height/100)), width/2, height/2-70*displayDensity);
      text("Highscore: " + str(prev_highscore), width/2, height/2-30*displayDensity);
    }
    rectMode(CENTER);
    fill(0);
    stroke(255);
    strokeWeight(10);
    rect(width/2, height/2 + 40*displayDensity, 180*displayDensity, 80*displayDensity, 20*displayDensity, 20*displayDensity, 20*displayDensity, 20*displayDensity);
    fill(255);
    text("TRY AGAIN", width/2, height/2 + 40*displayDensity);
    
    if (mousePressed && mouseX > width/2 - 90*displayDensity && mouseX < width/2 + 90*displayDensity && mouseY > height/2 && mouseY < height/2 + 80*displayDensity) {
      gameState = GAME_STATE_PLAY;
      fileCheck = false;
      generator = new Platform_Generator();
      player = new Player();
    }
    
  }
  
}

// UPDATE TILT VALUE
class OrientationListener implements SensorEventListener {
  
  float[] gravity = new float[3];
  float[] geomagnetic = new float[3];
  float[] I = new float[16];
  float[] R = new float[16];
  float orientation[] = new float[3];
  
  public void onSensorChanged(SensorEvent event) {
    
    if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD) {
      arrayCopy(event.values, geomagnetic);
    }
    if (event.sensor.getType() ==  Sensor.TYPE_ACCELEROMETER) {
      arrayCopy(event.values, gravity);
    }
    if (SensorManager.getRotationMatrix(R, I, gravity, geomagnetic)) {
      SensorManager.getOrientation(R, orientation);
      theta = orientation[2];
    }
    
  }
  
  public void onAccuracyChanged(Sensor sensor, int accuracy) {}
}

//class OrientationListener1 implements SensorEventListener {
  
//  public void onSensorChanged(SensorEvent event) {
//    if (event.sensor.getType() == Sensor.TYPE_GAME_ROTATION_VECTOR) {
//      theta = event.values[1];
//    }
//  }
  
//  public void onAccuracyChanged(Sensor sensor, int accuracy) {}
//}

// APP STATE FUNCTIONS
void onPause() {
  super.onPause();
  if (manager != null) {
    manager.unregisterListener(listener);
  }
}

void onResume() {
  super.onResume();
  if (manager != null) {
    manager.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_GAME);
    manager.registerListener(listener, magnetometer, SensorManager.SENSOR_DELAY_GAME);
  }
}

// FILE READING AND WRITING FUNCTIONS
void writeHighscore(String score) {
  FileOutputStream out = null;
  try {
    out = new FileOutputStream(highscoreFile);
    out.write(score.getBytes());
  }
  catch (FileNotFoundException e) {}
  catch (IOException e) {}
  finally {
    try {
      out.close();
    }
    catch (IOException e) {}
    catch (NullPointerException e) {}
  }
}

String readHighscore() {
  int len = (int) highscoreFile.length();
  byte[] bytes = new byte[len];
  
  FileInputStream in = null;
  try {
    in = new FileInputStream(highscoreFile);
    in.read(bytes);
  }
  catch (FileNotFoundException e) {}
  catch (IOException e) {}
  finally {
    try {
      in.close();
    }
    catch (IOException e) {}
    catch (NullPointerException e) {}
  }
  
  return new String(bytes);
}
