//by 김민성

public class GameManagementData{
  int stage = 1;
  boolean mainScene = true;//main scene
  
  boolean dokdoSetup = false;// Dokdo
  boolean dokdoGamePlay = false;
  boolean dokdoGameIsClear = false;
  
  //hangeul
  boolean hangeulSetup = false;
  boolean hangeulGamePlay = false;
  boolean hangeulGameIsClear = false;
  
  //army
  boolean armySetup = false;
  boolean armyGamePlay = false;
  boolean armyGameIsClear = false;
  
  //police
  boolean policeSetup = false;
  boolean policeGamePlay = false;
  boolean policeGameIsClear = false;
  
  public void dokdoClear(){
    dokdoGamePlay=false;
    mainScene = true;
    dokdoGameIsClear =true;
    stage++;
  }
  public void hangeulClear(){
    hangeulGamePlay=false;
    mainScene = true;
    hangeulGameIsClear =true;
    stage++;  
  }
  public void armyClear(){
    armyGamePlay=false;
    mainScene = true;
    armyGameIsClear =true;
    stage++;
  }
  public void policeClear(){
    policeGamePlay=false;
    mainScene = true;
    policeGameIsClear =true;
    stage++;
  }
  public void convertToDokdo(){
    mainScene = false;
    dokdoSetup = true;
    dokdoGamePlay = true;
  }
  public void convertToArmy(){
    mainScene = false;
    armySetup = true;
    armyGamePlay = true;
  }
  public void convertToHanGeul(){
    mainScene = false;
    hangeulSetup = true;
    hangeulGamePlay = true;
  }
  public void convertToPolice(){
    mainScene = false;
    policeSetup = true;
    policeGamePlay = true;
  }
  public void gameOver(){// Methods to be used in common across all games
    mainScene = true;
  }
}
