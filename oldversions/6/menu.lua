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
local controls = display.newGroup();
local muteBtn
local credits
local backgroundMusic

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local originX, originY = display.screenOriginX, display.screenOriginY

backgroundMusic = audio.loadStream( "sound/musictheme.wav" )
local function gotoCredits()
	composer.gotoScene( "credits", "fade", 500 )
end
local function onMuteBtnRelease()
	muted = not muted
	muteBtn:removeSelf()
	muteBtn = nil

	if muted then
		audio.stop(1)
		audio.setVolume(0)
		muteBtn = display.newImageRect("img/unmute.png", 160, 160)
	else
		audio.play( backgroundMusic, { channel=1, loops=-1 } )
		audio.setVolume(0.7)
		muteBtn = display.newImageRect("img/mute.png", 160, 160 )
	end
	muteBtn.x = display.actualContentWidth-80
	muteBtn.y = 80
	muteBtn:addEventListener(	"tap", onMuteBtnRelease )
end

function scene:create( event )
	local sceneGroup = self.view
	audio.setVolume(0)
	muted = false
	-- menu buttons, same buttons will be used for controls
	local left = display.newRect( originX, originY+screenH*0.9, screenW/3, screenH/10 )
	left.anchorX = 0
	left.anchorY = 0
	left.text = display.newText( "Play", screenW/6, screenH*0.95, native.systemFont, screenW/16)

	left:setFillColor( 0.93, 0.07, 0.11 )
	left.objType = "left"

	local right = display.newRect( originX + screenW/3, originY + screenH*0.9, screenW/3, screenH/10 )
	right.anchorX = 0
	right.anchorY = 0
	right.text = display.newText( "Mute", screenW/2, screenH*0.95, native.systemFont, screenW/16)
	right:setFillColor( 0.77, 0.06, 0.09 )
	right.objType = "right"

	local jump = display.newRect( originX + screenW*2/3, originY + screenH*0.9, screenW/3, screenH/10 )
	jump.anchorX = 0
	jump.anchorY = 0
	right.text = display.newText( "Credits", screenW*5/6, screenH*0.95, native.systemFont, screenW/16)
	jump:setFillColor( 0.67, 0, 0.1 )
	jump.objType = "jump"


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

	muteBtn = display.newImageRect( "img/mute.png", 160, 160 )
	muteBtn.x = display.actualContentWidth-80
	muteBtn.y = 80
	muteBtn:setFillColor(2)
	-- create a widget button (which will loads level1.lua on release)

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	controls:insert(left)
	controls:insert(right)
	controls:insert(jump)
	sceneGroup:insert(controls)
	local function switchScene (self)
		composer.gotoScene( "levellist", "crossFade", 500 )
	end
	--left.tap = switchScene
	left:addEventListener( "tap", switchScene)
	muteBtn:addEventListener(	"tap", onMuteBtnRelease )
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

		audio.play( backgroundMusic, { channel=1, loops=-1 } )
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



end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
