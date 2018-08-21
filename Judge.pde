class Judge {
  private final int INITIAL_DURATION = 20;
  public int duration = this.INITIAL_DURATION;
  public String comment = "";
  public int x;
  public int y;
  public color c;
  
  Judge(String comment, int x, int y, color c) {
    this.comment = comment;
    this.x = x;
    this.y = y;
    this.c = c;
  }
  
  public void display() {
    fill(this.c);
    text(this.comment, this.x, this.y);
    this.duration--;
  }
}