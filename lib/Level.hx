package lib;

typedef Level = {
     name:String
    ,data:String
    ,map:Map<String, LevelElement>
    ,?plot:Array<LevelPlot>
    ,?beaten:Bool
  };

enum LevelElement {
  None;
  Obstacle;
  Start;
  Enemy(t:lib.Enemy.EnemyType);
}

enum LevelPlot {
  Text(t:String);
  TextUntil(t:String, f:Void->Bool);
}
