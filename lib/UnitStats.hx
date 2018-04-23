package lib;

typedef UnitStats = {
     name:String
    ,hp:Int, hpMax:Int
    ,ap:Int//, apMax:Int
    ,mp:Int, mpMax:Int
    ,rank:Null<UnitRank>
  };

enum UnitRank {
  RankS;
  RankA;
  RankB;
  RankD;
  RankF;
}
