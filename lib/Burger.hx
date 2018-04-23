package lib;

class Burger extends Unit {
  public static var pattyMap = [
       0 => null
      ,1 => [
           17 => 7
          ,18 => 17
          ,19 => 18
        ]
      ,2 => [
           17 => 7
          ,18 => 23
          ,19 => 1
        ]
      ,3 => [
           17 => 7
          ,18 => 20
          ,19 => 21
        ]
    ];
  
  public var lastZ:Int = 0;
  public var recipe:Array<BurgerLayer> = [];
  public var recipeRanks:Array<UnitRank> = [];
  
  public function new() {
    super();
    player = true;
    stats = {
         name: "Untitled burger"
        ,hp: 1, hpMax: 1
        ,ap: 1
        ,mp: 1, mpMax: 1
        ,rank: RankS
        ,traits: []
      };
    addLayer(BunBottom);
  }
  
  public function restat():Void {
    function check(cur:Array<BurgerLayer>, l:BurgerLayer):Int {
      for (i in 0...cur.length) switch [cur[i], l] {
        case [BunTop, BunTop]
         | [Tomato, Tomato]
         | [Carrot, Carrot]
         | [Cucumber, Cucumber]
         | [Lettuce, Lettuce]
         | [Cheese, Cheese]
         | [Sauce, Sauce]
         | [Pepsalt, Pepsalt]
         | [BunBottom, BunBottom]: return i;
        case [Patty(a), Patty(b)]: if (a == b) return i;
        case _:
      }
      return -1;
    }
    function checkAll(cur:Array<BurgerLayer>, recipe:Array<BurgerLayer>, ?ignoreSeasoning:Bool = true):Bool {
      if (cur.length != recipe.length) return false;
      var cc = cur.copy();
      if (ignoreSeasoning) cc = cc.filter(c -> switch (c) {
          case Sauce | Pepsalt: false;
          case _: true;
        });
      for (r in recipe) {
        var cci = check(cc, r);
        if (cci == -1) return false;
        cc.splice(cci, 1);
      }
      return true;
    }
    var hp = 1;
    var ap = 1;
    var mp = 1;
    var traits:Array<UnitTrait> = [];
    stats.name = (switch (recipe) {
        case [Patty(0)]: mp = 3; "Rawburger";
        case [Patty(3)]: ap = 3; "Coalburger";
        case checkAll(_, [Patty(0), Patty(3)]) => true: ap = mp = 3; "Raw coal";
        case checkAll(_, [Lettuce, Tomato, Cucumber, Carrot]) => true: hp = 5; ap = 2; mp = 2; "Veggie burger";
        case [Patty(_.withinI(0, 2) => true), Cheese, Patty(_.withinI(0, 2) => true)]: hp = 3; ap = 3; mp = 3; "Jucy Lucy";
        case [Sauce, Patty(3), Cheese, Tomato, Lettuce]: ap = 4; mp = 2; traits.push(Toxic); "Juicy coalburger";
        case [Sauce, Patty(_), Cheese, Tomato, Lettuce]: hp = 3; ap = 4; mp = 3; "Juicy burger";
        case [Lettuce, Tomato, Patty(_.withinI(0, 2) => true), Cucumber]: hp = ap = mp = 3; "Classic burger";
        case [Lettuce, Tomato, Patty(_.withinI(0, 2) => true), Cheese]: hp = ap = mp = 3; "Cheeseburger";
        case [Sauce]: mp = 3; traits.push(Healer); "Raw sauce";
        case checkAll(_, [Patty(0), Patty(1), Patty(2), Patty(3)]) => true: traits.push(Poison); "Gradient burger";
        case checkAll(_, [Patty(0), Cheese, Patty(1), Cheese, Patty(2), Cheese, Patty(3)]) => true: hp = ap = mp = 3; traits.push(Poison); "Gradient cheeseburger";
        case checkAll(_, [Cheese, Tomato]) => true: hp = ap = mp = 2; "Toastie";
        case checkAll(_, [Cheese, Tomato, Pepsalt], false) => true: hp = ap = mp = 2; traits.push(Healer); "Seasoned toastie";
        case checkAll(_, [Cheese, Patty(2)]) => true: hp = 2; ap = 3; mp = 1; traits.push(Healer); "Croque-monsieur";
        case []: "Untitled burger";
        case _:
        var shp = 0.3;
        var sap = 0.3;
        var smp = 0.3;
        for (r in recipe) switch (r) {
          case Tomato | Carrot | Cucumber: smp += .4;
          case Patty(3): sap += 1.8; shp -= 2.1;
          case Patty(cook): sap += .2 + .2 * cook; shp += .1;
          case Lettuce: shp += .2; smp += .3;
          case Cheese: shp += .3;
          case _:
        }
        hp += shp.floor().maxI(0);
        ap += sap.floor().maxI(0);
        mp += smp.floor().maxI(0);
        "Mutt burger";
      });
    if (check(recipe, Sauce) != -1) mp++;
    if (check(recipe, Pepsalt) != -1) ap++;
    stats.hpMax = hp;
    stats.ap = ap;
    stats.mpMax = mp;
    stats.traits = traits;
    
    var total = 0;
    for (r in recipeRanks) total += r;
    var align = 0;
    for (a in 1...layers.length) {
      align += (layers[a].angle % 9).minI((Trig.densityAngle - layers[a].angle) % 9);
    }
    stats.rank = ((total >> 1) + (align / 6).floor()).minI(UnitRank.RankF);
    var maxStat = (switch (stats.rank) {
        case RankS: 7;
        case RankA: 5;
        case RankB: 3;
        case RankD: 2;
        case RankF: 1;
      });
    stats.hpMax = stats.hpMax.minI(maxStat);
    stats.ap = stats.ap.minI(maxStat);
    stats.mpMax = stats.mpMax.minI(maxStat);
  }
  
  public function addLayer(t:BurgerLayer, ?map:Map<Int, Int>):P3DBuild {
    var rank = -1;
    var off = 0;
    function parseLayer(t:BurgerLayer) {
      var add = true;
      var ret = (switch (t) {
          case BunTop | BunBottom: add = false; t;
          case Scored(l, s): rank = s; add = false; parseLayer(l);
          case _: t;
        });
      if (add) recipe.push(ret);
      return ret;
    }
    var unpacked = parseLayer(t);
    var layer = P3DBuild.build(
        Anchor("")
        ,[Offset(switch (unpacked) {
            case BunTop: off = 6; Unit.ss["bunTop"];
            case BunBottom: off = 5; Unit.ss["bunBottom"];
            case Tomato: off = 2; Unit.ss["tomato"];
            case Carrot: off = 2; Unit.ss["carrot"];
            case Cucumber: off = 2; Unit.ss["cucumber"];
            case Patty(cook): map = pattyMap[cook]; off = 4; Unit.ss["patty"];
            case Lettuce: off = 1; Unit.ss["lettuce"];
            case Cheese: off = 1; Unit.ss["cheese"];
            case Sauce: off = 1; Unit.ss["sauce"];
            case Pepsalt: off = 1; Unit.ss["pepsalt"];
            case _: null;
          }, 0, 0, lastZ, 0)]
        ,null
      );
    if (rank != -1) recipeRanks.push(rank);
    restat();
    if (map != null) for (p in layer.parts) p.remap(map);
    layers.push(layer);
    lastZ += off;
    return layer;
  }
}
