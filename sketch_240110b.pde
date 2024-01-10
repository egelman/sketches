float numPoints = 200;
float r = 200;
int multVal = 2;

void setup() {
  frameRate(2);
  fullScreen();
}

void draw() {
  background(100);
  translate(width/2, height/2);
  for (int i = 0; i < 200; i++) {
    point(r * cos(i/numPoints * TWO_PI), r * sin(i/numPoints * TWO_PI));
  }
  
  for (int i = 0; i < 200; i++) {
    line(r * cos(i/numPoints * TWO_PI), r * sin(i/numPoints * TWO_PI),
      r * cos(multVal * i/numPoints % numPoints * TWO_PI),
      r * sin(multVal * i/numPoints % numPoints * TWO_PI));

  }
  
  multVal++;
}
