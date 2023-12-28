numBits = 32
powerBits = numBits ^ 2

-- Bitmask used to encode/decode roomFlags which describe different properties of a Room
ROOM_FLAGS = {
  ['INDOORS']  = 1,
  ['NONE']     = 2,
  ['DARK']     = 4,
  ['PRIVATE']  = 8,
  ['NO_MOB']   = 16,
  ['ARENA']    = 32,
  ['NO_MAGIC'] = 64,
  ['NEUTRAL']  = 128,
  ['SNDPROOF'] = 256,
  ['SAFE']     = 512,
  ['TUNNEL']   = 1024,
  ['DEATH']    = 2048,
  ['BFS_MARK'] = 4096,
  ['DUEL']     = 8192,
  ['CLUB']     = 16384,
  ['HALLOWED'] = 32768
}

-- Bitmask used to encode/decode exitFlags which describe different properties of an Exit
EXIT_FLAGS = {
  ['IS-DOOR']  = 1,
  ['CLOSED']   = 2,
  ['LOCKED']   = 4,
  ['HIDDEN']   = 8,
  ['SECRET']   = 16,
  ['RSCLOSED'] = 32,
  ['!PICK']    = 64,
}

-- Perform a 32-bit bitwise AND
function bitwiseAND( x, y )
  if y == 0xff then return x % 0x100 end
  if y == 0xffff then return x % 0x10000 end
  if y == 0xffffffff then return x % 0x100000000 end
  x, y = x % powerBits, y % powerBits
  local r = 0
  local p = 1
  for i = 1, numBits do
    local a, b = x % 2, y % 2
    x, y = math.floor( x / 2 ), math.floor( y / 2 )
    if a + b == 2 then
      r = r + p
    end
    p = 2 * p
  end
  return r
end

function bitwiseOR( x, y )
  -- Common usecases, they deserve to be optimized
  if y == 0xff then return x - (x % 0x100) + 0xff end
  if y == 0xffff then return x - (x % 0x10000) + 0xffff end
  if y == 0xffffffff then return 0xffffffff end
  x, y = x % powerBits, y % powerBits
  local r = 0
  local p = 1
  for i = 1, numBits do
    local a, b = x % 2, y % 2
    x, y = math.floor( x / 2 ), math.floor( y / 2 )
    if a + b >= 1 then
      r = r + p
    end
    p = 2 * p
  end
  return r
end

-- Decode a bit-masked value into its original strings; note that encode accepts a string while decode returns a table
function decodeValue( encodedValue, mask )
  local decodedStrings = {}

  for s, bitValue in pairs( mask ) do
    if bitwiseAND( encodedValue, bitValue ) ~= 0 then
      table.insert( decodedStrings, s )
    end
  end
  return table.concat( decodedStrings, " " )
end

-- Encode a line with the given mask
function encodeString( decodedLine, mask )
  -- Initialize the mask
  local encodedValue = 0

  -- Trim any surrounding whitespace
  decodedLine = decodedLine:trim()

  -- Split on space
  local decodedStrings = decodedLine:split( " " )

  -- Loop through each element and update the value
  for _, s in ipairs( decodedStrings ) do
    if mask[s] then
      encodedValue = bitwiseOR( encodedValue, mask[s] )
    else
      print( "\027[31merr: failed to find encoding for " .. s .. "\027[0m" )
    end
  end
  return encodedValue
end
