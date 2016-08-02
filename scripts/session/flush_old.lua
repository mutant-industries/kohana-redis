-- Flushes session records (keys starting with @prefix) that have last_active < @last_active_limit
--
-- parameters:
-- - ARGV[1] prefix Session keys prefix
-- - ARGV[2] last_active_limit - unix timestamp

-- -----------------------------------------------------------------------------

local function is_empty(s)
    return s == nil or s == ""
end

local prefix = ARGV[1]
local last_active_limit = ARGV[2]

assert(not is_empty(prefix), "prefix cannot be empty")
assert(not is_empty(last_active_limit), "last_active_limit cannot be empty")

last_active_limit = tonumber(last_active_limit)

assert(not is_empty(last_active_limit) and last_active_limit > 0, "last_active_limit must be positive number")

-- -----------------------------------------------------------------------------

for _, key in pairs(redis.call("keys", prefix .. "*")) do
    local type = redis.call("type", key)

    if type[next(type)] == "hash" and redis.call("hexists", key, "last_active") == 1 then
        -- regex, because last active is serialized integer
        local last_active = string.match((redis.call("hget", key, "last_active")), "%d+")

        -- no mercy when last_active is not a number
        if is_empty(last_active) then
            redis.call("del", key)
        else
            last_active = tonumber(last_active)

            if is_empty(last_active) or last_active < last_active_limit then
                redis.call("del", key)
            end
        end
    end
end

return redis.status_reply("OK")
