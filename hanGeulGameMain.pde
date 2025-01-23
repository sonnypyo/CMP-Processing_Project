//by 손준표

import gab.opencv.*; // Import OpenCV library
import processing.video.*; // Import video library
import java.awt.*; // AWT library (for using Rectangle)

public class hanGeulGameMain {
    PApplet main;
    GameManagementData GMdata;

    Capture video; // Declare video object
    OpenCV opencv; // Declare OpenCV object
    PImage imgSad, imgSmile, imgGood;  // Declare PImage objects
    PFont fontLarge, fontSmall, fontDes, fontMid;
    
    public Capture getVideo(){
      return video;
    }
    String[][] words = {
        {"훈민정음", "한민족음", "한글정음", "흥민정음"},
        {"고운", "버스", "바람", "마을"},
        {"세종대왕", "이순신", "신사임당", "장영실"},
        {"1443", "1445", "1446", "1450"}
    };

    String[] selectedWords = new String[4];  // Array to store selected words
    String[] description = {
        "한글의 원래 이름은?\n(What is the original name of Hangul?)",
        "순우리말이 아닌 것은?\n(What is not pure Korean?)",
        "한글을 만든 사람은?\n(Who created Hangul?)", 
        "훈민정음이 반포된 연도는 언제인가요?\n(In what year was Hunminjeongeum promulgated?)"
    };  

    String[] correctAnswers = {"훈민정음", "버스", "세종대왕", "1446"};  // Array of correct answers for each question
    
    boolean isCorrect = false;
    boolean selectionLocked = false;
    boolean gameStarted = false;
    int selectedOption = -1;
    int currentQuestion = 0;

    int startTime;
    int timeLimit = 5000;
    int remainingTime;

    int correctCount = 0;
    boolean gameEnded = false;
    boolean sadSJ = false;
    boolean goodSJ = false;
   
    public void detectclick(){
       if(sadSJ){
          GMdata.gameOver(); // Game over
       }else if(goodSJ){
         GMdata.hangeulClear(); // Game clear
       }
    }
    // Constructor: Takes PApplet and GameManagementData objects as parameters.
    hanGeulGameMain(PApplet main, GameManagementData GMdata) {
        this.main = main;
        this.GMdata = GMdata;
    }

    void hangeulSetup() {
        main.size(800, 800);  
        imgSad = main.loadImage("asset_sjp/SadSejong2.png");
        imgSmile = main.loadImage("asset_sjp/SmileSejong2.png");
        imgGood = main.loadImage("asset_sjp/GoodSejong2.png");

        fontLarge = main.createFont("NanumGothic", 180);  
        fontMid = main.createFont("NanumGothic", 100); 
        fontSmall = main.createFont("NanumGothic", 48);   
        fontDes = main.createFont("NanumGothic", 20);

        main.textAlign(main.CENTER, main.CENTER);  

        // Initialize video capture and face detection
        video = new Capture(main, 800, 800); 
        opencv = new OpenCV(main, 800, 800); 
        opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
        video.start(); 
    }

    void hangeulDraw() {
        if (gameEnded) {
            // Game over screen
            main.background(255);
            main.textFont(fontSmall);
            main.fill(0);
            if (correctCount > 3) {
                main.text("한글날을 잘 지켜주셨습니다! \n(Thank you for protecting Hangul Day!)", main.width / 2, main.height / 2 - 100);
                main.image(imgGood, main.width / 2 - 200, main.height / 2 - 20, 400, 400);  // Display success image
                goodSJ = true;
                
                return;
            } else {
                main.text("한글날을 다시 지켜주세여..\n(Please observe Hangul Day again)", main.width / 2, main.height / 2 - 100);
                main.image(imgSad, main.width / 2 - 200, main.height / 2 - 20, 400, 400);  // Display failure image
                sadSJ = true;
                
            }

            main.fill(200, 200, 255);
            main.rect(300, 650, 200, 80);
            main.fill(0);
            main.textFont(fontSmall);
            main.text("다시 시작", 400, 690);  // Restart button
            return;
        }
        
        main.background(255);  

        // Read the new frame from the video
        if (video.available()) {
            video.read(); // Check if the video stream is available and read the new frame
        }

        // Face detection and video processing
        opencv.loadImage(video); 
        main.image(video, 0, 0, main.width, main.height); 

        Rectangle[] faces = opencv.detect();  // Detect faces in the video frame
        for (int i = 0; i < faces.length; i++) {
            main.image(imgSmile, faces[i].x, faces[i].y, faces[i].width, faces[i].height); 
            checkFacePosition(faces[i]); // Check the position of each detected face to see if it corresponds to a selectable option
        }

        if (gameStarted) {
            remainingTime = timeLimit - (main.millis() - startTime); // Calculate remaining time for the game

            main.fill(0);
            main.textSize(48);
            if (remainingTime > 0) {
                main.text("남은 시간: " + (remainingTime / 1000) + "초", main.width / 2, 100);  // Display remaining time in seconds
            } else {
                main.text("시간 종료!", main.width / 2, 100);  // Display message for time up
                selectionLocked = true;
            }
        }

        if (!gameStarted) {
            main.textFont(fontMid);
            main.fill(255);
            main.text("Protect Hangul\n 한글을 지켜줘", 400, 200);

            main.fill(200, 200, 255);
            main.rect(300, 650, 200, 80); // Draw a rectangle for the start button
            main.fill(0);
            main.textFont(fontSmall);
            main.text("게임 시작", 400, 690); // Display "Start Game" text inside the button
        } else {
            // 게임 화면 처리
            main.textFont(fontDes);
            for (int i = 0; i < selectedWords.length; i++) {
                int xOffset = (i % 2 == 0) ? -150 : 150;  
                int yOffset = (i < 2) ? -150 : 50;  

                int rectWidth = 160;  
                int rectHeight = 60;  

                if (selectedOption == i) {
                    main.fill(0, 255, 0);
                } else {
                    main.fill(0);
                }

                main.text(selectedWords[i], main.width / 2 + xOffset, main.height / 2 + yOffset);
                main.noFill();
                main.stroke(0);
                main.rect(main.width / 2 + xOffset - rectWidth / 2, main.height / 2 + yOffset - rectHeight / 2, rectWidth, rectHeight);  
            }

            main.fill(240);
            main.rect(100, 600, 600, 150, 20);  
            main.fill(0);
            main.textAlign(main.LEFT, main.CENTER);  
            main.text(description[currentQuestion], 120, 650);  
            main.textAlign(main.CENTER, main.CENTER);

            main.fill(200, 200, 255);
            main.rect(300, 720, 200, 50); // Draw a rectangle for the "Next Question" button
            main.fill(0);
            main.textFont(fontSmall);
            main.text("다음 문제", 400, 745); // Display "Next Question" text inside the button
            
            if (selectedOption != -1 && selectionLocked) {
              if (isCorrect) {
                strokeWeight(1);
                fill(0, 255, 0);
                ellipse(width / 2, 200, 100, 100);  // Draw a circle (when the answer is correct)
                correctCount++; // Increment correct answer count
                
              } else {
                strokeWeight(5);
                fill(255, 0, 0);
                line(width / 2 - 50, 200 - 50, width / 2 + 50, 200 + 50); // Draw an X (when the answer is incorrect)
                line(width / 2 - 50, 200 + 50, width / 2 + 50, 200 - 50);
                strokeWeight(1);
              }
            }
        }
    }

    void checkFacePosition(Rectangle face) {
        if (selectionLocked) return;

        int faceCenterX = face.x + face.width / 2;
        int faceCenterY = face.y + face.height / 2;

        for (int i = 0; i < selectedWords.length; i++) {
            int xOffset = (i % 2 == 0) ? -150 : 150;
            int yOffset = (i < 2) ? -150 : 50;

            int rectWidth = 160;
            int rectHeight = 60;

            int x1 = main.width / 2 + xOffset - rectWidth / 2;
            int y1 = main.height / 2 + yOffset - rectHeight / 2;
            int x2 = x1 + rectWidth;
            int y2 = y1 + rectHeight;

            if (faceCenterX > x1 && faceCenterX < x2 && faceCenterY > y1 && faceCenterY < y2) {
                selectedOption = i;

                if (selectedWords[i].equals(correctAnswers[currentQuestion])) {
                    isCorrect = true;
                } else {
                    isCorrect = false;
                }

                break;
            }
        }
    }
    void hangeulmousePressed() {
      if (gameEnded) {
        // Handle the restart button on the ending screen
        if (mouseX > 300 && mouseX < 500 && mouseY > 650 && mouseY < 730) {
          gameEnded = false;
          correctCount = 0;
          currentQuestion = 0;
          selectedOption = -1;  // Reset selected option
          isCorrect = false;  // Reset correctness status
          selectionLocked = false; // Unlock selection
          gameStarted = true; // Start the game again
          
          // Initialize words for the first question
          for (int i = 0; i < selectedWords.length; i++) {
            selectedWords[i] = words[currentQuestion][i];
          }
          startTime = millis();  // Reset time for the new game
        }
      } else if (!gameStarted) {
        // Handle game start
        if (mouseX > 300 && mouseX < 500 && mouseY > 650 && mouseY < 730) {
          gameStarted = true;
          selectedOption = -1;  // Reset selected option
          isCorrect = false;  // Reset correctness status
          selectionLocked = false;  // Unlock selection
          
          // Initialize words for the first question
          for (int i = 0; i < selectedWords.length; i++) {
            selectedWords[i] = words[currentQuestion][i];
          }
          startTime = millis();  // Reset time for the new game
        }
      } else {
        // Handle "Next Question" button click
        if (mouseX > 300 && mouseX < 500 && mouseY > 720 && mouseY < 770) {
          currentQuestion++;
          if (currentQuestion < words.length) {
            selectedOption = -1;  // Reset selected option
            isCorrect = false;  // Reset correctness status
            selectionLocked = false;  // Unlock selection (allow user to make a new selection)
            
            // Initialize words for the next question
            for (int i = 0; i < selectedWords.length; i++) {
              selectedWords[i] = words[currentQuestion][i];
            }
            startTime = millis();  // Start the timer for the new question
          } else {
            // End the game if all questions have been answered
            gameStarted = false; // Set the game to not started state
            gameEnded = true;  // Change the game state to ended
          }
        }
      }
}

void captureEvent(Capture c) {
  c.read();  
}
    
}
