local make_map = require 'common.make_map'
local pickups = require 'common.pickups'
local random = require 'common.random'
local game = require 'dmlab.system.game'

-- This map defines an environment with bots with a scripted behavior and should train
-- the AI to avoid them. Specifically, a row of bots is spawned after a row of goals and they all proceed at
-- random speeds towards the player, which has to avoid them, since hitting them provides a negative reward. 
-- A new map is generated after the player wins one, with the base speed of the bots increased.
-- The map also shows how to use the api calls onPlayerBotCollision, getBotScriptedInput and getButtonsBlacklist

local api = {}
local maxBotsCount = 5
local skillLevel = 3

local baseSpeed = 180;
local randomSpeeds = {}

local BOT_NAMES_COLOR = {
    'CygniColor',
    'LeonisColor',
    'EpsilonColor',
    'CepheiColor',
    'CentauriColor',
    'DraconisColor'
}

local BOT_NAMES = {
    'Cygni',
    'Leonis',
    'Epsilon',
    'Cephei',
    'Centauri',
    'Draconis'
}

-- Same convention used in q_shared.h. Add them as needed
local BUTTONS_MAP = {
  BUTTON_ATTACK = 1,
  BUTTON_USE_HOLDABLE = 4
}

local map = [[
*******
*  P  *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*     *
*DDDDD*
*GGGGG*
******
]]

function increaseBaseSpeed()
  if baseSpeed < 340 then
    baseSpeed = baseSpeed + 20
  end
end

function randomizeSpeeds()
  for i=0,maxBotsCount do
    randomSpeeds[i] = random.uniformInt(baseSpeed, 380)
  end
end

function api:start(episode, seed)
  make_map.seedRng(seed)
  random.seed(seed)
  api._count = 0
end

function api:getButtonsBlacklist()
  return BUTTONS_MAP['BUTTON_ATTACK']
end

function api:addBots()
  local bots = {}
  for i, name in ipairs(BOT_NAMES_COLOR or BOT_NAMES) do
    if i > maxBotsCount then
      break
    end
    bots[#bots + 1] = {name = name, skill = skillLevel}
  end
  return bots
end

function api:onPlayerBotCollision(player_id, bot_id)
  -- First id is reserved for player
  local realid = bot_id - 1
  if realid < maxBotsCount then
    game:addScore(player_id, -0.5)
  end
end

-- Needs to return a table with "speed", "velocityX", "velocityY", "velocityZ"
function api:getBotScriptedInput(bot_id)
  -- First id is reserved for player
  local realid = bot_id - 1

  if realid < maxBotsCount then
    return {
      speed = randomSpeeds[realid],
      velocityX = 1.0,
      velocityY = 0.0,
      velocityZ = 0.0
    }
  end
  return {
    speed = 0.0
  }
end

function api:commandLine(oldCommandLine)
  return make_map.commandLine(oldCommandLine)
end

function api:createPickup(className)
  return pickups.defaults[className]
end

function api:nextMap()
  api._count = api._count + 1
  increaseBaseSpeed()
  randomizeSpeeds()
  return make_map.makeMap("scripted_demo_map_" .. api._count, map)
end

return api
