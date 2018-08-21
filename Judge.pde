class Judge {
  public int duration = 20;
  public String comment = "";
  
  Judge(String comment) {
    this.comment = comment;
  }
  
  public void display() {
    text(comment, 0, 0);
    this.duration--;
  }
}