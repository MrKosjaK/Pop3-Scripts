import(Module_Defines);
import(Module_Game);
import(Module_Globals);
import(Module_Map);
import(Module_Objects);
import(Module_Players);
import(Module_String);
import(Module_System);
import(Module_Table);

--global pointer to scenery constants, since i don't know if someone modified them
local scenery_consts = scenery_type_info();

local max_amount_of_decaying_trees = 10; --maximum decaying trees.
local trees_buffer = {}; --decaying trees buffer for processing them.
local current_decaying_trees = 0; --current decaying trees, used for controlling and saving.

--class implementation
local DecayTree = {};
DecayTree.__index = DecayTree;

setmetatable(DecayTree, {
  __call = function(cls, ...)
    return cls.new(...);
  end,
});

function DecayTree:createDT()
  local self = setmetatable({}, DecayTree);

  self.TreeThingIdx = nil;
  self.TreeThingProxy = ObjectProxy.new();
  self.TreeThingProxy:set(0);

  self.TimeSlice = 0;
  self.DecaySpeed = 0;
  self.Decayed = false;

  return self;
end

function DecayTree:attachTree(t_thing)
  if (t_thing.Type == T_SCENERY) then
    if (t_thing.Model <= 6) then
      self.TreeThingIdx = t_thing.ThingNum;
      self.TreeThingProxy:set(t_thing.ThingNum);
      self.TimeSlice = 0;
      --make sure decay speed is ALWAYS faster than tree's growth.
      self.DecaySpeed = scenery_consts[t_thing.Model].ResourceGrowth + G_RANDOM(2) + 1;
      self.Decayed = false;
    end
  end
end

function DecayTree:processDT()
  if (not self.TreeThingProxy:isNull()) then
    if (self.TreeThingProxy:getType() == T_SCENERY) then
      self.TimeSlice = self.TimeSlice + 1;
      local t = self.TreeThingProxy:get();

      --fancy effect to visualize "decaying"
      --could be commented out for some CPU time savings.
      local final_c3d = Coord3D.new();
      final_c3d.Xpos = (t.Pos.D3.Xpos + 128) - G_RANDOM(256);
      final_c3d.Zpos = (t.Pos.D3.Zpos + 128) - G_RANDOM(256);
      final_c3d.Ypos = t.Pos.D3.Ypos + G_RANDOM(128);
      createThing(T_EFFECT,M_EFFECT_LIGHTNING_ELEM,8,final_c3d,false,false);

      --process every 4th turn.
      if (self.TimeSlice % 4 == 0) then
        if (t.u.Scenery.ResourceRemaining - self.DecaySpeed > 100) then
          t.u.Scenery.ResourceRemaining = t.u.Scenery.ResourceRemaining - self.DecaySpeed;
        else
          --only in this specific case we'll run a gamble if we should spawn new tree or not.
          if (G_RANDOM(5) == 1) then
            CREATE_THING_WITH_PARAMS4(T_SCENERY, M_SCENERY_DORMANT_TREE, 8, t.Pos.D3, T_SCENERY, t.Model, 0, 0);
            if (G_RANDOM(2) == 1) then
              -- and a gamble if we want mother tree to exhaust, this is to control overgrow
              t.u.Scenery.ResourceRemaining = 0;
            end
          end
          self.Decayed = true;
          self.TimeSlice = 0;
          self.TreeThingIdx = 0;
          self.TreeThingProxy:set(0);
        end
      end
    else --wasn't a tree
      self.Decayed = true;
      self.TimeSlice = 0;
      self.TreeThingIdx = 0;
      self.TreeThingProxy:set(0);
    end
  else --was a null
    self.Decayed = true;
    self.TimeSlice = 0;
    self.TreeThingIdx = 0;
    self.TreeThingProxy:set(0);
  end
end

function OnTurn()
  --make sure we only ever process random if theres space left for new trees
  if (current_decaying_trees < max_amount_of_decaying_trees) then
    if (G_RANDOM(400) == 1) then
      --pick up random tree to decay!
      local neutral_cont = getPlayerContainer(TRIBE_HOSTBOT);
      local tree_list = neutral_cont.PlayerLists[WOODLIST];
      if (tree_list:count() > 0) then
        --validate thing
        local tree_thing = tree_list:getNth(G_RANDOM(tree_list:count()));
        if (tree_thing ~= nil) then
          if (tree_thing.Model <= 6) then
            if (tree_thing.u.Scenery.ResourceRemaining >= scenery_consts[tree_thing.Model].DfltResourceValue-1) then
              --tree is VALID! let's insert it into table
              local tree_decay = DecayTree:createDT();
              tree_decay:attachTree(tree_thing);
              table.insert(trees_buffer, tree_decay);
              current_decaying_trees = current_decaying_trees + 1;
            end
          end
        end
      end
    end
  end

  --process all decaying trees for it's logic.
  for i,DTree in ipairs(trees_buffer) do
    if (DTree.Decayed) then
      --delete any decayed/null/invalid trees, logic is handled inside class
      table.remove(trees_buffer, i);
      current_decaying_trees = current_decaying_trees - 1;
    else
      DTree:processDT();
    end
  end
end

function OnSave(sd)
  --ORDER MUCKING FATTERS.
  --save trees first, then global variables
  for i,DTree in ipairs(trees_buffer) do
    sd:push_int(DTree.TreeThingIdx);
    sd:push_int(DTree.TimeSlice);
    sd:push_int(DTree.DecaySpeed);
    sd:push_bool(DTree.Decayed);
  end

  sd:push_int(current_decaying_trees);
  sd:push_int(max_amount_of_decaying_trees);
end

function OnLoad(ld)
  --load backwards!
  max_amount_of_decaying_trees = ld:pop_int();
  current_decaying_trees = ld:pop_int();

  for i=1,current_decaying_trees do
    -- create empty body of DecayTree class.
    local DTree = DecayTree:createDT();

    --ORDER MUCKING FATTERS.
    DTree.Decayed = ld:pop_bool();
    DTree.DecaySpeed = ld:pop_int();
    DTree.TimeSlice = ld:pop_int();
    DTree.TreeThingIdx = ld:pop_int();

    --validate thing idx.
    local t = GetThing(DTree.TreeThingIdx);
    if (t ~= nil) then
      if (t.Type == T_SCENERY and t.Model <= 6) then
        --VALID!!!!
        DTree.TreeThingProxy:set(DTree.TreeThingIdx);
      else -- wasn't tree
        DTree.Decayed = true;
        DTree.TimeSlice = 0;
        DTree.TreeThingIdx = 0;
        DTree.TreeThingProxy:set(0);
      end
    else -- was null
      DTree.Decayed = true;
      DTree.TimeSlice = 0;
      DTree.TreeThingIdx = 0;
      DTree.TreeThingProxy:set(0);
    end

    --insert to table anyway, main script logic will delete any invalidated things
    table.insert(trees_buffer, DTree);
  end
end
