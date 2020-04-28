-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"
audio.reserveChannels( 1 )
audio.setVolume( 0.5 )
-- load menu screen
composer.gotoScene( "menu" )
