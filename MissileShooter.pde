//by 김민성
//for dokdo game
class MissileShooter {
  AudioPlayer fire;
  float x, y;
  int fireRate;
  int damage;
  int timer = 0;
 dokdoGameMain DG;
  MissileShooter(float x, float y, int fireRate, int damage,  dokdoGameMain DG) {
    this.x = x;
    this.y = y;
    this.fireRate = fireRate; // Firing interval
    this.damage = damage; // Missile damage
    this.DG = DG;
    fire = new AudioPlayer(DG.main, "asset_kms/fireballSound.wav");
    fire.setVolume(0.5);
  }

  // Method to shoot missiles
  void shoot(ArrayList<Missile> missiles, ArrayList<Monster> monsters) {
    if (millis() - timer > fireRate && DG.waveIsGoing) {
      timer = millis();
      missiles.add(new Missile(x, y, damage, monsters, DG));
      fire.play();
      fire.setVolume(0.5);
    }
  }
}
