% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.

%% @author  Biokoda d.o.o.
%% @doc Pre-prepared responses for myactor serverside module.<br/>
%%      Some of these responses ensure compatibility with different drivers that can connect to ActorDB via MySQL protocol.<br/>
%%
%%  ```

-module(myactor_static).
-include_lib("myactor.hrl").
-compile(export_all).

show_variables() ->
	[{<<"db_version">>,?MYACTOR_VER},
	{<<"max_allowed_packet">>,<<"1048576">>},
	{<<"character_set_client">>,<<"utf8">>},
	{<<"character_set_connection">>,<<"utf8">>},
	{<<"character_set_database">>,<<"utf8">>},
	{<<"character_set_filesystem">>,<<"utf8">>},
	{<<"character_set_results">>,<<"utf8">>},
	{<<"character_set_server">>,<<"utf8">>},
	{<<"character_set_system">>,<<"utf8">>},
	{<<"collation_connection">>,<<"utf8_general_ci">>},
	{<<"collation_database">>,<<"utf8_general_ci">>},
	{<<"collation_server">>,<<"utf8_general_ci">>}   ].

show_collation() ->
	[{<<"big5_chinese_ci">>,<<"big5">>,1,1,1,1},
	{<<"big5_bin">>,<<"big5">>,84,undefined,1,1},
	{<<"dec8_swedish_ci">>,<<"dec8">>,3,1,1,1},
	{<<"dec8_bin">>,<<"dec8">>,69,undefined,1,1},
	{<<"cp850_general_ci">>,<<"cp850">>,4,1,1,1},
	{<<"cp850_bin">>,<<"cp850">>,80,undefined,1,1},
	{<<"hp8_english_ci">>,<<"hp8">>,6,1,1,1},
	{<<"hp8_bin">>,<<"hp8">>,72,undefined,1,1},
	{<<"koi8r_general_ci">>,<<"koi8r">>,7,1,1,1},
	{<<"koi8r_bin">>,<<"koi8r">>,74,undefined,1,1},
	{<<"latin1_german1_ci">>,<<"latin1">>,5,undefined,1,1},
	{<<"latin1_swedish_ci">>,<<"latin1">>,8,1,1,1},
	{<<"latin1_danish_ci">>,<<"latin1">>,15,undefined,1,1},
	{<<"latin1_german2_ci">>,<<"latin1">>,31,undefined,1,2},
	{<<"latin1_bin">>,<<"latin1">>,47,undefined,1,1},
	{<<"latin1_general_ci">>,<<"latin1">>,48,undefined,1,1},
	{<<"latin1_general_cs">>,<<"latin1">>,49,undefined,1,1},
	{<<"latin1_spanish_ci">>,<<"latin1">>,94,undefined,1,1},
	{<<"latin2_czech_cs">>,<<"latin2">>,2,undefined,1,4},
	{<<"latin2_general_ci">>,<<"latin2">>,9,1,1,1},
	{<<"latin2_hungarian_ci">>,<<"latin2">>,21,undefined,1,1},
	{<<"latin2_croatian_ci">>,<<"latin2">>,27,undefined,1,1},
	{<<"latin2_bin">>,<<"latin2">>,77,undefined,1,1},
	{<<"swe7_swedish_ci">>,<<"swe7">>,10,1,1,1},
	{<<"swe7_bin">>,<<"swe7">>,82,undefined,1,1},
	{<<"ascii_general_ci">>,<<"ascii">>,11,1,1,1},
	{<<"ascii_bin">>,<<"ascii">>,65,undefined,1,1},
	{<<"ujis_japanese_ci">>,<<"ujis">>,12,1,1,1},
	{<<"ujis_bin">>,<<"ujis">>,91,undefined,1,1},
	{<<"sjis_japanese_ci">>,<<"sjis">>,13,1,1,1},
	{<<"sjis_bin">>,<<"sjis">>,88,undefined,1,1},
	{<<"hebrew_general_ci">>,<<"hebrew">>,16,1,1,1},
	{<<"hebrew_bin">>,<<"hebrew">>,71,undefined,1,1},
	{<<"tis620_thai_ci">>,<<"tis620">>,18,1,1,4},
	{<<"tis620_bin">>,<<"tis620">>,89,undefined,1,1},
	{<<"euckr_korean_ci">>,<<"euckr">>,19,1,1,1},
	{<<"euckr_bin">>,<<"euckr">>,85,undefined,1,1},
	{<<"koi8u_general_ci">>,<<"koi8u">>,22,1,1,1},
	{<<"koi8u_bin">>,<<"koi8u">>,75,undefined,1,1},
	{<<"gb2312_chinese_ci">>,<<"gb2312">>,24,1,1,1},
	{<<"gb2312_bin">>,<<"gb2312">>,86,undefined,1,1},
	{<<"greek_general_ci">>,<<"greek">>,25,1,1,1},
	{<<"greek_bin">>,<<"greek">>,70,undefined,1,1},
	{<<"cp1250_general_ci">>,<<"cp1250">>,26,1,1,1},
	{<<"cp1250_czech_cs">>,<<"cp1250">>,34,undefined,1,2},
	{<<"cp1250_croatian_ci">>,<<"cp1250">>,44,undefined,1,1},
	{<<"cp1250_bin">>,<<"cp1250">>,66,undefined,1,1},
	{<<"cp1250_polish_ci">>,<<"cp1250">>,99,undefined,1,1},
	{<<"gbk_chinese_ci">>,<<"gbk">>,28,1,1,1},
	{<<"gbk_bin">>,<<"gbk">>,87,undefined,1,1},
	{<<"latin5_turkish_ci">>,<<"latin5">>,30,1,1,1},
	{<<"latin5_bin">>,<<"latin5">>,78,undefined,1,1},
	{<<"armscii8_general_ci">>,<<"armscii8">>,32,1,1,1},
	{<<"armscii8_bin">>,<<"armscii8">>,64,undefined,1,1},
	{<<"utf8_general_ci">>,<<"utf8">>,33,1,1,1},
	{<<"utf8_bin">>,<<"utf8">>,83,undefined,1,1},
	{<<"utf8_unicode_ci">>,<<"utf8">>,192,undefined,1,8},
	{<<"utf8_icelandic_ci">>,<<"utf8">>,193,undefined,1,8},
	{<<"utf8_latvian_ci">>,<<"utf8">>,194,undefined,1,8},
	{<<"utf8_romanian_ci">>,<<"utf8">>,195,undefined,1,8},
	{<<"utf8_slovenian_ci">>,<<"utf8">>,196,undefined,1,8},
	{<<"utf8_polish_ci">>,<<"utf8">>,197,undefined,1,8},
	{<<"utf8_estonian_ci">>,<<"utf8">>,198,undefined,1,8},
	{<<"utf8_spanish_ci">>,<<"utf8">>,199,undefined,1,8},
	{<<"utf8_swedish_ci">>,<<"utf8">>,200,undefined,1,8},
	{<<"utf8_turkish_ci">>,<<"utf8">>,201,undefined,1,8},
	{<<"utf8_czech_ci">>,<<"utf8">>,202,undefined,1,8},
	{<<"utf8_danish_ci">>,<<"utf8">>,203,undefined,1,8},
	{<<"utf8_lithuanian_ci">>,<<"utf8">>,204,undefined,1,8},
	{<<"utf8_slovak_ci">>,<<"utf8">>,205,undefined,1,8},
	{<<"utf8_spanish2_ci">>,<<"utf8">>,206,undefined,1,8},
	{<<"utf8_roman_ci">>,<<"utf8">>,207,undefined,1,8},
	{<<"utf8_persian_ci">>,<<"utf8">>,208,undefined,1,8},
	{<<"utf8_esperanto_ci">>,<<"utf8">>,209,undefined,1,8},
	{<<"utf8_hungarian_ci">>,<<"utf8">>,210,undefined,1,8},
	{<<"utf8_sinhala_ci">>,<<"utf8">>,211,undefined,1,8},
	{<<"utf8_general_mysql500_ci">>,<<"utf8">>,223,undefined,1,1},
	{<<"ucs2_general_ci">>,<<"ucs2">>,35,1,1,1},
	{<<"ucs2_bin">>,<<"ucs2">>,90,undefined,1,1},
	{<<"ucs2_unicode_ci">>,<<"ucs2">>,128,undefined,1,8},
	{<<"ucs2_icelandic_ci">>,<<"ucs2">>,129,undefined,1,8},
	{<<"ucs2_latvian_ci">>,<<"ucs2">>,130,undefined,1,8},
	{<<"ucs2_romanian_ci">>,<<"ucs2">>,131,undefined,1,8},
	{<<"ucs2_slovenian_ci">>,<<"ucs2">>,132,undefined,1,8},
	{<<"ucs2_polish_ci">>,<<"ucs2">>,133,undefined,1,8},
	{<<"ucs2_estonian_ci">>,<<"ucs2">>,134,undefined,1,8},
	{<<"ucs2_spanish_ci">>,<<"ucs2">>,135,undefined,1,8},
	{<<"ucs2_swedish_ci">>,<<"ucs2">>,136,undefined,1,8},
	{<<"ucs2_turkish_ci">>,<<"ucs2">>,137,undefined,1,8},
	{<<"ucs2_czech_ci">>,<<"ucs2">>,138,undefined,1,8},
	{<<"ucs2_danish_ci">>,<<"ucs2">>,139,undefined,1,8},
	{<<"ucs2_lithuanian_ci">>,<<"ucs2">>,140,undefined,1,8},
	{<<"ucs2_slovak_ci">>,<<"ucs2">>,141,undefined,1,8},
	{<<"ucs2_spanish2_ci">>,<<"ucs2">>,142,undefined,1,8},
	{<<"ucs2_roman_ci">>,<<"ucs2">>,143,undefined,1,8},
	{<<"ucs2_persian_ci">>,<<"ucs2">>,144,undefined,1,8},
	{<<"ucs2_esperanto_ci">>,<<"ucs2">>,145,undefined,1,8},
	{<<"ucs2_hungarian_ci">>,<<"ucs2">>,146,undefined,1,8},
	{<<"ucs2_sinhala_ci">>,<<"ucs2">>,147,undefined,1,8},
	{<<"ucs2_general_mysql500_ci">>,<<"ucs2">>,159,undefined,1,1},
	{<<"cp866_general_ci">>,<<"cp866">>,36,1,1,1},
	{<<"cp866_bin">>,<<"cp866">>,68,undefined,1,1},
	{<<"keybcs2_general_ci">>,<<"keybcs2">>,37,1,1,1},
	{<<"keybcs2_bin">>,<<"keybcs2">>,73,undefined,1,1},
	{<<"macce_general_ci">>,<<"macce">>,38,1,1,1},
	{<<"macce_bin">>,<<"macce">>,43,undefined,1,1},
	{<<"macroman_general_ci">>,<<"macroman">>,39,1,1,1},
	{<<"macroman_bin">>,<<"macroman">>,53,undefined,1,1},
	{<<"cp852_general_ci">>,<<"cp852">>,40,1,1,1},
	{<<"cp852_bin">>,<<"cp852">>,81,undefined,1,1},
	{<<"latin7_estonian_cs">>,<<"latin7">>,20,undefined,1,1},
	{<<"latin7_general_ci">>,<<"latin7">>,41,1,1,1},
	{<<"latin7_general_cs">>,<<"latin7">>,42,undefined,1,1},
	{<<"latin7_bin">>,<<"latin7">>,79,undefined,1,1},
	{<<"utf8mb4_general_ci">>,<<"utf8mb4">>,45,1,1,1},
	{<<"utf8mb4_bin">>,<<"utf8mb4">>,46,undefined,1,1},
	{<<"utf8mb4_unicode_ci">>,<<"utf8mb4">>,224,undefined,1,8},
	{<<"utf8mb4_icelandic_ci">>,<<"utf8mb4">>,225,undefined,1,8},
	{<<"utf8mb4_latvian_ci">>,<<"utf8mb4">>,226,undefined,1,8},
	{<<"utf8mb4_romanian_ci">>,<<"utf8mb4">>,227,undefined,1,8},
	{<<"utf8mb4_slovenian_ci">>,<<"utf8mb4">>,228,undefined,1,8},
	{<<"utf8mb4_polish_ci">>,<<"utf8mb4">>,229,undefined,1,8},
	{<<"utf8mb4_estonian_ci">>,<<"utf8mb4">>,230,undefined,1,8},
	{<<"utf8mb4_spanish_ci">>,<<"utf8mb4">>,231,undefined,1,8},
	{<<"utf8mb4_swedish_ci">>,<<"utf8mb4">>,232,undefined,1,8},
	{<<"utf8mb4_turkish_ci">>,<<"utf8mb4">>,233,undefined,1,8},
	{<<"utf8mb4_czech_ci">>,<<"utf8mb4">>,234,undefined,1,8},
	{<<"utf8mb4_danish_ci">>,<<"utf8mb4">>,235,undefined,1,8},
	{<<"utf8mb4_lithuanian_ci">>,<<"utf8mb4">>,236,undefined,1,8},
	{<<"utf8mb4_slovak_ci">>,<<"utf8mb4">>,237,undefined,1,8},
	{<<"utf8mb4_spanish2_ci">>,<<"utf8mb4">>,238,undefined,1,8},
	{<<"utf8mb4_roman_ci">>,<<"utf8mb4">>,239,undefined,1,8},
	{<<"utf8mb4_persian_ci">>,<<"utf8mb4">>,240,undefined,1,8},
	{<<"utf8mb4_esperanto_ci">>,<<"utf8mb4">>,241,undefined,1,8},
	{<<"utf8mb4_hungarian_ci">>,<<"utf8mb4">>,242,undefined,1,8},
	{<<"utf8mb4_sinhala_ci">>,<<"utf8mb4">>,243,undefined,1,8},
	{<<"cp1251_bulgarian_ci">>,<<"cp1251">>,14,undefined,1,1},
	{<<"cp1251_ukrainian_ci">>,<<"cp1251">>,23,undefined,1,1},
	{<<"cp1251_bin">>,<<"cp1251">>,50,undefined,1,1},
	{<<"cp1251_general_ci">>,<<"cp1251">>,51,1,1,1},
	{<<"cp1251_general_cs">>,<<"cp1251">>,52,undefined,1,1},
	{<<"utf16_general_ci">>,<<"utf16">>,54,1,1,1},
	{<<"utf16_bin">>,<<"utf16">>,55,undefined,1,1},
	{<<"utf16_unicode_ci">>,<<"utf16">>,101,undefined,1,8},
	{<<"utf16_icelandic_ci">>,<<"utf16">>,102,undefined,1,8},
	{<<"utf16_latvian_ci">>,<<"utf16">>,103,undefined,1,8},
	{<<"utf16_romanian_ci">>,<<"utf16">>,104,undefined,1,8},
	{<<"utf16_slovenian_ci">>,<<"utf16">>,105,undefined,1,8},
	{<<"utf16_polish_ci">>,<<"utf16">>,106,undefined,1,8},
	{<<"utf16_estonian_ci">>,<<"utf16">>,107,undefined,1,8},
	{<<"utf16_spanish_ci">>,<<"utf16">>,108,undefined,1,8},
	{<<"utf16_swedish_ci">>,<<"utf16">>,109,undefined,1,8},
	{<<"utf16_turkish_ci">>,<<"utf16">>,110,undefined,1,8},
	{<<"utf16_czech_ci">>,<<"utf16">>,111,undefined,1,8},
	{<<"utf16_danish_ci">>,<<"utf16">>,112,undefined,1,8},
	{<<"utf16_lithuanian_ci">>,<<"utf16">>,113,undefined,1,8},
	{<<"utf16_slovak_ci">>,<<"utf16">>,114,undefined,1,8},
	{<<"utf16_spanish2_ci">>,<<"utf16">>,115,undefined,1,8},
	{<<"utf16_roman_ci">>,<<"utf16">>,116,undefined,1,8},
	{<<"utf16_persian_ci">>,<<"utf16">>,117,undefined,1,8},
	{<<"utf16_esperanto_ci">>,<<"utf16">>,118,undefined,1,8},
	{<<"utf16_hungarian_ci">>,<<"utf16">>,119,undefined,1,8},
	{<<"utf16_sinhala_ci">>,<<"utf16">>,120,undefined,1,8},
	{<<"cp1256_general_ci">>,<<"cp1256">>,57,1,1,1},
	{<<"cp1256_bin">>,<<"cp1256">>,67,undefined,1,1},
	{<<"cp1257_lithuanian_ci">>,<<"cp1257">>,29,undefined,1,1},
	{<<"cp1257_bin">>,<<"cp1257">>,58,undefined,1,1},
	{<<"cp1257_general_ci">>,<<"cp1257">>,59,1,1,1},
	{<<"utf32_general_ci">>,<<"utf32">>,60,1,1,1},
	{<<"utf32_bin">>,<<"utf32">>,61,undefined,1,1},
	{<<"utf32_unicode_ci">>,<<"utf32">>,160,undefined,1,8},
	{<<"utf32_icelandic_ci">>,<<"utf32">>,161,undefined,1,8},
	{<<"utf32_latvian_ci">>,<<"utf32">>,162,undefined,1,8},
	{<<"utf32_romanian_ci">>,<<"utf32">>,163,undefined,1,8},
	{<<"utf32_slovenian_ci">>,<<"utf32">>,164,undefined,1,8},
	{<<"utf32_polish_ci">>,<<"utf32">>,165,undefined,1,8},
	{<<"utf32_estonian_ci">>,<<"utf32">>,166,undefined,1,8},
	{<<"utf32_spanish_ci">>,<<"utf32">>,167,undefined,1,8},
	{<<"utf32_swedish_ci">>,<<"utf32">>,168,undefined,1,8},
	{<<"utf32_turkish_ci">>,<<"utf32">>,169,undefined,1,8},
	{<<"utf32_czech_ci">>,<<"utf32">>,170,undefined,1,8},
	{<<"utf32_danish_ci">>,<<"utf32">>,171,undefined,1,8},
	{<<"utf32_lithuanian_ci">>,<<"utf32">>,172,undefined,1,8},
	{<<"utf32_slovak_ci">>,<<"utf32">>,173,undefined,1,8},
	{<<"utf32_spanish2_ci">>,<<"utf32">>,174,undefined,1,8},
	{<<"utf32_roman_ci">>,<<"utf32">>,175,undefined,1,8},
	{<<"utf32_persian_ci">>,<<"utf32">>,176,undefined,1,8},
	{<<"utf32_esperanto_ci">>,<<"utf32">>,177,undefined,1,8},
	{<<"utf32_hungarian_ci">>,<<"utf32">>,178,undefined,1,8},
	{<<"utf32_sinhala_ci">>,<<"utf32">>,179,undefined,1,8},
	{<<"binary">>,<<"binary">>,63,1,1,1},
	{<<"geostd8_general_ci">>,<<"geostd8">>,92,1,1,1},
	{<<"geostd8_bin">>,<<"geostd8">>,93,undefined,1,1},
	{<<"cp932_japanese_ci">>,<<"cp932">>,95,1,1,1},
	{<<"cp932_bin">>,<<"cp932">>,96,undefined,1,1},
	{<<"eucjpms_japanese_ci">>,<<"eucjpms">>,97,1,1,1},
	{<<"eucjpms_bin">>,<<"eucjpms">>,98,undefined,1,1}].

session_variable("tx_isolation") ->
	{{<<"@@session.tx_isolation">>},[{<<"REPEATABLE-READ">>}]};
session_variable(Variable) ->
	{{iolist_to_binary(["@@session.",Variable])},[{<<"1">>}]}.