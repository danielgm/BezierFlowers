
import themidibus.*;

InterferingBeziers beziers;
MidiBus bus;

PGraphics gradientCanvas;

FileNamer fileNamer;
FileNamer settingsFileNamer;

void setup() {
  size(1920, 1080, P2D);

  beziers = new InterferingBeziers();
  beziers.updateFromJSONObject(loadJSONObject("settings.json"));

  MidiBus.list();
  bus = new MidiBus(this, 0, 1);

  float x0 = 0.3 * width;
  float y0 = -0.2 * height;
  float innerRadius = 0;
  float outerRadius = width-x0;
  RadialGradient gradient = new RadialGradient(
      x0, y0, innerRadius, x0 + 0.2 * width, y0, outerRadius);
  gradient.addColorStop(0, 0xff85e4ff);
  gradient.addColorStop(1, 0xff252e75);

  gradientCanvas = createGraphics(width, height, P2D);
  gradient.fillRect(gradientCanvas, 0, 0, width, height, false);

  fileNamer = new FileNamer("output/export", "png");
  settingsFileNamer = new FileNamer("output/settings", "json");
}

void draw() {
  int rotationFrameCount = 2000;

  g.image(gradientCanvas, 0, 0);

  g.pushStyle();

  g.noFill();
  g.stroke(0xff000000);
  g.strokeWeight(4);

  g.pushMatrix();
  g.translate(width/2, height/2);
  g.rotate(frameCount % rotationFrameCount * 2 * PI / rotationFrameCount);

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
      saveJSONObject(beziers.toJSONObject(), settingsFileNamer.next());
      break;
  }
}

void controllerChange(int channel, int number, int value) {
  beziers.controllerChange(channel, number, value);
  saveJSONObject(beziers.toJSONObject(), "settings.json");
}
