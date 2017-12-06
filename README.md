# lua-resty-maghash
lua-resty-maghash implements Google's load balance solution - Maglev's consistent hashing algorithm

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [new](#new)
    * [add_backend](#add-backend)
    * [remove_backend](#remove-backend)
    * [get_backend](#get-backend)
    * [lookup](#lookup)
* [Installation](#installation)
* [Dependency](#dependency)
* [Authors](#authors)
* [Copyright and License](#copyright-and-license)

Synopsis
========
```lua
    lua_package_path "/path/to/lua-resty-maghash/lib/?.lua;;";

    server {
        location /test {
            content_by_lua '
            local cjson = require('cjson.safe')
            local maghash = require('resty.maghash')
            local mag = maghash:new(7)

            mag:add_backend('b1')
            mag:add_backend('b2')
            mag:add_backend('b3')
            local lookup = mag:lookup()
            ngx.print(cjson.encode(lookup))
            local entry = mag.entry
            ngx.print(cjson.encode(entry))
            
            mag:remove_backend('b3')
            local lookup = mag:lookup()
            ngx.print(cjson.encode(lookup))
            local entry = mag.entry
            ngx.print(cjson.encode(entry))
            ';
        }
    }
```

Methods
=======

[Back to TOC](#table-of-contents)

new
---
`syntax: mag = maghash:new(m)`

Create a new maghash object.

[Back to TOC](#table-of-contents)

add_backend
-----------
`syntax: mag:add_backend(backend)`

Add a backend into mag backends

[Back to TOC](#table-of-contents)

remove_backend
--------------
`syntax: mag:remove_backend(backend)`

Remove a backend from mag backends

[Back to TOC](#table-of-contents)

get_backend
-----------
`syntax: backend = mag:get_backend('abc123&^%')`

Fetch the backend for specified content

[Back to TOC](#table-of-contents)

lookup
------
`syntax: lookup = mag:lookup()`

Fetch all the backend

[Back to TOC](#table-of-contents)

Installation
============

You can install it with [opm](https://github.com/openresty/opm#readme).
Just like that: opm install kwanhur/lua-resty-maghash

[Back to TOC](#table-of-contents)

Dependency
============

* [lua-resty-xxhash](https://github.com/bungle/lua-resty-xxhash)
* [lua-resty-murmurhash](https://github.com/bungle/lua-resty-murmurhash2)

[Back to TOC](#table-of-contents)

Authors
=======

kwanhur <huang_hua2012@163.com>, VIPS Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD 2-Clause License .

Copyright (C) 2016, by kwanhur <huang_hua2012@163.com>, VIPS Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)