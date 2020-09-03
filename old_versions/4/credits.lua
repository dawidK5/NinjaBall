
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

local creditsText = [===================[Ninja Ball

Created by
Oscar Bogenberger
Elliot Cleary
Tomás Crowley
Dawid Kocik
Ronan McMorrow

Reference:
(Where we sourced our images and materials from)
mute button= icon8.com
pngbuffet.com
musictheme = playonloop.com
bumper = playonloop.com
3d black cirlce png = clipart-library.com
crate= apkpure.com
spring = chegg.com
Level Background = simsworkshop.net

Assets
pngbuffet.com
icon8.com
freesound.org
opengameart.org


]===================]

local textBox
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
        height = display.viewableContentHeight,
        horizontalScrollDisabled = true
    }

)

  local background = display.newImageRect("img/scroll.png", display.actualContentWidth, textBox.height+textBox.height*0.2 )
  background.anchorX = 0
  background.anchorY = 0
	-- Code here runs when the scene is first created but has not yet appeared on screen
  scrollView:insert( background )
  scrollView:insert( textBox )
  sceneGroup:insert(scrollView)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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
