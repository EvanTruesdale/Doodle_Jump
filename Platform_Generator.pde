class Platform_Generator {
  
  ArrayList<Platform> platforms;
  
  float platform_gap, last_platform_position;
  
  Platform_Generator() {
    
    // ADD FIRST PLATFORMS
    platforms = new ArrayList<Platform>();
    platform_gap = 50*displayDensity;
    addPlatform(width/2, 0, PLATFORM_TYPE_BOTTOM, 0, 0, 0);
    for (int i=int(platform_gap); i<=height+platform_gap; i+=platform_gap) {
      addPlatform(width*random(.05, .95), i, PLATFORM_TYPE_LONG, 0, 0, 0);
    }
    last_platform_position = height;
  
  }
  
  void addPlatform(float position_x, float position_y, int type, float speed, float boundary_low, float boundary_high) {
    platforms.add(new Platform(position_x, position_y, type, speed, boundary_low, boundary_high));
  }
  
  void removePlatform(int index) {
    platforms.remove(index);
  }
  
  void update() {
    
    // SCORE DETAILS
    textAlign(CENTER, TOP);
    textFont(font);
    stroke(255);
    fill(255);
    text("Score: " + str(int(player.max_height/100)), width/2, 20*displayDensity);
    
    //REMOVE THE PLATFORMS THAT ARE OFF SCREEN
    for (Platform platform : platforms) {
      if (height*.6 + player.max_height - platform.position_y > height) {
        removePlatform(0);
        break;
      }
    }
    
    //ADD NEW PLATFORMS AS THE PLAYER MOVES UP
    if (height + player.max_height > last_platform_position + platform_gap) {
      float long_prob = .5*exp(-player.max_height/10000);
      float spring_prob = .25 - .25*exp(-player.max_height/10000);
      float disappearing_prob = .25 - .25*exp(-player.max_height/10000);
      float moving_prob = .50 - .50*exp(-player.max_height/50000);
      
      float p = random(0, 1);
      int new_type;
      
      if (p < long_prob) {
        new_type = PLATFORM_TYPE_LONG;
      } else if (p < spring_prob + long_prob) {
        new_type = PLATFORM_TYPE_SPRING;
      } else if (p < disappearing_prob + spring_prob + long_prob) {
        new_type = PLATFORM_TYPE_DISAPPEARING;
      } else {
        new_type = PLATFORM_TYPE_NORMAL;
      }
      
      p = random(0, 1);
      float speed;
      if (p < moving_prob) {
        speed = random(.5*displayDensity, 2.5*displayDensity);
      } else {
        speed = 0;
      }
      
      addPlatform(width*random(.05, .95), last_platform_position + platform_gap + random(-15*displayDensity, 15*displayDensity), new_type, speed, width*.05, width*.95);
      
      last_platform_position += platform_gap;
      platform_gap = 250*displayDensity-200*displayDensity*exp(-last_platform_position/100000);
    }
    
    // UPDATE PLATFORMS
    for (Platform platform : platforms) {
      platform.update();
    }
    
  }
  
  void display() {
    
    pushMatrix();
    rectMode(CORNERS);
    translate(0, height*.6 + player.max_height);
    
    // DISPLAY DIFFERENT PLATFORMS
    for (Platform platform : platforms) {
      if (!platform.disappeared) {
        PImage img;
        if (platform.type == PLATFORM_TYPE_DISAPPEARING) {
          img = platform_disappearing;
        } else if (platform.type == PLATFORM_TYPE_SPRING){
          img = platform_spring;
        } else if (platform.type == PLATFORM_TYPE_LONG) {
          img = platform_long;
        } else if (platform.type == PLATFORM_TYPE_BOTTOM) {
          img = platform_long;
        } else {
          img = platform_normal;
        }
        
        imageMode(CORNERS);
        int x = int(platform.position_x);
        int y = int(platform.position_y);
        int w = int(platform.platform_width);
        int h = int(platform.platform_width*44/60);
        image(img, x-w/2, -y, x+w/2, -y + h);
      } 
    }
    
    popMatrix();
    
  }
  
}
