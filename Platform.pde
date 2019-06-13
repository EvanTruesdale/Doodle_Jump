class Platform {
    
  float position_x, position_y, speed, boundary_low, boundary_high, platform_width;
  int type;
  boolean disappeared;
  
  Platform (float position_x_in, float position_y_in, int type_in, float speed_in, float boundary_low_in, float boundary_high_in) {
    
    position_x = position_x_in;
    position_y = position_y_in;
    speed = speed_in;
    boundary_low = boundary_low_in;
    boundary_high = boundary_high_in;
    type = type_in;
    
    if (type == PLATFORM_TYPE_LONG) {
      platform_width = 300;
    } else if (type == PLATFORM_TYPE_BOTTOM) {
      platform_width = width*1.2;
    } else {
      platform_width = 150;
    }
    
    disappeared = false;
    
  }
  
  void update() {
    
    // EULER CALCULATION
    position_x += speed;
    
    // BOUNDARY CONDITIONS
    if (position_x <= boundary_low || position_x >= boundary_high) {
      speed *= -1;
    }
    
  }
  
  // PLATFORM FUNCTIONALITIES
  void bounce() {
    if (type == PLATFORM_TYPE_DISAPPEARING) {
      disappeared = true;
      player.velocity_y = 30;
      bounce_normal.play();
    }
    else if (type == PLATFORM_TYPE_SPRING) {
      player.velocity_y = 60;
      bounce_spring.play();
    } 
    else {
      player.velocity_y = 30;
      bounce_normal.play();
    } 
    
    player.position_y = position_y + player.radius;
  }
  
}
