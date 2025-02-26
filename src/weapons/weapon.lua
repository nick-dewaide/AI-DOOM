function Weapon(name, damage, range, ammoCapacity)
    local weapon = {
        name = name,
        damage = damage,
        range = range,
        ammoCapacity = ammoCapacity,
        currentAmmo = ammoCapacity
    }

    function weapon:shoot()
        if self.currentAmmo > 0 then
            self.currentAmmo = self.currentAmmo - 1
            return true -- Shooting successful
        else
            return false -- Out of ammo
        end
    end

    function weapon:reload()
        self.currentAmmo = self.ammoCapacity
    end

    function weapon:getInfo()
        return {
            name = self.name,
            damage = self.damage,
            range = self.range,
            currentAmmo = self.currentAmmo,
            ammoCapacity = self.ammoCapacity
        }
    end

    return weapon
end

return Weapon