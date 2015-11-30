
import themidibus.*;

final int MIDI_MIN = 0;
final int MIDI_MAX = 128;

MidiBus bus;

int numFlowers;
BezierFlower bezierFlower0;
BezierFlower bezierFlower1;
PGraphics gradientCanvas;

float xOffset;
float yOffset;
float rotationOffset;

FileNamer fileNamer;

void setup() {
  size(640, 480, P2D);

  MidiBus.list();
  bus = new MidiBus(this, 0, 1);

  numFlowers = 50;

  bezierFlower0 = new BezierFlower()
    .numPoints(5)
    .innerRadius(250)
    .outerRadius(500);

  bezierFlower1 = new BezierFlower()
    .numPoints(5)
    .innerRadius(250)
    .outerRadius(500);

  float x0 = 0.3 * width;
  float y0 = -0.2 * height;
  float innerRadius = 0;
  float outerRadius = width-x0;
  RadialGradient gradient = new RadialGradient(
      x0, y0, innerRadius, x0 + 0.2 * width, y0, outerRadius);
  gradient.addColorStop(0, 0xff5bff69);
  gradient.addColorStop(1, 0xff66ffec);

  gradientCanvas = createGraphics(width, height, P2D);
  gradient.fillRect(gradientCanvas, 0, 0, width, height, false);

  fileNamer = new FileNamer("output/export", "png");

  zero();
}

void draw() {
  int rotationFrameCount = 2000;

  g.image(gradientCanvas, 0, 0);

  g.pushStyle();

  g.noFill();
  g.stroke(0xfff375b0);
  g.strokeWeight(4);

  g.pushMatrix();
  g.translate(width/2, height/2);
  g.rotate(frameCount % rotationFrameCount * 2 * PI / rotationFrameCount);

  for (int i = 0; i < numFlowers; i++) {
    g.pushMatrix();
    g.scale(1.7 * i / numFlowers);

    bezierFlower0.draw(g);

    g.pushMatrix();
    g.translate(xOffset, yOffset);
    g.rotate(rotationOffset);

    bezierFlower1.draw(g);

    g.popMatrix();

    g.popMatrix();
  }

  g.popStyle();
  g.popMatrix();
}

void zero() {
  for (int i = 0; i < 24; i++) {
    controllerChange(0, i, MIDI_MIN);
  }
}

void keyReleased() {
  switch (key) {
    case 'r':
      save(fileNamer.next());
      break;
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
      break;

    case 20:
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

float midiMap(float value, float minValue, float maxValue) {
  return map(value, MIDI_MIN, MIDI_MAX, minValue, maxValue);
}
