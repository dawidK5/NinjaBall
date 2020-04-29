local composer = require("composer")
local scene = composer.newScene()
local oldScene

function scene:create( event )
  local sceneGroup = self.view
  oldScene = composer.getSceneName( "previous" )
end
function scene:show( event )
  local sceneGroup = self.view


	local phase = event.phase
  if phase=="did" then

    timer.performWithDelay( 100, composer.gotoScene( oldScene, "fade", 500 ) )
  end
end
function scene:hide( event )
  local phase = event.phase
  if phase=="will" then
    timer.performWithDelay( 100, composer.removeScene(oldScene) )
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
