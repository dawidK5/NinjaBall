
local composer = require( "composer" )

local scene = composer.newScene()
local parent = composer.getScene( "game" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY
local muteText, backToGame, exitToMain
local muted = composer.getVariable( "muted" )
local function closeAndRestore()
  composer.hideOverlay( "fade", 300 )
  parent:resumeGame()
end
local function closeAndExit()
  composer.removeScene( "game" )
  composer.hideOverlay( "crossFade", 600 )

  composer.gotoScene("menu", "fade", 500)
end
local function changeMute()
  muted = not muted
  composer.setVariable( "muted", muted )
  if muted then
    audio.stop()
    audio.setVolume(0)
    muteText.text="Unmute"
  else
    audio.setVolume(0.5)
    audio.setVolume( 0.2, {channel=1} )
    audio.play( backgroundMusic, { channel=1, loops=-1, fadein=1500} )
    muteText.text="Mute"
  end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newRect( halfW, halfH, screenW, screenH )
  background.fill = {0.1, 0.1, 0.2, 0.95}
  muteText = display.newText("Mute", halfW, halfH*0.9, native.systemFont, screenW/16)
  backToGame = display.newText("Return to game", halfW, halfH, native.systemFont, screenW/16)
  exitToMain = display.newText("Exit to main menu", halfW, halfH*1.1, native.systemFont, screenW/16)
  sceneGroup:insert( background )
  sceneGroup:insert( muteText )
  sceneGroup:insert( backToGame )
  sceneGroup:insert(  exitToMain )

  muteText:addEventListener("tap", changeMute)
  backToGame:addEventListener("tap", closeAndRestore)
  exitToMain:addEventListener("tap", closeAndExit)


end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    muted = composer.getVariable( "muted")
    if muted then
      muteText.text = "Unmute"
    else
      muteText.text = "Mute"
    end


	elseif ( phase == "did" ) then


	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    muteText:removeEventListener("tap", changeMute)
    backToGame:removeEventListener("tap", closeAndRestore)
    exitToMain:removeEventListener("tap", closeAndRestore)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
