
/*

 Dithered Gradients coded by Dan Gries, rectangleworld.com.
 These gradients are dithered using the Floyd-Steinberg algorithm.
 
 Usage:
 *****************************************************************************
 Linear Gradient
 
 To create a linear gradient with start point (x0,y0) and end point (x1,y1):
  LinearGradient grad = new LinearGradient(x0,x1,y0,y1);
  
 Add color stops:
  grad.addColorStop(ratio, color);
  ratio should be between 0 and 1, representing how far from beginning to end points this color will be reached.
  
 Filling a rectangle with this gradient - two versions:
   To fill a rectangle in the main sketch display with the gradient:
     grad.fillRect(rectX, rectY, rectW, rectH, dither);
   To fill part of a PGraphics object pg with the gradient:
     grad.fillRect(pg, rectX, rectY, rectW, rectH, dither);
       rectX, rectY, rectW, rectH define the rectangle,
       boolean dither argument sets whether to use dithering.
 
 *****************************************************************************
 Radial Gradient
 
 Radial gradients are defined by a beginning and ending circle. To create a readial gradient
 with start circle center (x0,y0), radius rad0, end circle (x1,y1), radius r1:
   RadialGradient grad = new RadialGradient(x0, y0, rad0, x1, y1, rad1);
   
 Add color stops in the same way as linear gradients (see above)
 Fill a rectangle (in main display or PGraphics object), dithered or not, in the same way as linear gradients (see above).
 
 
 */


class LinearGradient {
  float x0;
  float x1;
  float y0;
  float y1;
  ArrayList<ColorStop> colorStops;

  LinearGradient(float _x0, float _y0, float _x1, float _y1) {
    x0 = _x0;
    y0 = _y0;
    x1 = _x1;
    y1 = _y1;
    colorStops = new ArrayList<ColorStop>();
  }

  void addColorStop(float ratio, int col) {
    if ((ratio < 0) || (ratio > 1)) {
      return;
    }
    ColorStop newStop = new ColorStop(ratio, col);

    if ((ratio >= 0) && (ratio <= 1)) {
      if (colorStops.size() == 0) {
        colorStops.add(newStop);
      }
      else {
        int i = 0;
        boolean found = false;
        int len = colorStops.size();
        //search for proper place to put stop in order.
        while ( (!found) && (i<len)) {
          found = (ratio <= colorStops.get(i).ratio);
          if (!found) {
            i++;
          }
        }
        //add stop - remove next one if duplicate ratio
        if (!found) {
          //place at end
          colorStops.add(newStop);
        }
        else {
          if (ratio == colorStops.get(i).ratio) {
            //replace
            colorStops.set(i, newStop);
          }
          else {
            //insert
            colorStops.add(i, newStop);
          }
        }
      }
    }
  }


  //createGradRect returns PGraphics object. In second version, you pass a PGraphics object which gets filled.

  //overloaded - version without PGraphics fills main display.
  void fillRect(float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGradRect(rectX0, rectY0, rectW, rectH, dither);
    image(gradRect, rectX0, rectY0);
  }

  void fillRect(PGraphics pg, float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGradRect(rectX0, rectY0, rectW, rectH, dither);
    pg.beginDraw();
    pg.image(gradRect, rectX0, rectY0);
    pg.endDraw();
  }

  private PGraphics createGradRect(float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGraphics(rectW, rectH, P2D);

    if (colorStops.size() == 0) {
      return gradRect;
    }

    gradRect.loadPixels();
    
    int i;
    int len = rectW*rectH;

    float nearestValue;
    float quantError;
    float x;
    float y;

    float vx = x1 - x0;
    float vy = y1 - y0;
    float vMagSquareRecip = 1/(vx*vx+vy*vy);
    float ratio;

    float r, g, b;
    float r0, g0, b0, r1, g1, b1;
    int col0, col1;
    float ratio0, ratio1;
    float f;
    int stopNumber;
    boolean found;
    float q;

    ArrayList<Float> rBuffer = new ArrayList<Float>();
    ArrayList<Float> gBuffer = new ArrayList<Float>();
    ArrayList<Float> bBuffer = new ArrayList<Float>();

    float weightR = 7.0/16.0;
    float weightLD = 3.0/16.0;
    float weightD = 5.0/16.0;
    float weightRD = 1.0/16.0;

    int destX;
    int destY;

    //first complete color stops with 0 and 1 ratios if not already present
    if (colorStops.get(0).ratio != 0) {
      ColorStop newStop = new ColorStop(0, colorStops.get(0).col); 

      colorStops.add(0, newStop);
    }
    if (colorStops.get(colorStops.size()-1).ratio != 1) {
      ColorStop newStop = new ColorStop(1, colorStops.get(colorStops.size()-1).col);
      colorStops.add(newStop);
    }

    //create float valued gradient
    for (i = 0; i < len; i++) {

      x = rectX0 + (i % rectW);
      y = rectY0 + floor(((float) i)/((float) rectW));

      ratio = (vx*(x - x0) + vy*(y - y0))*vMagSquareRecip;
      if (ratio < 0) {
        ratio = 0;
      }
      else if (ratio > 1) {
        ratio = 1;
      }

      //find out what two stops this is between
      if (ratio == 1) {
        stopNumber = colorStops.size()-1;
      }
      else {
        stopNumber = 0;
        found = false;
        while (!found) {
          found = (ratio < colorStops.get(stopNumber).ratio);
          if (!found) {
            stopNumber++;
          }
        }
      }

      //calculate color.
      col0 = colorStops.get(stopNumber-1).col;
      r0 = (col0 >> 16) & 0xFF;
      g0 = (col0 >> 8) & 0xFF;
      b0 = (col0) & 0xFF;
      col1 = colorStops.get(stopNumber).col;
      r1 = (col1 >> 16) & 0xFF;
      g1 = (col1 >> 8) & 0xFF;
      b1 = (col1) & 0xFF;
      ratio0 = colorStops.get(stopNumber-1).ratio;
      ratio1 = colorStops.get(stopNumber).ratio;

      f = (ratio-ratio0)/(ratio1-ratio0);
      r = r0 + (r1 - r0)*f;
      g = g0 + (g1 - g0)*f;
      b = b0 + (b1 - b0)*f;

      //set color as float values in buffer arrays
      rBuffer.add(r);
      gBuffer.add(g);
      bBuffer.add(b);
    }


    //While converting floats to integer valued color values, apply Floyd-Steinberg dither.
    for (i = 0; i<len; i++) {
      if ((dither) && (i<len-rectW)&&(i % rectW != 0)&&(i % rectW != rectW-1)) {
        nearestValue = floor(rBuffer.get(i));
        quantError =rBuffer.get(i) - nearestValue;
        rBuffer.set(i+1, rBuffer.get(i+1) + weightR*quantError);
        rBuffer.set(i-1+rectW, rBuffer.get(i-1+rectW) + weightLD*quantError);
        rBuffer.set(i + rectW, rBuffer.get(i + rectW) + weightD*quantError);
        rBuffer.set(i+1 + rectW, rBuffer.get(i+1 + rectW) + weightRD*quantError);

        nearestValue = floor(gBuffer.get(i));
        quantError =gBuffer.get(i) - nearestValue;
        gBuffer.set(i+1, gBuffer.get(i+1) + weightR*quantError);
        gBuffer.set(i-1+rectW, gBuffer.get(i-1+rectW) + weightLD*quantError);
        gBuffer.set(i + rectW, gBuffer.get(i + rectW) + weightD*quantError);
        gBuffer.set(i+1 + rectW, gBuffer.get(i+1 + rectW) + weightRD*quantError);

        nearestValue = floor(bBuffer.get(i));
        quantError =bBuffer.get(i) - nearestValue;
        bBuffer.set(i+1, bBuffer.get(i+1) + weightR*quantError);
        bBuffer.set(i-1+rectW, bBuffer.get(i-1+rectW) + weightLD*quantError);
        bBuffer.set(i + rectW, bBuffer.get(i + rectW) + weightD*quantError);
        bBuffer.set(i+1 + rectW, bBuffer.get(i+1 + rectW) + weightRD*quantError);
      }
      gradRect.pixels[i] = 0xFF000000 | floor(rBuffer.get(i)) << 16 | floor(gBuffer.get(i)) << 8 | floor(bBuffer.get(i));
    }

    gradRect.updatePixels();

    return gradRect;
  }
}

class RadialGradient {
  float x0;
  float x1;
  float y0;
  float y1;
  float rad0;
  float rad1;
  ArrayList<ColorStop> colorStops;

  RadialGradient(float _x0, float _y0, float _rad0, float _x1, float _y1, float _rad1) {
    x0 = _x0;
    y0 = _y0;
    x1 = _x1;
    y1 = _y1;
    rad0 = _rad0;
    rad1 = _rad1;
    colorStops = new ArrayList<ColorStop>();
  }

  void addColorStop(float ratio, int col) {
    if ((ratio < 0) || (ratio > 1)) {
      return;
    }
    ColorStop newStop = new ColorStop(ratio, col);

    if ((ratio >= 0) && (ratio <= 1)) {
      if (colorStops.size() == 0) {
        colorStops.add(newStop);
      }
      else {
        int i = 0;
        boolean found = false;
        int len = colorStops.size();
        //search for proper place to put stop in order.
        while ( (!found) && (i<len)) {
          found = (ratio <= colorStops.get(i).ratio);
          if (!found) {
            i++;
          }
        }
        //add stop - remove next one if duplicate ratio
        if (!found) {
          //place at end
          colorStops.add(newStop);
        }
        else {
          if (ratio == colorStops.get(i).ratio) {
            //replace
            colorStops.set(i, newStop);
          }
          else {
            //insert
            colorStops.add(i, newStop);
          }
        }
      }
    }
  }

  //createGradRect returns PGraphics object. In second version, you pass a PGraphics object which gets filled.

  //overloaded - version without PGraphics fills main display.
  void fillRect(float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGradRect(rectX0, rectY0, rectW, rectH, dither);
    image(gradRect, rectX0, rectY0);
  }

  void fillRect(PGraphics pg, float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGradRect(rectX0, rectY0, rectW, rectH, dither);
    pg.beginDraw();
    pg.image(gradRect, rectX0, rectY0);
    pg.endDraw();
  }

  private PGraphics createGradRect(float rectX0, float rectY0, int rectW, int rectH, boolean dither) {
    PGraphics gradRect = createGraphics(rectW, rectH, P2D);

    if (colorStops.size() == 0) {
      return gradRect;
    }

    gradRect.loadPixels();

    int i;
    int len = rectW*rectH;

    float nearestValue;
    float quantError;
    float x;
    float y;
    float ratio;
    float red, green, blue;
    float r0, g0, b0, r1, g1, b1;
    int col0, col1;
    float ratio0, ratio1;
    float f;
    int stopNumber;
    boolean found;
    float q;

    ArrayList<Float> rBuffer = new ArrayList<Float>();
    ArrayList<Float> gBuffer = new ArrayList<Float>();
    ArrayList<Float> bBuffer = new ArrayList<Float>();

    float a, a2, b, c, discrim;
    float dx, dy;

    float xDiff = x1 - x0;
    float yDiff = y1 - y0;
    float rDiff = rad1 - rad0;
    a = rDiff*rDiff - xDiff*xDiff - yDiff*yDiff;
    a2 = 2*a;
    float rConst1 = 2*rad0*(rad1-rad0);
    float r0Square = rad0*rad0;

    float weightR = 7.0/16.0;
    float weightLD = 3.0/16.0;
    float weightD = 5.0/16.0;
    float weightRD = 1.0/16.0;

    int destX;
    int destY;

    //first complete color stops with 0 and 1 ratios if not already present
    if (colorStops.get(0).ratio != 0) {
      ColorStop newStop = new ColorStop(0, colorStops.get(0).col); 

      colorStops.add(0, newStop);
    }
    if (colorStops.get(colorStops.size()-1).ratio != 1) {
      ColorStop newStop = new ColorStop(1, colorStops.get(colorStops.size()-1).col);
      colorStops.add(newStop);
    }

    //create float valued gradient
    for (i = 0; i < len; i++) {

      x = rectX0 + (i % rectW);
      y = rectY0 + floor(((float) i)/((float) rectW));

      dx = x - x0;
      dy = y - y0;
      b = rConst1 + 2*(dx*xDiff + dy*yDiff);
      c = r0Square - dx*dx - dy*dy;
      discrim = b*b-4*a*c;

      if (discrim >= 0) {
        ratio = (-b + sqrt(discrim))/a2;

        if (ratio < 0) {
          ratio = 0;
        }
        else if (ratio > 1) {
          ratio = 1;
        }

        //find out what two stops this is between
        if (ratio == 1) {
          stopNumber = colorStops.size()-1;
        }
        else {
          stopNumber = 0;
          found = false;
          while (!found) {
            found = (ratio < colorStops.get(stopNumber).ratio);
            if (!found) {
              stopNumber++;
            }
          }
        }

        //calculate color.
        col0 = colorStops.get(stopNumber-1).col;
        r0 = (col0 >> 16) & 0xFF;
        g0 = (col0 >> 8) & 0xFF;
        b0 = (col0) & 0xFF;
        col1 = colorStops.get(stopNumber).col;
        r1 = (col1 >> 16) & 0xFF;
        g1 = (col1 >> 8) & 0xFF;
        b1 = (col1) & 0xFF;
        ratio0 = colorStops.get(stopNumber-1).ratio;
        ratio1 = colorStops.get(stopNumber).ratio;

        f = (ratio-ratio0)/(ratio1-ratio0);
        red = r0 + (r1 - r0)*f;
        green = g0 + (g1 - g0)*f;
        blue = b0 + (b1 - b0)*f;
      }
      else {
        col0 = colorStops.get(0).col;
        r0 = (col0 >> 16) & 0xFF;
        g0 = (col0 >> 8) & 0xFF;
        b0 = (col0) & 0xFF;
        red = r0;
        green = g0;
        blue = b0;
      }

      //set color as float values in buffer arrays
      rBuffer.add(red);
      gBuffer.add(green);
      bBuffer.add(blue);
    }

    //While converting floats to integer valued color values, apply Floyd-Steinberg dither.
    for (i = 0; i<len; i++) {
      if ((dither) && (i<len-rectW)&&(i % rectW != 0)&&(i % rectW != rectW-1)) {
        nearestValue = floor(rBuffer.get(i));
        quantError =rBuffer.get(i) - nearestValue;
        rBuffer.set(i+1, rBuffer.get(i+1) + weightR*quantError);
        rBuffer.set(i-1+rectW, rBuffer.get(i-1+rectW) + weightLD*quantError);
        rBuffer.set(i + rectW, rBuffer.get(i + rectW) + weightD*quantError);
        rBuffer.set(i+1 + rectW, rBuffer.get(i+1 + rectW) + weightRD*quantError);

        nearestValue = floor(gBuffer.get(i));
        quantError =gBuffer.get(i) - nearestValue;
        gBuffer.set(i+1, gBuffer.get(i+1) + weightR*quantError);
        gBuffer.set(i-1+rectW, gBuffer.get(i-1+rectW) + weightLD*quantError);
        gBuffer.set(i + rectW, gBuffer.get(i + rectW) + weightD*quantError);
        gBuffer.set(i+1 + rectW, gBuffer.get(i+1 + rectW) + weightRD*quantError);

        nearestValue = floor(bBuffer.get(i));
        quantError =bBuffer.get(i) - nearestValue;
        bBuffer.set(i+1, bBuffer.get(i+1) + weightR*quantError);
        bBuffer.set(i-1+rectW, bBuffer.get(i-1+rectW) + weightLD*quantError);
        bBuffer.set(i + rectW, bBuffer.get(i + rectW) + weightD*quantError);
        bBuffer.set(i+1 + rectW, bBuffer.get(i+1 + rectW) + weightRD*quantError);
      }
      gradRect.pixels[i] = 0xFF000000 | floor(rBuffer.get(i)) << 16 | floor(gBuffer.get(i)) << 8 | floor(bBuffer.get(i));
    }

    gradRect.updatePixels();

    return gradRect;
  }
}

class ColorStop {
  float ratio;
  int col;
  ColorStop(float _ratio, int _col) {
    ratio = _ratio;
    col = _col;
  }
}