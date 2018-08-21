import ddf.minim.*;
import ddf.minim.effects.*;

PImage titleImg;

Minim minim;
AudioPlayer audioPlayer;
AudioSample audioSample;

String stage; // 現在何をしているのか格納する

ArrayList<Judge> judges = new ArrayList<Judge>();

int [] states;
int noteIndex = 0;
int pathIndex = 0;
boolean steering = false;
int steeringNoteIndex = -1; // ステアリング中のノートのインデックス
int steeringPathIndex = -1;
ArrayList<Position> steeringPositions = new ArrayList<Position>(); // ステアリング中のマウス座標を全部記録

int getNoteIndex() {
  return int((audioPlayer.position() - OFFSET) / MPN - 0.5);
}

int getPathIndex() {
  int pathIndex = 0;
  for (int i = 0; i < notes.length; i++) {
    if (notes[i] == 0) {
      continue;
    }
    if (states[i] == STATE_GREAT || states[i] == STATE_GOOD || states[i] == STATE_OKAY || states[i] == STATE_BAD) {
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
  textSize(TEXT_SIZE);
  
  titleImg = loadImage("title.png");

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
  if (!stage.equals(STAGE_TITLE)) {
    return;
  }
  // スペースキーが押されたらタイトル画面終了でゲームに移行する
  if (keyCode == SPACE_KEY_CODE) {
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

  audioSample.trigger();

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
      if (abs(i) <= GREAT_RANGE) {
        states[noteIndex + i] = STATE_GREAT_STEERING;
      } else if (abs(i) <= GOOD_RANGE) {
        states[noteIndex + i] = STATE_GOOD_STEERING;
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
  if (noteIndex - (OKAY_RANGE + 1) >= 0 && noteIndex - (OKAY_RANGE + 1) < notes.length) {
    if (notes[noteIndex - (OKAY_RANGE + 1)] == 1 && states[noteIndex - (OKAY_RANGE + 1)] == STATE_FRESH) {
      states[noteIndex - (OKAY_RANGE + 1)] = STATE_BAD;
      judges.add(new Judge(BAD_COMMENT, START_X, CENTER_Y, RED_COLOR));
    }
  }

  // 判定描画
  for (int i = 0; i < judges.size(); i++) {
    fill(0);
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
        judges.add(new Judge(BAD_COMMENT, mouseX, mouseY, RED_COLOR));
        steering = false;
        steeringPositions = new ArrayList<Position>();
      }
    }

    // ステアリング終了していた場合
    if (mouseX > START_X + paths[pathIndex][1]) {
      switch (states[steeringNoteIndex]) {
        case STATE_GREAT_STEERING:
          states[steeringNoteIndex] = STATE_GREAT;
          judges.add(new Judge(GREAT_COMMENT, mouseX, mouseY, RED_COLOR));
          break;
        case STATE_GOOD_STEERING:
          states[steeringNoteIndex] = STATE_GOOD;
          judges.add(new Judge(GOOD_COMMENT, mouseX, mouseY, RED_COLOR));
          break;
        case STATE_OKAY_STEERING:
          states[steeringNoteIndex] = STATE_OKAY;
          judges.add(new Judge(OKAY_COMMENT, mouseX, mouseY, RED_COLOR));
          break;
        default:
          break;
      }
      steering = false;
      steeringPositions = new ArrayList<Position>();
    }

    // ステアリングの軌跡を描画
    stroke(RED_COLOR);
    for (int i = 0; i < steeringPositions.size() - 1; i++) {
      line(steeringPositions.get(i).x, steeringPositions.get(i).y, steeringPositions.get(i + 1).x, steeringPositions.get(i + 1).y);
    }
    noStroke();
  }

  if (noteIndex >= notes.length) {
    stage = STAGE_RESULT;
    audioPlayer.pause();
  }

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
    println("====================");
  }
}

void drawResult() {
  background(WHITE_COLOR);
}

void stop() {
  audioPlayer.close();
  audioSample.stop();
  minim.stop();
  super.stop();
}