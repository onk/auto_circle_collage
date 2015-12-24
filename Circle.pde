class Circle {
  PVector loc;
  int d;

  Circle(PVector loc, int d) {
    this.loc = loc;
    this.d = d;
  }

  boolean detectCollision(Circle other) {
    return dist(loc.x, loc.y, other.loc.x, other.loc.y) < ((d + other.d));
  }
}
