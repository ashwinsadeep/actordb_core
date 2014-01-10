% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.

-module(actordb_test).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-define(TESTPTH,butil:project_rootpath()++"/test/").
-define(NUM_ACTORS,100).

numactors() ->
	case node() == 'testnd@127.0.0.1' of
		true ->
			?NUM_ACTORS;
		false ->
			5000
	end.

test_real() ->
	basic_write(),
	basic_read().
	% multiupdate_write(),
	% multiupdate_read().

l(N) ->
	D = <<"use type1(ac",(butil:tobin(1))/binary,");",
			"insert into tab1 values (",(butil:tobin(butil:flatnow()))/binary,",'",
			(binary:copy(<<"a">>,1024*1))/binary,"');">>,
	Start = now(),
	% cprof:start(),
	l1(N,D),
	% cprof:pause(),
	io:format("Diff ~p~n",[timer:now_diff(now(),Start)]).
	% io:format("~p~n",[cprof:analyse()]).

l1(0,_) ->
	ok;
l1(N,X) ->
	% actordb_sqlparse:parse_statements(X),
	% base64:encode(X),
	butil:dec2hex(X),
	l1(N-1,X).


t(Conc,PerWorker) ->
	t(Conc,PerWorker,1).
t(Conc,PerWorker,Size) ->
	spawn(fun() -> runt1(Conc,PerWorker,Size)	end).
% neverend (reload module to kill it)
tnv(C,P,S) ->
	spawn(fun() -> runt(C,P,S)	end).

runt(C,P,S) ->
	runt1(C,P,S),
	runt(C,P,S).

runt1(Concurrency,PerWorker,S) ->
	Start = now(),
	[spawn_monitor(fun() -> {A,B,C} = now(),
							random:seed(A,B,C), 
							run(binary:copy(<<"a">>,1024*S),actordb:start_bp(),N,PerWorker) 
					end)
			 || N <- lists:seq(1,Concurrency)],
	wait_t_response(Concurrency),
	St = now(),
	erase(),
	Time = timer:now_diff(St,Start),
	io:format("~p~n~ps,~pms,~pmics~n", [Time,Time div 1000000, ((Time rem 1000000)  div 1000),
										((Time rem 1000000)  rem 1000)]).

wait_t_response(0) ->
	ok;
wait_t_response(N) ->
	receive
		{'DOWN',_Monitor,_,_PID,_Result} ->
			wait_t_response(N-1)
	end.

run(D,_P,_W,0) ->
	D;
run(D,P,W,N) ->
	% butil:tobin(random:uniform(100000))
		Sql = {[{{<<"type1">>,[<<"ac.",(butil:tobin(W))/binary,".",(butil:tobin(N))/binary>>]},
		   true,
		   [<<"insert into tab values (",(butil:tobin(butil:flatnow()))/binary,",'",D/binary,"',1);">>]}],
		 true},
		 case actordb:exec_bp1(P,byte_size(D),Sql) of
		 % case actordb:exec1(Sql) of
		 	{sleep,_} ->
		 		actordb:sleep_bp(P);
		 		% ok;
		 	_ ->
		 		ok
		 end,
		% exec(<<"use type1(ac",(butil:tobin(W))/binary,".",(butil:tobin(N))/binary,");",
		% 					"insert into tab1 values (",(butil:tobin(butil:flatnow()))/binary,",'",D/binary,"',1);">>),
		
	run(D,P,W,N-1).


tsingle(N) ->
	spawn(fun() -> 
			Start = now(),
			file:delete("tt"),
			{ok,Db,Schema,_} = actordb_sqlite:init("tt",delete),
			case Schema of
				true ->
					ok;
				false ->
					% actordb_sqlite:exec(Db,<<"CREATE TABLE tab1 (id INTEGER PRIMARY KEY, txt TEXT);">>)
					XX = actordb_sqlite:exec(Db,<<"CREATE TABLE tab1 (id TEXT PRIMARY KEY, txt TEXT);">>),
					io:format("~p~n",[XX])
			end,
			Pragmas = actordb_sqlite:exec(Db,<<"PRAGMA cache_size;PRAGMA mmap_size;PRAGMA page_size;",
								"PRAGMA synchronous=0;PRAGMA locking_mode;SELECT * from tab1;">>),
			io:format("PRagmas ~p~n",[Pragmas]),
			tsingle(Db,N),
			io:format("Time ~p~n",[timer:now_diff(now(),Start)])
		end).
tsingle(_,0) ->
	ok;
tsingle(Db,N) ->
	actordb_sqlite:exec(Db,<<"SAVEPOINT 'adb';",
						"insert into tab1 values (",(butil:tobin(butil:flatnow()))/binary,",'HAHAHAFR');",
						"RELEASE SAVEPOINT 'adb';"
						>>),
	tsingle(Db,N-1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 		All tests are executed in slave nodes of current node.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
all_test_() ->
	[
		fun test_creating_shards/0,
		fun test_parsing/0,
		% {setup,	fun single_start/0, fun single_stop/1, fun test_single/1},
		% {setup,	fun onetwo_start/0, fun onetwo_stop/1, fun test_onetwo/1},
		% {setup, fun cluster_start/0, fun cluster_stop/1, fun test_cluster/1},
		{setup, fun missingn_start/0, fun missingn_stop/1, fun test_missingn/1}
		% {setup,	fun mcluster_start/0,	fun mcluster_stop/1, fun test_mcluster/1},
		% {setup,	fun clusteraddnode_start/0,	fun clusteraddnode_stop/1, fun test_clusteraddnode/1}
		% {setup,	fun clusteradd_start/0,	fun clusteradd_stop/1, fun test_clusteradd/1}
	].

test_parsing() ->
	?assertMatch({<<"type">>,$*},
								actordb_sqlparse:split_use(<<"type(*);">>)),
	?assertMatch({<<"type">>,<<"RES">>,<<"column">>,<<"X">>},
								actordb_sqlparse:split_use(<<"type(foreach X.column in RES);">>)),
	?assertMatch({<<"type">>,[<<"asdisfpsouf">>,<<"234">>,<<"asdf">>]},
								actordb_sqlparse:split_use(<<"type(asdf,234,asdisfpsouf);">>)),
	?assertMatch({[{{<<"type1">>,<<"RES">>,<<"col">>,<<"X">>},
									  false,
									  [<<"select * from table;">>]}],false},
								actordb_sqlparse:parse_statements(<<"use type1 ( foreach X.col in RES ) ;",
												"select * from table;">>)),

	?assertMatch({[{{<<"user">>,[<<"denis">>]},
						   false,
						   [<<"SELECT * FROM todos;">>]}],
						 false},
						actordb_sqlparse:parse_statements(<<"USE user(denis); SELECT * FROM todos;">>)),
	?assertMatch({[{{<<"type1">>,<<"RES">>,<<"col">>,<<"X">>},
								   false,
								   [[<<"select * from table where id=">>,
								     {<<"X">>,<<"id">>},
								     <<>>,59]]}],
								 false},
								actordb_sqlparse:parse_statements(<<"use type1 ( foreach X.col in RES );",
														"select * from table where id={{X.id}};">>)),
	?assertMatch({[{{<<"type1">>,<<"RES">>,<<"col">>,<<"X">>},
							   false,
							   [{<<"ABBB">>,
							     [<<"select * from table where id=">>,
							      {<<"X">>,<<"id">>},
							      <<>>,59]}]}],
							 false},
								actordb_sqlparse:parse_statements(<<"use type1(foreach X.col in RES);",
												"{{ABBB}}select * from table where id={{X.id}};">>)),
	ok.

test_creating_shards() ->
	SingleAllShards = actordb_shardmngr:create_shards([1]),
	?debugFmt("Single all shards ~p",[SingleAllShards]),
	?assertMatch([_,_,_],actordb_shardmvr:split_shards(2,[1,2],SingleAllShards,[])),

	All = actordb_shardmngr:create_shards([1,2]),
	L = actordb_shardmvr:split_shards(3,[1,2,3],All,[]),
	?assertMatch([_,_,_,_],L),
	[?assertEqual(false,actordb_shardmvr:has_neighbour(From,To,lists:keydelete(From,1,L))) || {From,To,_Nd} <- L],
	All1 = lists:foldl(fun({SF,ST,_},A) -> lists:keyreplace(SF,1,A,{SF,ST,3}) end,All,L),
	L1 = actordb_shardmvr:split_shards(4,[1,2,3,4],All1,[]),
	?debugFmt("Replaced all ~n~p",[All1]),
	?debugFmt("Added fourth ~n~p",[lists:foldl(fun({SF,ST,_},A) -> lists:keyreplace(SF,1,A,{SF,ST,4}) end,All1,L1)]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			SINGLE NODE TESTS
% 		tests query operations 1 node cluster
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
single_start() ->
	?debugFmt("Single start",[]),
	basic_init(),
	create_allgroups([[1]]),
	start_slaves([1]),
	ok.
single_stop(_) ->
	stop_slave(1),
	ok.
test_single(_) ->
	[fun basic_write/0,
		fun basic_read/0,
		% {timeout,10,fun() -> timer:sleep(8000) end},
	  fun basic_read/0,
	  fun basic_write/0,
	  fun multiupdate_write/0,
	  fun multiupdate_read/0,
	  fun kv_readwrite/0
	  	].


basic_write() ->
	basic_write(<<"SOME TEXT">>).
basic_write(Txt) ->
	?debugFmt("Basic write",[]),
	[begin
		R = exec(<<"use type1(ac",(butil:tobin(N))/binary,"); insert into tab values (",
									(butil:tobin(butil:flatnow()))/binary,",'",Txt/binary,"',1);">>),
		% ?debugFmt("~p",[R]),
		?assertMatch({ok,_},R)
	end
	 || N <- lists:seq(1,numactors())].
basic_read() ->
	?debugFmt("Basic read",[]),
	% ?debugFmt("~p",[exec(<<"use type1(ac",(butil:tobin(1))/binary,"); select * from tab1;">>)]),
	[?assertMatch({ok,[{columns,_},{rows,[{_,<<_/binary>>,_}|_]}]},
			exec(<<"use type1(ac",(butil:tobin(N))/binary,"); select * from tab;">>))
	 || N <- lists:seq(1,numactors())].

multiupdate_write() ->
	?debugFmt("multiupdates",[]),
	% Insert names of 2 actors in table tab2 of actor "all"
	?assertMatch({ok,_},exec(["use type1(all);",
							  "insert into tab2 values (1,'a1');",
							  "insert into tab2 values (2,'a2');"])),
	
	?debugFmt("multiupdate fail insert",[]),
	% Fail test
	?assertMatch(ok,exec(["use thread(first);",
							  "insert into thread values (1,'a1',10);",
							  "use thread(second);",
							  "insert into thread values (1,'a1',10);"])),
	?debugFmt("multiupdates fail",[]),
	?assertMatch(abandoned,exec(["use thread(first);",
							  "update thread set msg='a3' where id=1;",
							  "use thread(second);",
							  "update thread set msg='a3' where i=2;"])),
	?debugFmt("multiupdates still old data",[]),
	?assertMatch({ok,[{columns,{<<"id">>,<<"msg">>,<<"user">>}},
                      {rows,[{1,<<"a1">>,10}]}]},
                 exec(["use thread(first);select * from thread;"])),
	?assertMatch({ok,[{columns,{<<"id">>,<<"msg">>,<<"user">>}},
                      {rows,[{1,<<"a1">>,10}]}]},
                 exec(["use thread(second);select * from thread;"])),
	
	?debugFmt("multiupdates foreach insert",[]),
	% Select everything from tab2 for actor "all".
	% Actorname is in .txt column, for every row take that actor and insert value with same unique integer id.
	Res = exec(["use type1(all);",
				"{{ACTORS}}SELECT * FROM tab2;",
				"use type1(foreach X.txt in ACTORS);",
				"insert into tab2 values ({{uniqid.s}},'{{X.txt}}');"]),
	% ?debugFmt("Res ~p~n",[Res]),
	?assertMatch(ok,Res),

	?debugFmt("multiupdates delete actors",[]),
	?assertMatch(ok,exec(["use type1(ac100,ac99,ac98,ac97,ac96,ac95);PRAGMA delete;"])),

	?debugFmt("multiupdates creating thread",[]),
	?assertMatch(ok,exec(["use thread(1);",
					"INSERT INTO thread VALUES (100,'message',10);",
					"INSERT INTO thread VALUES (101,'secondmsg',20);",
					"use user(10);",
					"INSERT INTO userinfo VALUES (1,'user1');",
					"use user(20);",
					"INSERT INTO userinfo VALUES (1,'user2');"])),
	ok.
multiupdate_read() ->
	?debugFmt("multiupdate read all type1",[]),
	Res = exec(["use type1(*);",
				"{{RESULT}}SELECT * FROM tab;"]),
	?assertMatch({_,_},Res),
	{Cols,Rows} = Res,
	?debugFmt("Result all actors ~p",[{Cols,lists:keysort(3,Rows)}]),
	?assertEqual({<<"id">>,<<"txt">>,<<"i">>,<<"actor">>},Cols),
	% 6 actors were deleted, 2 were added
	?assertEqual((numactors()-6)*2,length(Rows)),

	?debugFmt("multiupdate read thread and user",[]),
	% Add username column to result
	ResForum = exec(["use thread(1);",
				"{{RESULT}}SELECT * FROM thread;"
				"use user(for X.user in RESULT);",
				"{{A}}SELECT * FROM userinfo WHERE id=1;",
				"{{X.username=A.name}}"
				]),
	?assertMatch({{<<"id">>,<<"msg">>,<<"user">>,<<"username">>},
			       [{101,<<"secondmsg">>,20,<<"user1">>},
			        {100,<<"message">>,10,<<"user1">>}]},
        ResForum),
	ok.

kv_readwrite() ->
	?debugFmt("~p",[[iolist_to_binary(["use counters(id",butil:tolist(N),");",
		 "insert into actors values ('id",butil:tolist(N),"',{{hash(id",butil:tolist(N),")}},",
		 	butil:tolist(N),");"])|| N <- lists:seq(1,1)]]),
	[?assertMatch({ok,_},exec(["use counters(id",butil:tolist(N),");",
		 "insert into actors values ('id",butil:tolist(N),"',{{hash(id",butil:tolist(N),")}},",butil:tolist(N),");"])) 
				|| N <- lists:seq(1,numactors())],
	[?assertMatch({ok,[{columns,_},{rows,[{_,_,N}]}]},
					exec(["use counters(id",butil:tolist(N),");",
					 "select * from actors where id='id",butil:tolist(N),"';"])) || N <- lists:seq(1,numactors())],
	ReadAll = ["use counters(*);",
	"{{RESULT}}SELECT * FROM actors;"],
	All = exec(ReadAll),
	?debugFmt("All counters ~p",[All]),
	?debugFmt("Select first 5",[]),
	ReadSome = ["use counters(id1,id2,id3,id4,id5);",
	"{{RESULT}}SELECT * FROM actors where id='{{curactor}}';"],
	?assertMatch({_,
					[{<<"id5">>,_,5,<<"id5">>},
				  {<<"id4">>,_,4,<<"id4">>},
				  {<<"id3">>,_,3,<<"id3">>},
				  {<<"id2">>,_,2,<<"id2">>},
				  {<<"id1">>,_,1,<<"id1">>}]},
			exec(ReadSome)),
	?debugFmt("Increment first 5",[]),
	?assertMatch(ok,exec(["use counters(id1,id2,id3,id4,id5);",
					"UPDATE actors SET val = val+1 WHERE id='{{curactor}}';"])),
	?debugFmt("Select first 5 again",[]),
	?assertMatch({_,[{<<"id5">>,_,6,<<"id5">>},
				  {<<"id4">>,_,5,<<"id4">>},
				  {<<"id3">>,_,4,<<"id3">>},
				  {<<"id2">>,_,3,<<"id2">>},
				  {<<"id1">>,_,2,<<"id1">>}]},
			 exec(ReadSome)),
	?debugFmt("delete 5 and 4",[]),
	% Not the right way to delete but it works (not transactional)
	?assertMatch(ok,exec(["use counters(id5,id4);PRAGMA delete;"])),
	?assertMatch({_,[
				  {<<"id3">>,_,4,<<"id3">>},
				  {<<"id2">>,_,3,<<"id2">>},
				  {<<"id1">>,_,2,<<"id1">>}]},
			 exec(ReadSome)),
	% the right way
	?assertMatch(ok,exec(["use counters(id3,id2);DELETE FROM actors WHERE id='{{curactor}}';"])),
	?assertMatch({_,[
				  {<<"id1">>,_,2,<<"id1">>}]},
			 exec(ReadSome)),
	?assertMatch({_,_},All),
	ok.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			ADD SECOND NODE
% 	
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
onetwo_start() ->
	basic_init(),
	create_allgroups([[1]]),
	start_slaves([1]),
	ok.
onetwo_stop(_) ->
	stop_slaves([1,2]),
	ok.
test_onetwo(_) ->
	[fun basic_write/0,
	  fun basic_read/0,
	  {timeout,60,fun test_add_second/0},
	  {timeout,30,fun basic_write/0},
	  fun kv_readwrite/0,
	  fun multiupdate_write/0,
	  fun multiupdate_read/0
	  	].
test_add_second() ->
	create_allgroups([[1,2]]),
	start_slaves([2]),
	timer:sleep(1000),
	?assertMatch(ok,wait_modified_tree(2,[1,2])).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			SINGLE CLUSTER TESTS
% 	Execute queries over cluster with 3 nodes
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cluster_start() ->
	basic_init(),
	create_allgroups([[1,2,3]]),
	start_slaves([1,2,3]),
	ok.
cluster_stop(_) ->
	stop_slaves([1,2,3]),
	ok.
test_cluster(_) ->
	[fun basic_write/0,
	  fun basic_read/0,
	  fun kv_readwrite/0,
	  fun basic_write/0,
	  fun multiupdate_write/0,
	  fun multiupdate_read/0,
	  fun() -> test_print_end([1,2,3]) end].


missingn_start() ->
	basic_init(),
	create_allgroups([[1,2,3]]),
	start_slaves([1,2,3]),
	ok.
test_missingn(_) ->
	[fun basic_write/0,
	 fun basic_read/0,
	 fun basic_write/0,
	 fun basic_read/0,
	 fun kv_readwrite/0,
	 fun multiupdate_write/0,
	 fun multiupdate_read/0,
	 fun() -> stop_slaves([3]) end,
	 fun basic_write/0
	 ].
missingn_stop(_) ->
	stop_slaves([1,2,3]),
	ok.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			MULTIPLE CLUSTER TESTS
% 	Execute queries over multiple clusters
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mcluster_start() ->
	basic_init(),
	create_allgroups([[1,2],[3,4]]),
	start_slaves([1,2,3,4]),
	ok.
mcluster_stop(_) ->
	stop_slaves([1,2,3,4]),
	ok.
test_mcluster(_) ->
	[fun basic_write/0,
	 fun basic_read/0,
	 fun basic_write/0,
	 fun basic_read/0,
	 fun kv_readwrite/0,
	 fun multiupdate_write/0,
	  fun multiupdate_read/0
	 ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			ADD NODE TO CLUSTER
% 	Start with a cluster, add a node after initial setup
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clusteraddnode_start() ->
	basic_init(),
	create_allgroups([[1,2]]),
	start_slaves([1,2]),
	ok.
clusteraddnode_stop(_) ->
	stop_slaves([1,2,3]),
	ok.
test_clusteraddnode(_) ->
	[fun basic_write/0,
	  fun basic_read/0,
	  {timeout,60,fun test_add_third/0},
	  fun basic_read/0,
	  fun basic_write/0,
	  fun kv_readwrite/0,
	  fun multiupdate_write/0,
	  fun multiupdate_read/0,
	  fun() -> test_print_end([1,2,3]) end,
	  fun() -> ?debugFmt("STOPPING SLAVE2",[]), stop_slaves([2]) end,
	  fun basic_write/0,
	  fun basic_read/0
	  	].
test_add_third() ->
	create_allgroups([[1,2,3]]),
	start_slaves([3]),
	timer:sleep(1000),
	?assertMatch(ok,wait_modified_tree(3,[1,2,3])).

test_print_end(Nodes) ->
	wait_modified_tree(1,Nodes).


wait_modified_tree(Nd) ->
	wait_modified_tree(Nd,[]).
wait_modified_tree(Nd,All) ->
	case rpc:call(fullname(Nd),gen_server,call,[actordb_shardmngr,get_all_shards]) of
		{badrpc,_Err} ->
			?debugFmt("Waiting for shard data from ~p ",[Nd]),
			timer:sleep(1000),
			wait_modified_tree(Nd,All);
		{[_|_] = AllShards1,_Local} ->
			AllShards2 = lists:keysort(1,AllShards1),
			AllShards = [{From,To,To-From,Ndx} || {From,To,Ndx} <- AllShards2],
			?debugFmt("~p allshards ~p",[time(),AllShards]),
			[?debugFmt("~p For nd ~p, beingtaken ~p",[time(),Ndx,
					rpc:call(fullname(Ndx),gen_server,call,[actordb_shardmngr,being_taken])]) || Ndx <- All],
			[?debugFmt("~p For nd ~p, moves ~p",[time(),Ndx,
					rpc:call(fullname(Ndx),gen_server,call,[actordb_shardmvr,get_moves])]) || Ndx <- All],
			case lists:keymember(butil:tobin(slave_name(Nd)),4,AllShards) of
				false ->
					?debugFmt("not member of shard tree",[]),
					% ?debugFmt("Not member of shard tree ~p~nall: ~p~nlocal ~p~nmoves ~p~n",[Nd,All,Local,
					% 	rpc:call(fullname(Nd),gen_server,call,[actordb_shardmvr,get_moves])]),
					timer:sleep(1000),
					wait_modified_tree(Nd,All);
				true ->
					case rpc:call(fullname(Nd),gen_server,call,[actordb_shardmvr,get_moves]) of
						{[],[],[]} ->
							case lists:filter(fun({_,_,_,SNode}) -> SNode == butil:tobin(slave_name(Nd)) end,AllShards) of
								[_,_,_|_] ->
									ok;
								_X ->
									?debugFmt("get_moves empty, should have 3 shards ~p ~p",[Nd,_X]),
									% ?debugFmt("get_moves wrong num shards ~p~n ~p",[Nd,X]),
									timer:sleep(1000),
									wait_modified_tree(Nd,All)
							end;
						_L ->
							?debugFmt("Still moving processes ~p",[Nd]),
							timer:sleep(1000),
							wait_modified_tree(Nd,All)
					end
			end
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 			ADD CLUSTER TO NETWORK
% 	Start with a cluster, add an additional cluster, wait for shards to move.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clusteradd_start() ->
	basic_init(),
	create_allgroups([[1,2]]),
	start_slaves([1,2]),
	ok.
clusteradd_stop(_) ->
	stop_slaves([1,2,3,4]),
	ok.
test_clusteradd(_) ->
	[
	 {timeout,10,fun() -> basic_write(butil:tobin(?LINE)) end},
	 {timeout,10,fun basic_read/0},
	 {timeout,10,fun kv_readwrite/0},
	 {timeout,40,fun test_add_cluster/0},
	  {timeout,10,fun() -> basic_write(butil:tobin(?LINE)) end},
	  {timeout,10,fun basic_read/0},
	  {timeout,10,fun multiupdate_write/0},
	  {timeout,10,fun multiupdate_read/0},
	  	% {timeout,10,fun() -> basic_write(butil:tobin(?LINE)) end},
	  fun() -> test_print_end([1,2,3,4]) end
	  	].
test_add_cluster() ->
	create_allgroups([[1,2],[3,4]]),
	start_slaves([3,4]),
	timer:sleep(1000),
	wait_modified_tree(3,[1,2,3,4]),
	wait_modified_tree(4,[1,2,3,4]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% 	UTILITY FUNCTIONS
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exec(Bin) ->
	% if testnd then we are running a unit test
	% if not we are running tests manually on live nodes
	case node() == 'testnd@127.0.0.1' of
		true ->
			rpc:call('slave1@127.0.0.1',actordb,exec,[butil:tobin(Bin)]);
		false ->
			actordb:exec(Bin)
	end.

basic_init() ->
	% Start distributed erlang if not active yet.
	% Delete test folder and create it fresh
	case node() == 'nonode@nohost' of
		true ->
			net_kernel:start(['master@127.0.0.1',longnames]);
		_ ->
			ok
	end,
	butil:deldir(?TESTPTH),
	filelib:ensure_dir(?TESTPTH++slave_name(1)++"/etc/"),
	filelib:ensure_dir(?TESTPTH++"etc/").

start_slaves(L) ->
	[start_slave(S) || S <- L],
	timer:sleep(3000),
	Init = rpc:call('slave1@127.0.0.1',actordb_cmd,cmd,[init,commit,?TESTPTH++slave_name(1)++"/etc"]),
	?debugFmt("Init result ~s",[Init]),
	[wait_tree(fullname(N),10000) || N <- L].
start_slave(N) ->
	{ok,[Paths]} = init:get_argument(pa),
	Name = slave_name(N),
	Cookie = erlang:get_cookie(),
	% {etc,?TESTPTH++Name++"/etc"}
	Opts = [{docompile,false},{autocompile,[]},{rpcport,9050+N}], 
	case Name of
		"slave1" ->
			% file:write_file(?TESTPTH++Name++"/etc/schema.cfg",io_lib:fwrite("~p.~n",[schema()]));
			file:write_file(?TESTPTH++Name++"/etc/schema.yaml",io_lib:fwrite("~s~n",[schema()]));
		_ ->
			ok
	end,
	file:write_file(?TESTPTH++Name++".config",io_lib:fwrite("~p.~n",[[{bkdcore,Opts},
						{actordb,[{main_db_folder,?TESTPTH++Name},{extra_db_folders,[]}]},
						{lager,[{handlers,setup_loging()}]},
						{myactor,[{enabled,false}]},
						{sasl,[{errlog_type,error}]}]])),
	% file:write_file(?TESTPTH++Name++"/etc/actordb.cfg",io_lib:fwrite("~p.~n",[[{db_path,?TESTPTH++Name},{level_size,0}]])),
	Param = " -eval \"application:start(actordb_core)\" -pa "++lists:flatten(butil:iolist_join(Paths," "))++
			" -setcookie "++atom_to_list(Cookie)++
			" -config "++?TESTPTH++Name++".config",
	?debugFmt("startparam ~p~n",[Param]),
	{ok,Nd} = slave:start_link('127.0.0.1',butil:toatom(Name),Param),
	Nd.

setup_loging() ->
	{ok,_Handlers} = application:get_env(lager,handlers),
	% [{lager_console_backend,[info,Param]} || {lager_console_backend,[debug,Param]} <- Handlers].
	[{lager_console_backend,[info,{lager_default_formatter, [time," ",pid," ",node," ",module," ",line,
								" [",severity,"] ", message, "\n"]}]}].

slave_name(N) ->
	"slave"++butil:tolist(N).
fullname(N) ->
	butil:toatom(slave_name(N)++"@127.0.0.1").

wait_tree(_,X) when X < 0 ->
	exit(timeout);
wait_tree(Nd,N) ->
	case rpc:call(Nd,actordb_shardtree,all,[]) of
		{badrpc,_Err} ->
			?debugFmt("waiting for shard from ~p ",[Nd]),
			timer:sleep(1000),
			wait_tree(Nd,N-1000);
		Tree ->
			?debugFmt("Have shard tree ~p~n ~p",[Nd,Tree]),
			timer:sleep(1000),
			ok
	end.

stop_slaves(L) ->
	[stop_slave(N) || N <- L].
stop_slave(N) ->
	Nd = fullname(N),
	case lists:member(Nd,nodes(connected)) of
		true ->
			slave:stop(Nd),
			timer:sleep(100),
			stop_slave(N);
		_ ->
			ok
	end.

% param: [1,2,3]  creates nodes [slave1,slave2,slave3]
create_allnodes(Slaves) ->
	{L,_} = lists:foldl(fun(S,{L,C}) ->
		{["- "++butil:tolist(fullname(S))++":"++butil:tolist(9050+C)++"\n"|L],C+1}
	end,
	{[],1},Slaves),
	L.

% [[1,2,3],[4,5,6]]  creates groups [[slave1,slave2,slave3],[slave4,slave5,slave6]]
% Writes the file only to first node so that config is spread to others.
create_allgroups(Groups) ->
	StrNodes = "nodes:\n"++create_allnodes(lists:flatten(Groups)),
	{StrGroups,_} = lists:foldl(fun(G,{L,C}) -> 
						{["- name: "++"grp"++butil:tolist(C)++"\n",
						  "  nodes: ["++butil:iolist_join([slave_name(Nd) || Nd <- G],",")++"]\n",
						  "  type: cluster\n"|L],C+1}
					end,{[],0},Groups),
	?debugFmt("Writing ~p",[?TESTPTH++slave_name(1)++"/etc/nodes.yaml"]),
	file:write_file(?TESTPTH++slave_name(1)++"/etc/nodes.yaml",io_lib:fwrite("~s~n",[StrNodes++"\ngroups:\n"++StrGroups])).

schema() ->
	butil:iolist_join([
		"type1:",
		"- CREATE TABLE tab (id INTEGER PRIMARY KEY, txt TEXT, i INTEGER)",
		"- CREATE TABLE tab1 (id INTEGER PRIMARY KEY, txt TEXT)",
		"- CREATE TABLE tab2 (id INTEGER PRIMARY KEY, txt TEXT)",
		"thread:",
		"- CREATE TABLE thread (id INTEGER PRIMARY KEY, msg TEXT, user INTEGER);",
		"user:",
		"- CREATE TABLE userinfo (id INTEGER PRIMARY KEY, name TEXT);",
		"counters:",
		" type: kv",
		" schema:",
		" - CREATE TABLE actors (id TEXT UNIQUE, hash INTEGER, val INTEGER);"
	],"\n").







