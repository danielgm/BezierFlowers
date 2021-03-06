
import themidibus.*;

int loopFrameCount;

InterferingBeziers beziers0;
InterferingBeziers beziers1;
MidiBus bus;

PGraphics gradientCanvas;

FileNamer fileNamer;

color strokeColor, backgroundColor0, backgroundColor1;

void setup() {
  size(640, 640, P2D);

  loopFrameCount = 300;

  beziers0 = new InterferingBeziers();
  beziers0.updateFromJSONObject(loadJSONObject("settings0.json"));
  beziers1 = new InterferingBeziers();
  beziers1.updateFromJSONObject(loadJSONObject("settings1.json"));

  MidiBus.list();
  bus = new MidiBus(this, 0, 1);

  strokeColor = 0xff39545d;
  backgroundColor0 = 0xff49b6b0;
  backgroundColor1 = 0xffaeae94;

  float x0 = 0.3 * width;
  float y0 = -0.2 * height;
  float innerRadius = 0;
  float outerRadius = width-x0;
  RadialGradient gradient = new RadialGradient(
      x0, y0, innerRadius, x0 + 0.2 * width, y0, outerRadius);
  gradient.addColorStop(0, backgroundColor0);
  gradient.addColorStop(1, backgroundColor1);

  gradientCanvas = createGraphics(width, height, P2D);
  gradient.fillRect(gradientCanvas, 0, 0, width, height, false);

  fileNamer = new FileNamer("output/output", "/");
}

void draw() {
  float t = (float)(frameCount % loopFrameCount) / loopFrameCount;
  draw(g, t);
}

void draw(PGraphics g, float t) {
  t = remapTime(t);

  InterferingBeziers beziers = beziers0.interpolate(beziers1, t);

  g.image(gradientCanvas, 0, 0);

  g.pushStyle();

  g.noFill();
  g.stroke(strokeColor);
  g.strokeWeight(4);

  g.pushMatrix();
  g.translate(width/2, height/2);

  beziers.draw(g);

  g.popStyle();
  g.popMatrix();
}

float remapTime(float t) {
  float amplitude = 0.1;
  float frequencyFactor = 14;
  float mapped = cos((2 * t + 1) * PI) + 0.5;
  mapped += amplitude * cos(PI * (frequencyFactor * t + 1));

  return mapped;
}

void saveAnimation() {
  String dir = fileNamer.next();

  PGraphics g = createGraphics(width, height, P2D);
  for (int i = 0; i < loopFrameCount; i++) {
    g.beginDraw();
    draw(g, (float)i / loopFrameCount);
    g.endDraw();
    g.save(dir + "frame" + nf(i, 4) + ".png");
  }
}

void keyReleased() {
  switch (key) {
    case 'r':
      saveAnimation();
      break;
  }
}

void controllerChange(int channel, int number, int value) {
}
