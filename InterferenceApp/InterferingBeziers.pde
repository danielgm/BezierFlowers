
class InterferingBeziers {
  final int MIDI_MIN = 0;
  final int MIDI_MAX = 128;

  int numFlowers;
  BezierFlower bezierFlower0;
  BezierFlower bezierFlower1;

  float xOffset;
  float yOffset;
  float rotationOffset;
  float rotationDelta;
  float rotationDeltaOffset;

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

    zero();
  }

  void draw(PGraphics g) {
    for (int i = 0; i < numFlowers; i++) {
      g.pushMatrix();
      g.scale(1.7 * i / numFlowers);
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

  JSONObject toJSONObject() {
    JSONObject json = new JSONObject();
    json.setJSONObject("flower0", bezierFlower0.toJSONObject());
    json.setJSONObject("flower1", bezierFlower1.toJSONObject());

    json.setInt("numFlowers", numFlowers);
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
    xOffset = json.getFloat("xOffset");
    yOffset = json.getFloat("yOffset");
    rotationOffset = json.getFloat("rotationOffset");
    rotationDelta = json.getFloat("rotationDelta");
    rotationDeltaOffset = json.getFloat("rotationDeltaOffset");
  }

  private void zero() {
    for (int i = 0; i < 24; i++) {
      controllerChange(0, i, MIDI_MIN);
    }
  }

  void controllerChange(int channel, int number, int midiValue) {
    println(channel, number, midiValue);

    float value;
    int intValue;
    switch (number) {

      // Sliders.

      case 0:
        println("inner radius");
        value = midiMap(midiValue, width/2, width * 2);
        bezierFlower0.innerRadius(value);
        bezierFlower1.innerRadius(value);
        break;
      case 1:
        println("outer radius");
        value = midiMap(midiValue, width/2, width * 2);
        bezierFlower0.outerRadius(value);
        bezierFlower1.outerRadius(value);
        break;

      case 2:
        println("inner control distance factor");
        value = midiMap(midiValue, 0.001, 2);
        bezierFlower0.innerControlDistanceFactor(value);
        bezierFlower1.innerControlDistanceFactor(value);
        break;
      case 3:
        println("outer control distance factor");
        value = midiMap(midiValue, 0.001, 2);
        bezierFlower0.outerControlDistanceFactor(value);
        bezierFlower1.outerControlDistanceFactor(value);
        break;

      case 4:
        println("inner control rotation");
        value = midiMap(midiValue, 0, 2 * PI);
        bezierFlower0.innerControlRotation(value);
        bezierFlower1.innerControlRotation(value);
        break;
      case 5:
        println("outer control rotation");
        value = midiMap(midiValue, 0, 2 * PI);
        bezierFlower0.outerControlRotation(value);
        bezierFlower1.outerControlRotation(value);
        break;

      case 6:
        println("x offset");
        xOffset = midiMap(midiValue, 0, 100);
        break;
      case 7:
        println("y offset");
        yOffset = midiMap(midiValue, 0, 100);
        break;

      // Knobs.

      case 16:
        println("num points");
        intValue = floor(midiMap(midiValue, 1, 12));
        bezierFlower0.numPoints(intValue);
        bezierFlower1.numPoints(intValue);
        break;
      case 17:
        println("num flowers");
        numFlowers = floor(midiMap(midiValue, 1, 256));
        break;

      case 18:
        println("rotation offset");
        rotationOffset = midiMap(midiValue, 0, 2 * PI / bezierFlower0.numPoints());
        break;
      case 19:
        println("rotation delta");
        value = midiMap(midiValue, 0, 0.01 * PI);
        rotationDelta = value;
        break;

      case 20:
        println("rotation delta offset");
        value = midiMap(midiValue, 0, 0.01 * PI);
        rotationDeltaOffset = value;
        break;
      case 21:
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
