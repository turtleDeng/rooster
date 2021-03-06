-module(rooster_srv).
-include_lib("rooster.hrl").
-behaviour(gen_server).

-export([start/1, stop/0, init/1]).
-export([handle_call/3, handle_cast/2, terminate/2, handle_info/2, code_change/3]).

start(State) ->
    gen_server:start_link(?MODULE, State, []).

stop() ->
    gen_server:cast(?MODULE, stop).

init(Env) ->
    process_flag(trap_exit, true),
    {ok, Env}.

terminate(_Reason, _Env) ->
    ok.

handle_info({'EXIT', _Pid, _Reason}, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_cast(stop, Env) ->
    {stop, normal, Env}.

%% @doc handle http request, executing relevant routes and middleware that fit on it
%%
handle_call({analyze_route, Req}, _From, {Routes, Middlewares, RespHeaders}) ->
    {Status, Response} = rooster_dispatcher:match_route(Req, Routes, Middlewares),
    Headers = [{"Content-type", "application/json"}] ++ RespHeaders,
    make_response(Status, Response, Headers).

%% @doc build response based on status and headers
%%
-spec make_response(integer(), any(), list()) -> {atom(), atom(), tuple(), list()}.

make_response(404, _, Headers) ->
    Msg = rooster_json:encode(#{message => <<"Requested endpoint not found.">>}),
    {stop, normal, {404, Headers, Msg}, []};

make_response(Status, Response, Headers) ->
    {stop, normal, {Status, Headers, rooster_json:encode(Response)}, []}.
