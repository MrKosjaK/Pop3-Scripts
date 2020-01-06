import(Module_Table)
import(Module_Globals)
import(Module_Defines)
import(Module_Map)
import(Module_DataTypes)
import(Module_Game)
import(Module_Objects)

_gsi = gsi()
discCache = {}
disc2Cache = {}
stoneCache = {}
triggerCache = {}
end_process = false
index = 1
extra_index = 1
delay = _gsi.Counts.GameTurn + 12

myAngles = {0,512,1024,1536}
mySpells = {M_SPELL_BLAST,
            M_SPELL_INSECT_PLAGUE,
            M_SPELL_LAND_BRIDGE,
            M_SPELL_LIGHTNING_BOLT,
            M_SPELL_INVISIBILITY,
            M_SPELL_HYPNOTISM,
            M_SPELL_WHIRLWIND,
            M_SPELL_SWAMP,
            M_SPELL_SHIELD,
            M_SPELL_FLATTEN,
            M_SPELL_EROSION,
            M_SPELL_EARTHQUAKE,
            M_SPELL_FIRESTORM,
            M_SPELL_ANGEL_OF_DEATH,
            M_SPELL_VOLCANO,
            M_SPELL_BLOODLUST,
            M_SPELL_TELEPORT
}

function register_discovery(a, b, c, e, f)
  local d = createThing(T_GENERAL, M_GENERAL_DISCOVERY, TRIBE_HOSTBOT, a, false, false)
  local proxy = ObjectProxy.new()
  proxy:set(d.ThingNum)

  d.u.Discovery.DiscoveryType = 11
  d.u.Discovery.DiscoveryModel = b
  _gsi.SpellsPresentOnLevel = _gsi.SpellsPresentOnLevel | (1 << b)
  d.u.Discovery.AvailabilityType = c
  d.u.Discovery.TriggerType = f

  if (e == TRUE) then
    table.insert(discCache,proxy)
  else
    table.insert(disc2Cache,proxy)
  end
end

function register_stone(a, b)
  local s = createThing(T_SCENERY, M_SCENERY_HEAD, TRIBE_HOSTBOT, a, false, false)
  local proxy = ObjectProxy.new()
  proxy:set(s.ThingNum)

  s.u.Scenery.HeadType = b
  s.AngleXZ = myAngles[G_RANDOM(#myAngles)+1]

  table.insert(stoneCache,proxy)
end

function register_trigger(a, b, c, d, e, f)
  local t = createThing(T_GENERAL, M_GENERAL_TRIGGER, TRIBE_HOSTBOT, a, false, false);
  local proxy = ObjectProxy.new()
  proxy:set(t.ThingNum)

  t.u.Trigger.Flags = t.u.Trigger.Flags | (1 << 0)
  t.u.Trigger.Flags = t.u.Trigger.Flags | (1 << 5)
	t.u.Trigger.TriggerType = TRIGGER_TYPE_PROXIMITY
	t.u.Trigger.CellRadius = 1
	t.u.Trigger.NumOccurences = b
	t.u.Trigger.TriggerCount = c
	t.u.Trigger.InactiveTime = 1
  t.u.Trigger.OriginalInactiveTime = 1
	t.u.Trigger.PrayTime = d
	t.u.Trigger.CreatePlayerOwned = e
  t.u.Trigger.HeadThingIdx:set(f:getThingNum())

  table.insert(triggerCache,proxy)
end

function link_thing(_t, _tl, a)
  local t = _t:get()
  local tl = _tl:get()
  uninit_thing(tl)
  t.u.Trigger.EditorThingIdxs[a] = tl.ThingNum
end

function FindLandSpot()
	local tries = 48
	local coord = Coord3D.new()
	coord.Xpos = G_RANDOM(65536)
	coord.Zpos = G_RANDOM(65536)
	while (tries > 0) do
    tries=tries-1
		local me_pos = world_coord3d_to_map_ptr(coord)
		if (is_map_elem_sea_or_coast(me_pos) == 0) then
			if (check_tiles(2, coord) == 0) then
        break
      else
			  coord.Xpos = G_RANDOM(65536)
			  coord.Zpos = G_RANDOM(65536)
      end
		else
			coord.Xpos = G_RANDOM(65536)
			coord.Zpos = G_RANDOM(65536)
    end
	end

	return coord
end

function check_tiles(radius, coord)
  local count = 0
  SearchMapCells(SQUARE,0,0,radius,world_coord3d_to_map_idx(coord),function(me)
    me.MapWhoList:processList(function(t)
      if (t.Type == T_BUILDING or t.Type == T_SHAPE or t.Type == T_SCENERY) then
        count = count+1
        return false
      end
      return true
    end)

    return true
  end)

  return count
end

for i = 0,31 do
  local c3d = FindLandSpot()
  local c2d = Coord2D.new()
  centre_coord3d_on_block(c3d)
  coord3D_to_coord2D(c3d, c2d)
  if (is_map_point_land(c2d) == 1 and check_tiles(2, c3d) == 0) then
    local r = G_RANDOM(#mySpells)+1
    register_discovery(c3d, mySpells[r], 3, TRUE, 1)
    register_stone(c3d, 2)
    register_trigger(c3d, (#mySpells+1 - r), (1 + r), (30 + (25*r)), 0, stoneCache[index])
    link_thing(triggerCache[index], discCache[index], 1)
    --Second discovery treasure
    if (G_RANDOM(4) == 0 and r > 3) then
      c3d.Xpos = c3d.Xpos - 512
      register_discovery(c3d, mySpells[G_RANDOM(#mySpells-4)+1], 3, FALSE, 1)
      link_thing(triggerCache[index], disc2Cache[extra_index], 2)
      extra_index=extra_index+1
    end
    index=index+1
  end
end
exit()
