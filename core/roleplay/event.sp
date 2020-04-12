#if defined _roleplay_event_included
#endinput
#endif
#define _roleplay_event_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#endif

#include <roleplay/event.damage.sp>
#include <roleplay/event.game.sp>
#include <roleplay/event.player.sp>
#include <roleplay/event.player.connect.sp>
#include <roleplay/event.think.sp>

public Action BashCheckName(Handle timer, any client) {
	detectCapsLock(client);
}

