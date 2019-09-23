local mod = {}

function mod.strictShortcut(hotkey, fn, exec)
    if fn() then
        print(exec)
    else
        print(hotkey)
    end
end

return mod
