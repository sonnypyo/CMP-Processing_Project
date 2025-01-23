//by 김민성

import http.requests.*;  // Import the httpRequests library
import processing.data.JSONObject;  // Import the JSON processing library
import java.util.Calendar;

public class Weather{
  PFont font;  // Variable for font
  // Declare global variables
  JSONObject weatherData;
  String nearestFcstTime = "";
  float temp = 5;
  float windSpeed = 5;
  int windDirection = 5;
  int skyCondition = 5;
  int precipitation = 5;
  String timeStr;
  String currentTime;
  boolean jsonRequested = false;
  dokdoGameMain dokdoMain;
  public void setDokdoMain(dokdoGameMain dokdoMain) { // Set the dokdoGameMain instance
      this.dokdoMain = dokdoMain;
  }
  public float getWindSpeed(){ // Get wind speed
    return windSpeed;
  }
  public int getWindDirection(){ // Get wind direction
    return windDirection;
  }
  public int getSkyCondition(){ // Get sky condition
    return skyCondition;
  }
 public int getPrecipitation(){ // Get precipitation information
    return precipitation;
  }
void extractForecast(String currentTime) { // Extract forecast data from JSON
  try{
     if (weatherData == null) {
        println("weatherData is null. Requesting JSON data...");
        requestJSON();
     } else {
      JSONObject body = weatherData.getJSONObject("response").getJSONObject("body");
      JSONObject items = body.getJSONObject("items");
      JSONArray itemArray = items.getJSONArray("item");
          
      int currentHour = Integer.parseInt(currentTime.substring(0, 2));
      int currentMinute = Integer.parseInt(currentTime.substring(2, 4));

      // If the current time is on the hour, move to the next hour
      if (currentMinute == 0) {
          currentHour += 1;  // Move to the next hour
      } else if (currentMinute > 0) {
          // If more than 30 minutes have passed, move to the next hour
          currentHour += 1;  // Move to the next hour
      }
      
      // Reset to 00 if it goes beyond 24 hours
      if (currentHour == 24) {
          currentHour = 0;
      }
      
      // Set rqtime to the next hour (always "00 minutes")
      String rqtime = String.format("%02d00", currentHour);
    
      // Extract the closest forecast data from the JSON array
      for (int i = itemArray.size()-1; i >= 0; i--) {
        JSONObject item = itemArray.getJSONObject(i);
        String category = item.getString("category");
        String fcstTime = item.getString("fcstTime");
        
        nearestFcstTime = fcstTime;
         
        if (fcstTime.equals(rqtime)) {
          if (category.equals("T1H")) temp = item.getFloat("fcstValue");
          if (category.equals("WSD")) windSpeed = item.getFloat("fcstValue");
          if (category.equals("VEC")) windDirection = item.getInt("fcstValue");
          if (category.equals("SKY")) skyCondition = item.getInt("fcstValue");
          if (category.equals("PTY")) precipitation = item.getInt("fcstValue");
        }
      }
     }
    } catch (NullPointerException e) {
      temp = 0;
      windSpeed = 0;
      windDirection = 0;
      skyCondition = 0;
      precipitation = 0;// No data around midnight
    }
    dokdoMain.setWeatherInfo();
    
}

  public void requestJSON(){
  Calendar calendar = Calendar.getInstance();
    int year = calendar.get(Calendar.YEAR);
    int month = calendar.get(Calendar.MONTH) + 1; // Calendar.MONTH starts from 0, so add 1
    int day = calendar.get(Calendar.DAY_OF_MONTH);
    int hour = calendar.get(Calendar.HOUR_OF_DAY);
    int minute = calendar.get(Calendar.MINUTE);
    // Create date string (YYYYMMDD)
    String dateStr = String.format("%04d%02d%02d", year, month, day);

    int halfHour = (hour * 60 + minute) / 30; // Divide into 30-minute intervals
    int adjustedHalfHour = halfHour - 2; // Adjust by -2 for the request
    if (adjustedHalfHour < 0) {
        adjustedHalfHour += 48; // Adjust for 24-hour format
    }
    int adjustedHour = adjustedHalfHour / 2; // Divide by 30-minute intervals
    int adjustedMinute = (adjustedHalfHour % 2) * 30; // Convert remainder to minutes
    // Create time string
    timeStr = String.format("%02d%02d", adjustedHour, adjustedMinute);
    print(timeStr);
    // Create font (SansSerif 16pt)
    font = createFont("SansSerif", 16);
    textFont(font);  // Set font
    // Set parameters for API request
    String serviceKey = "W%2Bvsq1SUkmb4Lk%2FWlXMR7ZZc2049Mmt5mXCHkUPTnn%2FBtkdTuUgW2%2B7EguhzJvVYvYK0aocwynSpqEuqhFAmRw%3D%3D";  // API 인증키
    String pageNo = "1";        // Page number
    String numOfRows = "60";    // Number of data per page
    String dataType = "JSON";   // Data type (JSON)
    String baseDate = dateStr;  // Base date (yyyyMMdd)
    dateStr = "20241025";       // For testing, hardcoded date
    String baseTime = timeStr;  // Base time (HHmm)
    String nx = "144";          // Grid x-coordinate
    String ny = "123";          // Grid y-coordinate
    
    // Construct API request URL
    String baseUrl = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst";
    String requestUrl = baseUrl + "?"
      + "serviceKey=" + serviceKey + "&"
      + "pageNo=" + pageNo + "&"
      + "numOfRows=" + numOfRows + "&"
      + "dataType=" + dataType + "&"
      + "base_date=" + baseDate + "&"
      + "base_time=" + baseTime + "&"
      + "nx=" + nx + "&"
      + "ny=" + ny;
    // Send HTTP GET request
    GetRequest getRequest = new GetRequest(requestUrl);
    getRequest.send();
    //println(getRequest.getContent());
    
    // Get JSON response data
    String response = getRequest.getContent();
    weatherData = parseJSONObject(response);
    // Extract the nearest forecast information
    extractForecast(timeStr);
}
  // Function to visualize the forecast data
  public void drawForecastData(int x, int y) {
    Calendar calendar = Calendar.getInstance();
    int hour = calendar.get(Calendar.HOUR_OF_DAY);
    int minute = calendar.get(Calendar.MINUTE);

    // Check if the current time is on the hour or half-hour
    boolean isTopOfHourOrHalfHour = (minute == 0 || minute == 30);

    // Create date string
    int halfHour = (hour * 60 + minute) / 30; // Divide into 30-minute intervals
    int adjustedHalfHour = halfHour - 2;  // Adjust for the request
    if (adjustedHalfHour < 0) {
        adjustedHalfHour += 48; // Adjust for 24-hour format
    }
    int adjustedHour = adjustedHalfHour / 2; // Divide by 30-minute intervals
    int adjustedMinute = (adjustedHalfHour % 2) * 30; // Convert remainder to minutes
    
    currentTime = String.format("%02d%02d", adjustedHour, adjustedMinute);
    
   if (isTopOfHourOrHalfHour && !jsonRequested) {
        requestJSON();
        //print("예보정보 갱신");//for debug
        jsonRequested = true;  // Set flag when the request is complete
        
    }
    // Reset flag after the hour or half-hour has passed (after 1 minute)
    if (!isTopOfHourOrHalfHour) {
        jsonRequested = false;
    }
    fill(255);
    rectMode(CENTER);
    rect(x, y, 200, 340);
    y-=25;
    // Display wind direction and speed as a compass
    fill(0);
    textAlign(CENTER);
    // Add forecast time
    text("Forecast Time: " + nearestFcstTime, x, y-120);  // Show forecast time
    text("Wind Direction & Speed", x, y-100);
    translate(x, y);

    // Cardinal direction text
    textAlign(CENTER, CENTER);
    text("N", 0, -88);    // North
    text("E", 80, 0);     // East
    text("S", 0, 88);     // South
    text("W", -80, 0);    // West
    rotate(radians(windDirection));  // Rotate according
    
    stroke(0);
    line(0, 0, 0, -70); // Draws the compass needle pointing in the direction of the wind

    resetMatrix();  // Reset to the original state
    text("Wind Speed: " + windSpeed + " m/s", x, y + 120);
  
    // Display temperature
    text("Temperature: " + temp + "°C", x, y + 140);
  
    // Display sky condition
    String sky = skyCondition == 1 ? "Clear" : (skyCondition == 2 ? "Partly Cloudy" : "Cloudy");
    text("Sky: " + sky, x, y + 160);
  
    // Display type of precipitation
    String rain = precipitation == 0 ? "No Rain" : (precipitation == 1||precipitation == 5 ? "Rain" : (precipitation == 2 ||precipitation == 6? "Rain/Snow" : "Snow"));
    text("Precipitation: " + rain, x, y + 180);
  }
      
  void draw() {
  }
}
