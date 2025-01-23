//by 윤지석

import processing.sound.*;

public class armyGameMain{
  PImage img1, img2;  // Load two images
  PImage bgImage;     // Variable for background image
  PImage gunfireImage; // Variable for bullet image
  PImage[] extraImages = new PImage[4]; // Array for 4 additional images
  PApplet main;
  ArrayList<FloatingImage> images;  // List to hold multiple images
  ArrayList<TemporaryGunfire> gunfires; // List to hold bullets
  ArrayList<TemporaryImage> temporaryImages; // List for additional images
  
  int lastSpawnTime = 0;  // Time when the last image was created
  int lastExtraImageTime = 0; // Last creation time for additional images
  int score = 0;  // Score variable
  boolean gameCleared = false;  // Variable to track game cleared status
  boolean gameOver = false;  // Variable to track game over status
  
  AudioIn mic;  // Variable for microphone input
  Amplitude amp;
  float micThreshold = 0.3;  // Sound detection threshold
  
  SoundFile armyBgm;
  SoundFile PlayerGunSound;
  SoundFile EnemyGunSound;
  SoundFile deadSound;
  
  GameManagementData GMdata;
  armyGameMain(PApplet main, GameManagementData GMdata){
    this.main = main;
    this.GMdata = GMdata;
  }
  
  
  void armySetup() {
    size(800, 800);  // Set window size
    img1 = loadImage("asset_yjs/enemySol2.png");
    img2 = loadImage("asset_yjs/enemySol.png");
    bgImage = loadImage("asset_yjs/Background.jpeg");  // Load background image
    gunfireImage = loadImage("asset_yjs/gunfire.png"); // Load bullet image
  
    // Load 4 additional images
    for (int i = 0; i < 4; i++) {
      extraImages[i] = loadImage("asset_yjs/extra" + i + ".png");
      extraImages[i].resize(100, 100); // Resize images
    }
  
    // Resize main images
    img1.resize(100, 100);
    img2.resize(100, 100);
    gunfireImage.resize(50, 50);
  
    images = new ArrayList<FloatingImage>();  // Initialize list
    gunfires = new ArrayList<TemporaryGunfire>(); // Initialize bullet list
    temporaryImages = new ArrayList<TemporaryImage>(); // Initialize additional image list
  
    // Create first image
    images.add(new FloatingImage(img1, img2));
  
    // Initialize microphone
    mic = new AudioIn(main, 0);
    mic.start();
    
    amp = new Amplitude(main);
    amp.input(mic);
    
    armyBgm = new SoundFile(main, "asset_yjs/battlefield.wav");
    PlayerGunSound = new SoundFile(main, "asset_yjs/PlayerGun.mp3");
    EnemyGunSound = new SoundFile(main, "asset_yjs/EnemyGun.mp3");
    deadSound = new SoundFile(main, "asset_yjs/deadSound.mp3");
    
    armyBgm.loop();
  }
  
  void ArmyDraw() {
    image(bgImage, 0, 0, width, height);  // Draw background image
  
    if (score >= 300) gameCleared = true; // Game cleared status
    if (score <= -50) gameOver = true;    // Game over status if score is below -50
  
    // Create new image every 5 seconds
    if(!gameCleared){
      if (millis() - lastSpawnTime > 5000 && !gameCleared) {
        images.add(new FloatingImage(img1, img2));
        lastSpawnTime = millis();
      }
      
      // Randomly create one of the 4 additional images every 8 seconds
      if (millis() - lastExtraImageTime > 8000) {
        PImage randomImage = extraImages[(int) random(4)];
        temporaryImages.add(new TemporaryImage(randomImage, random(width - 100), random(height - 100)));
        lastExtraImageTime = millis();
      }
    }
    
    // Update and draw all images
    for (FloatingImage img : images) {
      img.update();
      img.display();
    }
  
    // Update and draw all bullets
    for (int i = gunfires.size() - 1; i >= 0; i--) {
      TemporaryGunfire gunfire = gunfires.get(i);
      gunfire.update();
      gunfire.display();
      if (gunfire.isExpired()) gunfires.remove(i);  // Remove expired bullets
    }
  
    // Update and draw all additional images
    for (int i = temporaryImages.size() - 1; i >= 0; i--) {
      TemporaryImage tempImg = temporaryImages.get(i);
      tempImg.update();
      tempImg.display();
      if (tempImg.isExpired()) {
        score -= 30; // Subtract 30 points when the image disappears
        deadSound.play();
        temporaryImages.remove(i); // Remove expired images
      }
    }
  
    // Sound detection handling
    detectSound();
  
    // Display score
    if(!gameCleared){
      fill(0);
      textSize(32);
      textAlign(LEFT, TOP);
      text("Score: " + score, 10, 30);
    }
   
  
    // Display game clear message
    if (gameCleared) {
      fill(255);
      textSize(48);
      textAlign(CENTER, CENTER);
      text("Game Clear!", width / 2, height / 2);
      armyBgm.stop();
      GMdata.armyClear();
    }
    
    if (gameOver){
      fill(255);
      textSize(48);
      textAlign(CENTER, CENTER);
      text("Game Over!", width / 2, height / 2);
      armyBgm.stop();
      GMdata.gameOver();
    }
  }
  
  void armyMousePressed() {
    // Handle click on FloatingImage objects
    for (int i = images.size() - 1; i >= 0; i--) {
      FloatingImage img = images.get(i);
      if (img.checkClick(mouseX, mouseY)) {
        images.remove(i);
        score += 10;  // Add points to score
        break;
      }
    }
  
    // Handle click on TemporaryImage objects
    for (int i = temporaryImages.size() - 1; i >= 0; i--) {
      TemporaryImage tempImg = temporaryImages.get(i);
      if (tempImg.checkClick(mouseX, mouseY)) {
        score -= 50;  // Set score to 50 points
        temporaryImages.remove(i);
        break;
      }
    }
  
    // Add bullet at clicked position
    gunfires.add(new TemporaryGunfire(mouseX - gunfireImage.width / 2, mouseY - gunfireImage.height / 2));
    PlayerGunSound.play();
  }
  
  // Sound detection function
  void detectSound() {
    float volume = amp.analyze();
    if (volume > micThreshold) {
      if (temporaryImages.size() > 0) {
        temporaryImages.remove(0);  // Remove the first additional image
        score += 30;  // Add 30 points to score
      }
    }
  }
  
  // Define FloatingImage class
  class FloatingImage {
    PImage img1, img2, currentImage;
    float x, y;
    int state = 0;
    int changeTime;
    boolean visible = true;
  
    FloatingImage(PImage img1, PImage img2) {
      this.img1 = img1;
      this.img2 = img2;
      currentImage = img1;
      changeTime = millis();
      x = random(width - img1.width);
      y = random(height-200 - img1.height);
    }
  
    void update() {
      int elapsedTime = millis() - changeTime;
      if (state == 0 && elapsedTime > 3000) {
        currentImage = img2;
        EnemyGunSound.play();
        score -= 20;
        state = 1;
        changeTime = millis();
      } else if (state == 1 && elapsedTime > 500) {
        currentImage = img1;
        state = 0;
        changeTime = millis();
      }
    }
  
    void display() {
      if (visible) image(currentImage, x, y);
    }
  
    boolean checkClick(int mx, int my) {
      return visible && mx > x && mx < x + currentImage.width &&
             my > y && my < y + currentImage.height;
    }
  }
  
  // Define TemporaryGunfire class
  class TemporaryGunfire {
    float x, y;
    int lifespan = 300;
    int startTime;
  
    TemporaryGunfire(float x, float y) {
      this.x = x;
      this.y = y;
      startTime = millis();
    }
  
    void update() {}
  
    void display() {
      image(gunfireImage, x, y);
    }
  
    boolean isExpired() {
      return millis() - startTime > lifespan;
    }
  }
  
  // Define TemporaryImage class
  class TemporaryImage {
    PImage image;
    float x, y;
    int lifespan = 2000;  // Disappears after 2 seconds
    int startTime;
  
    TemporaryImage(PImage image, float x, float y) {
      this.image = image;
      this.x = x;
      this.y = y;
      startTime = millis();
    }
  
    void update() {}
  
    void display() {
      image(image, x, y);
    }
  
    boolean isExpired() {
      return millis() - startTime > lifespan;
    }
  
    boolean checkClick(int mx, int my) {
      return mx > x && mx < x + image.width &&
             my > y && my < y + image.height;
    }
  }
}
