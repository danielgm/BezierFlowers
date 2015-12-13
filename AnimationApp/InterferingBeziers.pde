
class InterferingBeziers {
  final int MIDI_MIN = 0;
  final int MIDI_MAX = 128;

  private int numFlowers;
  private BezierFlower bezierFlower0;
  private BezierFlower bezierFlower1;

  private float scaleFactor;
  private float xOffset;
  private float yOffset;
  private float rotationOffset;
  private float rotationDelta;
  private float rotationDeltaOffset;

  InterferingBeziers() {
    numFlowers = 50;

    bezierFlower0 = new BezierFlower()
      .numPoints(5)
      .innerRadius(250)
      .outerRadius(500);

    bezierFlower1 = new BezierFlower()
      .numPoints(5)
      .innerRadius(250)
      .outerRadius(500);
  }

  int numFlowers() {
    return numFlowers;
  }

  InterferingBeziers numFlowers(int v) {
    numFlowers = v;
    return this;
  }

  BezierFlower bezierFlower0() {
    return bezierFlower0;
  }

  InterferingBeziers bezierFlower0(BezierFlower v) {
    bezierFlower0 = v;
    return this;
  }

  BezierFlower bezierFlower1() {
    return bezierFlower1;
  }

  InterferingBeziers bezierFlower1(BezierFlower v) {
    bezierFlower1 = v;
    return this;
  }

  float scaleFactor() {
    return scaleFactor;
  }

  InterferingBeziers scaleFactor(float v) {
    scaleFactor = v;
    return this;
  }

  float xOffset() {
    return xOffset;
  }

  InterferingBeziers xOffset(float v) {
    xOffset = v;
    return this;
  }

  float yOffset() {
    return yOffset;
  }

  InterferingBeziers yOffset(float v) {
    yOffset = v;
    return this;
  }

  float rotationOffset() {
    return rotationOffset;
  }

  InterferingBeziers rotationOffset(float v) {
    rotationOffset = v;
    return this;
  }

  float rotationDelta() {
    return rotationDelta;
  }

  InterferingBeziers rotationDelta(float v) {
    rotationDelta = v;
    return this;
  }

  float rotationDeltaOffset() {
    return rotationDeltaOffset;
  }

  InterferingBeziers rotationDeltaOffset(float v) {
    rotationDeltaOffset = v;
    return this;
  }

  void draw(PGraphics g) {
    for (int i = 0; i < numFlowers; i++) {
      g.pushMatrix();
      g.scale(scaleFactor * i / numFlowers);
      g.rotate(i * rotationDelta);

      bezierFlower0.draw(g);

      g.pushMatrix();
      g.translate(xOffset, yOffset);
      g.rotate(rotationOffset + i * rotationDeltaOffset);

      bezierFlower1.draw(g);

      g.popMatrix();

      g.popMatrix();
    }
  }

  InterferingBeziers interpolate(InterferingBeziers b, float t) {
    InterferingBeziers a = this;

    InterferingBeziers result = new InterferingBeziers()
      .numFlowers(floor(mapt(t, a.numFlowers, b.numFlowers)))
      .scaleFactor(mapt(t, a.scaleFactor, b.scaleFactor))
      .bezierFlower0(a.bezierFlower0.interpolate(b.bezierFlower0, t))
      .bezierFlower1(a.bezierFlower1.interpolate(b.bezierFlower1, t))
      .xOffset(mapt(t, a.xOffset, b.xOffset))
      .yOffset(mapt(t, a.yOffset, b.yOffset))
      .rotationOffset(mapt(t, a.rotationOffset, b.rotationOffset))
      .rotationDelta(mapt(t, a.rotationDelta, b.rotationDelta))
      .rotationDeltaOffset(mapt(t, a.rotationDeltaOffset, b.rotationDeltaOffset));

    return result;
  }

  private float mapt(float t, float low, float high) {
    return map(t, 0, 1, low, high);
  }

  JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setJSONObject("flower0", bezierFlower0.toJSONObject());
    json.setJSONObject("flower1", bezierFlower1.toJSONObject());

    json.setInt("numFlowers", numFlowers);
    json.setFloat("scaleFactor", scaleFactor);
    json.setFloat("xOffset", xOffset);
    json.setFloat("yOffset", yOffset);
    json.setFloat("rotationOffset", rotationOffset);
    json.setFloat("rotationDelta", rotationDelta);
    json.setFloat("rotationDeltaOffset", rotationDeltaOffset);
    return json;
  }

  void updateFromJSONObject(JSONObject json) {
    bezierFlower0.updateFromJSONObject(json.getJSONObject("flower0"));
    bezierFlower1.updateFromJSONObject(json.getJSONObject("flower1"));

    numFlowers = json.getInt("numFlowers");
    scaleFactor = json.getFloat("scaleFactor");
    xOffset = json.getFloat("xOffset");
    yOffset = json.getFloat("yOffset");
    rotationOffset = json.getFloat("rotationOffset");
    rotationDelta = json.getFloat("rotationDelta");
    rotationDeltaOffset = json.getFloat("rotationDeltaOffset");
  }

  void controllerChange(int channel, int number, int midiValue) {
    println(channel, number, midiValue);

    float value;
    int intValue;
    switch (number) {

      // Sliders.

      case 0:
        value = midiMap(midiValue, width/2, width * 2);
        println("inner radius", value);
        bezierFlower0.innerRadius(value);
        bezierFlower1.innerRadius(value);
        break;
      case 1:
        value = midiMap(midiValue, width/2, width * 2);
        println("outer radius", value);
        bezierFlower0.outerRadius(value);
        bezierFlower1.outerRadius(value);
        break;

      case 2:
        value = midiMap(midiValue, 0.001, 2);
        println("inner control distance factor", value);
        bezierFlower0.innerControlDistanceFactor(value);
        bezierFlower1.innerControlDistanceFactor(value);
        break;
      case 3:
        value = midiMap(midiValue, 0.001, 2);
        println("outer control distance factor", value);
        bezierFlower0.outerControlDistanceFactor(value);
        bezierFlower1.outerControlDistanceFactor(value);
        break;

      case 4:
        value = midiMap(midiValue, -PI, PI);
        println("inner control rotation", value);
        bezierFlower0.innerControlRotation(value);
        bezierFlower1.innerControlRotation(value);
        break;
      case 5:
        value = midiMap(midiValue, -PI, PI);
        println("outer control rotation", value);
        bezierFlower0.outerControlRotation(value);
        bezierFlower1.outerControlRotation(value);
        break;

      case 6:
        value = midiMap(midiValue, -20, 20);
        println("x offset", value);
        xOffset = value;
        break;
      case 7:
        value = midiMap(midiValue, -20, 20);
        println("y offset", value);
        yOffset = value;
        break;

      // Knobs.

      case 16:
        value = midiMap(midiValue, 1, 12);
        println("num points", value);
        intValue = floor(value);
        bezierFlower0.numPoints(intValue);
        bezierFlower1.numPoints(intValue);
        break;
      case 17:
        value = midiMap(midiValue, 128, 1024);
        println("num flowers", value);
        numFlowers = floor(value);
        break;

      case 18:
        value = midiMap(midiValue, 0, 0.2 * 2 * PI / bezierFlower0.numPoints());
        println("rotation offset", value * 180 / PI);
        rotationOffset = value;
        break;
      case 19:
        value = midiMap(midiValue, -0.01, 0.01 * PI);
        println("rotation delta", value * 180 / PI);
        rotationDelta = value;
        break;

      case 20:
        value = midiMap(midiValue, -0.001, 0.001) * PI;
        println("rotation delta offset", value * 180 / PI);
        rotationDeltaOffset = value;
        break;
      case 21:
        value = midiMap(midiValue, 0.1, 1.5);
        println("scale factor", value);
        scaleFactor = value;
        break;

      case 22:
        break;
      case 23:
        break;

      default:
    }
  }

  private float midiMap(float value, float minValue, float maxValue) {
    return map(value, MIDI_MIN, MIDI_MAX, minValue, maxValue);
  }
}
