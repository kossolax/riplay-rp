#if defined _snake_included_
  #endinput
#endif
#define _snake_included_
 
/**
 * Check if a player is currently playing tetris.
 *
 * @param client  Client index.
 * @return        True if the player is currently playing tetris, false otherwise.
 */
native bool:IsClientInSnakeGame(client);


public SharedPlugin:__pl_snake = 
{
	name = "snake",
	file = "snake.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_snake_SetNTVOptional()
{
	MarkNativeAsOptional("IsClientInSnakeGame");
}
#endif