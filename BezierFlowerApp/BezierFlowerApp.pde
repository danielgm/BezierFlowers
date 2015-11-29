
import themidibus.*;

final int MIDI_MIN = 0;
final int MIDI_MAX = 128;

MidiBus bus;

int numFlowers;
BezierFlower bezierFlower;
PGraphics gradientCanvas;
FileNamer fileNamer;

void setup() {
  size(640, 480, P2D);

  MidiBus.list();
  bus = new MidiBus(this, 0, 1);

  numFlowers = 50;

  bezierFlower = new BezierFlower()
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

    bezierFlower.draw(g);

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
    case 'k':
      bezierFlower.numPoints(bezierFlower.numPoints() + 1);
      break;
    case 'j':
      bezierFlower.numPoints(bezierFlower.numPoints - 1);
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}

void controllerChange(int channel, int number, int value) {
  println(channel, number, value);
  float maxOffset = 50;
  float minSize = 100;
  float maxSize = 400;
  float minFactor = 1.01;
  float maxFactor = 1.08;
  float minHeightRatio = 1;
  float maxHeightRatio = 2;
  float minStartIndex = 0;
  float maxStartIndex = 128;

  switch (number) {

    // Sliders.

    case 0:
      println("inner radius");
      bezierFlower.innerRadius(midiMap(value, width/2, width * 2));
      break;
    case 1:
      println("outer radius");
      bezierFlower.outerRadius(midiMap(value, width/2, width * 2));
      break;

    case 2:
      println("inner control distance factor");
      bezierFlower.innerControlDistanceFactor(midiMap(value, 0.001, 2));
      break;
    case 3:
      println("outer control distance factor");
      bezierFlower.outerControlDistanceFactor(midiMap(value, 0.001, 2));
      break;

    case 4:
      println("inner control rotation");
      bezierFlower.innerControlRotation(midiMap(value, 0, 2 * PI));
      break;
    case 5:
      println("outer control rotation");
      bezierFlower.outerControlRotation(midiMap(value, 0, 2 * PI));
      break;

    case 6:
      break;
    case 7:
      break;

    // Knobs.

    case 16:
      println("num points");
      bezierFlower.numPoints(floor(midiMap(value, 1, 12)));
      break;
    case 17:
      println("num flowers");
      numFlowers = floor(midiMap(value, 1, 256));
      break;

    case 18:
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
