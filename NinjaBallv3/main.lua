-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local composer = require "composer"
composer.setVariable( "muted", false )

audio.reserveChannels( 1 )
audio.setVolume( 0.5 )
-- load menu screen
composer.gotoScene( "menu" )
