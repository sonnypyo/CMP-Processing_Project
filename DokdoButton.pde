//by 김민성

public class DokdoButton {
  float x, y, size;
  int level;
  int maxlevel;
  int price;
  String label;
  boolean isOvered = false;
  boolean isClicked = false;
  dokdoGameMain DG;
  GameManagementData GMdata;
  DokdoButton(float x, float y, float size, int level, int price, String label, int maxlevel, dokdoGameMain DG, GameManagementData GMdata) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.level = level;
    this.price = price;
    this.label = label;
    this.DG = DG;
    this.maxlevel = maxlevel;
    this.GMdata = GMdata;
  }

  // Method to display the button on the screen
  void display() {
    if(!label.equals("WAVE")){
      // Change color based on whether the mouse is over the button
      if (isOvered) {
        fill(200); // Darker gray when mouse is over
      } else {
        fill(255); // White in default state
      }
  
      stroke(0); // Black border
      strokeWeight(2);
      rect(x, y, size, size); // Draw square button
  
      fill(0); // Black text
      textAlign(CENTER, CENTER);
      textSize(16);
      
      if(level==maxlevel){
        text(label + " Lv.Max", x + size / 2, y + size / 2); 
      }else{
        text(label + " Lv." + level, x + size / 2, y + size / 2); // 버튼 내부 텍스트 
      }
      
      fill(255, 204, 0); // Yellow color for price text
      textSize(14);
      text("Price: " + price, x + size / 2, y + size + 20); // Display price below the button
      }else if(label.equals("WAVE")){
      if(DG.waveIsGoing){
        noStroke();
        fill(0, 0);
      }else{
        // Change color based on mouse being over the button and wave progress
        if (isOvered) {
          fill(200, 50, 50); // Slight color change when mouse is over
        } else {
          fill(200, 0, 0);   // Default state
        }
        stroke(0); // Black border
      }
      strokeWeight(2);
      rect(x, y, size, size/2); // Draw square button
      fill(0); // Black text
      textAlign(CENTER, CENTER);
      textSize(16);
      if(DG.waveIsGoing) text(label +" "+ DG.wave+"/8", x + size / 2, (y + size / 2)/2); // Text inside button
      else {
        text(label +" "+ DG.wave+"/8", x + size / 2, (y + size / 2)/2);
        text("Next", x + size / 2, (y + size / 2)-9);
      }  
    }
  }
  
  // Check if the button is clicked
  boolean isMouseOver() {
    return mouseX > x && mouseX < x + size && mouseY > y && mouseY < y + size;
  }

  // Update mouse state
  void update() {
    isOvered = isMouseOver();
  }

  // Method to handle button click
  void handleClick() {
    switch (label) {
      case "WAVE":
         if(DG.waveIsGoing){
            isClicked = false; 
         }else{
            if(isOvered) {
              isClicked = true;
              if(DG.wave==8){
                //게임 클리어
                GMdata.dokdoClear();
            }else{
                DG.wave++;
                DG.waveIsGoing = true;
              }
            }
         }
         break;
      case "Add shooter\n":
      if(isOvered) {
        if(level<5&&price<=DG.coin){
          level++;
          DG.coin-=price;
          if(level==2) price = 3000;
          if(level==3) price = 13000;
          if(level==4) price = 20000;
          DG.addShooter(level);
        }
      }
        break;
      case "Attack Power\n":
      if(isOvered) {
        if(price<=DG.coin){
          level++;
          DG.coin-=price;
          price = int(price*1.5f);
          for(MissileShooter shooter:DG.shooters){
              shooter.damage += 2;
              println(shooter.damage);
            }
          }
        }
        break;
      case "Firerate\n":
      if(isOvered) {
          if(price<=DG.coin){
          level++;
          DG.coin-=price;
          price = int(price*1.5f);
          for(MissileShooter shooter:DG.shooters){
              shooter.fireRate -= 50;
              println(shooter.fireRate);
            }
          }
      }
        break;
      default:
        println("Unknown fruit!");
        break;
    }
  }
}
