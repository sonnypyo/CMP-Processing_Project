//by 김민성

import processing.sound.*;

public class dokdoGameMain{
  AudioPlayer BGMplayer;
  //AudioPlayer fireballSoundPlayer;
  AudioPlayer coinSoundPlayer;
  PApplet main;
  public int coin = 200; // Initial amount of coin
  public int wave = 0;  // Current wave
  public boolean waveIsGoing = false; // Flag to check if a wave is in progress
  PImage dokdo;
  PImage rain;
  PImage noRain;
  PImage rainSnow;
  PImage snow;
  PImage weatherBackgorund;
  PImage cloud;
  PImage tower;
  PImage fireball;
  PImage ship;
  int WtBg = 0;
  float CdBg = 0;
  float windSpeed = 0;
  int windDirection = 0;
  int skyCondition = 0;
  int precipitation = 0;
    
  public ArrayList<DokdoButton> myButtons = new ArrayList<DokdoButton>(); // List of buttons
    
  ArrayList<MissileShooter> shooters; // List of missile shooters
  ArrayList<Missile> missiles; // List of missiles
  ArrayList<Monster> monsters; // List of monsters
  
  int[] monsterAmount = {20, 40, 60, 70, 70, 70, 70, 70};  // Number of monsters for each wave
  int[] monsterHP = {50, 80, 90, 100, 120, 140, 160, 180}; // Hit points for monsters in each wave
  int count = 0; // Current execution count
  int interval;  // Execution interval (in milliseconds)
  int lastTime;  // Last time the function was executed
  
  Monster noMonster = new Monster(850, 410, 100000000, 0, this, false);
  
  Weather weather = new Weather();
  GameManagementData GMdata;
  dokdoGameMain(PApplet main, GameManagementData GMdata){
    this.main = main;
    this.GMdata = GMdata;
  }
  
  public Weather getWeather() {
    return weather;
  }
  void DokdoSetup() {
    //size(800, 800);  // Set window size
    background(255);
    interval = 60000 / monsterAmount[0];// etermine execution interval by dividing 60 seconds by number of monsters
    lastTime = millis(); // Record current time
    
    myButtons.add(new DokdoButton(230, 510, 100, 1, 500, "Add shooter\n", 5, this, GMdata));
    myButtons.add(new DokdoButton(230+110*2, 510, 100, 1, 100, "Firerate\n", 100000, this, GMdata));
    myButtons.add(new DokdoButton(230+110, 510, 100, 1, 100, "Attack Power\n", 100000, this, GMdata));
    myButtons.add(new DokdoButton(350, 10, 100, 0, 0, "WAVE", 100, this, GMdata));
    shooters = new ArrayList<MissileShooter>();
    missiles = new ArrayList<Missile>();
    monsters = new ArrayList<Monster>();
    
    shooters.add(new MissileShooter(100, 300, 1000, 10, this)); // Starting missile shooter
    
    // Set dokdoMain for Weather object
    weather.setDokdoMain(this); // Set dokdoMain
    
    weather.requestJSON();
    dokdo = loadImage("asset_kms/dokdo.png");
    rain = loadImage("asset_kms/rain.png");
    cloud = loadImage("asset_kms/cloud.png");
    noRain = loadImage("asset_kms/noRain.png");
    rainSnow = loadImage("asset_kms/rainSnow.png");
    snow = loadImage("asset_kms/snow.png");
    tower = loadImage("asset_kms/tower.png");
    fireball = loadImage("asset_kms/fireball.png");
    ship = loadImage("asset_kms/ship.png");
    BGMplayer = new AudioPlayer(main, "asset_kms/waveSound.wav"); 
    BGMplayer.loop();
    BGMplayer.setVolume(0.3);
   
    //fireballSoundPlayer = new AudioPlayer(main, "asset_kms/fireballSound.wav");
    coinSoundPlayer = new AudioPlayer(main, "asset_kms/coinSound.wav");
  }
  public void addShooter(int level){ // Add shooters based on the level
    if(level==2) shooters.add(0, new MissileShooter(70, 270, 1000, shooters.get(shooters.size()-1).damage, this));
    if(level==3) shooters.add(0, new MissileShooter(130, 250, 1000, shooters.get(shooters.size()-1).damage, this));
    if(level==4) shooters.add(0, new MissileShooter(160, 270, 1000, shooters.get(shooters.size()-1).damage, this));
    if(level==5) shooters.add(0, new MissileShooter(50, 290, 1000, shooters.get(shooters.size()-1).damage, this));
  }
  void executeFunction(int totalExecutions) { // Execute function if the count is less than totalExecutions and time interval has passed
    if (count < totalExecutions && millis() - lastTime >= interval) {
      monsters.add(new Monster(850, 410, monsterHP[wave-1], 0.5f, this, true));
      
      lastTime = millis(); // Update last execution time
      count++; // Increase execution count
    }else if(count==totalExecutions&&monsters.size()==0){ // If all monsters are defeated
      waveIsGoing = false;
      count = 0; // Reset execution count
      interval = 60000 / monsterAmount[wave-1]; // Execution interval (in milliseconds)
    }
  }
  void DokdoDraw() {
    drawBackGround();
    
    drawUI();
    for(DokdoButton myButton:myButtons){
      myButton.update();
      myButton.display();
    }
    gamePlayDisplay();
    
    if(waveIsGoing){
      executeFunction(monsterAmount[wave-1]);
    }
    
    weather.drawForecastData(110, 1000-200-180);
  }
  void gamePlayDisplay(){
    // Missile firing and updating
    for(MissileShooter shooter: shooters){
      shooter.shoot(missiles, monsters);
    }
    for (int i = missiles.size() - 1; i >= 0; i--) {
      Missile missile = missiles.get(i);
      missile.update();
      // Draw missile
      if (!missile.destroyed) {
        image(fireball, missile.x, missile.y);
      }
  
      if (missile.destroyed) {
        missiles.remove(i); // Remove missile from the list if destroyed
      }
    }
    // Update and remove monsters
    for (int i = monsters.size() - 1; i >= 0; i--) {
      Monster monster = monsters.get(i);
      monster.update(); // Update monster position
      if (monster.destroyed) {
        monsters.remove(i); // Remove monster from the list if destroyed
        coinSoundPlayer.play();
      } else {
        if (!monster.destroyed) { // Draw only if the monster is not destroyed
           monster.display(); // Draw health bar for the monster that is not destroyed
          image(ship, monster.x - 25, monster.y - 25);
        }
      }
    }
  }
  void drawBackGround(){
    background(255);
     if(weatherBackgorund!=null){
      image(weatherBackgorund, 0, 0+WtBg);
      image(weatherBackgorund, 0, -800+WtBg++);
    }else{
      setWeatherInfo();
    }
    tint(255, 255*0.333*(skyCondition-1)==0?255*0.333*0.333:255*0.333*(skyCondition-1)); // cloud transpareny
    image(cloud, 0+CdBg, 0);
    image(cloud, 2000+CdBg, 0);
    image(cloud, -2000+CdBg, 0);
    noTint();
    
    CdBg+=(windSpeed*sin(radians(windDirection))*0.2); // wind speed & direction reflect to cloud speed & direction.
    if(WtBg==800) WtBg = 0;
    if(abs(CdBg)>=2000) CdBg = 0;
  }
  void drawUI(){
   
    noStroke();
    rectMode(CORNER);
    fill(0, 100, 250);
    rect(0, 435, 800, 340);
    for(MissileShooter shooter:shooters){
      image(tower, shooter.x -40, shooter.y-20);
    }
    image(dokdo, 0, 401);
    fill(0, 200, 200);
    rect(0, 1000-360-200, 220, 360);
    rect(220, 1000-300-200, 800-220, 500);
    
    // Display money
    textAlign(LEFT, TOP);
    
    fill(255, 204, 0); // Text color is yellow
    textSize(40);
    text("GOLD: " + coin, 20, 20);
      
  }
  public void setWeatherInfo(){
    windSpeed = weather.getWindSpeed();
    windDirection = weather.getWindDirection();
    skyCondition = weather.getSkyCondition();
    precipitation = weather.getPrecipitation();
   
    weatherBackgorund = precipitation == 0 ? noRain : (precipitation == 1||precipitation == 5 ? rain : (precipitation == 2 ||precipitation == 6? rainSnow : snow));
  }
}
