
-- local sort_func = function( a,b ) return string.lower(a) < string.lower(b) end


-- wpSwitch = function()
--     local wallpapers = {}
--     local paths = {
--         '/Library/Desktop Pictures',
--         '/Users/roey/Pictures/wallpapers',
--     }
--     for _,path in ipairs(paths) do
--         local iterFn, dirObj = hs.fs.dir(path)
--         if iterFn then
--         for file in iterFn, dirObj do
--             if file:sub(-5) == ".heic" then
--             table.insert( wallpapers, path .. '/' .. file )
--             end
--         end
--         else
--             print(string.format("The following error occurred: %s", dirObj))
--             end
--     end
--     table.sort( wallpapers, sort_func )
--     for i,v in ipairs(wallpapers) do
--         print(i,v)
--     end
-- end

-- wpSwitch()
