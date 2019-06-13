class Enemy {
  
  float position_x, position_y, speed;
  int type;
  
  Enemy (float position_x_in, float position_y_in, int type_in, float speed_in) {
    
    position_x = position_x_in;
    position_y = position_y_in;
    type = type_in;
    speed = speed_in;
    
  }
  
  void update(){
   
    // EULER CALCULATION
    position_x += speed;
    
    // BOUNDARY CONDITIONS
    if (position_x < .05*width || position_x > .95*width) {
      speed *= -1;
    }
    
  }
  
  void display() {
    
  }
  
}
