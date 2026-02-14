function Weapon(name, damage, range, ammoCapacity, reloadTime)
    local weapon = {
        name         = name,
        damage       = damage,
        range        = range,
        ammoCapacity = ammoCapacity,
        currentAmmo  = ammoCapacity,
        reserveAmmo  = ammoCapacity * 3,   -- start with 3 full magazines in reserve
        isReloading  = false,
        reloadTimer  = 0,
        reloadTime   = reloadTime or 1.5,  -- seconds to reload
    }

    -- Call every frame so the reload timer advances.
    function weapon:update(dt)
        if self.isReloading then
            self.reloadTimer = self.reloadTimer - dt
            if self.reloadTimer <= 0 then
                -- Transfer as many rounds as needed/available from reserve to magazine.
                local needed = self.ammoCapacity - self.currentAmmo
                local take   = math.min(needed, self.reserveAmmo)
                self.currentAmmo  = self.currentAmmo  + take
                self.reserveAmmo  = self.reserveAmmo  - take
                self.isReloading  = false
                self.reloadTimer  = 0
            end
        end
    end

    -- Returns true and consumes one round if able to fire, false otherwise.
    function weapon:shoot()
        if self.isReloading           then return false end
        if self.currentAmmo <= 0      then
            -- Try to reload automatically if reserve is available.
            self:startReload()
            return false
        end
        self.currentAmmo = self.currentAmmo - 1
        -- Auto-reload when the magazine runs dry.
        if self.currentAmmo == 0 and self.reserveAmmo > 0 then
            self:startReload()
        end
        return true
    end

    -- Begin a reload cycle (ignored if already reloading or magazine is full / reserve empty).
    function weapon:startReload()
        if self.isReloading                         then return end
        if self.currentAmmo >= self.ammoCapacity    then return end
        if self.reserveAmmo <= 0                    then return end
        self.isReloading = true
        self.reloadTimer = self.reloadTime
    end

    -- Compatibility alias kept so existing call-sites don't break.
    function weapon:reload()
        self:startReload()
    end

    -- Add rounds to the reserve (ammo pickup).
    function weapon:pickupAmmo(amount)
        self.reserveAmmo = self.reserveAmmo + (amount or 10)
    end

    function weapon:getInfo()
        return {
            name         = self.name,
            damage       = self.damage,
            range        = self.range,
            currentAmmo  = self.currentAmmo,
            ammoCapacity = self.ammoCapacity,
            reserveAmmo  = self.reserveAmmo,
            isReloading  = self.isReloading,
        }
    end

    return weapon
end

return Weapon
