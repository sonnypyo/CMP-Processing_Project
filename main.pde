//by 김민성
import processing.sound.*;
dokdoGameMain dokdoMain;
armyGameMain armyMain;
hanGeulGameMain hanGeulMain;
policeGameMain policeMain;
GameManagementData GMdata = new GameManagementData();
ArrayList<MainBtn> mainBtns = new ArrayList<MainBtn>();
Boolean dokDoClear = false;
Boolean hangeulClear = false;
Boolean armyClear = false;
Boolean policeClear = false;

PImage mainBG;
PImage mainBGCleared;
PImage btn1;
PImage btn2;
PImage btn3;
PImage btn4;
PImage rock2;
PImage rock3;
PImage rock4;
PImage clearParticle;
boolean isClickHandled = true;
SoundFile congraturation;
void setup() {
    size(800, 800);  // Set the window size
    congraturation = new SoundFile(this, "asset_kms/Congratulations__You.wav");
    btn1 = loadImage("asset_kms/btn1.png");
    btn2 = loadImage("asset_kms/btn2.png");
    btn3 = loadImage("asset_kms/btn3.png");
    btn4 = loadImage("asset_kms/btn4.png");
    rock2 = loadImage("asset_kms/Rock2.png");
    rock3 = loadImage("asset_kms/Rock3.png");
    rock4 = loadImage("asset_kms/Rock4.png");
    clearParticle = loadImage("asset_kms/clearParticle.png");
    mainBtns.add(new MainBtn(168, 338, 90, "Army", GMdata, btn1));
    mainBtns.add(new MainBtn(258, 415, 90, "HanGeul", GMdata, rock2));
    mainBtns.add(new MainBtn(83, 566, 90, "Police", GMdata, rock3));
    mainBtns.add(new MainBtn(450, 570, 90, "DokDo", GMdata, rock4));
    mainBG = loadImage("asset_kms/mainBG.png");
    mainBGCleared = loadImage("asset_kms/mainBGCleared.png");
    armyMain = new armyGameMain(this, GMdata);
    hanGeulMain = new hanGeulGameMain(this , GMdata);
    policeMain = new policeGameMain(this, GMdata);
    dokdoMain = new dokdoGameMain(this, GMdata);
}
int plusY = 0;
boolean isloop = false;
void draw() {
    garbageClear();
    if(GMdata.mainScene) {
      if(mainBtns.size()==0){
        if(!isloop){
          congraturation.loop();
          isloop = true;
        }
        image(mainBGCleared, 0, 0);
        image(clearParticle, 0, 0+plusY);
        image(clearParticle, 0, -800+plusY);
        plusY+=5;
        if(plusY>=800){ plusY = 0; }
      }else{
        image(mainBG, 0, 0);
      }
        mainBtnManagement();
        
        processGameOver(); 
    }
    gamePlay();
}

void gamePlay() {
    if(GMdata.dokdoGamePlay) {
        if(GMdata.dokdoSetup) {
            dokdoMain.DokdoSetup();
            GMdata.dokdoSetup = false;
        }
        dokdoMain.DokdoDraw();
    }
    if(GMdata.armyGamePlay) {
        if(GMdata.armySetup) {
            armyMain.armySetup();
            GMdata.armySetup = false;
        }
        armyMain.ArmyDraw();
    }
    if(GMdata.policeGamePlay) {
        if(GMdata.policeSetup) {
            policeMain.policeSetup();
            GMdata.policeSetup = false;
        }
        policeMain.policeDraw();
    }
    if(GMdata.hangeulGamePlay) {
        if(GMdata.hangeulSetup) {
            hanGeulMain.hangeulSetup();
            GMdata.hangeulSetup = false;
        }
        hanGeulMain.hangeulDraw();
    }
}

void processGameOver() {
    if(GMdata.dokdoGamePlay) { // On game over and click to return to the main screen
        GMdata.dokdoGamePlay = false;
        dokdoMain.BGMplayer.stop(); // Stop BGM
        dokdoMain = new dokdoGameMain(this, GMdata);
    }
    if(GMdata.armyGamePlay) { // On game over and click to return to the main screen
        GMdata.armyGamePlay = false;
        armyMain.armyBgm.stop();
        armyMain = new armyGameMain(this, GMdata);
    }
    if(GMdata.policeGamePlay) { // On game over and click to return to the main screen
        GMdata.policeGamePlay = false;
        policeMain.Game_Music.stop();  
        policeMain.Siren.stop();
        policeMain = new policeGameMain(this, GMdata);
    }
    if(GMdata.hangeulGamePlay) { // On game over and click to return to the main screen
        GMdata.hangeulGamePlay = false;
        hanGeulMain.getVideo().stop();
        hanGeulMain.getVideo().dispose();
        hanGeulMain = new hanGeulGameMain(this, GMdata);
    }
}

void setBtnImage() {
    if(GMdata.stage == 2) {
        mainBtns.get(0).setImage(btn2);
    } else if(GMdata.stage == 3) {
        mainBtns.get(0).setImage(btn3);
    } else if(GMdata.stage == 4) {
        mainBtns.get(0).setImage(btn4);
    }
}

void garbageClear() {
    if(GMdata.dokdoGameIsClear && !dokDoClear) {
        dokdoMain.BGMplayer.stop(); // Stop BGM
        dokdoMain = null;
        for(int i = 0; i < mainBtns.size(); i++) {
            if(mainBtns.get(i).label.equals("DokDo")) {
                mainBtns.remove(i); // Remove button -> Prevent object creation
                setBtnImage();
            }
        }
        dokDoClear = true;
    }
    if(GMdata.hangeulGameIsClear && !hangeulClear) {
        hanGeulMain.getVideo().stop();
        hanGeulMain.getVideo().dispose();
        hanGeulMain = null;
        for(int i = 0; i < mainBtns.size(); i++) {
            if(mainBtns.get(i).label.equals("HanGeul")) {
                mainBtns.remove(i); // Remove button -> Prevent object creation
                setBtnImage();
            }
        }
        hangeulClear = true;
    }
    if(GMdata.policeGameIsClear && !policeClear) {
        policeMain.Game_Music.stop();
        policeMain.Siren.stop();
        policeMain = null;
        for(int i = 0; i < mainBtns.size(); i++) {
            if(mainBtns.get(i).label.equals("Police")) {
                mainBtns.remove(i); // Remove button -> Prevent object creation
                setBtnImage();
            }
        }
        policeClear = true;
    }
    if(GMdata.armyGameIsClear && !armyClear) {
        armyMain.armyBgm.stop();  
        armyMain = null;
        for(int i = 0; i < mainBtns.size(); i++) {
            if(mainBtns.get(i).label.equals("Army")) {
                mainBtns.remove(i); // Remove button -> Prevent object creation
                setBtnImage();
            }
        }
        armyClear = true;
    }
}

void mainBtnManagement() {
    for(MainBtn mainBtn : mainBtns) {
        switch(GMdata.stage) {
            case 1:
                if(mainBtn.label.equals("Army")) {
                    mainBtn.update();   
                }
                break;
            case 2:
                if(mainBtn.label.equals("HanGeul")) {
                    mainBtn.update();   
                }
                break;
            case 3:
                if(mainBtn.label.equals("Police")) {
                    mainBtn.update();   
                }
                break;
            case 4:
                if(mainBtn.label.equals("DokDo")) {
                    mainBtn.update();   
                }
                break;
        }
        mainBtn.display();
    }
}

void mousePressed() {
    if(GMdata.mainScene && isClickHandled) { // Handle clicks on the main screen
        for(MainBtn myButton : mainBtns) {
            myButton.handleClick();
        }
        isClickHandled = false;
    }
    if(GMdata.dokdoGamePlay && isClickHandled) { // Handle clicks in the Dokdo game
        for(DokdoButton myButton : dokdoMain.myButtons) {
            myButton.handleClick();
        }
        isClickHandled = false;
    }
    if(GMdata.hangeulGamePlay) { // Handle clicks for HanGeul
        hanGeulMain.hangeulmousePressed(); // Call mouse input handling method for HanGeul game
        hanGeulMain.detectclick();
        isClickHandled = false;
    }
    if(GMdata.armyGamePlay && isClickHandled) { // Handle clicks for Army Day
        armyMain.armyMousePressed();
        isClickHandled = false;
    }
    if(GMdata.policeGamePlay && isClickHandled) { // Handle clicks for Police
        policeMain.policeMousePressed();
        policeMain.detectClick();
        isClickHandled = false;
    }
    isClickHandled = false;
}

void mouseReleased() {
    isClickHandled = true; // Reset to allow click handling when the mouse button is released
}

void keyPressed() {
    if (key == ']') { // Pressing the ] key returns to the main screen
        GMdata.gameOver();
        background(255);
    }else if(key == 'c'){ // close game 
      noLoop();
      exit();
    }
    if(GMdata.hangeulGamePlay) { // Handle keyboard input for HanGeul
        // Additional logic can be added here
    }
    if(GMdata.armyGamePlay) { // Handle keyboard input for Army Day
        // Additional logic can be added here
    }
    if(GMdata.policeGamePlay) { // Handle keyboard input for Police
        // Additional logic can be added here
    }
}
