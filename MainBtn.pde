//by 김민성
// only for main scene`s button
public class MainBtn {
  float x, y, size;
  String label;
  boolean isOvered = false;
  boolean isClicked = false;
  PImage btnImg;
  GameManagementData GMdata;

  MainBtn(float x, float y, float size, String label, GameManagementData GMdata, PImage btnImg) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.label = label;
    this.GMdata = GMdata;
    this.btnImg = btnImg;
  }

  void setImage(PImage img){
    btnImg = img;
  }
  
  // Method to draw the button on the screen
  void display() {
    
      // Change color depending on whether the mouse is over the button
      if (isOvered) {
        //fill(200); // Display a slightly darker gray when mouse is over
      } else {
        //fill(255); // Display white in the default state
      }
  
      noStroke();
      fill(244, 236, 228);
      strokeWeight(2);
      rectMode(CORNER);
      rect(x, y, size, size); // Draw square button
      image(btnImg, x, y);
      if (isOvered) {
        fill(0, 76);
        ellipse(x+45, y+45, 80, 80); 
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

  // Method to check if the button has been clicked
  void handleClick() {
    switch (label) {
      case "DokDo":
        if(isOvered){
          GMdata.convertToDokdo();
        }
        break;
      case "Army":
        if(isOvered){ 
          GMdata.convertToArmy();  
      }
        break;
      case "HanGeul":
        if(isOvered){
          GMdata.convertToHanGeul();
        }
        break;
      case "Police":
        if(isOvered) {
          GMdata.convertToPolice();
        }
        break;
      default:
        println("Unknown fruit!");
        break;
    }
  }
}
