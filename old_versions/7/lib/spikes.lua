local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

  if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
	end
	function instance:collision( event )

		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "hero" then
			audio.play( sounds.coin )
			scene.score:add( 100 )
			display.remove( self )
		end
	end

	instance._y = instance.y
	physics.addBody( instance, "static", { isSensor = true } )
  print("hello")
  instance.objType= "spikes"
	instance:addEventListener( "collision" )

	return instance
end

return M
