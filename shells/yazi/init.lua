function Linemode:custom_linemode()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    else
        time = os.date("%H:%M:%S %Y-%m-%d", time)
    end

    local size = self._file:size()

    local perms = self._file.cha:perm()
    local username = ya.user_name(self._file.cha.uid) or ""
    local group = ya.group_name(self._file.cha.gid) or ""
    local ownership = ""
    -- if username and group then
    --     ownership = string.format(" %s:%s", username, group)
    -- end
    return string.format("%s %s %s%s", size and ya.readable_size(size) or "-", time, perms, ownership)
end
