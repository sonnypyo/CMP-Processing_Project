//by 김민성
// dokdo gmae's monster
class Monster {
  float x, y;
  int hp;
  int maxHp;
  boolean destroyed = false;
  float speed; // Monster's movement speed
  boolean isMonster = true;
  dokdoGameMain DG;
  Monster(float x, float y, int hp, float speed, dokdoGameMain DG, boolean isMonster) {
    this.x = x;
    this.y = y;
    this.hp = hp;
    this.speed = speed;
    this.DG = DG;
    maxHp = hp;
    this.isMonster = isMonster;
  }

  // Method to take damage
  void takeDamage(int damage) {
    if(isMonster){
      hp -= damage;
    }
    if (hp <= 0) {
      destroyed = true; // Destroyed when HP is 0 or less
      DG.coin += maxHp; // Add reward money for destruction
    }
  }

  // Update monster's position (moves only to the left)
  void update() {
    x -= speed; // Decrease x coordinate to move left

    // Handle the case where the monster goes beyond the screen boundary
    if (x < -25) {
      destroyed = true; // Destroy the monster if it goes off-screen
    }
  }

  // Draw the monster's health bar
  void display() { 
    // Draw health bar background (white background with a black border)
    stroke(0); // Black border
    fill(255); // White background
    rect(x - 25, y - 40, 50, 8); // Draw health bar background above the monster

    // Draw health gauge (red)
    float healthWidth = map(hp, 0, maxHp, 0, 50); // Calculate gauge width based on health
    noStroke();
    fill(255, 0, 0); // 빨간색
    rect(x - 25, y - 40, healthWidth, 8); // Draw gauge based on current health

    if (x - 25 <= 220) {
      println("GameOver");
      hp = 0;
      GMdata.gameOver();
    }
  }
}
