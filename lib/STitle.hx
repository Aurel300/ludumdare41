package lib;

class STitle extends sk.thenet.app.JamState {
  public function new(app) super("title", app);
  
  var txt = new sk.thenet.anim.Bitween(60);
  
  override public function tick() {
    txt.setTo(true);
    txt.tick();
    ab.fill(Pal.reg[7]);
    Text.render(ab, -Main.W + (txt.valueF * Main.W).floorZ() + 8, 8, "Advance Cookwares

A game made for LD41 in 72 hours
By Aurel B%l&
With music by Adrian Hall

Click to start");
  }
  
  override public function mouseClick(_, _) st("game");
}
