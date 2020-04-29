
local composer = require( "composer" )

local scene = composer.newScene()
local widget = require( "widget" )
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local screenW = display.actualContentWidth
local screenH = display.actualContentHeight
local originX, originY = display.screenOriginX, display.screenOriginY
local creditsText = [===================[





Ninja Ball

Created by
Oscar Bogenberger
Elliot Cleary
Tomás Crowley
Dawid Kocik
Ronan McMorrow

Theme from
playonloop.com

Game Sounds from
freesounds.org

3d black circle from
clipart-library.coms

Spring from
freepik.com

Background
simsworkshop.net

Pause from
icons8.com

Spikes from
graphic-buffet.com

Shelf from
opengameart.org

Lightning-
Background from
freepik.com

Tower from
png.pngtree.com

Scroll from
clipartbest.com
]===================]
local rightText
local textBox
local function switchScene (event)
	if event.target.objType == "left" then
			composer.gotoScene( "menu", "fade", 500 )
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
	end
end

-- create()
function scene:create( event )
  local sceneGroup = self.view

  local textOptions =
{
    text = creditsText,
    x = display.screenOriginX,
    y = display.screenOriginY+display.actualContentHeight*0.23,
    width = display.actualContentWidth,
    font = native.systemFont,
    fontSize = 46,
    align = "center"  -- Alignment parameter
}
  textBox =  display.newText( textOptions )
  textBox:setFillColor(0, 0, 0)
  textBox.anchorX = 0
  textBox.anchorY = 0
  local scrollView = widget.newScrollView(
    {
        width = display.viewableContentWidth,
        height = display.viewableContentHeight*0.9,
        horizontalScrollDisabled = true
    }

)

  local background = display.newImageRect("img/scroll.png", display.actualContentWidth, textBox.height+textBox.height*0.5 )
  background.anchorX = 0
  background.anchorY = 0
  local left = display.newRect( originX, originY+screenH*0.9, screenW/3, screenH/10 )
	left.anchorX = 0
	left.anchorY = 0
	leftText = display.newText( "Back", screenW/6, screenH*0.95, native.systemFont, screenW/16)

	left:setFillColor( 0.93, 0.07, 0.11 )
	left.objType = "left"

	local right = display.newRect( originX + screenW/3, originY + screenH*0.9, screenW/3, screenH/10 )
	right.anchorX = 0
	right.anchorY = 0
	rightText = display.newText( "Mute", screenW/2, screenH*0.95, native.systemFont, screenW/16)
	right:setFillColor( 0.77, 0.06, 0.09 )
	right.objType = "right"
	if muted then
		rightText.text = "Unmute"
	else
		rightText.text = "Mute"
	end
  scrollView:insert( background )
  scrollView:insert( textBox )
  sceneGroup:insert(scrollView)

	sceneGroup:insert( left )
	sceneGroup:insert( leftText )
	sceneGroup:insert( right )
	sceneGroup:insert( rightText )
	-- Code here runs when the scene is first created but has not yet appeared on screen
  left:addEventListener( "tap",switchScene ) -- back
	right:addEventListener( "tap", switchScene )-- mute
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
    if muted then
			rightText.text="Unmute"
		else
			rightText.text="Mute"
		end
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  if scrollView then
    scrollView:removeSelf()
    scrollView=nil
  end
  left:removeEventListener( "tap",switchScene ) -- back
  right:removeEventListener( "tap", switchScene )-- mute
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
