// Intersection Aggregate, {Software} Structures
// j.tarbell   May, 2004
// Albuquerque, New Mexico
// complexification.net

// commissioned by the Whitney ArtPort 
// collaboration with Casey Reas, Robert Hodgin, William Ngan 

// Processing 0085 Beta syntax update
// j.tarbell   April, 2005


// dimensions
int dim = 500;
int num = 100;
int time = 0;
int CENTER_RADIUS = 100;

Disc[] discs;

int maxpal = 512;
int numpal = 0;
color[] goodcolor = new color[maxpal];

// MAIN

void setup() {
  size(500,500,P3D);
//  size(dim,dim,P3D);
  ellipseMode(CENTER_RADIUS);
  takecolor("pollockShimmering.jpg");
  background(255);
  frameRate(30);
  
  discs = new Disc[num];

  // arrange linearly
  for (int i=0;i<num;i++) {
    float x = random(dim);
    float y = random(dim);
    float fy = 0;
    float fx = random(-1.2,1.2);
    float r = 5+random(55);
    discs[i] = new Disc(i,x,y,fx,fy,r);
  }
}

void draw() {
  // move discs
  for (int c=0;c<num;c++) {
    discs[c].move();
    discs[c].render();
  }
  time++;
}



// OBJECTS
class Disc {
  // index identifier
  int id;
  // position
  float x,y;
  // radius
  float r;
  // destination radius
  float dr;
  // velocity
  float vx,vy;

  // sand painters
  int numsands = 3;
  SandPainter[] sands = new SandPainter[numsands];

  Disc(int Id, float X, float Y, float Vx, float Vy, float R) {
    // construct
    id=Id;
    x=X;
    y=Y;
    vx=Vx;
    vy=Vy;
    r=0;
    dr=R;
    
    // create sand painters
    for (int n=0;n<numsands;n++) {
      sands[n] = new SandPainter();
    }
  }

  void reset(int Id, float X, float Y, float Vx, float Vy, float R) {
    // construct
    id=Id;
    x=X;
    y=Y;
    vx=Vx;
    vy=Vy;
    r=0;
    dr=R;
  }

  void draw() {
    stroke(0,50);
    noFill();
    ellipse(x,y,r,r);
  }

  void render() {
    // find intersecting points with all ascending discs
    for (int n=id+1;n<num;n++) {
      // find distance to other disc
      float dx = discs[n].x-x;
      float dy = discs[n].y-y;
      float d = sqrt(dx*dx+dy*dy);
      // intersection test
      if (d<(discs[n].r+r)) {
        // complete containment test
        if (d>abs(discs[n].r-r)) {
          // find solutions
          float a = (r*r - discs[n].r*discs[n].r + d*d ) / (2*d);
          
          float p2x = x + a*(discs[n].x - x)/d;
          float p2y = y + a*(discs[n].y - y)/d;
          
          float h = sqrt(r*r - a*a);
          
          float p3ax = p2x + h*(discs[n].y - y)/d;
          float p3ay = p2y - h*(discs[n].x - x)/d;
          
          float p3bx = p2x - h*(discs[n].y - y)/d;
          float p3by = p2y + h*(discs[n].x - x)/d;
          
          for (int s=0;s<numsands;s++) {
            sands[s].render(p3ax,p3ay,p3bx,p3by);
          }
        }
      }
    }
  }

  void move() {
    // add velocity to position
    x+=vx;
    y+=vy;
    // grow to destination radius
    if (r<dr) {
      r+=0.1;
    }
    // bound check
    if (x+r<0) x+=dim+r+r;
    if (x-r>dim) x-=dim+r+r;
    if (y+r<0) y+=dim+r+r;
    if (y-r>dim) y-=dim+r+r;
  }
}


class SandPainter {

  float p;
  color c;
  float g;

  SandPainter() {

    p = random(1.0);
    c = somecolor();
    g = random(0.01,0.1);
  }

  void render(float x, float y, float ox, float oy) {
    // draw painting sweeps

    g+=random(-0.050,0.050);
    float maxg = 0.22;
    if (g<-maxg) g=-maxg;
    if (g>maxg) g=maxg;
    p+=random(-0.050,0.050);
    if (p<0) p=0;
    if (p>1.0) p=1.0;

    float w = g/10.0;
    for (int i=0;i<11;i++) {
      float a = 0.1-i/110;
      stroke(red(c),green(c),blue(c),256*a);
      point(ox+(x-ox)*sin(p + sin(i*w)),oy+(y-oy)*sin(p + sin(i*w)));
      point(ox+(x-ox)*sin(p - sin(i*w)),oy+(y-oy)*sin(p - sin(i*w)));
    }
  }
}



// COLORING ROUTINES ----------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(numpal))];
}

void takecolor(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b,0,0);

  for (int x=0;x<b.width;x++){
    for (int y=0;y<b.height;y++) {
      color c = get(x,y);
      boolean exists = false;
      for (int n=0;n<numpal;n++) {
        if (c==goodcolor[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (numpal<maxpal) {
          goodcolor[numpal] = c;
          numpal++;
        }
      }
    }
  }
}

void takecolorOther(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b,0,0);

  for (int x=0;x<b.width;x++){
    for (int y=0;y<b.height;y++) {
      color c = get(x,y);
      boolean exists = false;
      for (int n=0;n<numpal;n++) {
        if (c==goodcolor[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (numpal<maxpal) {
          goodcolor[numpal] = c;
          numpal++;
        }
      }
    }
  }
  // pump black and white into palette
  for (int x=0;x<22;x++) {
    goodcolor[numpal]=#000000;
    numpal++;
    goodcolor[numpal]=#FFFFFF;
    numpal++;
  }
}


// j.tarbell   May, 2004
// Albuquerque, New Mexico
