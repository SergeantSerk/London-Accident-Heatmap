/*
  Author - Serkan Sahin
  This software is under Creative Commons BY 4.0 license as described here: https://creativecommons.org/licenses/by/4.0/
*/

//Imported this to be only used at line 141, so the array can be sorted in alphabetical order
import java.util.Arrays;

String appID = "";                                                 //Unique ID to identify the app
String appKey = "";                                                //API key to access TfL. Note: light applications do not need a key
int year = 2015;                                                   //Year to retrieve data of accidents
float offX = 0;
float offY = 0;
float panVX = random(random(-0.25, -0.1), random(0.1, 0.25));      //Panning velocity (x)
float panVY = random(random(-0.35, -0.1), random(0.1, 0.35));      //Panning velocity (y) | Note that the numbers for both x and y are made so that it is not really close to 0
float scl = 3.0;                                                   //Scale of zoom

ArrayList<Accident> accidents = new ArrayList();

boolean showSeriousAbove = false;                                  //State which shows only serious and fatal accidents if true
boolean rendered = false;                                          //Useful if using a static screen and preventing multiple renders, hence saving system resources
int designState = 1;                                               //Initial design state, 1 by default, which is the accidents heatmap

/* Structure of designState:
 1 - Map of London with spots of accidents
 2 - Bar chart of accidents with regards to severity
 3 - Bar chart of accidents with regards to which borough
 */

void setup()
{
  //FX2D is surprisingly fast for chunks of ellipses rendering per second
  //size(1280, 720, FX2D);
  fullScreen(FX2D);

  //This link takes ages to get data since the data is just too big.
  //getData("https://api.tfl.gov.uk/AccidentStats/" + year + "?app_id=" + appID + "&app_key=" + appKey);
  getData("accidents_2015.txt");

  offX = width / 2;
  offY = height / 2;
}

void draw()
{
  //Checks if rendered state is false
  if (rendered == false)
  {
    //Checks which design state is in use
    if (designState == 1)
    {
      //Initial settings
      background(0);
      translate(width / 2, height / 2);
      for (Accident accident : accidents)
      {
        accident.offsetX = -offX;
        accident.offsetY = -offY;
        accident.showOnlySeriousAbove = showSeriousAbove;
        accident.scale = scl;
        accident.draw();
      }
  
      //Draws legend with info about accidents
      drawLegend();

      //Bounce off borders
      //Move "camera" with constant velocity
      offX = offX + panVX;
      offY = offY + panVY;
      //Check for border hit on X axis
      if (offX > width * 0.75 || offX < 150)
      {
        panVX = -panVX;
      }
      //Check for border hit on Y axis
      if (offY > height * 0.85 || offY < 130)
      {
        panVY = -panVY;
      }
    }
    //Design state 2 - severity bar chart
    else if (designState == 2)
    {
      //Create variables to store count of severity of accidents
      int slight = 0;
      int serious = 0;
      int fatal = 0;
      //For each accident, get severity and store in corresponding variable
      for (Accident accident : accidents)
      {
        if (accident.mild == true)
        {
          slight++;
        } else if (accident.serious == true)
        {
          serious++;
        } else if (accident.fatal == true)
        {
          fatal++;
        }
      }
      
      //Initial settings for design
      textSize(16);
      background(0);
      fill(255);
      rectMode(CORNER);
      noStroke();

      //Slight accidents bar
      fill(255);
      noStroke();
      text("Slight (" + slight + "):", 20, 86);      
      fill(0, 0, 255);
      stroke(0, 0, 255);
      rect(width / 6, 70, map(slight, 0, 30000, 0, width - 5), 20);

      //Serious accidents bar
      fill(255);
      noStroke();
      text("Serious (" + serious + "):", 20, 132);
      fill(255, 0, 128);
      stroke(255, 0, 128);
      rect(width / 6, 116, map(serious, 0, 30000, 0, width - 5), 20);

      //Fatal accidents bar
      fill(255);
      noStroke();
      text("Fatal (" + fatal + "):", 20, 178);
      fill(255, 0, 0);
      stroke(255, 0, 0);
      rect(width / 6, 162, map(fatal, 0, 30000, 0, width - 5), 20);
    }
    //Design state 3 - bar chart for accidents with respect to boroughs
    else if (designState == 3)
    {
      //Name of each 32 boroughs in London
      String boroughs[] = {"Camden", "Greenwich", "Hackney", "Hammersmith", "Islington", "Kensington and Chelsea", "Lambeth", "Lewisham", "Southwark", "Tower Hamlets", "Wandsworth", "Westminster", "Barking", "Barnet", "Bexley", "Brent", "Bromley", "Croydon", "Ealing", "Enfield", "Haringey", "Harrow", "Havering", "Hillingdon", "Hounslow", "Kingston", "Merton", "Newham", "Redbridge", "Richmond upon Thames", "Sutton", "Waltham Forest"};
      //Sort these in alphabetical order
      Arrays.sort(boroughs);
      //Array for accidents in each borough, arrays in sync with the boroughs array
      int bCount[] = new int[32];
      for (Accident accident : accidents)
      {
        for (int i = 0; i < 32; i++)
        {
          if (accident.borough.contains(boroughs[i]) == true)
          {
            bCount[i]++;
          }
        }
      }

      //Initial settings for the massive bar chart of data
      textSize(16);
      background(0);
      rectMode(CORNER);
      fill(255);
      noStroke();

      //For each borough, display label and bar
      for (int c = 0; c < 32; c++)
      {
        fill(255);
        noStroke();
        text(boroughs[c] + " (" + bCount[c] + "):", 20, (25 * (c + 1)) - offY);      
        fill(0, 0, 255);
        stroke(0, 0, 255);
        rect(width / 3, ((25 * (c + 1)) - 15) - offY, map(bCount[c], 0, 3000, 0, width - 5), 20);
      }

      //Scroll up and if offY reaches limit, move to the entire thing back down
      offY = offY + 2;
      if (offY >= height)
      {
        offY = -height;
      }
      
      rendered = false;
    }
  }
}

void drawLegend()
{
  //Accidents in London for Year x
  fill(255);
  noStroke();
  textSize(30);
  text(accidents.size() + " accidents in London for year " + year, -textWidth(accidents.size() + " accidents in London for year " + year) / 2, (-height / 2) + (height / 16) + 30);

  //Legend for fatal accidents
  textSize(20);
  fill(255, 0, 0);
  noStroke();
  ellipse((-width / 2) + 30, (-height / 2) + (height / 16), 20, 20);
  fill(255);
  noStroke();
  text("- Fatal", (-width / 2) + 50, (-height / 2) + (height / 16) + 6);

  //Legend for serious accidents
  fill(255, 0, 128);
  noStroke();
  ellipse((-width / 2) + 30, (-height / 2) + (height / 16) + 30, 20, 20);
  fill(255);
  noStroke();
  text("- Serious", (-width / 2) + 50, (-height / 2) + (height / 16) + 36);      

  //Legend for slight accidents
  fill(255, 255, 0);
  noStroke();
  ellipse((-width / 2) + 30, (-height / 2) + (height / 16) + 60, 20, 20);
  fill(255);
  noStroke();
  text("- Slight", (-width / 2) + 50, (-height / 2) + (height / 16) + 66);
  
  //Legend for City, University of London
  fill(0, 255, 0);
  noStroke();
  ellipse((-width / 2) + 30, (-height / 2) + (height / 16) + 90, 20, 20);
  fill(255);
  noStroke();
  text("- City, University of London", (-width / 2) + 50, (-height / 2) + (height / 16) + 96);
}

void getData(String urlOnline)
{
  try
  {
    JSONArray data = loadJSONArray(urlOnline);
    for (int i = 0; i < data.size(); i++)
    {
      JSONObject accidentsList = data.getJSONObject(i);
      float lon = accidentsList.getFloat("lon");
      float lat = accidentsList.getFloat("lat");
      String sev = accidentsList.getString("severity");
      String borough = accidentsList.getString("borough");
      if (sev.contains("Slight") == true)
      {
        //Mild accidents are orange
        accidents.add(new Accident(new PVector(lon, lat), 0.5, color(255, 255, 0), true, false, false, borough));
      } else if (sev.contains("Serious") == true)
      {
        //Serious accidents are pink
        accidents.add(new Accident(new PVector(lon, lat), 1.0, color(255, 0, 128), false, true, false, borough));
      } else if (sev.contains("Fatal") == true)
      {
        //Fatal accidents are core red
        accidents.add(new Accident(new PVector(lon, lat), 2.0, color(255, 0, 0), false, false, true, borough));
      }
      //Geographic center
      //accidents.add(new Accident(new PVector(-0.1, 51.5), 3.0, color(255), false, false, true));
      //City Uni
    }
    accidents.add(new Accident(new PVector(-0.105732, 51.5254742), 2.0, color(0, 255, 0), true, false, false, ""));
  }
  catch(Exception e)
  {
    println("ERROR: You are not connected to the Internet or local file is non-existent.");
  }
}

void keyPressed()
{
  //If left arrow
  if (keyCode == 37)
  {
    panVX = 0;
    panVY = 0;
    offX = offX - 5;
    rendered = false;
  }
  //If right arrow
  else if (keyCode == 39)
  {
    panVX = 0;
    panVY = 0;
    offX = offX + 5;
    rendered = false;
  }
  //If down arrow
  else if (keyCode == 38)
  {
    panVX = 0;
    panVY = 0;
    offY = offY - 5;
    rendered = false;
  }
  //If up arrow
  else if (keyCode == 40)
  {
    panVX = 0;
    panVY = 0;
    offY = offY + 5;
    rendered = false;
  }
  //If + key(s)
  else if (keyCode == 61 || keyCode == 107)
  {
    if (scl < 25.0)
    {
      scl = scl + 0.5;
      println(scl);
      rendered = false;
    }
  }
  //If - key(s)
  else if (keyCode == 45 || keyCode == 109)
  {
    if (scl > 1)
    {
      scl = scl - 0.5;
      rendered = false;
    }
  }
  //If A key
  if (key == 'a' || key == 'A')
  {
    //Show all accidents
    showSeriousAbove = false;
    rendered = false;
  }
  //If S key
  else if (key == 's' || key == 'S')
  {
    //Show serious and fatal accidents
    showSeriousAbove = true;
    rendered = false;
  }
  //Reset R key
  if (key == 'r' || key == 'R')
  {
    offX = 0;
    offY = 0;
    scl = 1.0;
    rendered = false;
  }
  //Set designState to 1
  if (keyCode == 49)
  {
    designState = 1;
    rendered = false;
    offX = width / 2;
    offY = height / 2;
  } else if (keyCode == 50)
  {
    designState = 2;
    rendered = false;
  } else if (keyCode == 51)
  {
    designState = 3;
    rendered = false;
    offX = 0;
    offY = 0;
  }
}