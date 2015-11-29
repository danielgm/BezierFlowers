
BezierFlower bezierFlower;
PGraphics gradientCanvas;
FileNamer fileNamer;

void setup() {
  size(640, 480, P2D);

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
}

void draw() {
  int numFlowers = 20;
  int rotationFrameCount = 2000;

  g.image(gradientCanvas, 0, 0);

  g.pushStyle();

  g.noFill();
  g.stroke(0xfff375b0);
  g.strokeWeight(4);

  g.pushMatrix();
  g.translate(width/2, height/2);
  g.rotate(frameCount % rotationFrameCount * 2 * PI / rotationFrameCount);

  bezierFlower
    .innerControlDistanceFactor(map(mouseX, 0, width, 0, 1))
    .outerControlDistanceFactor(map(mouseY, 0, height, 0, 1));

  for (int i = 0; i < numFlowers; i++) {
    g.pushMatrix();
    g.scale(1.7 * i / numFlowers);

    bezierFlower.draw(g);

    g.popMatrix();
  }

  g.popStyle();
  g.popMatrix();
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
