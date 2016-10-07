class Accident
{
  PVector location;
  color colour;
  float diameter;
  float scale;
  float offsetX;
  float offsetY;
  String borough;
  Boolean mild;
  Boolean serious;
  Boolean fatal;
  Boolean showOnlySeriousAbove;

  Accident(PVector l, float d, color c, Boolean mi, Boolean se, Boolean fa, String b)
  {
    location = l;
    diameter = d;
    colour = c;
    scale = 1.0;
    offsetX = 0.0;
    offsetY = 0.0;
    mild = mi;
    serious = se;
    fatal = fa;
    showOnlySeriousAbove = false;
    borough = b;
  }

  void draw()
  {
    noStroke();
    if (showOnlySeriousAbove == false)
    {
      fill(colour);
      ellipse((offsetX + map(location.x, -0.5, 0.3, 5, width - 5)) * scale, (offsetY + map(location.y, 51.7, 51.3, 5, height - 5)) * scale, diameter * scale, diameter * scale);
    } else
    {
      if (serious == true || fatal == true)
      {
        fill(colour);
        ellipse((offsetX + map(location.x, -0.5, 0.3, 5, width - 5)) * scale, (offsetY + map(location.y, 51.7, 51.3, 5, height - 5)) * scale, diameter * scale, diameter * scale);
      }
    }
  }
}