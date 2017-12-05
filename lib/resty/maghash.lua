-- Copyright (C) by Kwanhur Huang


-- ref: http://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/44824.pdf
local modulename = 'restyMagHash'
local _M = {}
local mt = { __index = _M }
_M._VERSION = '0.0.1'
_M._NAME = modulename


local setmetatable = setmetatable
local sqrt = math.sqrt
local floor = math.floor
local fmod = math.fmod
local ipairs = ipairs
local type = type

local mrmr = require('resty.murmurhash2')
local xxhash = require('resty.xxhash')

local is_prime = function(m)
    if m < 2 then
        return false
    end

    local i = 2
    local m_root = floor(sqrt(m))
    local flag = false

    while i < m do
        if fmod(m_root, i) == 0 then
            flag = true
        end
        i = i + 1
    end

    return flag
end


_M.new = function(self, m)
    if m and not is_prime(m) then
        return nil, 'invalid prime number'
    end
    self.m = m or 65537
    self.permutation = {}
    self.b_index = {}
    self.backends = {}
    self.n = 0
    local entry = {}

    local i = 1
    while i <= self.m do
        entry[i] = -1
        i = i + 1
    end

    self.entry = entry

    return setmetatable(self, mt)
end

_M.get_backend = function(self, flow)
    local m = self.m
    if m ~= #self.backends then
        return nil, 'internal index inconsistent'
    end

    local hash = mrmr(flow)
    local b_index = self.entry[fmod(hash, m)]
    return self.backends[b_index]
end

_M.add_backend = function(self, backend)
    if type(backend) ~= 'string' then
        return nil, 'invalid type, must be string'
    end
    if not self.b_index[backend] then
        self.backends[self.n + 1] = backend
        self.n = self.n + 1
    end
    self:spawn_permutation(0)
    self:populate()
    return true
end

_M.remove_backend = function(self, backend)
    if type(backend) ~= 'string' then
        return nil, 'invalid type, must be string'
    end

    if not self.b_index[backend] then
        return nil, 'invalid backend'
    end
    local del_b_idx = self.b_index[backend]

    local bbuf, pbuf = {}, {}
    for i = 1, #self.backends do
        if del_b_idx ~= i then
            bbuf[#bbuf + 1] = self.backends[i]
            pbuf[#pbuf + 1] = self.permutation[i]
        end
    end
    self.backends = bbuf
    self.permutation = pbuf
    self.n = #self.backends
    local b_index = {}
    for i, b in ipairs(self.backends) do
        b_index[b] = i
    end
    self.b_index = b_index
    self:populate()
    return true
end

_M.populate = function(self)
    local n = self.n
    local m = self.m
    local i, j = 1, 1

    local nexts = {}
    while i <= n do
        nexts[i] = 0
        i = i + 1
    end

    local entry = {}
    while j <= m do
        entry[j] = -1
        j = j + 1
    end

    j = 1
    while j <= m do
        i = 1
        while i <= n do
            local c = self.permutation[i][nexts[i]]
            while entry[c] >= 0 do
                nexts[i] = nexts[i] + 1
                c = self.permuatation[i][nexts[i]]
            end
            entry[c] = i
            nexts[i] = nexts[i] + 1

            i = i + 1
            j = j + 1
        end
    end
    self.entry = entry
end

_M.spawn_permutation = function(self, m)
    local n = self.n
    if m == 0 then
        m = self.m
    else
        self.m = m
    end

    if n ~= #self.backends then
        error('backend number inconsistent, something wrong')
    end

    local calced = #self.permutation
    local i = calced
    if i == 0 then
        i = 1
    end
    while i <= n do
        local offset, err = self:offset(i)
        if not offset then
            ngx.log(ngx.ERR, err)
        end
        local skip, err = self:skip(i)
        if not skip then
            ngx.log(ngx.ERR, err)
        end

        local buf = {}
        if offset and skip then
            local j = 1
            while j <= m do
                buf[j] = fmod((offset + j * skip), m)
                j = j + 1
            end
        end

        self.permuatation[#self.permutation + 1] = buf
        i = i + 1
    end
end

_M.lookup = function(self)
    local len = #self.entry
    local i = 1

    local lookup = {}
    while i <= len do
        local b_index = self.entry[i]
        lookup[i] = self.backends[b_index]
        i = i + 1
    end
    return lookup
end

_M.offset = function(self, backend_index)
    local n = self.n
    if backend_index > n then
        return nil, 'invalid index'
    end
    if backend_index <= #self.backends then
        local backend = self.backends[backend_index]
        local hash = xxhash.hash32(backend)
        local m = self.m
        return fmod(hash, m)
    else
        return nil, 'invalid index'
    end
end

_M.skip = function(self, backend_index)
    local n = self.n
    if backend_index > n then
        return nil, 'invalid index'
    end
    if backend_index <= #self.backends then
        local backend = self.backends[backend_index]
        local hash = mrmr(backend)
        local m = self.m
        return fmod(hash, m - 1) + 1
    else
        return nil, 'invalid index'
    end
end

return _M