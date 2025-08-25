-- init.lua
function Linemode:custom_linemode()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    else
        time = os.date("%H:%M:%S %Y-%m-%d", time)

    end
    local size = self._file:size()
    local perms = self._file.cha:perm() or ""
    local username = self._file.cha.uid and ya.user_name(self._file.cha.uid) or ""
    local group = self._file.cha.gid and ya.group_name(self._file.cha.gid) or ""
    local ownership = ""
    if username:len() > 0 and group:len() > 0 then
        ownership = string.format(" %s:%s", username, group)
    end
    if size then
        size = ya.readable_size(size)
    else
        size = "-"
    end
    return string.format("%s %s %s%s", size, time, perms, ownership)
end
