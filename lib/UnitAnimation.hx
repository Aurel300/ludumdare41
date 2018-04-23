package lib;

enum UnitAnimation {
  None;
  Walk(ox:Int, oy:Int, f:Int, n:UnitAnimation);
  Attack(ox:Int, oy:Int, f:Int, n:UnitAnimation);
  Func(f:Void->Void, n:UnitAnimation);
}
