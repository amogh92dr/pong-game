Ball = Class{}

function Ball:init(size)
  self.width = size
  self.height = size
  self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
  self.y = (VIRTUAL_HEIGHT / 2) - (self.height / 2)
  self.dx = 0
  self.dy = 0
end
function Ball:reset()
  self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
  self.y = (VIRTUAL_HEIGHT / 2) - (self.height / 2)
  self.dx = 0
  self.dy = 0
end
function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end
function Ball:collides(paddle)
  if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
    return false
  end
  if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
    return false
  end
  return true
end
function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
