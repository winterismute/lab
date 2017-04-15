local map_maker = require 'dmlab.system.map_maker'

local LEVEL_DATA = '/tmp/dmlab_level_data'
local make_map = {}

local pickups = {
    A = 'apple_reward',
    G = 'goal',
}

-- Those tables allow to specify enemy positions when making a map.
-- Specifically, L R U D are interpret as bot spawning points and associated with an angle
-- to spawn them facing a certain direction.
local enemies = {
  L = 'info_player_deathmatch',
  R = 'info_player_deathmatch',
  U = 'info_player_deathmatch',
  D = 'info_player_deathmatch'
}

local enemyAngle = {
  R = '180',
  U = '240',
  D = '90'
}

function make_map.makeMap(mapName, mapEntityLayer, mapVariationsLayer)
  os.execute('mkdir -p ' .. LEVEL_DATA .. '/baselab')
  assert(mapName)
  map_maker:mapFromTextLevel{
      entityLayer = mapEntityLayer,
      variationsLayer = mapVariationsLayer,
      outputDir = LEVEL_DATA .. '/baselab',
      mapName = mapName,
      callback = function(i, j, c, maker)
        if pickups[c] then
          return maker:makeEntity(i, j, pickups[c])
        end
        if enemies[c] then
          local en_attr = {
            nohumans = '1'
          }
          if enemyAngle[c] then
            en_attr['angle'] = enemyAngle[c]
          end
          return maker:makeEntity(i, j, enemies[c], en_attr)
        end
      end
  }
  return mapName
end

function make_map.commandLine(old_command_line)
  return old_command_line .. '+set sv_pure 0 +set fs_steampath ' .. LEVEL_DATA
end

function make_map.seedRng(value)
  map_maker:randomGen():seed(value)
end

return make_map
