import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer audioPlayer;
AudioSample audioSample;

String stage; // 現在何をしているのか格納する

final float OFFSET = 3000; // 曲の本当の開始時間（ミリ秒）
final int BPM = 100;
final int NPM = BPM * 4; // 1分間に流れるノーツの数
final float MPN = 60000.0 / (float)NPM; // ノート1個が流れるのに要する時間（ミリ秒）

final int [] notes = {
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

int [] hits;

int getNotePosition() {
  int notePosition = int((audioPlayer.position() - OFFSET) / MPN - 0.5);
  return notePosition;
}

void settings() {
  size(UNIT * X_NUM, UNIT * Y_NUM);
}

void setup() {
  noStroke();
  
  minim = new Minim(this);
  audioPlayer = minim.loadFile("music.wav");
  audioSample = minim.loadSample("ka.wav");
  
  stage = STAGE_TITLE;
}

void draw() {
  switch(stage) {
    case STAGE_TITLE:
      drawTitle();
      break;
      
    case STAGE_GAME:
      drawGame();
      break;
      
    case STAGE_RESULT:
      drawResult();
      break;
      
    default:
      break;
  }
}

void keyPressed() {
  // スペースキーが押されたらタイトル画面終了でゲームに移行する
  if (stage.equals(STAGE_TITLE) && keyCode == SPACE_KEY_CODE) {
    stage = STAGE_GAME;
    audioPlayer.play();
  }
}

void drawTitle() {
  
}

void drawGame() {
  background(255, 255, 255);
    
  // 左側水色部分描画
  fill(157, 204, 224);
  rect(0, 0, UNIT * 20, UNIT * Y_NUM);
  
  // 右側緑色部分描画
  fill(152, 251, 152);
  rect(UNIT * 20, 0, UNIT * (X_NUM - 20), UNIT * Y_NUM);
  
  if (ENVIRONMENT.equals(DEVELOPMENT)) {
    // 判定部分描画
    fill(0, 0, 0);
    rect(0, UNIT * 34 - 1, UNIT * X_NUM, 2);
    
    int notePosition = getNotePosition();
    println(notePosition);
  }
}

void drawResult() {
  
}