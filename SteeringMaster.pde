void settings() {
  size(UNIT * X_NUM, UNIT * Y_NUM);
}

void setup() {
  noStroke();
}

void draw() {
  background(255, 255, 255);
  
  // 左側水色部分
  fill(157, 204, 224);
  rect(0, 0, UNIT * 10, UNIT * Y_NUM);
  
  // 右側緑色部分
  fill(152, 251, 152);
  rect(UNIT * 10, 0, UNIT * (X_NUM - 10), UNIT * Y_NUM);
  
  if (ENV.equals("development")) {
    // 判定部分（デバッグ用）
    fill(0, 0, 0);
    rect(0, UNIT * 17 - 1, UNIT * X_NUM, 2);
  }
}