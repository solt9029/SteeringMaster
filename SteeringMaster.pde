import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer audioPlayer;
AudioSample audioSample;

String stage; // 現在何をしているのか格納する

final float OFFSET = 3000; // 曲の本当の開始時間（ミリ秒）
final int BPM = 230;
final int NPM = BPM * 4; // 1分間に流れるノーツの数
final float MPN = 60000.0 / (float)NPM; // ノート1個が流れるのに要する時間（ミリ秒）

int noteIndex = 0;
final int [] notes = {
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
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
int [] states;
final int [][] paths = {
  {40, 1000},
  {200, 1500},
  {90, 1200},
  {40, 1100},
  {40, 700},
  {140, 1000},
  {100, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000},
  {40, 1000}
};

int getNoteIndex() {
  return int((audioPlayer.position() - OFFSET) / MPN - 0.5);
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
  
  states = new int [notes.length];
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
  background(WHITE_COLOR);
    
  // 左側水色部分描画
  fill(WATER_COLOR);
  rect(0, 0, START_X, UNIT * Y_NUM);
  
  // 右側緑色部分描画
  fill(YELLOW_GREEN_COLOR);
  rect(START_X, 0, UNIT * X_NUM - START_X, UNIT * Y_NUM);
  
  // 経路描画
  int pathIndex = 0;
  for (int i = 0; i < notes.length; i++) {
    if (notes[i] == 0) {
      continue;
    }
    if (states[i] == STATE_GREAT || states[i] == STATE_GOOD || states[i] == STATE_OKAY || states[i] == STATE_BAD) {
      pathIndex++;
      continue;
    }
    
    fill(GLAY_COLOR);
    rect(START_X, 0, paths[pathIndex][1], UNIT * Y_NUM);
    fill(WHITE_COLOR);
    rect(START_X, CENTER_Y - paths[pathIndex][0] / 2, paths[pathIndex][1], paths[pathIndex][0]);
  }
  
  // ノーツ描画
  int noteIndex = getNoteIndex();
  // int((UNIT * Y_NUM - CENTER_Y) / NOTE_SPACE)はCENTER_Yを過ぎた後でもノーツが表示されうる範囲
  for (int i = noteIndex - int((UNIT * Y_NUM - CENTER_Y) / NOTE_SPACE); i < notes.length; i++) {
    if (i < 0) {
      continue;
    }
    if (notes[i] > 0 && states[i] == 0) {
      fill(PINK_COLOR);
      ellipse(START_X, CENTER_Y - (i - noteIndex) * NOTE_SPACE, NOTE_RADIUS * 2, NOTE_RADIUS * 2);
    }
  }
  
  // 4個前でまだヒットされていなかったらBadとする
  if (noteIndex - 4 >= 0) {
    if (notes[noteIndex - 4] == 1 && states[noteIndex - 4] == STATE_FRESH) {
      states[noteIndex - 4] = STATE_BAD;
    }
  }
  
  if (ENVIRONMENT.equals(DEVELOPMENT)) {
    // 判定部分描画
    fill(0, 0, 0);
    rect(0, CENTER_Y - 1, UNIT * X_NUM, 2);
    
    // オート再生
    //if (notePosition >= 0) {
    //  if (states[notePosition] == 0 && notes[notePosition] > 0) {
    //    states[notePosition] = 4;
    //    audioSample.trigger();
    //  }
    //}
  }
}

void drawResult() {
  
}

void stop() {
  audioPlayer.close();
  audioSample.stop();
  minim.stop();
  super.stop();
}