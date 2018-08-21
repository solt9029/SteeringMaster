class Path {
  public boolean isNote = true;
  public int w;
  public int l;
  
  Path(int w, int l) {
    this.w = w;
    this.l = l;
  }
  
  Path(boolean isNote) {
    this.isNote = isNote;
  }
}