class Player {
  
  // TRANSLATE SCREEN BASED ON max_height
  // IF position_y IS GREATER THAN max_height, UPDATE max_height
  float position_x, position_y;
  float velocity_x, velocity_y;
  float acceleration_y;
  float max_height;
  float radius = 27*displayDensity;
  
  Player () {
    
    // STARTING VALUES
    position_x = width/2;
    position_y = 100;
    
    velocity_x = 0;
    velocity_y = 0;
    
    acceleration_y = -.6;
    
    max_height = 0;
    
  }
  
  void update() {
    
    // UPDATE SIDEWAYS VELOCITY
    velocity_x = 35*theta;
    
    // EULER CALCULATION
    velocity_y += acceleration_y;
    position_y += velocity_y;
    position_x += velocity_x;
    
    // WRAPPING
    if (position_x < -radius) {
      position_x = width + radius;
    } else if (position_x > width + radius) {
      position_x = -radius;
    }
    
    // UPDATE max_height
    if (position_y > max_height) {
      max_height = position_y;
    }
    
    // DEATH BOUNDARY
    if (height*.6 + player.max_height - position_y > height) {
      gameState = GAME_STATE_DEAD;
    }
    
    // CHECK FOR PLATFORMS
    checkPlatforms();
    
  }
  
  void display() {
    
    pushMatrix();
    translate(0, height*.6 + player.max_height);
    
    // IMAGE SELECTION
    PImage img;
    int bound_y = 8;
    int bound_x = 5;
    if (velocity_x < -bound_x) {
      
      if (velocity_y < -bound_y) {
        img = player_down_left;
      } else if (velocity_y > bound_y) {
        img = player_up_left;
      } else {
        img = player_left;
      }
      
    } else if (velocity_x > bound_x) {
      
      if (velocity_y < -bound_y) {
        img = player_down_right;
      } else if (velocity_y > bound_y) {
        img = player_up_right;
      } else {
        img = player_right;
      }
      
    } else {
      
      if (velocity_y < -bound_y) {
        img = player_down;
      } else if (velocity_y > bound_y) {
        img = player_up;
      } else {
        img = player_forward;
      }
      
    }
    
    imageMode(CENTER);
    image(img, position_x, -position_y, int(2*radius*15/19), int(2*radius));
    popMatrix();
    
  }
  
  void checkPlatforms() {
    
    for (Platform platform : generator.platforms) {
      if (velocity_y < 0) {
        if (position_x + radius*.35 > platform.position_x - platform.platform_width/2     &&     position_x - radius*.35 < platform.position_x + platform.platform_width/2) {
          if (position_y - radius < platform.position_y) {
            if (position_y - radius*.6 > platform.position_y) {
              if (!platform.disappeared) {
                platform.bounce();
              }
            }
          }
        }
      }
    }
    
  }
  
}
