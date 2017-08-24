import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import controlP5.*;
import processing.video.*;
import processing.sound.*;

Movie mov;
//SoundFile sound;
Minim minim;
AudioPlayer audioPlayer;
//Amplitude amp;
float peacefulRangeMin;
float peacefulRangeMax;
int jumpDistance;
float lastJumpTime;
float jumpCooldownTime;

//controlP5
float smoothedSoundAmp;
ControlP5 cp5;
float smoothStep;
Chart soundWaveChart;
Textlabel soundWaveValue;
Group g1;

void setup() {
  size(1280, 720);
  mov = new Movie(this, "ocean.mp4");  
  minim = new Minim(this);
  audioPlayer = minim.loadFile("ocean.wav");
  audioPlayer.loop();

  //sound = new SoundFile(this, "ocean.wav");
  //amp = new Amplitude(this);
  //sound.loop();
  mov.loop();
  //amp.input(sound);
  mov.volume(0);


  //control p5
  cp5 = new ControlP5(this);
  g1 = cp5.addGroup("g1").setPosition(0, 0);
  cp5.addSlider("smoothStep")
    .setRange(0.5, 0.01)
    .setDecimalPrecision(5)
    .setPosition(10, 10)
    .setSize(200, 10)
    .setGroup(g1);
  cp5.addRange("peaceful Range Controller")  
    .setSize(200, 30)
    .setRange(0.02, 0.09)
    .setRangeValues(0.033, 0.055)
    .setDecimalPrecision(4)
    .setPosition(10, 30)
    .setGroup(g1);
  soundWaveChart = cp5
    .addChart("soundWave")
    .setPosition(10, 70)
    .setRange(0.03, 0.08)
    .setView(Chart.LINE)
    .setGroup(g1);
  soundWaveChart.addDataSet("soundWave");
  soundWaveValue = cp5
    .addTextlabel("sound wave value")
    .setPosition(220, 70)
    .setGroup(g1);
  cp5.addSlider("jumpDistance")
    .setLabel("Jump Distance ( in Millis )")
    .setRange(1000, 120000)
    .setValue(9000)
    .setPosition(10, 190)
    .setSize(200, 30)
    .setGroup(g1);
  cp5.addSlider("jumpCooldownTime")
    .setPosition(10, 230)
    .setRange(300, 20000)
    .setValue(6000)
    .setSize(200, 20)
    .setGroup(g1);
}

void draw() {
  image(mov, 0, 0);
  if (mov.available()) {
    mov.read();
  }

  smoothedSoundAmp = smoothedSoundAmp + (audioPlayer.left.level() - smoothedSoundAmp)*smoothStep;
  soundWaveChart.push("soundWave", smoothedSoundAmp);
  soundWaveValue.setText("" + smoothedSoundAmp);

  if (smoothedSoundAmp > peacefulRangeMin && smoothedSoundAmp < peacefulRangeMax) {
    //soundWaveChart.setColorBackground(color(0, 255, 0));
  } else {
    if (millis()-lastJumpTime >= jumpCooldownTime) {
      //soundWaveChart.setColorBackground(color(255, 0, 0));
      mov.jump(mov.time() + (float)jumpDistance/1000);
      audioPlayer.skip((int)jumpDistance);
      lastJumpTime = millis();
      println("Jumpped " + jumpDistance);
    }
  }
}

void controlEvent(ControlEvent e) {
  if (e.isFrom("peaceful Range Controller")) {
    peacefulRangeMin = e.getController().getArrayValue(0);
    peacefulRangeMax = e.getController().getArrayValue(1);
  }
}

void keyPressed() {
  if (key=='h') {
    g1.hide();
  }
  if (key=='s') {
    g1.show();
  }
}