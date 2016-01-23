
import themidibus.*;

PImage background;
PVector center;

InterferingBeziers beziers;
MidiBus bus;

PGraphics gradientCanvas;

FileNamer fileNamer;
FileNamer settingsFileNamer;

color strokeColor, backgroundColor0, backgroundColor1;

void setup() {
  size(640, 640, P2D);

  background = loadImage("zebra.jpg");
  center = new PVector(width/2, height/2);

  JSONObject json = loadJSONObject("settings.json");
  beziers = new InterferingBeziers();
  beziers.updateFromJSONObject(json.getJSONObject("beziers"));
  center.x = json.getFloat("centerX");
  center.y = json.getFloat("centerY");

  MidiBus.list();
  bus = new MidiBus(this, 0, 1);

  strokeColor = 0xff030303;
  backgroundColor0 = 0xff69d3ce;
  backgroundColor1 = 0xff887abf;

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

  fileNamer = new FileNamer("output/export", "png");
  settingsFileNamer = new FileNamer("output/settings", "json");
}

void draw() {
  drawBackground();
  drawGradient();
  drawInterference();
}

void drawBackground() {
  float scale;
  if (background.width / width < background.height / height) {
    scale = (float)width / background.width;
  }
  else {
    scale = (float)height / background.height;
  }

  g.pushStyle();
  g.imageMode(CENTER);
  g.image(background, width/2, height/2, background.width * scale, background.height * scale);
  g.popStyle();
}

void drawGradient() {
  g.pushStyle();
  g.blendMode(ADD);
  g.tint(255, 60);
  g.image(gradientCanvas, 0, 0);
  g.popStyle();
}

void drawInterference() {
  g.pushStyle();

  g.noFill();
  g.stroke(strokeColor);
  g.strokeWeight(4);

  g.pushMatrix();
  g.translate(center.x, center.y);

  beziers.draw(g);

  g.popStyle();
  g.popMatrix();
}

void keyReleased() {
  switch (key) {
    case 'r':
      save(fileNamer.next());
      break;
    case 's':
      saveJSONObject(toJSONObject(), settingsFileNamer.next());
      break;
  }
}

void mouseReleased() {
  center.x = mouseX;
  center.y = mouseY;
}

void controllerChange(int channel, int number, int value) {
  beziers.controllerChange(channel, number, value);
  saveJSONObject(toJSONObject(), "settings.json");
}

JSONObject toJSONObject() {
  JSONObject json = new JSONObject();
  json.setJSONObject("beziers", beziers.toJSONObject());
  json.setFloat("centerX", center.x);
  json.setFloat("centerY", center.y);
  return json;
}
