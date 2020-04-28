-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
--local controls = display.newGroup();



local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local originX, originY = display.screenOriginX, display.screenOriginY
local rightText
muted = false
backgroundMusic = audio.loadStream( "sound/musictheme.wav" )

function scene:create( event )
	local sceneGroup = self.view

	audio.setVolume(0.5)
	audio.setVolume( 0.2, {channel=1} )


	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.


	-- display a background image
	local background = display.newImageRect( "img/menubckg.png", screenW, screenH*0.9 )
	background.anchorX = 0
	background.anchorY = 0
	background.x = originX
	background.y = originY

	local left = display.newRect( originX, originY+screenH*0.9, screenW/3, screenH/10 )
	left.anchorX = 0
	left.anchorY = 0
	local leftText = display.newText( "Play", screenW/6, screenH*0.95, native.systemFont, screenW/16)
	left:setFillColor( 0.93, 0.07, 0.11 )
	left.objType = "left"

	local right = display.newRect( originX + screenW/3, originY + screenH*0.9, screenW/3, screenH/10 )
	right.anchorX = 0
	right.anchorY = 0
	rightText = display.newText( "Mute", screenW/2, screenH*0.95, native.systemFont, screenW/16)
	right:setFillColor( 0.77, 0.06, 0.09 )
	right.objType = "right"

	local jump = display.newRect( originX + screenW*2/3, originY + screenH*0.9, screenW/3, screenH/10 )
	jump.anchorX = 0
	jump.anchorY = 0
	local jumpText = display.newText( "Credits", screenW*5/6, screenH*0.95, native.systemFont, screenW/16)
	jump:setFillColor( 0.67, 0, 0.1 )
	jump.objType = "jump"

	local function switchScene (event)
	  if event.target.objType == "left" then
	      composer.gotoScene( "levellist", "crossFade", 500 )
	  elseif event.target.objType == "right" then
	    muted = not muted
	    if muted then
				audio.stop()
	      audio.setVolume(0)
	      rightText.text="Unmute"
	    else
				audio.setVolume(0.5)
	      audio.setVolume( 0.2, {channel=1} )
	      audio.play( backgroundMusic, { channel=1, loops=-1, fadein=1500} )
	      rightText.text="Mute"
	    end
	  else
	    composer.gotoScene( "credits", "crossFade", 500 )
	  end
	end

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( left )
	sceneGroup:insert( leftText )
	sceneGroup:insert( right )
	sceneGroup:insert( rightText )
	sceneGroup:insert( jump )
	sceneGroup:insert( jumpText )


	left:addEventListener("tap", switchScene);
	right:addEventListener("tap", switchScene);
	jump:addEventListener("tap", switchScene);
	print("createdscene")
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then

		if muted then
			rightText.text="Unmute"

		else
			rightText.text="Mute"
		end

	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		audio.play( backgroundMusic, { channel=1, loops=-1, fadein=1500 } )
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen

	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	left:removeEventListener("tap", switchScene);
	right:removeEventListener("tap", switchScene);
	jump:removeEventListener("tap", switchScene);


end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
