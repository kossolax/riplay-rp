#if defined _pong_included_
  #endinput
#endif
#define _pong_included_
 
/**
 * Check if a player is currently playing tetris.
 *
 * @param client  Client index.
 * @return        True if the player is currently playing tetris, false otherwise.
 */
native bool:IsClientInPongGame(client);


public SharedPlugin:__pl_pong = 
{
	name = "pong",
	file = "pong.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_pong_SetNTVOptional()
{
	MarkNativeAsOptional("IsClientInPongGame");
}
#endif