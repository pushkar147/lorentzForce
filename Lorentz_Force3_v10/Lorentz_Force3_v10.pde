/**********************************************************************************
 Lorentz_Force
 
 Copyright 2017, Pushkaraj
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either
 version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this program; if not, see
 <http://www.gnu.org/licenses/>.
 
**********************************************************************************/

/*Simulator to simulate motion of charged particle in presence of electric and magnetic field*/

// variable declarations:
float xAngle;
//we provide facility to rotate the coordinate system about x-axis at runtime
//xAngle holds the value in radian through which system should be rotated
float q, x, y, z, vx, vy, vz, ex, ey, ez, bx, by, bz;
//these are usual parameters in electrodynamics
float dt, x0, y0, z0, vx0, vy0, vz0;
//dt for very small time interval
// '0' suffix implies initial values
int delayelt, l, t;
//delayelt ==> to adjust speed of simulations
//l ==> convinient length to draw graphics
//t ==> time
boolean playFlag;
//this holds status of application, whether it is playing simulation or paused.
String playButtonText;
//this is caption for buttons on screen
//int record[100][3]
//this 2-D array holds the history of the path through which the particle is travelled
// Ohhh nooo....
//why Processing leaved this error??
//we cannot declare an array without defining it
//we found no other way to declare this matrix, unless spending this much space of screen
int record[][]={
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
  {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}
};
//here is the starting point of program execution
void setup()
{
  //declare the size of window
  size(1000, 600, P3D);
  //P3D implies this window is capable of drawing 3D graphics
  //now initialize all the variables by assigning their default values
  assignDefaultValues();
}//this is central function of the program
//this function is repeatedly called until the user exits the application
void draw()
{
  //refresh the screen
  drawScreen();
  if (playFlag)
  {
    //continue the simulation
    playSimulation();
    //wait for some time, to synchronize with human eye
    delay(delayelt/2);
  }
}
void assignDefaultValues()
{
  playFlag=false;
  // simulation is stopped
  xAngle=-0.1;
  // initial view
  q=0;
  // charge neutral
  x=y=z=0;
  // at origin
  vx=vy=vz=0;
  // stationary
  ex=ey=ez=0;
  // no electric field
  bx=by=bz=0;
  // no magnetic field
  dt=0.01;
  // small time interval
  delayelt=100;
  // time in milliseconds, which is to be used to give delay
  l=250;
  // a convinient unit, while drawing graphics
  t=0;
  // time
  playButtonText=" Play"; // caption on 'Play' button
  for (int i=0; i<100; i++)
    record[i][0]=record[i][1]=record[i][2]=0;
  // particle was at origin for long time
}
void drawScreen()
{
  background(0);
  // clear the screen
  // now paint a region where objects are to be drawn
  // this is not a region where particle travels
  fill(205);
  noStroke();
  rect(height+100, 0, width-height, height);
  strokeWeight(1);
  // now draw all neccessory graphics
  drawAxes();
  drawChrgpt();
  drawScales();
  drawPlayButton();
  displayNames();
  drawEbarandBbar();
  drawTrace();
}
void drawAxes()
{
  stroke(255);
  pushMatrix();
  translate(height/2, height/2, 0);
  rotateX(xAngle);
  line(-l, 0, 0, l, 0, 0); //x-axis
  line(0, l, 0, 0, -l, 0); //y-axis
  line(0, 0, -l, 0, 0, l); //z-axis
  popMatrix();
}
void drawChrgpt()
{
  pushMatrix();
  translate(height/2, height/2, -0);
  rotateX(xAngle);
  translate(x*l, -y*l, z*l);
  fill(255, 255, 0);
  noStroke();
  if (screenX(0, 0, 0)<height+50)
    // within allowed region
    sphere(4);
  popMatrix();
}
void drawScales()
{
  stroke(0);
  // first draw horizontal lines
  for (int i=1; i<=14; i++)
  {
    line(750, 30*i, 950, 30*i);
    line(850, 30*i-2, 850, 30*i+2);
  }
  // now draw small triangles on the lines,
  // which will reflect the values of variables.
  fill(255, 255, 0);
  if (q>=-1 && q<=1)
    triangle(850+q*100, 30, 860+q*100, 20, 840+q*100, 20); //charge
  fill(0, 0, 255);
  if (ex>=-1 && ex<=1)
    triangle(850+ex*100, 60, 860+ex*100, 50, 840+ex*100, 50); //Ex
  if (ey>=-1 && ey<=1)
    triangle(850+ey*100, 90, 860+ey*100, 80, 840+ey*100, 80); //Eyif (ez>=-1 && ez<=1)
  triangle(850+ez*100, 120, 860+ez*100, 110, 840+ez*100, 110); //Ez
  fill(255, 0, 0);
  if (bx>=-1 && bx<=1)
    triangle(850+bx*100, 150, 860+bx*100, 140, 840+bx*100, 140); //Bx
  if (by>=-1 && by<=1)
    triangle(850+by*100, 180, 860+by*100, 170, 840+by*100, 170); //By
  if (bz>=-1 && bz<=1)
    triangle(850+bz*100, 210, 860+bz*100, 200, 840+bz*100, 200); //Bz
  fill(0, 255, 0);
  if (vx>=-1 && vx<=1)
    triangle(850+vx*100, 240, 860+vx*100, 230, 840+vx*100, 230); //Vx
  if (vy>=-1 && vy<=1)
    triangle(850+vy*100, 270, 860+vy*100, 260, 840+vy*100, 260); //Vy
  if (vz>=-1 && vz<=1)
    triangle(850+vz*100, 300, 860+vz*100, 290, 840+vz*100, 290); //Vz
  fill(255, 0, 255);
  if (x>=-1 && x<=1)
    triangle(850+x*100, 330, 860+x*100, 320, 840+x*100, 320); //x
  if (y>=-1 && y<=1)
    triangle(850+y*100, 360, 860+y*100, 350, 840+y*100, 350); //y
  if (z>=-1 && z<=1)
    triangle(850+z*100, 390, 860+z*100, 380, 840+z*100, 380); //z
  fill(255);
  if (delayelt>=0 && delayelt<=200)
    triangle(950-delayelt, 420, 960-delayelt, 410, 940-delayelt, 410);
}
void drawPlayButton()
{
  stroke(0);
  fill(128);
  rect(740, 520, 100, 40);
  rect(860, 520, 100, 40);
  // two rect functions, because we want flashing effect on mouse-click
}
void displayNames()
{
  // first, print the caption on the button
  textSize(24);
  fill(0);
  text(playButtonText, 755, 550);
  text("Reset", 880, 550);
  // now give labels to axes
  pushMatrix();
  translate(300, 300, 0);
  rotateX(xAngle);
  translate(-300, -300, 0);
  textSize(20);
  fill(255);
  text("X", 555, 300, 0);
  text("Y", 300, 45, 0);
  text("Z", 300, 300, 255);
  popMatrix();
  // finally give labels to sliders
  stroke(0);
  textSize(14);
  fill(255, 255, 0);
  text("-q", 725, 30); //charge
  fill(0, 0, 255);
  text("-Ex", 720, 60); //Ex
  text("-Ey", 720, 90); //Ey
  text("-Ez", 720, 120); //Ez
  fill(255, 0, 0);
  text("-Bx", 720, 150); //Bx
  text("-By", 720, 180); //By
  text("-Bz", 720, 210); //Bz
  fill(0, 200, 0);
  text("-Vx", 720, 240); //Vx
  text("-Vy", 720, 270); //Vy
  text("-Vz", 720, 300); //Vz
  fill(255, 0, 255);
  text("-X", 725, 330); //x
  text("-Y", 725, 360); //y
  text("-Z", 725, 390); //z
  fill(0);
  text("Slow", 710, 420);
  fill(255, 255, 0);
  text("+q", 960, 30); //charge
  fill(0, 0, 255);
  text("+Ex", 960, 60); //Ex
  text("+Ey", 960, 90); //Ey
  text("+Ez", 960, 120); //Ez
  fill(255, 0, 0);
  text("+Bx", 960, 150); //Bx
  text("+By", 960, 180); //By
  text("+Bz", 960, 210); //Bz
  fill(0, 200, 0);
  text("+Vx", 960, 240); //Vx
  text("+Vy", 960, 270); //Vy
  text("+Vz", 960, 300); //Vz
  fill(255, 0, 255);
  text("+X", 960, 330); //x
  text("+Y", 960, 360); //ytext("+Z", 960, 390); //z
  fill(0);
  text("Fast", 960, 420);
}
void playSimulation()
{
  // check whether motion is possible or not
  if ((vx*vx+vy*vy+vz*vz)==0 && (q==0 || (ex*ex+ey*ey+ez*ez)==0))
  {
    playFlag=false;
    playButtonText=" Play";
  }
  // mark initial position and velocity
  x0=x;
  y0=y;
  z0=z;
  vx0=vx;
  vy0=vy;
  vz0=vz;
  // calculate velocity for current instant
  vx=vx0+q*(0.5*ex+2.5*vy0*bz-2.5*vz0*by)*dt;
  vy=vy0+q*(0.5*ey+2.5*vz0*bx-2.5*vx0*bz)*dt;
  vz=vz0+q*(0.5*ez+2.5*vx0*by-2.5*vy0*bx)*dt;
  // calculate position for current instant
  x=x0+vx*dt;
  y=y0+vy*dt;
  z=z0+vz*dt;
  // save the history
  t+=100*dt;
  if ((0.1*t)-(t/10)==0)
    updateTraceRecord();
}
void drawEbarandBbar()
{
  pushMatrix();
  translate(300, 300, 0);
  rotateX(xAngle);
  // electric field vector
  strokeWeight(4);
  stroke(0, 0, 255);
  line(0, 0, 0, ex*100, -ey*100, ez*100);
  // magnetic field vector
  strokeWeight(4.2);
  stroke(255, 0, 0);
  line(0, 0, 0, bx*100, -by*100, bz*100);// velocity vector
  strokeWeight(3.8);
  stroke(0, 255, 0);
  if (screenX(x*l, -y*l, z*l)<height+50)
    // within allowed region
    line(x*l, -y*l, z*l, x*l+vx*100, -y*l-vy*100, z*l+vz*100);
  strokeWeight(1);
  popMatrix();
}
void drawTrace()
{
  pushMatrix();
  translate(height/2, height/2, -0);
  rotateX(xAngle);
  stroke(255, 255, 0);
  for (int i=0; i<100; i++)
  {
    strokeWeight(0.02*i);
    // points get diminished as particle goes ahead
    if (screenX(record[i][0], -record[i][1], record[i][2])<height+50)
      // within allowed region
      point(record[i][0], -record[i][1], record[i][2]);
  }
  popMatrix();
}
void updateTraceRecord()
{
  int i;
  // delete oldest record, in order to make room for newest one
  // this is done by shifting
  for (i=0; i<99; i++)
  {
    record[i][0]=record[i+1][0];
    record[i][1]=record[i+1][1];
    record[i][2]=record[i+1][2];
  }
  // store current position
  record[i][0]=int(l*x);
  record[i][1]=int(l*y);
  record[i][2]=int(l*z);
}
void mouseClicked()
{
  if (mouseY>520 && mouseY<560)
    if (mouseX>740 && mouseX<840) {
      // user has pressed on 'Play' button
      if (!playFlag)
      {
        // simulation has been stoped/paused and we should start/resume it
        stroke(0);
        fill(150);
        rect(740, 520, 100, 40);
        for (int i=0; i<50; i++)
        {
          record[i][0]=int(x*l);
          record[i][1]=int(y*l);
          record[i][2]=int(z*l);
        }
        playFlag=true;
        playButtonText="Pause";
      } else
      {
        // simulation is running and we should pause it
        playFlag=false;
        playButtonText=" Play";
      }
    } else if (mouseX>860 && mouseX<960)
    {
      // user has pressed on 'Play' button
      stroke(0);
      fill(150);
      rect(860, 520, 100, 40);
      // restore defaults
      setup();
    }
}
void mousePressed()
{
  if (mouseX>750 && mouseX<950)
  {
    if (mouseY>25 && mouseY<35)
    {
      q=mouseX-850;
      q/=100;
    }
    if (mouseY>55 && mouseY<65)
    {
      ex=mouseX-850;
      ex/=100;
    }
    if (mouseY>85 && mouseY<95)
    {
      ey=mouseX-850;
      ey/=100;
    }
    if (mouseY>115 && mouseY<125)
    {
      ez=mouseX-850;
      ez/=100;
    }
    if (mouseY>145 && mouseY<155)
    {
      bx=mouseX-850;
      bx/=100;
    }
    if (mouseY>175 && mouseY<185)
    {
      by=mouseX-850;
      by/=100;
    }
    if (mouseY>205 && mouseY<215)
    {
      bz=mouseX-850;
      bz/=100;
    }
    if (mouseY>235 && mouseY<245)
    {
      vx=mouseX-850;
      vx/=100;
    }
    if (mouseY>265 && mouseY<275)
    {
      vy=mouseX-850;
      vy/=100;
    }
    if (mouseY>295 && mouseY<305)
    {
      vz=mouseX-850;
      vz/=100;
    }
    if (mouseY>325 && mouseY<335)
    {
      x=mouseX-850;
      x/=100;
    }
    if (mouseY>355 && mouseY<365)
    {
      y=mouseX-850;
      y/=100;
    }
    if (mouseY>385 && mouseY<395) {
      z=mouseX-850;
      z/=100;
    }
    if (mouseY>415 && mouseY<425)
      delayelt=950-mouseX;
  }
}
void mouseWheel(MouseEvent event)
{
  if (mouseX<height+100 && mouseY<height)
    // change the angle of view
    xAngle+=0.1*event.getCount();
  // wrap the angle
  if (xAngle>2*PI)
    xAngle-=2*PI;
}
