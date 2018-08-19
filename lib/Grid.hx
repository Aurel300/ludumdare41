package lib;

class Grid {
  public static inline var TURN_TIME:Int = 12 * 60;
  
  public static inline var TILE_DIM:Int = 32;
  public static inline var TILE_HALF:Int = 16;
  public static inline var TILE_MARGIN:Int = 2;
  public static var tileData:Vector<Int> = Vector.fromArrayCopy([-1]);
  public static var tileDataSelect:Vector<Int> = Vector.fromArrayCopy([-3]);
  public static var tileDataHover:Vector<Int> = Vector.fromArrayCopy([-5]);
  public static var tileDataMove:Vector<Int> = Vector.fromArrayCopy([11]);
  public static var tileDataAttack:Vector<Int> = Vector.fromArrayCopy([8]);
  
  public static var levels:Map<String, Level> = [
      "cactus" => {
           name: "The Cactus"
          ,data: "
.S....
......
....C.
......
......"
          ,map: [
               "S" => Start
              ,"C" => Enemy(Cactus)
            ]
          ,plot: [
               Text("Oh no, it is a duel! Burgers vs. Cactus!")
              ,Text("No worries, you can defeat this cactus easily! It won't move or attack you, unlike more tricky foes.")
              ,Text("In Advance Cookwares you create burgers and deploy them as your army!")
              ,TextUntil("First, let's enter the RV - click on the bar at the bottom of the screen or press space bar.", () -> Main.g.boardY() < 1)
              ,Text("This is where you assemble your burgers and gather ingredients.")
              ,Text("Let's make a simple cheeseburger - bun, patty, cheese, bun.")
              ,Text("The bottom bun is always on the plate.")
              ,TextUntil("Click on the patty in the ingredient box to prepare it!", () -> Main.g.board.task == Tenderise)
              ,TextUntil("Now you need to tenderise it - click as fast as you can!", () -> Main.g.board.task != Tenderise)
              ,Text("Next the patty is grilled. Both sides should reach a crispy brown before serving.")
              ,TextUntil("Pick a spot on the grill and click the patty when you see the flashing symbol.", () -> switch (Main.g.board.task) { case SelectBurger(_): true; case _: false; })
              ,TextUntil("Great! Now choose a spot for the patty.", () -> switch (Main.g.board.task) { case SelectBurger(_): false; case _: true; })
              ,Text("Your burger is scored based on how well you prepare the ingredients, but also on how well you place them.")
              ,TextUntil("Click / press the spacebar when the blue arrow is pointing to a green spot (when it is horizontal or vertical).", () -> switch (Main.g.board.task) { case Drop(_): false; case _: true; })
              ,TextUntil("Now place a slice of cheese on the same burger!", () -> switch (Main.g.board.task) { case Drop(Cheese): true; case _: false; })
              ,TextUntil("Remember to time it well!", () -> switch (Main.g.board.task) { case None: true; case _: false; })
              ,TextUntil("Great! Now you can deploy your burger into battle. Select it and then click the deploy button.", () -> Main.g.boardY() > 1)
              ,Text("You now have a burger ready to fight!")
              ,Text("Different recipes and ingredients result in burgers with different stats and traits. Try various combos!")
              ,Text("You can control your units by clicking them and telling them where to move or what to attack.")
              ,Text("To finish this tutorial, use your burger to defeat that cactus!")
              ,Text("Oh, and WASD to move the camera, Q and E to orbit again. F to zoom in, R to zoom out.")
            ]
        }
      ,"3scorp" => {
           name: "3 Scorpions"
          ,data: "
..........
......x...
.S......X.
......x...
.........."
          ,map: [
               "S" => Start
              ,"x" => Enemy(Scorpion(1))
              ,"X" => Enemy(Scorpion(2))
            ]
        }
      ,"umlaut" => {
             name: "Umlaut"
            ,data: "
...-...
.S.-.U.
...-...
..---..
...-...
.......
......."
          ,map: [
               "S" => Start
              ,"U" => Enemy(UfoSpawner)
              ,"-" => Obstacle
            ]
          ,plot: [
               Text("Also, a UFO crashed.")
              ,Text("Be careful! The saucers can fly over obstacles.")
            ]
        }
      ,"quick" => {
           name: "Quick!"
          ,data: "
...CCCCCG
.S.------
........U"
          ,map: [
               "S" => Start
              ,"-" => Obstacle
              ,"G" => Enemy(Idol)
              ,"C" => Enemy(Cactus)
              ,"U" => Enemy(Ufo(4))
            ]
          ,plot: [
              Text("Be quicker than the UFO destroyer! You win the level if you capture the golden idol.")
            ]
        }
      ,"6scorp" => {
           name: "Ambush"
          ,data: "
..x...........x..
..X.....S.....X..
..x...........x.."
          ,map: [
               "S" => Start
              ,"-" => Obstacle
              ,"x" => Enemy(Scorpion(1))
              ,"X" => Enemy(Scorpion(2))
            ]
        }
      ,"islands" => {
           name: "Islands"
          ,data: "
------------------
------------------
--....-....-....--
--.U..-.......U.--
--....-....-....--
--....-....-....--
---.-----.---.----
--....-....-....--
--....-....-....--
--.......U.-..S.--
--....-....-....--
------------------
------------------"
          ,map: [
               "S" => Start
              ,"-" => Obstacle
              ,"U" => Enemy(UfoSpawner)
            ]
        }
      ,"toxic" => {
           name: "Toxic only"
          ,data: "
.....
.--..
CU-.S
.--..
....."
          ,map: [
               "S" => Start
              ,"-" => Obstacle
              ,"C" => Enemy(Cactus)
              ,"U" => Enemy(Ufo(4))
            ]
          ,plot: [
               Text("There are rumours of a burger recipe that combines the juiciness of saucy, meaty, cheesy, tomato, letuce-y goodness ...")
              ,Text("With the awfulness of coal products.")
              ,Text("Such burgers are toxic and can damage things from afar!")
            ]
        }
    ];
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var w:Int;
  public var h:Int;
  public var turnCounter:Int;
  
  public var units:Vector<Unit>;
  public var renTiles:Vector<P3DPart>;
  
  public var state:GridState = Turn(true, TURN_TIME);
  public var turn:TurnState = Idle;
  
  var renEnts:Vector<GridTile>;
  public var rv:Unit;
  
  public var playerTime(get, never):Float;
  private inline function get_playerTime():Float {
    return (switch (state) {
        case Turn(true, t): t / TURN_TIME;
        case _: 0;
      });
  }
  
  public function new() {}
  
  public function resetLevel(x:Int, y:Int, level:Level):Void {
    var data:Array<Array<lib.Level.LevelElement>>
      = level.data.split("\n").slice(1)
        .map(l -> l.split("").map(c -> level.map.exists(c) ? level.map[c] : lib.Level.LevelElement.None));
    reset(x, y, data[0].length, data.length);
    for (y in 0...h) for (x in 0...w) {
      switch (data[y][x]) {
        case Start: (rv = new RV()).putAt(this, x, y);
        case Obstacle: renEnts[c2i(x, y)].walkable = renTiles[c2i(x, y)].display = false;
        case Enemy(type): (new Enemy(type)).putAt(this, x, y);
        case _:
      }
    }
  }
  
  public function reset(x:Int, y:Int, w:Int, h:Int):Void {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    turnCounter = 0;
    units = new Vector(w * h);
    renEnts = new Vector(w * h);
    renTiles = new Vector(w * h);
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renEnts[vi] = new GridTile(this, x, y);
      renTiles[vi] = renEnts[vi].part;
      vi++;
    }
  }
  
  public function deploy(b:Burger):Bool {
    switch (state) {
      case Turn(false, _): return false;
      case _:
      b.addLayer(BunTop);
      var deployAt = i2c(bfs(rv, true)[0].ati);
      b.putAt(this, deployAt.x, deployAt.y);
      return true;
    }
  }
  
  inline function c2i(x:Int, y:Int):Int return x + y * w;
  inline function i2c(i:Int):{x:Int, y:Int} return {x: i % w, y: (i / w).floorZ()};
  inline function idist(i:Int, j:Int):Int {
    var p1 = i2c(i);
    var p2 = i2c(j);
    return (p1.x - p2.x).absI() + (p1.y - p2.y).absI();
  }
  
  function clearUnits(player:Bool):Void {
    turnCounter++;
    var healer = [];
    var smell = [];
    //var poison = [];
    var toxic = [];
    var num = 0;
    for (vi in 0...units.length) {
      if (units[vi] == null) continue;
      for (t in units[vi].stats.traits) switch (t) {
        case Healer if (units[vi].player == player): healer.push(vi);
        case Smell if (units[vi].player != player): smell.push(vi);
        //case Poison if (units[vi].player != player): poison.push(vi);
        case Toxic if (units[vi].player != player): toxic.push(vi);
        case _:
      }
      if (units[vi].player != player) continue;
      num++;
      units[vi].aiMoved = false;
      units[vi].stats.mp = units[vi].stats.mpMax;
      units[vi].stats.ap = units[vi].stats.apMax;
    }
    if (num == 0) {
      Main.g.enterRoam(!player);
    }
    for (vi in 0...units.length) {
      if (units[vi] == null) continue;
      if (units[vi].player != player) continue;
      for (h in healer) {
        if (idist(h, vi) <= 2 && h != vi) units[vi].stats.hp = (units[vi].stats.hp + 1).minI(units[vi].stats.hpMax);
      }
      for (s in smell) {
        if (idist(h, vi) <= 2) units[vi].stats.ap = (units[vi].stats.ap - 1).maxI(1);
      }
      for (t in toxic) {
        if (idist(h, vi) <= 2) units[vi].stats.hp = (units[vi].stats.hp - 1).maxI(1);
      }
      if (units[vi].stats.poison > 0) {
        units[vi].stats.hp = (units[vi].stats.hp - 1).maxI(1);
        units[vi].stats.poison--;
      }
    }
  }
  
  function ai(u:Unit, allies:Array<Unit>, enemies:Array<Unit>):AIOutcome {
    u.aiMoved = true;
    var space = bfs(u);
    if (enemies.length == 0 || space.length == 0) return space[0];
    var hpf = u.stats.hp / u.stats.hpMax;
    var aggressive = u.stats.ap > 10;
    for (s in space) {
      var sc = i2c(s.ati);
      var closest = null;
      var closestDist = 0;
      for (e in enemies) {
        var dist = (e.gridX - sc.x).absI() + (e.gridY - sc.y).absI();
        if (closest == null || dist < closestDist) {
          closest = e;
          closestDist = dist;
        }
      }
      if (aggressive) {
        if (s.attack) return s;
        s.score = -closestDist;
      } else {
        var damage = 0.0;
        if (s.attack) {
          var tgt = units[s.ati];
          damage += u.stats.ap;
          if (u.stats.ap < tgt.stats.hp) {
            damage -= tgt.stats.ap * .3;
          }
        }
        var proxMod = 1 / (hpf * u.stats.ap * closestDist);
        closest = null;
        closestDist = 0;
        for (e in allies) {
          var dist = (e.gridX - sc.x).absI() + (e.gridY - sc.y).absI();
          if (closest == null || dist < closestDist) {
            closest = e;
            closestDist = dist;
          }
        }
        var distMod = (1 - hpf) * closestDist;
        s.score = damage + proxMod + distMod;
      }
    }
    space.sort((a, b) -> a.score < b.score ? 1 : -1);
    if (aggressive) return space[0];
    var i = 0;
    while (i < space.length - 1 && FM.prng.nextMod(3) == 0) i++;
    return space[i];
  }
  
  public function update():Void {
    state = (switch [state, turn] {
        case [_, WaitFor(u)]: turn = (u.anim == None ? initTurn(Idle) : turn); state;
        case [Turn(false, _), _]:
        var them = [];
        var us = [ for (u in units) {
            if (u == null) continue; 
            if (u.player) { them.push(u); continue; }
            if (u.aiMoved) continue;
            u;
          } ];
        if (us.length == 0) {
          initTurn(Idle);
          clearUnits(true);
          Turn(true, TURN_TIME);
        } else {
          var tu = FM.prng.nextElement(us);
          us.remove(tu);
          act(tu, ai(tu, us, them).ati);
          turn = WaitFor(tu);
          Turn(false, 1);
        }
        case [Turn(p, t), _]:
        if (t > 0) Turn(p, t - 1);
        else {
          initTurn(Idle);
          clearUnits(!p);
          Turn(!p, TURN_TIME);
        }
        case _: state;
      });
    var selVi = (switch [state, turn] {
        case [_, WaitFor(u)]: turn = (u.anim == None ? Idle : turn); -1;
        case [Turn(true, t), Inspect(s) | Select(s)]: c2i(s.gridX, s.gridY);
        case _: if (GUI.currentStatsGrid) GUI.hide("stats"); -1;
      });
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renTiles[vi].data = renEnts[vi].mouse
        ? tileDataHover : (vi == selVi
          ? tileDataSelect : (renEnts[vi].move
            ? tileDataMove : (renEnts[vi].attack
              ? tileDataAttack : tileData)));
      vi++;
    }
  }
  
  function clearMove():Void {
    for (vi in 0...renEnts.length) {
      renEnts[vi].move = false;
      renEnts[vi].attack = false;
      renEnts[vi].moveFX = 0;
      renEnts[vi].moveFY = 0;
      renEnts[vi].moveDist = -1;
    }
  }
  
  function bfs(sel:Unit, ?first:Bool = false):Array<AIOutcome> {
    var ret:Array<AIOutcome> = [];
    clearMove();
    var flying = sel.stats.traits.indexOf(Flying) != -1;
    var queue = [{fx: sel.gridX, fy: sel.gridY, x: sel.gridX, y: sel.gridY, dist: 0}];
    while (queue.length > 0) {
      var cur = queue.shift();
      if (!cur.x.withinI(0, w - 1) || !cur.y.withinI(0, h - 1)) continue;
      var i = c2i(cur.x, cur.y);
      var cent = renEnts[i];
      if (units[i] != null && units[i] != sel && !first) {
        if (units[i].player != sel.player) {
          ret.push({
               score: 0
              ,ati: i
              ,attack: true
            });
          cent.attack = true;
          cent.moveFX = cur.fx - cur.x;
          cent.moveFY = cur.fy - cur.y;
          cent.moveDist = cur.dist;
        }
        continue;
      }
      if (!cent.walkable && !flying) continue;
      if (cent.moveDist == -1 || cur.dist < cent.moveDist) {
        ret.push({
             score: 0
            ,ati: i
            ,attack: false
          });
        if (first && i != c2i(sel.gridX, sel.gridY)) {
          return [ret[ret.length - 1]];
        }
        cent.move = true;
        cent.moveFX = cur.fx - cur.x;
        cent.moveFY = cur.fy - cur.y;
        cent.moveDist = cur.dist;
      }
      if (cur.dist < sel.stats.mp || first) {
        for (off in [
             {x: -1, y: 0}
            ,{x: 1, y: 0}
            ,{x: 0, y: -1}
            ,{x: 0, y: 1}
          ]) {
          queue.push({fx: cur.x, fy: cur.y, x: cur.x + off.x, y: cur.y + off.y, dist: cur.dist + 1});
        }
      }
    }
    return ret;
  }
  
  function act(sel:Unit, ati:Int):Void {
    if (ati == c2i(sel.gridX, sel.gridY)) {
      switch (sel.stats.name) {
        case "UFO spawner":
        if (turnCounter % 3 == 0) {
          var e = new Enemy(Ufo(1));
          var deployAt = i2c(bfs(sel, true)[0].ati);
          e.putAt(this, deployAt.x, deployAt.y);
        }
        case _:
      }
      return;
    }
    var curi = ati;
    var cur = renEnts[ati];
    var canim:UnitAnimation = None;
    if (renEnts[ati].attack) {
      canim = Func(() -> {
          units[ati].hit(sel.stats.ap, sel.stats.traits.indexOf(Poison) != -1);
          sel.stats.mp = 0;
        }, None);
    }
    var first = true;
    while (cur.moveFX != 0 || cur.moveFY != 0) {
      canim = (renEnts[ati].attack && first
        ? Attack(-cur.moveFX, -cur.moveFY, 0, canim)
        : Walk(-cur.moveFX, -cur.moveFY, 0, canim));
      curi += c2i(cur.moveFX, cur.moveFY);
      cur = renEnts[curi];
      sel.stats.mp--;
      first = false;
    }
    sel.anim = canim;
  }
  
  function initTurn(turn:TurnState):TurnState {
    this.turn = turn;
    switch (turn) {
      case Select(sel): bfs(sel);
      case _: clearMove();
    }
    return turn;
  }
  
  public function gridClick(x:Int, y:Int):Void {
    var ati = c2i(x, y);
    switch (state) {
      case Turn(true, _):
      var showStats = false;
      var atGrid = units[ati];
      turn = (switch (turn) {
          case Idle:
          if (atGrid != null) {
            showStats = true;
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Inspect(_):
          if (atGrid != null) {
            showStats = true;
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Select(sel):
          if (atGrid == sel) Idle;
          else if (renEnts[ati].move || renEnts[ati].attack) {
            act(sel, ati);
            WaitFor(sel);
          } else if (atGrid == null) Idle;
          else if (atGrid.player) {
            showStats = true;
            Select(atGrid);
          }
          else Idle;
          case _: turn;
        });
      if (showStats) GUI.showStats(atGrid.stats, true);
      else if (GUI.currentStatsGrid) GUI.hide("stats");
      initTurn(turn);
      case _:
    }
  }
}

class GridTile implements Entity {
  public var grid:Grid;
  public var part:P3DPart;
  public var x:Int;
  public var y:Int;
  public var mouse:Bool = false;
  public var move:Bool = false;
  public var attack:Bool = false;
  public var moveFX:Int;
  public var moveFY:Int;
  public var moveDist:Int;
  public var walkable:Bool = true;
  
  public function new(grid:Grid, x:Int, y:Int) {
    this.grid = grid;
    this.x = x;
    this.y = y;
    part = new P3DPart(this);
    part.vert = false;
    part.x = grid.x + x * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.y = grid.y + y * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.z = 1;
    part.data = Grid.tileData;
    part.w = part.h = Grid.TILE_DIM - Grid.TILE_MARGIN * 2;
    part.dw = part.dh = 1;
  }
  
  public function partClick():Void grid.gridClick(x, y);
  public function partMOver():Void mouse = true;
  public function partMLeave():Void mouse = false;
}

enum GridState {
  // intro, win, loss?
  
  Turn(player:Bool, time:Int);
}

enum TurnState {
  Idle;
  Inspect(u:Unit);
  Select(u:Unit);
  WaitFor(u:Unit);
}

typedef AIOutcome = {
     score:Float
    ,ati:Int
    ,attack:Bool
  };
