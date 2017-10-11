Version
=======

Version comparison library for Lua. Does simple comparisons between versions, 
ranges, and sets of ranges. Including basic SemVer support.

License: Apache 2.0

Copyright: Mashape Inc.

Author: Thijs Schreijer

Installation
============
Install through LuaRocks (`luarocks install version`) or from source, see the [github repo](https://github.com/Mashape/version.lua).

Documentation
=============
Can be generated using Ldoc. Just run `"./ldoc ."` from the repo.

Tests are in the `spec` folder.

History
=======

1.0 13-Oct-2017

- many breaking changes, renamed methods, added SemVer, and updated 'strict'

0.3 18-Oct-2016

- relaxed parsing rules, added the `strict` flag

0.2 14-May-2016

- added 'tostring' meta-methods, and a required initial version for 'set'

0.1 13-May-2016

- Initial version