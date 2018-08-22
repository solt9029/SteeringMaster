import ddf.minim.*;
import ddf.minim.effects.*;

PImage titleImg;
PImage resultImg;
String selectedMode;

Minim minim;
AudioPlayer audioPlayer;
AudioSample clickAudioSample;
AudioSample selectAudioSample;
AudioSample startAudioSample;

String stage; // 現在何をしているのか格納する

int [] notes;
int [][] paths;
int [][] steeringTimestamps;

int score = 0;
int combo = 0;
int maxCombo = 0;

PFont normalFont;
PFont bigFont;

ArrayList<Judge> judges = new ArrayList<Judge>();

int [] states;
int noteIndex = 0;
int pathIndex = 0;
boolean steering = false;
int steeringNoteIndex = -1; // ステアリング中のノートのインデックス
int steeringPathIndex = -1;
ArrayList<Position> steeringPositions = new ArrayList<Position>(); // ステアリング中のマウス座標を全部記録

LinearRegression linearRegression; // ステアリングの法則の適合度を計算するために最後に使用

int getNoteIndex() {
  return int((audioPlayer.position() - OFFSET) / MPN - 0.5);
}

int getPathIndex() {
  int pathIndex = 0;
  for (int i = 0; i < notes.length; i++) {
    if (notes[i] == 0) {
      continue;
    }
    if (states[i] == STATE_GREAT || states[i] == STATE_OKAY || states[i] == STATE_BAD) {
      pathIndex++;
      continue;
    }
    break;
  }
  return pathIndex;
}

void settings() {
  size(UNIT * X_NUM, UNIT * Y_NUM);
}

void setup() {
  noStroke();
  normalFont = loadFont("RictyDiminished-Bold-120.vlw");
  bigFont = loadFont("RictyDiminished-Bold-240.vlw");

  selectedMode = EASY_MODE;
  titleImg = loadImage("title.png");
  resultImg = loadImage("result.png");

  minim = new Minim(this);
  audioPlayer = minim.loadFile("music.wav");
  clickAudioSample = minim.loadSample("ka.wav");
  selectAudioSample = minim.loadSample("select.mp3");
  startAudioSample = minim.loadSample("start.mp3");

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
  if (!stage.equals(STAGE_TITLE)) {
    return;
  }
  // 矢印
  if (keyCode == LEFT || keyCode == RIGHT) {
    selectAudioSample.trigger();
    if (selectedMode.equals(EASY_MODE)) {
      selectedMode = HARD_MODE;
    } else {
      selectedMode = EASY_MODE;
    }
  }
  
  // スペースキーが押されたらタイトル画面終了でゲームに移行する
  if (keyCode == SPACE_KEY_CODE) {
    startAudioSample.trigger();
    switch (selectedMode) {
      case EASY_MODE:
        notes = EASY_NOTES;
        paths = EASY_PATHS;
        break;
      case HARD_MODE:
        notes = HARD_NOTES;
        paths = HARD_PATHS;
        break;
      default:
        break;
    }
    steeringTimestamps = new int [paths.length][paths[0].length];
    states = new int [notes.length];
    stage = STAGE_GAME;
    audioPlayer.play();
  }
}

void mousePressed() {
  if (!stage.equals(STAGE_GAME)) {
    return;
  }
  if (steering) {
    return;
  }
  if (mouseX > START_X) {
    return;
  }

  clickAudioSample.trigger();

  noteIndex = getNoteIndex();
  pathIndex = getPathIndex();
  for (int i = -OKAY_RANGE; i <= OKAY_RANGE; i++) {
    if (noteIndex + i < 0 || noteIndex + i >= notes.length) {
      continue;
    }
    if (notes[noteIndex + i] == 1 && states[noteIndex + i] == STATE_FRESH) {
      steeringNoteIndex = noteIndex + i;
      steeringPathIndex = pathIndex;
      steering = true;
      steeringTimestamps[pathIndex][0] = millis();
      if (abs(i) <= GREAT_RANGE) {
        states[noteIndex + i] = STATE_GREAT_STEERING;
      } else if (abs(i) <= OKAY_RANGE) {
        states[noteIndex + i] = STATE_OKAY_STEERING;
      }
      break;
    }
  }
}

void drawTitle() {
  background(WHITE_COLOR);
  image(titleImg, 0, 0, UNIT * X_NUM, UNIT * Y_NUM);
  
  textAlign(CENTER, CENTER);
  
  // easyモードを描画
  fill(ORANGE_COLOR);
  if (selectedMode.equals(EASY_MODE)) {
    textFont(bigFont);
    stroke(YELLOW_COLOR);
    strokeWeight(MODE_STROKE_WEIGHT);
    ellipse(MODE_X, MODE_Y, MODE_SELECTED_RADIUS * 2, MODE_SELECTED_RADIUS * 2);
    noStroke();
  } else {
    textFont(normalFont);
    ellipse(MODE_X, MODE_Y, MODE_RADIUS * 2, MODE_RADIUS * 2);
  }
  fill(WHITE_COLOR);
  text(EASY_MODE, MODE_X, MODE_Y);
  
  // hardモードを描画
  fill(PURPLE_COLOR);
  if (selectedMode.equals(HARD_MODE)) {
    textFont(bigFont);
    stroke(YELLOW_COLOR);
    strokeWeight(MODE_STROKE_WEIGHT);
    ellipse(UNIT * X_NUM - MODE_X, MODE_Y, MODE_SELECTED_RADIUS * 2, MODE_SELECTED_RADIUS * 2);
    noStroke();
  } else {
    textFont(normalFont);
    ellipse(UNIT * X_NUM - MODE_X, MODE_Y, MODE_RADIUS * 2, MODE_RADIUS * 2);
  }
  fill(BLACK_COLOR);
  text(HARD_MODE, UNIT * X_NUM - MODE_X, MODE_Y);
  
}

void drawGame() {
  background(WHITE_COLOR);

  // 左側水色部分描画
  fill(WATER_COLOR);
  rect(0, 0, START_X, UNIT * Y_NUM);

  // 右側黄緑色部分描画
  fill(YELLOW_GREEN_COLOR);
  rect(START_X, 0, UNIT * X_NUM - START_X, UNIT * Y_NUM);

  // 経路描画
  pathIndex = getPathIndex();
  if (pathIndex >= 0 && pathIndex < paths.length) {
    fill(GLAY_COLOR);
    rect(START_X, 0, paths[pathIndex][1], UNIT * Y_NUM);
    fill(WHITE_COLOR);
    rect(START_X, CENTER_Y - paths[pathIndex][0] / 2, paths[pathIndex][1], paths[pathIndex][0]);
  }

  // ノーツ描画
  noteIndex = getNoteIndex();
  // int((UNIT * Y_NUM - CENTER_Y) / NOTE_SPACE)はCENTER_Yを過ぎた後でもノーツが表示されうる範囲
  stroke(BLACK_COLOR);
  strokeWeight(NOTE_STROKE_WEIGHT);
  for (int i = noteIndex - int((UNIT * Y_NUM - CENTER_Y) / NOTE_SPACE); i < notes.length; i++) {
    if (i < 0) {
      continue;
    }
    if (notes[i] > 0 && states[i] == 0) {
      fill(PINK_COLOR);
      ellipse(START_X, CENTER_Y - (i - noteIndex) * NOTE_SPACE, NOTE_RADIUS * 2, NOTE_RADIUS * 2);
    }
  }
  noStroke();

  // 4個前でまだヒットされていなかったらBadとする
  if (noteIndex - (OKAY_RANGE + 1) >= 0 && noteIndex - (OKAY_RANGE + 1) < notes.length) {
    if (notes[noteIndex - (OKAY_RANGE + 1)] == 1 && states[noteIndex - (OKAY_RANGE + 1)] == STATE_FRESH) {
      states[noteIndex - (OKAY_RANGE + 1)] = STATE_BAD;
      steeringTimestamps[pathIndex][0] = -1;
      steeringTimestamps[pathIndex][1] = -1;
      judges.add(new Judge(BAD_COMMENT, START_X, CENTER_Y, BLUE_COLOR));
      combo = 0;
    }
  }

  // 判定描画
  for (int i = 0; i < judges.size(); i++) {
    textFont(normalFont);
    judges.get(i).display();
    if (judges.get(i).duration < 0) {
      judges.remove(i);
    }
  }

  if (steering) {
    steeringPositions.add(new Position(mouseX, mouseY)); // マウス座標を記録

    // ステアリング経路中
    if (mouseX >= START_X && mouseX <= START_X + paths[pathIndex][1]) {
      // 幅からはみ出ている場合
      if (mouseY < CENTER_Y - paths[pathIndex][0] / 2 || mouseY > CENTER_Y + paths[pathIndex][0] / 2) {
        states[steeringNoteIndex] = STATE_BAD;
        steeringTimestamps[pathIndex][1] = -1;
        judges.add(new Judge(BAD_COMMENT, mouseX, mouseY, BLUE_COLOR));
        combo = 0;
        steering = false;
        steeringPositions = new ArrayList<Position>();
      }
    }

    // ステアリング終了していた場合
    if (mouseX > START_X + paths[pathIndex][1]) {
      combo++;
      if (combo > maxCombo) {
        maxCombo = combo;
      }
      switch (states[steeringNoteIndex]) {
      case STATE_GREAT_STEERING:
        states[steeringNoteIndex] = STATE_GREAT;
        judges.add(new Judge(GREAT_COMMENT, mouseX, mouseY, RED_COLOR));
        score += (SCORE_BASIC_OKAY_INCREMENT + SCORE_COMBO_INCREMENT * combo) * SCORE_OKAY_GREAT_RATIO;
        break;
      case STATE_OKAY_STEERING:
        states[steeringNoteIndex] = STATE_OKAY;
        judges.add(new Judge(OKAY_COMMENT, mouseX, mouseY, BLACK_COLOR));
        score += (SCORE_BASIC_OKAY_INCREMENT + SCORE_COMBO_INCREMENT * combo);
        break;
      default:
        break;
      }
      steeringTimestamps[pathIndex][1] = millis();
      steering = false;
      steeringPositions = new ArrayList<Position>();
    }

    // ステアリングの軌跡を描画
    stroke(RED_COLOR);
    strokeWeight(STEERING_STROKE_WEIGHT);
    for (int i = 0; i < steeringPositions.size() - 1; i++) {
      line(steeringPositions.get(i).x, steeringPositions.get(i).y, steeringPositions.get(i + 1).x, steeringPositions.get(i + 1).y);
    }
    noStroke();
  }

  // 得点描画
  fill(BLACK_COLOR);
  textFont(normalFont);
  textAlign(LEFT);
  text(score, UNIT, NORMAL_TEXT_SIZE);

  // コンボ描画
  fill(WHITE_COLOR);
  textAlign(CENTER);
  textFont(bigFont);
  text(combo, UNIT * X_NUM / 2, BIG_TEXT_SIZE);
  textFont(normalFont);
  text("COMBO", UNIT * X_NUM / 2, BIG_TEXT_SIZE + NORMAL_TEXT_SIZE);
  
  if (ENVIRONMENT.equals(DEVELOPMENT)) {
    // 判定部分描画
    fill(0, 0, 0);
    rect(0, CENTER_Y - 1, UNIT * X_NUM, 2);

    // 変数プリント
    println("====================");
    println("noteIndex:" + noteIndex);
    println("pathIndex:" + pathIndex);
    println("steering:" + steering);
    println("steeringNoteIndex:" + steeringNoteIndex);
    println("steeringPathIndex:" + steeringPathIndex);
    println("combo:" + combo);
    println("score:" + score);
    println("steeringTimestamps:");
    for (int l = 0; l < steeringTimestamps.length; l++) {
      for (int c = 0; c < steeringTimestamps[l].length; c++) {
        println("[" + l + "]" + "[" + c + "]" + ":" + steeringTimestamps[l][c]);
      }
    }
    println("====================");
  }

  if (noteIndex >= notes.length || audioPlayer.position() >= audioPlayer.length()) {
    stage = STAGE_RESULT;
    audioPlayer.pause();
    
    // ステアリングの法則の適合度を計算する処理
    ArrayList <double[]> steeringList = new ArrayList<double[]>();
    for (int i = 0; i < paths.length; i++) {
      if (steeringTimestamps[i][1] < 0) {
        continue;
      }
      boolean added = false; // データが既にsteeringListに加えられたかどうか
      double ID = (double)((double)paths[i][1] / (double)paths[i][0]);
      double steeringTime = (double)(steeringTimestamps[i][1] - steeringTimestamps[i][0]);
      for (int l = 0; l < steeringList.size(); l++) {
        if (steeringList.get(l)[0] != ID) {
          continue;
        }
        double steeringData[] = steeringList.get(l);
        steeringData[1] += steeringTime;
        steeringData[2]++;
        steeringList.set(l, steeringData);
        added = true;
      }
      if (!added) {
        double steeringData[] = {ID, steeringTime, 1};
        steeringList.add(steeringData);
      }
    }
    
    double [] IDs = new double [steeringList.size()];
    double [] steeringTimes = new double[steeringList.size()];
    for (int i = 0; i < steeringList.size(); i++) {
      IDs[i] = steeringList.get(i)[0];
      steeringTimes[i] = (double)((double)steeringList.get(i)[1] / (double)steeringList.get(i)[2]);
    }
    
    linearRegression = new LinearRegression(IDs, steeringTimes);
    
    if (ENVIRONMENT.equals(DEVELOPMENT)) {
      println("====================");
      println("IDs:");
      for (int i = 0; i < IDs.length; i++) {
        println("[" + i + "]" + ":" + IDs[i]);
      }
      println("steeringTimes:");
      for (int i = 0; i < steeringTimes.length; i++) {
        println("[" + i + "]" + ":" + steeringTimes[i]);
      }
      println("R2:" + linearRegression.R2());
      println("intercept:" + linearRegression.intercept());
      println("slope:" + linearRegression.slope());
      println("====================");
    }
  }
}

void drawResult() {
  background(WHITE_COLOR);
  image(resultImg, 0, 0, UNIT * X_NUM, UNIT * Y_NUM);
  
  textAlign(LEFT);
  textFont(bigFont);
  fill(WHITE_COLOR);
  text(RESULT_SCORE + score, RESULT_X, BIG_TEXT_SIZE);
  text(RESULT_COMBO + maxCombo, RESULT_X, BIG_TEXT_SIZE * 2);
  
  textFont(normalFont);
  double R2 = linearRegression.R2();
  double slope = linearRegression.slope();
  double intercept = linearRegression.intercept();
  text("R2: " + R2, RESULT_X, BIG_TEXT_SIZE * 2 + NORMAL_TEXT_SIZE + UNIT * 2);
  text("MT = " + float(round((float)intercept * pow(10, 2))) / pow(10, 2) + " + " + float(round((float)slope * pow(10, 2))) / pow(10, 2) + " ID", RESULT_X, BIG_TEXT_SIZE * 2 + NORMAL_TEXT_SIZE * 2 + UNIT * 2);
}

void stop() {
  audioPlayer.close();
  clickAudioSample.stop();
  selectAudioSample.stop();
  startAudioSample.stop();
  minim.stop();
  super.stop();
}