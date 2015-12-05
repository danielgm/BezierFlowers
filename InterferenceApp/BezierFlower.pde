
class BezierFlower {
  private int numPoints;
  private float innerRadius;
  private float outerRadius;
  private float innerControlDistanceFactor;
  private float outerControlDistanceFactor;
  private float innerControlRotation;
  private float outerControlRotation;

  BezierFlower() {
    numPoints = 3;
    innerRadius = 100;
    outerRadius = 200;

    innerControlDistanceFactor = 0.2;
    outerControlDistanceFactor = 0.2;
    innerControlRotation = 0;
    outerControlRotation = 0;
  }

  int numPoints() {
    return numPoints;
  }

  BezierFlower numPoints(int v) {
    numPoints = v;
    return this;
  }

  BezierFlower innerRadius(float v) {
    innerRadius = v;
    return this;
  }

  BezierFlower outerRadius(float v) {
    outerRadius = v;
    return this;
  }

  BezierFlower innerControlDistanceFactor(float v) {
    innerControlDistanceFactor = v;
    return this;
  }

  BezierFlower outerControlDistanceFactor(float v) {
    outerControlDistanceFactor = v;
    return this;
  }

  BezierFlower innerControlRotation(float v) {
    innerControlRotation = v;
    return this;
  }

  BezierFlower outerControlRotation(float v) {
    outerControlRotation = v;
    return this;
  }

  void draw(PGraphics g) {
    for (int i = 0; i < numPoints * 2; i++) {
      drawPoint(g, i);
    }
  }

  JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setInt("numPoints", numPoints);
    json.setFloat("innerRadius", innerRadius);
    json.setFloat("outerRadius", outerRadius);
    json.setFloat("innerControlDistanceFactor", innerControlDistanceFactor);
    json.setFloat("outerControlDistanceFactor", outerControlDistanceFactor);
    json.setFloat("innerControlRotation", innerControlRotation);
    json.setFloat("outerControlRotation", outerControlRotation);
    return json;
  }

  void updateFromJSONObject(JSONObject json) {
    numPoints = json.getInt("numPoints");
    innerRadius = json.getFloat("innerRadius");
    outerRadius = json.getFloat("outerRadius");
    innerControlDistanceFactor = json.getFloat("innerControlDistanceFactor");
    outerControlDistanceFactor = json.getFloat("outerControlDistanceFactor");
    innerControlRotation = json.getFloat("innerControlRotation");
    outerControlRotation = json.getFloat("outerControlRotation");
  }

  String toString() {
    return "new BezierFlower()\n"
      + "\t.numPoints(" + numPoints + ")\n"
      + "\t.innerRadius(" + numPoints + ")\n"
      + "\t.outerRadius(" + outerRadius + ")\n"
      + "\t.innerControlDistanceFactor(" + innerControlDistanceFactor + ")\n"
      + "\t.outerControlDistanceFactor(" + outerControlDistanceFactor + ")\n"
      + "\t.innerControlRotation(" + innerControlRotation + ")\n"
      + "\t.outerControlRotation(" + outerControlRotation + ")";
  }

  private void drawPoint(PGraphics g, int index) {
    int prevIndex = index - 1;
    PVector prevPoint = getPoint(prevIndex);
    PVector prevControl = getTangent(prevIndex);
    prevControl.mult(getRadius(prevIndex) * getControlDistanceFactor(prevIndex));
    prevControl.rotate(getControlRotation(prevIndex));
    prevControl.add(prevPoint);

    PVector point = getPoint(index);
    PVector control = getTangent(index);
    control.mult(-getRadius(index) * getControlDistanceFactor(index));
    control.rotate(getControlRotation(index));
    control.add(point);

    drawBezier(g, prevPoint, prevControl, control, point);
  }

  private PVector getPoint(int index) {
    float radius = getRadius(index);
    PVector p = new PVector(radius, 0);
    p.rotate(index * PI / numPoints);
    return p;
  }

  private float getRadius(int index) {
    return index % 2 == 0 ? innerRadius : outerRadius;
  }

  private PVector getTangent(int index) {
    PVector p = new PVector(1, 0);
    p.rotate(index * PI / numPoints + PI / 2);
    return p;
  }

  private float getControlDistanceFactor(int index) {
    return index % 2 == 0 ? outerControlDistanceFactor : innerControlDistanceFactor;
  }

  private float getControlRotation(int index) {
    return index % 2 == 0 ? outerControlRotation : innerControlRotation;
  }

  private void drawBezier(PGraphics g, PVector a, PVector c0, PVector c1, PVector b) {
    g.bezier(a.x, a.y, c0.x, c0.y, c1.x, c1.y, b.x, b.y);
  }
}
