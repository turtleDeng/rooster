-module(rooster_app).

-include_lib("rooster.hrl").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for rooster.
start(_Type, _StartArgs) ->
    Options = gen_server:call(rooster_holder, get_state),
    rooster_holder:stop(),
    rooster_sup:start_link(Options).

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for rooster.
stop(_State) ->
    ok.
