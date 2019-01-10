[![Build Status](https://travis-ci.com/Kong/version.lua.svg?branch=master)](https://travis-ci.com/Kong/version.lua)
[![Coverage Status](https://coveralls.io/repos/github/Kong/version.lua/badge.svg?branch=master)](https://coveralls.io/github/Kong/version.lua?branch=master)

Version
=======

Version comparison library for Lua. Does simple comparisons between versions,
ranges, and sets of ranges. Including basic SemVer support.

License: Apache 2.0

Copyright: Kong Inc.

Author: Thijs Schreijer

Installation
============
Install through LuaRocks (`luarocks install version`) or from source, see the [github repo](https://github.com/Mashape/version.lua).

Documentation
=============
Can be generated using Ldoc. Just run `"./ldoc ."` from the repo.

Tests are in the `spec` folder.

Copyright and License
=====================

```
Copyright 2016-2019 Kong Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

History
=======

1.0.1 10-Jan-2019

 - fixed an accidental global variable
 - added check on types to the `__lt` metamethod to prevent accidental bad comparisons

1.0 13-Oct-2017

- many breaking changes, renamed methods, added SemVer, and updated 'strict'

0.3 18-Oct-2016

- relaxed parsing rules, added the `strict` flag

0.2 14-May-2016

- added 'tostring' meta-methods, and a required initial version for 'set'

0.1 13-May-2016

- Initial version