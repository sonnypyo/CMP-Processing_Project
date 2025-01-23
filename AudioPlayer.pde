//by 김민성
//A class that only manages the sound of Dokdo Game
import processing.sound.*;
import processing.core.PApplet;

public class AudioPlayer {
  SoundFile soundFile;
  float volume = 1.0; // Set default volume to 1.0

  // Constructor that takes a PApplet object and audio file name
  public AudioPlayer(PApplet main, String fileName) {
    // Initialize SoundFile object using the PApplet object
    soundFile = new SoundFile(main, fileName);
    soundFile.amp(volume); // Set initial volume
  }

  // Method to play audio once
  public void play() {
    soundFile.play();
  }

  // Method to loop audio playback
  public void loop() {
    soundFile.loop();
  }

  // Method to stop audio playback
  public void stop() {
    soundFile.stop();
  }

  // Method to adjust volume
  public void setVolume(float newVolume) {
    volume = constrain(newVolume, 0.0, 1.0); // Limit volume range between 0.0 and 1.0
    soundFile.amp(volume); // Set volume for SoundFile
  }
}
