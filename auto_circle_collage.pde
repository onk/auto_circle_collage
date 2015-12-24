import gab.opencv.*;
import java.awt.Rectangle;

OpenCV opencv;

int IMG_HEIGHT = 750;
int IMG_WIDTH  = 500;

PImage img;

ArrayList<Contour> mizugiAreaList;
Rectangle[] faces;
ArrayList<Circle> mizutamaList;

void setup() {
  size(IMG_WIDTH, IMG_HEIGHT);
  img = loadImage("input.jpg");
  img.resize(IMG_WIDTH, IMG_HEIGHT);
  opencv = new OpenCV(this, img);

  mizugiAreaList = new ArrayList<Contour>();
  mizutamaList = new ArrayList<Circle>();

  detectMizugi();
  detectFaces();
  createMizutama();
  drawImage();
}

void draw() {
}

void drawImage() {
  PGraphics mask = createGraphics(IMG_WIDTH, IMG_HEIGHT);
  mask.beginDraw();
  mask.background(0);
  mask.fill(255);
  for (Circle c : mizutamaList) {
    mask.ellipse(c.loc.x, c.loc.y, c.d*2, c.d*2);
  }
  mask.endDraw();
  img.mask(mask);
  image(img, 0, 0);
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

Circle createCircle(PVector loc) {
  int d = min(width, height);
  Circle c = new Circle(loc, d);
  while(detectMizugiCollision(c)) {
    d -= 5;
    if (d < 30) { return null; }
    c = new Circle(loc, d);
  }
  return c;
}

boolean detectMizugiCollision(Circle c) {
  boolean hasCollision = false;
  for (Contour contour : mizugiAreaList) {
    Rectangle r = contour.getBoundingBox();
    if (checkRectCollision(r, c)) {
      // OBB で試してから凸包の衝突判定
      Contour hull = contour.getConvexHull();
      if (checkConvexHullCollision(hull, c)) {
        hasCollision = true;
        break;
      }
    }
  }
  if (hasCollision) { return hasCollision; }
  for (Circle lc : mizutamaList) {
    if (lc.detectCollision(c)) {
      hasCollision = true;
      break;
    }
  }
  return hasCollision;
}

boolean checkConvexHullCollision(Contour contour, Circle c) {
  if (contour.containsPoint((int)c.loc.x, (int)c.loc.y)) {
    // 内包されているので衝突
    return true;
  } else {
    // 外にあるので各線分との距離が半径以下なら衝突
    // よく分かんないので頂点で代替
    ArrayList<PVector> points = contour.getPoints();
    for (int i = 0; i < points.size(); i++) {
      PVector a = points.get(i);
      PVector b;
      if (i == points.size() - 1) {
        b = points.get(0);
      } else {
        b = points.get(i + 1);
      }
      PVector p = c.loc.get();
      PVector pa = a.get(); pa.sub(p);
      PVector ab = b.get(); ab.sub(a);
      if (ab.mag() < 5) { continue; }
      float d = abs(pa.cross(ab).z / ab.mag());
      if (d < c.d) { return true; }
    }
    return false;
  }
}
boolean checkRectCollision(Rectangle r, Circle c) {
  // 左右
  boolean a = (r.x - c.d) <= c.loc.x && c.loc.x <= (r.x + r.width + c.d) && r.y <= c.loc.y && c.loc.y <= (r.y + r.height);
  // 上下
  boolean b = r.x <= c.loc.x && c.loc.x <= (r.x + r.width) && (r.y - c.d) <= c.loc.y && c.loc.y <= (r.y + r.height + c.d);
  // 頂点
  boolean c1 = new PVector(r.x, r.y).dist(c.loc) < c.d;
  boolean c2 = new PVector(r.x + r.width, r.y).dist(c.loc) < c.d;
  boolean c3 = new PVector(r.x + r.width, r.y + r.height).dist(c.loc) < c.d;
  boolean c4 = new PVector(r.x, r.y  + r.height).dist(c.loc) < c.d;
  return a || b || c1 || c2 || c3 || c4;
}

void createMizutama() {
  // 顔
  for (int i = 0; i < faces.length; i++) {
    Rectangle face = faces[i];
    int facex = face.x + face.width / 2;
    int facey = face.y + face.height / 2;
    Circle c = createCircle(new PVector(facex, facey));
    if (c != null) { mizutamaList.add(c); }
  }

  // 頂点
  PVector[] verts = { new PVector(0, 0), new PVector(width, 0), new PVector(0, height), new PVector(width, height) };
  for (int i = 0; i < verts.length; i++) {
    Circle c = createCircle(verts[i]);
    if (c != null) { mizutamaList.add(c); }
  }
  // ランダムに150個
  for (int i = 0; i < 150; i++) {
    Circle c = createCircle(new PVector(random(0, width), random(0, height)));
    if (c != null) { mizutamaList.add(c); }
  }
}
