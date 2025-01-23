//by 채희준

import processing.sound.*;

public class policeGameMain{
  PApplet main;

  // Maze width, height, and block size
  int cols = 40, rows = 40;
  int w = 20;
  // Maze function
  int[][] maze = new int[cols][rows];
  boolean[][] visited = new boolean[cols][rows];
  // Object creation
  int numObjects = 50;
  Criminal [] Criminals = new Criminal[numObjects];
  Criminal selectedCriminal;
  // View radius
  float viewRadius = 1000;
  // Images
  PGraphics mazeGraphics;
  PImage start_img;
  PImage clear_img;
  PImage over_img;
  PImage Character_img;
  // Game management
  boolean gameStarted = false, gameClear = false, gameOver = false, hideScreen = false;
  int startTime, hideStartTime;
  int displayDuration = 1000;
  int GameOver = 0;
  // Sounds
  SoundFile Game_Music, Siren, Radio, Nope, Laughter;
  
  GameManagementData GMdata;
  policeGameMain(PApplet main, GameManagementData GMdata){
    this.main = main;
    this.GMdata = GMdata;
  }
  
  void policeSetup() {
    // Sound creation
    Game_Music = new SoundFile(main, "asset_chj/Game_Music.mp3");
    Siren = new SoundFile(main, "asset_chj/Siren.mp3");
    Nope = new SoundFile(main, "asset_chj/Nope.mp3");
    Radio = new SoundFile(main, "asset_chj/Radio.mp3");
    Laughter = new SoundFile(main, "asset_chj/Laughter.mp3");
    Game_Music.play();
    // Image creation
    start_img = loadImage("asset_chj/The Pursuit of a Criminal.jpg");
    clear_img = loadImage("asset_chj/Catch the Criminal.jpg");
    over_img = loadImage("asset_chj/Criminal.jpg");
    Character_img = loadImage("asset_chj/Character.png");
    // Create maze
    mazeGraphics = createGraphics(width, height);
    setEdgesAsWalls();
    generateMaze(1, 1);
    // Randomly generate object positions
    for (int i = 0; i < numObjects; i++) {
      int startX = int(random(1, cols - 1)) * w;
      int startY = int(random(1, rows - 1)) * w;
      // Ensure the mover is not placed on a wall
      while (maze[startX / w][startY / w] == 0) {
        startX = int(random(1, cols - 1)) * w;
        startY = int(random(1, rows - 1)) * w;
      }
      Criminals[i] = new Criminal(startX, startY);
    }
    // Determine the criminal
    int select = int(random(Criminals.length));
    selectedCriminal = Criminals[select];
    // Extend the time to display the initial image
    startTime = millis();
  }
  boolean gameClear2 = false;
  boolean gameOver2 = false;
  void detectClick(){
    if(gameClear2){
      GMdata.policeClear();
    }else if(gameOver2){
      GMdata.gameOver();
    }
  }
  void policeDraw() {
    if (gameClear) {
      image(clear_img, 0, 0, width, height);
       gameClear2=true;
    } else if(gameOver){
      image(over_img, 0, 0, width, height);
       gameOver2=true;   
    }else if (millis() - startTime < displayDuration) {
      image(start_img, 0, 0, width, height);
    } else if (hideScreen) {
      if (millis() - hideStartTime > displayDuration) {
        hideScreen = false;
      } else {
        background(0);
      }
    } else {
      Game_Display();
    }
  }
  // Draw the criminal montage
  void SelectCriminalDisplay() {
    fill(255);
    rect((cols - 1) * w, 0, w, w); // White background at the top right
    
    fill(selectedCriminal.objectColor);
    ellipse((cols - 1) * w + w / 2, w / 2, w / 2, w / 2); // Montage
  }
  
  void Game_Display() {
    background(0);
  
    mazeGraphics.beginDraw();
    mazeGraphics.background(0);
   // Draw the maze
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (maze[i][j] == 0) {
          mazeGraphics.fill(0);
        } else {
          mazeGraphics.fill(255);
        }
        mazeGraphics.rect(i * w, j * w, w, w);
      }
    }
    // Draw objects
    for (Criminal criminal : Criminals) {
      criminal.move();
      criminal.display(mazeGraphics);
    }
    
    mazeGraphics.endDraw();
    // Mask the screen
    PGraphics maskGraphics = createGraphics(width, height); 
    maskGraphics.beginDraw();
    maskGraphics.fill(255);
    maskGraphics.ellipse(mouseX, mouseY, viewRadius, viewRadius);
    maskGraphics.endDraw();
  
    mazeGraphics.mask(maskGraphics); 
    image(mazeGraphics, 0, 0);
  
    SelectCriminalDisplay();
  }
  
  class Criminal {
    float x, y;
    float speedX, speedY;
    color objectColor;
    
    Criminal(float x, float y) {
      this.x = x;
      this.y = y;
      setRandomDirection();
      objectColor = color(random(255), random(255), random(255));
    }
    // Set object speed
    void setRandomDirection() {
      speedX = random(-1, 1);
      speedY = random(-1, 1);
      if (speedX == 0 && speedY == 0) {
        setRandomDirection();
      }
    }
    
    void move() {
      float nextX = x + speedX;
      float nextY = y + speedY;
      
      int gridX = int(nextX / w);
      int gridY = int(nextY / w);
      
      if (gridX >= 1 && gridX < cols - 1 && gridY >= 1 && gridY < rows - 1) {
        if (maze[gridX][gridY] == 1) {
          x = nextX;
          y = nextY;
        } else {
          setRandomDirection();
        }
      } else {
        setRandomDirection();
      }
    }
    // Draw object
    void display(PGraphics pg) {
      pg.imageMode(CENTER);
      pg.image(Character_img, x, y, w * 1.5, w * 3);
      pg.fill(objectColor);
      pg.ellipse(x - w * 0.1, y - w * 0.5 , w * 1.5 / 2.5, w * 3 / 10);
      pg.imageMode(CORNER);
    }
  }
  // Randomly generate the maze
  void generateMaze(int x, int y) {
    visited[x][y] = true;
    maze[x][y] = 1;
  
    int[][] neighbors = {
      {x - 2, y},
      {x + 2, y},
      {x, y - 2},
      {x, y + 2}
    };
  
    for (int i = neighbors.length - 1; i > 0; i--) {
      int j = int(random(i + 1));
      int[] temp = neighbors[i];
      neighbors[i] = neighbors[j];
      neighbors[j] = temp;
    }
  
    for (int[] neighbor : neighbors) {
      int nx = neighbor[0];
      int ny = neighbor[1];
  
      if (nx >= 1 && nx < cols - 1 && ny >= 1 && ny < rows - 1 && !visited[nx][ny]) {
        maze[(x + nx) / 2][(y + ny) / 2] = 1;
        generateMaze(nx, ny);
      }
    }
  }
  // Draw the maze edges
  void setEdgesAsWalls() {
    for (int i = 0; i < cols; i++) {
      maze[i][0] = 0;
      maze[i][rows - 1] = 0;
    }
  
    for (int j = 0; j < rows; j++) {
      maze[0][j] = 0;
      maze[cols - 1][j] = 0;
    }
  }
  
  void policeMousePressed() {
    if (mouseButton == LEFT) {
      for (Criminal criminal : Criminals) {
        if (dist(mouseX, mouseY, criminal.x, criminal.y) < w / 2) { // When selecting a criminal
          if (criminal == selectedCriminal) {
            gameClear = true;
            Game_Music.stop();
            Siren.play();
            Radio.play();
          } else {
            hideScreen = true;
            hideStartTime = millis();
            Nope.play();
            GameOver = GameOver + 1; // 5 attempts
            if (GameOver == 5){
              gameOver = true;
              Game_Music.stop();
              Laughter.play();
            }
          }
        }
      }
    }
  }
}
