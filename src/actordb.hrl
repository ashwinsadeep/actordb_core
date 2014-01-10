% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.

-compile([{parse_transform, lager_transform}]).
-define(MIN_SHARDS,3).
-define(NAMESPACE_MAX,134217728).
-define(MULTIUPDATE_TYPE,'__mupdate__').
-define(DEF_CACHE_PAGES,10).

-define(ADBG(F),lager:debug(F)).
-define(ADBG(F,A),lager:debug(F,A)).
-define(AINF(F),lager:info(F)).
-define(AINF(F,A),lager:info(F,A)).
-define(AERR(F),lager:error(F)).
-define(AERR(F,A),lager:error(F,A)).