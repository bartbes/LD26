require "lib/slither"

class "Sam"
{	
	__init__ = function(self, position, velocity, tex)
		self.position = position or {x=0,y=0}
		self.velocity = velocity or {x=0,y=0}
		self.scroll = scroll or{x=0,y=0}
		self.screenPosition = {x =0, y=0}
		self.tex = tex
	end,
	
	draw = function(self)
		love.graphics.draw(self.tex, self.screenPosition.x, self.screenPosition.y)
	end,
	
	
	update = function(self,dt)
		self.position.x = self.position.x + self.velocity.x * dt
		self.position.y = self.position.y + self.velocity.y * dt
		
		self.screenPosition.x = self.position.y - self.scroll.x
		self.screenPosition.y = self.position.y - self.scroll.y
	end
}