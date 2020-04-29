local composer = require("composer")
local scene = composer.newScene()
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY
function scene:create( event )
  local sceneGroup = self.view
  local background = display.newImageRect("img/bumper.png", screenW, screenH)
  background.x = halfW
  background.y = halfH
  background.anchorX = 0
  background.anchorY = 0
  local winnerText = display.newText("Congratulations! You win!", halfW, halfH, halfW, halfH, native.systemFont, screenW/10 )
  sceneGroup:insert(background)
  sceneGroup:insert(winnerText)
end
function scene:show( event )
  local sceneGroup = self.view
	local phase = event.phase
  if phase=="did" then
    timer.performWithDelay( 5000, composer.gotoScene( "menu", "fade", 500 ) )
  end
end
function scene:hide( event )
  local phase = event.phase
  if phase=="will" then
    timer.performWithDelay( 100, composer.removeScene(composer.getSceneName( "previous" )) )
  end
end
function scene:destroy(event)
  local sceneGroup = self.view
end
scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)
scene:addEventListener( "destroy", scene)
return scene
