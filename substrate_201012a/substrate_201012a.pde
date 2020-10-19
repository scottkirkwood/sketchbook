// Substrate Watercolor
// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net

// Processing 0085 Beta syntax update
// j.tarbell   April, 2005
import java.util.Map;
import javafx.util.Pair; 

int dimx = 1024;
int dimy = 768;
int num = 0;
int maxnum = 500;
int startingCracks = 10;
int filenumber = 1;

// grid of cracks
int[] cgrid;
Crack[] cracks;

// color parameters
int maxpal = 512;
int numpal = 0;
color[] goodcolor = new color[maxpal];

boolean dynamic = true;

// sand painters
SandPainter[] sands;

// MAIN METHODS ---------------------------------------------

void setup() {
  size(1024, 768, P2D);
  //size(dimx,dimy,P3D);
  background(255);
  //takecolor("pollockShimmering.jpg");
  //takecolor("monet-kunstdruck.jpg");
  takecolor("richter-abstract-painting.jpg");
  cgrid = new int[dimx*dimy];
  cracks = new Crack[maxnum];

  if (!dynamic) {
    noLoop();
  }
  begin();
}

void draw() {
  for (int i=0; i < (dynamic? 1 : 1000); i++) {
    // crack all cracks
    for (int n=0; n < num; n++) {
      cracks[n].move();
    }
  }
}

void mousePressed() {
  //begin();
  save("substrate-" + nf(filenumber) + ".png");
  filenumber++;
}


// METHODS --------------------------------------------------

void makeCrack() {
  if (num <  maxnum) {
    // make a new crack instance
    cracks[num] = new Crack();
    num++;
  }
}


void begin() {
  // erase crack grid
  for (int y=0; y < dimy; y++) {
    for (int x=0; x < dimx; x++) {
      cgrid[y*dimx+x] = 10001;
    }
  }
  // make random crack seeds
  for (int k=0; k < 16; k++) {
    int i = int(random(dimx*dimy - 1));
    cgrid[i] = int(random(360));
  }

  // make just three cracks
  num=0;
  for (int k=0; k < startingCracks; k++) {
    makeCrack();
  }
  background(255);
}



// COLOR METHODS ----------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(numpal))];
}


void takecolor(String filename) {
  PImage b;
  b = loadImage(filename);
  image(b, 0, 0);
  HashMap<Integer, Integer> hash = new HashMap<Integer, Integer>();

  for (int x=0; x < b.width; x++) {
    for (int y=0; y < b.height; y++) {
      color c = get(x, y);
      if (hash.containsKey(c)) {
        hash.put(c, hash.get(c) + 1);
      } else {
        hash.put(c, 1);
      }
    }
  }
  numpal = -1;
  for (Integer e : hash.keySet()) {
    numpal++;
    goodcolor[numpal] = e;
    if (numpal >= maxpal - 1) {
      break;
    }
  }
}


// OBJECTS -------------------------------------------------------

class Crack {
  float x, y;
  float t;    // direction of travel in degrees

  // sand painter
  SandPainter sp;

  Crack() {
    // find placement along existing crack
    findStart();
    sp = new SandPainter();
  }

  void findStart() {
    // pick random point
    int px=0;
    int py=0;

    // shift until crack is found
    boolean found=false;
    int timeout = 0;
    while ((!found) || (timeout++>1000)) {
      px = int(random(dimx));
      py = int(random(dimy));
      if (cgrid[py*dimx+px] < 10000) {
        found = true;
      }
    }

    if (found) {
      // start crack
      int a = cgrid[py*dimx+px];
      if (random(100)<50) {
        a-=90+int(random(-2, 2.1));
      } else {
        a+=90+int(random(-2, 2.1));
      }
      startCrack(px, py, a);
    } else {
      println("timeout: "+timeout);
    }
  }

  void startCrack(int X, int Y, int T) {
    x=X;
    y=Y;
    t=T;//%360;
    x+=0.61*cos(t*PI/180);
    y+=0.61*sin(t*PI/180);
  }

  void move() {
    // continue cracking
    x+=0.42*cos(t*PI/180);
    y+=0.42*sin(t*PI/180); 

    // bound check
    float z = 0.33;
    int cx = int(x + random(-z, z));  // add fuzz
    int cy = int(y + random(-z, z));

    // draw sand painter
    regionColor();

    // draw black crack
    stroke(0, 85);
    point(x+random(-z, z), y+random(-z, z));


    if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
      // safe to check
      if ((cgrid[cy*dimx+cx]>10000) || (abs(cgrid[cy*dimx+cx]-t)<5)) {
        // continue cracking
        cgrid[cy*dimx+cx]=int(t);
      } else if (abs(cgrid[cy*dimx+cx]-t)>2) {
        // crack encountered (not self), stop cracking
        findStart();
        makeCrack();
      }
    } else {
      // out of bounds, stop cracking
      findStart();
      makeCrack();
    }
  }

  void regionColor() {
    // start checking one step away
    float rx=x;
    float ry=y;
    boolean openspace=true;

    // find extents of open space
    while (openspace) {
      // move perpendicular to crack
      rx+=0.81*sin(t*PI/180);
      ry-=0.81*cos(t*PI/180);
      int cx = int(rx);
      int cy = int(ry);
      if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
        // safe to check
        if (cgrid[cy*dimx+cx]>10000) {
          // space is open
        } else {
          openspace=false;
        }
      } else {
        openspace=false;
      }
    }
    // draw sand painter
    sp.render(rx, ry, x, y);
  }
}

class SandPainter {
  color c; // Color
  float g; // Grain

  SandPainter() {
    c = somecolor();
    g = random(0.01, 0.1);
  }

  void render(float x, float y, float ox, float oy) {
    // modulate gain
    g += random(-0.050, 0.050);
    float maxg = 1.0;
    if (g < 0) g=0;
    if (g > maxg) g=maxg;

    // calculate grains by distance
    //int grains = int(sqrt((ox-x)*(ox-x)+(oy-y)*(oy-y)));
    int grains = 64;

    // lay down grains of sand (transparent pixels)
    float w = g/(grains-1);
    for (int i=0; i<grains; i++) {
      float a = 0.1 - i/(grains*10.0);
      stroke(red(c), green(c), blue(c), a*256);
      point(ox + (x-ox)*sin(sin(i*w)), oy + (y - oy)*sin(sin(i*w)));
    }
  }
}

// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net
