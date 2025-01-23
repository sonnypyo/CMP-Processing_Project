//by 김민성
//dokdo game's fire ball
class Missile {
  float x, y;
  int damage;
  ArrayList<Monster> monsters;
  Monster target;
  boolean destroyed = false;
  dokdoGameMain DG;

  Missile(float x, float y, int damage, ArrayList<Monster> monsters, dokdoGameMain DG) {
    this.x = x;
    this.y = y;
    this.damage = damage;
    this.monsters = monsters;
    this.target = findClosestMonster();
    this.DG = DG;
  }

  // Method to find the closest monster
  Monster findClosestMonster() {
    Monster closest = null;
    float closestDist = Float.MAX_VALUE;
    for (Monster monster : monsters) {
      if (!monster.destroyed) { // Only find monsters that are not destroyed
        float dist = dist(x, y, monster.x, monster.y);
        if (dist < closestDist) {
          closestDist = dist;
          closest = monster;
        }
      }
    }
    return closest;
  }

  // Method to update missile movement
  void update() {
    // If the target is destroyed or nonexistent, find a new target
    if (target == null || target.destroyed) {
      target = findClosestMonster();
      if (target == null) {
        // Set to aim towards the coordinates (0, 0) if no target
        target = DG.noMonster; // Set to fly towards a temporary target
      }
    }

    // While moving towards the temporary target, check if there are new monsters
    if (target == DG.noMonster) {
      Monster newTarget = findClosestMonster();
      if (newTarget != null) {
        target = newTarget; // If a new monster is found, set it as the target
      }
    }

    if (target != null && !destroyed) {
      // Steer towards the current target's position
      float angle = atan2(target.y - y, target.x - x);
      x += cos(angle) * 5; // Control speed
      y += sin(angle) * 5;

      // Remove missile if it goes out of bounds
      if (x < 0 || x > 820 || y < 0 || y > 820) {
        destroyed = true;
      }

      // Detect collision with the monster
      if (dist(x, y, target.x, target.y) < 25 && !(target.x == 0 && target.y == 0)) { 
        // Only if colliding with the monster and the target is not (0, 0)
        target.takeDamage(damage);
        destroyed = true;
      }
    }
  }


}
