Config = {}

--[[ 
    This text will appear on the screen 
]]
Config.text = {
    format = 'Postal: %s'
}

--[[ 
    Name of commands 
]]
Config.commands = {
    edit = 'postaledit',
    postal = 'postal'
}

--[[ 
    If you want the blip to only appear when you are in a vehicle 
]]
Config.OnlyPostalInCar = true

--[[ 
    Hide postal in pause menu
]]
Config.HideInPauseMenu = true

--[[ 
    Setting the blip when marking a postal 
]]
Config.blip = {
    -- The text to display in chat when setting a new route. 
    -- Formatted using Lua strings, http://www.lua.org/pil/20.html
    blipText = 'Route Postal%s',

    -- The sprite ID to display, the list is available here:
    -- https://docs.fivem.net/docs/game-references/blips/#blips
    sprite = 8,

    -- The color ID to use (default is 3, light blue)
    -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
    color = 3,

    -- When the player is this close (in meters) to the destination, 
    -- the blip will be removed.
    distToDelete = 100.0,

    -- The text to display in chat when a route is deleted
    deleteText = 'Route',

    -- The text to display in chat when drawing a new route
    drawRouteText = 'Route to %s',

    -- The text to display when a postal is not found.
    notExistText = "Postal Not Exists"
}

Config.updateDelay = nil