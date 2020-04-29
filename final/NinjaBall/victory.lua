local composer = require("composer")
local scene = composer.newScene()
local screenW, screenH, halfW, halfH = display.actualContentWidth, display.actualContentHeight, display.contentCenterX, display.contentCenterY
local originX, originY = display.screenOriginX, display.screenOriginY
function scene:create( event )
  local sceneGroup = self.view
  local background = display.newRect(halfW, halfH, screenW, screenH)
  background.fill = {0}
  local winnerTextOpt = { text="Congratulations! You win!", x=halfW, y=halfH, width=screenW*0.9, height=halfH, font= native.systemFont, fontSize=screenW/10, align="center" }
  local winnerText = display.newText( winnerTextOpt )
  sceneGroup:insert(background)
  sceneGroup:insert(winnerText)
end
function scene:show( event )
  local sceneGroup = self.view
	local phase = event.phase
  if phase=="did" then
    timer.performWithDelay( 3000, composer.gotoScene( "menu", "fade", 3000 ) )
  end
end
function scene:hide( event )
  local phase = event.phase
  if phase=="will" then
    timer.performWithDelay( 100, composer.removeScene( "game") )
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
