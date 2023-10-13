unit blocks;

{$mode objfpc}{$H+}



interface

  uses Generics.Collections;

  type
    tBlock = record
      blockId: integer;
    end;

  baseBlock = class
  private

  protected

  public

    isStepable: boolean;
    isEnemy: boolean;
    isBreakable: boolean;
    procedure onStep;       virtual;
    procedure onRender(X,Y: integer);     virtual;
    procedure onDamage(damage, X,Y: integer);     virtual;
  end;

   nonStepBlock = class(baseBlock)
   end;

   stepBlock = class(baseBlock)
   end;

   fenceBlock = class(baseBlock)
     health: integer;
     procedure onDamage(damage, X,Y: integer); override;
   end;

   candleBlock = class(baseBlock)
     health: integer;
     procedure onDamage(damage, X,Y: integer); override;
   end;

     goldBlock = class(baseBlock)
     procedure onStep(); override;
   end;

     foodBlock = class(baseBlock)
     procedure onStep(); override;
   end;

     renderBlock = class(baseBlock)
     procedure onRender(X,Y:integer); override;
   end;

     trapBlock = class(baseBlock)
     procedure onStep(); override;
   end;

     guardBlock = class(baseBlock)
     health: integer;
     procedure onRender(X,Y:integer); override;
     procedure onDamage(damage, X,Y: integer); override;
   end;

     bossBlock = class(baseBlock)
     health: integer;
     procedure onRender(X,Y:integer); override;
     procedure onDamage(damage, X,Y: integer); override;
   end;

      searchMap = specialize TDictionary<integer,baseBlock>;


function getBlockById(id: integer):baseBlock;

var
  blocksSearcher: searchMap;
  stepableBlocks: array of integer = (0,1,2,3,4,5,6,7,67,720,256,255,303,301,302,304,305,730,731,732,150, 619, 566);
  fenceBlocks: array of integer = (149);
  goldBlocks: array of integer = (214);
  foodBlocks: array of integer = (801, 802, 128, 182, 84, 139, 296, 561, 40);
  renderBlocks: array of integer = (509, 432);
  trapBlocks: array of integer = (714, 715, 716, 718, 719, 717);
  guardBlocks: array of integer = (123);
  candleBlocks: array of integer = (724);
  bossBlocks: array of integer = (120);
  rowTraps: integer = 0;


  i:integer;
  tempStep: stepBlock;
  tempNonStep: nonStepBlock;
  tempFenceBlock: fenceBlock;
  tempGoldBlock: goldBlock;
  tempFoodBlock: foodBlock;
  tempRenderBlock: renderBlock;
  tempTrapBlock: trapBlock;
  tempGuardBlock: guardBlock;
  tempCandleBlock: candleBlock;
  tempBossBlock: bossBlock;

  map: array of array of tBlock;
  HeroHealth: integer = 30;
  HeroGold: integer = 1;
  HeroDamage: integer = 2;
  HeroBlueKey: boolean = False;
  HeroCrown: boolean = False;
  HeroTile: integer = 25;
  candleAmount: integer = 0;
  Win: boolean = False;

  sizeX, sizeY, offsetX, offsetY, currX, currY: integer;
implementation

    procedure baseBlock.onStep;
    begin
    end;
    procedure baseBlock.onRender(X,Y: integer);
    begin
    end;
    procedure baseBlock.onDamage(damage, X,Y: integer);
    begin
    end;

    procedure fenceBlock.onDamage(damage, X,Y: integer);
    begin
        if health - damage <= 0 then
          map[x,y].blockId := 150;
    end;

    procedure candleBlock.onDamage(damage, X,Y: integer);
    begin
        if health - damage <= 0 then begin
          map[x,y].blockId := 0;
          candleAmount := candleAmount + 1;
        end;
    end;

    procedure goldBlock.onStep();
    begin
        HeroGold := HeroGold + 1;
        map[currY,currX].blockId := 0;
    end;

    procedure foodBlock.onStep();
    var bId: integer;
    begin
        bId := map[currY,currX].blockId;
        if (bId = 801) or (bId = 802) or (bId = 182) or (bId = 40) or (bId = 84) then
          begin
                      HeroHealth := HeroHealth + 5;
                      if (bId = 182) or (bId = 40) or (bId = 84) then HeroTile := 28;
          end;


        if (bId = 128) then
          HeroDamage := HeroDamage + 1;

        if (bId = 561) then
          HeroBlueKey := True;

        if (bId = 139) then
          HeroCrown := True;

        map[currY,currX].blockId := 0;
    end;
    
    procedure renderBlock.onRender(X,Y: integer);
    var bId: integer;
    begin
        bId := map[Y,X].blockId;
        if bId = 509 then
          begin
            if map[Y+1,X].blockId = 214 then
              begin

                 map[Y+1,X].blockId := 0;
                 map[Y+2,X-3].blockId := 0;
              end;
          end;

        if (bId = 432) and (HeroBlueKey) then
          map[Y,X].blockId := 0

    end;

    procedure trapBlock.onStep();
    var bId: integer;
    begin
        bId := map[currY,currX].blockId;
        if (bId = 714) and (rowTraps = 0) then
            inc(rowTraps)
        else if (bId = 715) and (rowTraps = 1) then
            inc(rowTraps)
        else if (bId = 716) and (rowTraps = 2) then
            inc(rowTraps)
        else if (bId = 717) and (rowTraps = 3) then
            inc(rowTraps)
       else if (bId = 718) and (rowTraps = 4) then
            inc(rowTraps)
       else if (bId = 719) and (rowTraps = 5) then
            inc(rowTraps)
       else dec(HeroHealth);


        map[currY,currX].blockId := 0;
    end;


    procedure guardBlock.onRender(X,Y: integer);
    var i, j: integer;
    begin
        if not HeroCrown then
          begin
            for i:=Y-2 to Y+2 do
              for j:= X-2 to X+2 do
                begin
                  if (currX = j) and (currY = i) then
                    begin
                    HeroHealth := HeroHealth - 5;
                    end
                end
            end
        else map[Y,X].blockId := 0;
    end;


    procedure guardBlock.onDamage(damage, X,Y: integer);
    begin
        health := health - damage;
        if health <= 0 then
          map[X,Y].blockId := 0;
    end;

    procedure bossBlock.onRender(X,Y: integer);
    var i, j: integer;
    begin
      if candleAmount < 5 then
        begin
          for i:=Y-1 to Y+1 do
            for j:= X-1 to X+1 do
              begin
              if (currX = j) and (currY = i) then
                begin
                HeroHealth := HeroHealth - 100;
                end
              end
        end;
    end;

    procedure bossBlock.onDamage(damage, X,Y: integer);
    begin
        health := health - damage;
        if health <= 0 then
          begin
            map[X,Y].blockId := 566;
            Win := True;
          end;

    end;

   function getBlockById(id: integer):baseBlock;
   begin
       blocks.blocksSearcher.TryGetValue(id, getBlockById);
   end;

initialization
begin
  blocksSearcher := searchMap.Create;

  tempStep := stepBlock.Create;
  tempStep.isStepable := True;
  tempStep.isBreakable := False;
  tempStep.isEnemy := False;

  tempNonStep := nonStepBlock.Create;
  tempNonStep.isStepable := False;
  tempNonStep.isBreakable := False;
  tempNonStep.isEnemy := False;

  tempFenceBlock := fenceBlock.Create;
  tempFenceBlock.isBreakable := True;
  tempFenceBlock.isEnemy := False;
  tempFenceBlock.isStepable := False;
  tempFenceBlock.health := 1;

  tempCandleBlock := candleBlock.Create;
  tempCandleBlock.isBreakable := True;
  tempCandleBlock.isEnemy := False;
  tempCandleBlock.isStepable := True;
  tempCandleBlock.health := 1;

  tempGoldBlock := goldBlock.Create;
  tempGoldBlock.isBreakable := False;
  tempGoldBlock.isEnemy := False;
  tempGoldBlock.isStepable := True;

  tempFoodBlock := foodBlock.Create;
  tempFoodBlock.isBreakable := False;
  tempFoodBlock.isEnemy := False;
  tempFoodBlock.isStepable := True;

  tempRenderBlock := renderBlock.Create;
  tempRenderBlock.isBreakable := False;
  tempRenderBlock.isEnemy := False;
  tempRenderBlock.isStepable := False;

  tempTrapBlock := trapBlock.Create;
  tempTrapBlock.isBreakable := False;
  tempTrapBlock.isEnemy := False;
  tempTrapBlock.isStepable := True;

  tempGuardBlock := guardBlock.Create;
  tempGuardBlock.isBreakable := False;
  tempGuardBlock.isEnemy := True;
  tempGuardBlock.isStepable := False;
  tempGuardBlock.health := 6;

  tempBossBlock:= bossBlock.Create;
  tempBossBlock.isBreakable := False;
  tempBossBlock.isEnemy := True;
  tempBossBlock.isStepable := False;
  tempBossBlock.health := 4;

  for i:=0 to Length(stepableBlocks)-1 do
  begin
    blocksSearcher.Add(stepableBlocks[i], tempStep);
  end;

  for i:=0 to Length(fenceBlocks)-1 do
  begin
    blocksSearcher.Add(fenceBlocks[i], tempFenceBlock);
  end;

  for i:=0 to Length(candleBlocks)-1 do
  begin
    blocksSearcher.Add(candleBlocks[i], tempCandleBlock);
  end;

  for i:=0 to Length(goldBlocks)-1 do
  begin
    blocksSearcher.Add(goldBlocks[i], tempGoldBlock);
  end;

  for i:=0 to Length(foodBlocks)-1 do
  begin
    blocksSearcher.Add(foodBlocks[i], tempFoodBlock);
  end;

  for i:=0 to Length(renderBlocks)-1 do
  begin
    blocksSearcher.Add(renderBlocks[i], tempRenderBlock);
  end;

  for i:=0 to Length(trapBlocks)-1 do
  begin
    blocksSearcher.Add(trapBlocks[i], tempTrapBlock);
  end;

  for i:=0 to Length(guardBlocks)-1 do
  begin
    blocksSearcher.Add(guardBlocks[i], tempGuardBlock);
  end;

  for i:=0 to Length(bossBlocks)-1 do
  begin
    blocksSearcher.Add(bossBlocks[i], tempBossBlock);
  end;

  for i:=0 to 1055 do
  begin
    if blocksSearcher.ContainsKey(i) = False then blocksSearcher.Add(i, tempNonStep);
  end;

end;

end.

