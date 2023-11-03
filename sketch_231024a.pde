int w = 480;
int h = w;
int cSiz = 3;   // cell size
int pCnt = 500; // calculation count
Labo lab;

void settings() {
  size(w, h);
}

void setup() {
  noLoop();
  lab = new Labo(cSiz);
  lab.init();
  for (int i = 0; i < pCnt; i++) {
    lab.proceed();
  }
  lab.observe();
}

// ... (Rest of your code remains unchanged)


class Labo {
  int cellSize;
  int matrixW;
  int matrixH;
  float diffU;
  float diffV;
  Cell[][] cells;

  Labo(int _cSiz) {
    cellSize = _cSiz;
    matrixW = floor(width / cellSize);
    matrixH = floor(height / cellSize);
    diffU = 0.9;
    diffV = 0.1;
    cells = new Cell[matrixW][matrixH];
  }

  void init() {
    for (int x = 0; x < matrixW; x++) {
      cells[x] = new Cell[matrixH];
      for (int y = 0; y < matrixH; y++) {
        cells[x][y] = new Cell(
          map(x, 0, matrixW, 0.03, 0.12),   // feed
          map(y, 0, matrixH, 0.045, 0.055), // kill
          1,                                // u
          (random(1.0) < 0.1) ? 1 : 0      // v
        );
      }
    }
  }

  void proceed() {
    // calculate Laplacian
    Cell[] nD = new Cell[4]; // neighbors on diagonal
    Cell[] nH = new Cell[4]; // neighbors on vertical and horizontal
    
    for (int x = 0; x < matrixW; x++) {
      for (int y = 0; y < matrixH; y++) {
        // set neighbors
        nD[0] = cells[max(x-1, 0)][max(y-1, 0)];
        nD[1] = cells[max(x-1, 0)][min(y+1, matrixH-1)];
        nD[2] = cells[min(x+1, matrixW-1)][max(y-1, 0)];
        nD[3] = cells[min(x+1, matrixW-1)][min(y+1, matrixH-1)];
        nH[0] = cells[max(x-1, 0)][y];
        nH[1] = cells[x][max(y-1, 0)];
        nH[2] = cells[x][min(y+1, matrixH-1)];
        nH[3] = cells[min(x+1, matrixW-1)][y];

        // Laplacian
        Cell c = cells[x][y];
        float sum = 0.0;
        for (int i = 0; i < 4; i++) {
          sum += nD[i].valU * 0.05 + nH[i].valU * 0.2;
        }
        sum -= c.valU;
        c.lapU = sum;

        sum = 0.0;
        for (int i = 0; i < 4; i++) {
          sum += nD[i].valV * 0.05 + nH[i].valV * 0.2;
        }
        sum -= c.valV;
        c.lapV = sum;
      }
    }

    // reaction-diffusion
    for (int x = 0; x < matrixW; x++) {
      for (int y = 0; y < matrixH; y++) {
        Cell c = cells[x][y];
        float reaction = c.valU * c.valV * c.valV;
        float inflow = c.feed * (1.0 - c.valU);
        float outflow = (c.feed + c.kill) * c.valV;
        c.valU = c.valU + diffU * c.lapU - reaction + inflow;
        c.valV = c.valV + diffV * c.lapV + reaction - outflow;
        c.standardization();
      }
    }
  }

  void observe() {
    background(0);
    for (int x = 0; x < matrixW; x++) {
    for (int y = 0; y < matrixH; y++) {
      float u = cells[x][y].valU;
      float v = cells[x][y].valV;
      
      // Dynamic color based on values of u and v
      color c = lerpColor(color(255, 0, 0), color(0, 0, 255), u);
      fill(c);
      
      float cx = x * cellSize;
      float cy = y * cellSize;
      rect(cx, cy, cellSize, cellSize);
    }
  }
    noStroke();
    for (int x = 0; x < matrixW; x++) {
      for (int y = 0; y < matrixH; y++) {
        int cx = x * cellSize;
        int cy = y * cellSize;
        float cs = cells[x][y].valU * cellSize;
        rect(cx, cy, cs, cs);
      }
    }
  }
}

class Cell {
  float feed; 
  float kill;
  float valU;
  float valV;
  float lapU;
  float lapV;

  Cell(float _f, float _k, float _u, float _v) {
    feed = _f;
    kill = _k;
    valU = _u;
    valV = _v;
    lapU = 0;
    lapV = 0;
  }

  void standardization() {
    valU = constrain(valU, 0, 1);
    valV = constrain(valV, 0, 1);
  }
}
