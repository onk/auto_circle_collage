import gab.opencv.*;

OpenCV opencv;

int IMG_HEIGHT = 750;
int IMG_WIDTH  = 500;

PImage img;

void setup() {
  size(IMG_WIDTH, IMG_HEIGHT);
  img = loadImage("input.jpg");
  img.resize(IMG_WIDTH, IMG_HEIGHT);
  opencv = new OpenCV(this, img);
  drawImage();
}

void draw() {
}

void drawImage() {
  image(img, 0, 0);
}
