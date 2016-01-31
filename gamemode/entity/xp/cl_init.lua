include('shared.lua')

function ENT:Draw()
    -- self.BaseClass.Draw(self) -- Overrides Draw
    self:DrawEntityOutline( 1.0 ) -- Draw an outline of 1 world unit.
    self:DrawModel() -- Draws Model Client Side
end
