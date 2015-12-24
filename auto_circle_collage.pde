import gab.opencv.*;
import java.awt.Rectangle;

OpenCV opencv;

int IMG_HEIGHT = 750;
int IMG_WIDTH  = 500;

PImage img;

ArrayList<Contour> mizugiAreaList;
Rectangle[] faces;

void setup() {
  size(IMG_WIDTH, IMG_HEIGHT);
  img = loadImage("input.jpg");
  img.resize(IMG_WIDTH, IMG_HEIGHT);
  opencv = new OpenCV(this, img);

  mizugiAreaList = new ArrayList<Contour>();

  detectMizugi();
  detectFaces();
  drawImage();
}

void draw() {
}

void drawImage() {
  image(img, 0, 0);

  // 抽出した水着の輪郭を赤色で塗る
  for (Contour contour : mizugiAreaList) {
    strokeWeight(10);
    stroke(255, 0, 0);
    noFill();
    contour.draw();
  }

  // 抽出した顔を青色で塗る
  for (int i = 0; i < faces.length; i++) {
    strokeWeight(10);
    stroke(0, 255, 255);
    noFill();
    Rectangle face = faces[i];
    rect(face.x, face.y, face.width, face.height);
  }
}

void detectMizugi() {
  // 水着を彩度 180..255, 明度 80..247 と定義。inRange で取り出す
  opencv.loadImage(img);
  opencv.useColor(HSB);
  opencv.setGray(opencv.getS().clone());
  opencv.inRange(180, 255);
  PImage s = opencv.getSnapshot();

  opencv.loadImage(img);
  opencv.useColor(HSB);
  opencv.setGray(opencv.getB().clone());
  opencv.inRange(8, 247);
  PImage b = opencv.getSnapshot();

  s.blend(b, 0, 0, width, height, 0, 0, width, height, MULTIPLY);

  opencv.loadImage(s);
  opencv.erode();
  opencv.dilate();

  ArrayList<Contour> contours = opencv.findContours();
  for (Contour contour : contours) {
    if (contour.area() > 25) {
      mizugiAreaList.add(contour);
    }
  }
}

void detectFaces() {
  opencv.loadImage(img);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  faces = opencv.detect();
}
