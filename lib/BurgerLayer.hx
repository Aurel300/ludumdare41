package lib;

enum BurgerLayer {
  BunTop;
  Tomato;
  Carrot;
  Cucumber;
  Patty(cook:Int);
  Lettuce;
  Cheese;
  Sauce;
  Pepsalt;
  BunBottom;
  
  Scored(l:BurgerLayer, r:UnitRank);
}
