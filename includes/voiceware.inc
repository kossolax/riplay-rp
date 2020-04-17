
/**
 * Sent text to speech to a client
 *
 * @param client            Client target.
 * @param language           Language of voice.
 * @param text            Text to reproduce.
 * 		       
 */
stock void VoiceWare(int client, char[] language, char[] text) 
{
	ReplaceString(text, 255, "&", ""); // prevent error
	char buffer[255];
	Format(buffer, sizeof(buffer), "https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s&client=tw-ob&ttsspeed=1.0", text, language); // use google traductor TTS
	Handle Radio = CreateKeyValues("data");
	KvSetString(Radio, "title", "Voice Ware");
	KvSetString(Radio, "type", "2");
	KvSetString(Radio, "msg", buffer);
	ShowVGUIPanel(client, "info", Radio, false);
	CloseHandle(Radio);
}

/**
 * Sent text to speech to all clients
 *
 * @param language           Language of voice.
 * @param text            Text to reproduce.
 * 		       
 */
stock void VoiceWareToAll(char[] language, char[] text) 
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			VoiceWare(i, language, text); 
}