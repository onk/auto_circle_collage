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

  PImage hada = getHada();
  image(hada, 0, 0);
}

void draw() {
}

PImage getHada() {
  // 作業用に hue で grayscale にする
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  // 肌色は 7..15 と定義。inRange で取り出す
  opencv.inRange(7, 15);

  // ノイズ除去 MORPH_OPEN
  opencv.erode();
  opencv.dilate();

  return opencv.getOutput();
}
