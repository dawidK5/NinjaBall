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
local levelsTable = {}
local playBtn
local screenW = display.actualContentWidth
local screenH = display.actualContentHeight
-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()

	-- go to level1.lua scene
	composer.gotoScene( "game", "fade", 700 )

	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local backgroundColor = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	backgroundColor.anchorX = 0
	backgroundColor.anchorY = 0
	backgroundColor:setFillColor(0.25,0.13,0.06,1)
	local background = display.newImageRect( "img/scroll.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY
	local levelsTable = {}
	local character = display.newImageRect("img/ninja_ball.png", 290, 290)
	character.x = display.contentCenterX
	character.y = screenH*0.65
	-- create a widget button (which will loads level1.lua on release)
	local playBtnY = 140
	sceneGroup:insert( backgroundColor )
	sceneGroup:insert( background )
	for i = 1, 4 do

		playBtn = widget.newButton{ label = i,
			labelColor= {default = {0,0,0,1}, over ={0,0,0,1} },
	        emboss = false,
	        shape = "roundedRect",
	        width = 160,
	        height = 160,
	        cornerRadius = 15,
	        fillColor = { default={0.0, 0.7, 0.2, 0.8}, over={0.0, 0.7, 0.2, 1} },
	        strokeColor = { default={0,0,0,1}, over={0,0,0,1} },
					strokeWidth = 0,
			fontSize=55,
			-- labelColor = { default={20, 255, 30}, over={20, 255, 30} },
			onRelease = onPlayBtnRelease }	-- event listener function
		if (i%2 == 0) then
			playBtn.x = 480
		else
			playBtn.x = 260
			playBtnY = playBtnY+ 200
		end
		playBtn.y = playBtnY
		sceneGroup:insert( playBtn )
	end

		-- all display objects must be inserted into group
	sceneGroup:insert(character)


end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
