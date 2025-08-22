-- Ghost props on physgun pickup & prevent prop throw abuse
hook.Add("PhysgunPickup", "Emporium_GhostOnPickup", function(ply, ent)
    if not IsValid(ent) or not ent:GetPhysicsObject():IsValid() then return end
    if ent:IsPlayer() then return end

    -- Ghost the entity
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    ent:SetColor(Color(255, 255, 255, 100))
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

    -- Tag for anti-throw logic
    ent._EmporiumGhosted = true
end)

hook.Add("PhysgunDrop", "Emporium_UnghostOnDrop", function(ply, ent)
    if not IsValid(ent) or not ent._EmporiumGhosted then return end

    -- Restore visuals and collisions
    ent:SetRenderMode(RENDERMODE_NORMAL)
    ent:SetColor(Color(255, 255, 255, 255))
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    ent._EmporiumGhosted = nil
end)

-- Anti prop throw: freeze velocity spikes on ghosted props
hook.Add("Think", "Emporium_AntiPropThrow", function()
    for _, ent in ipairs(ents.GetAll()) do
        if ent._EmporiumGhosted and IsValid(ent:GetPhysicsObject()) then
            local phys = ent:GetPhysicsObject()
            if phys:GetVelocity():Length() > 500 then
                phys:EnableMotion(false)
                timer.Simple(0.5, function()
                    if IsValid(phys) then phys:EnableMotion(true) end
                end)
            end
        end
    end
end)
