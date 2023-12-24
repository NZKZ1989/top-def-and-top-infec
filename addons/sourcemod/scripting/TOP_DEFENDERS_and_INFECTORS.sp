
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "TOP DEFENDERS and INFECTORS",
	author = "NZ",
	version = "( PRIVATE 1.0 )"
};

int g_iTopDmg[MAXPLAYERS+1][2];
int g_iTopInfect[MAXPLAYERS+1][2];
int g_iTopMax = 3;
int g_iHudColor[2][4] = {{1, 1, 255, 255}, {255, 1, 1, 255}};
int g_iHudEffect = 1; //0/1 приводит к тому, что текст исчезает и исчезает. 2 вызывает мигание текста[?].
float g_fHudX[2] = {0.0, 1.0};
float g_fHudY[2] = {-1.0, -1.0};
float g_fHudHoldTime = 15.1; //Количество секунд для удержания текста.
float g_fHudFxTime = 1.0; //Продолжительность выбранного эффекта (может применяться не ко всем эффектам).
float g_fHudFadeIn = 1.0; //Количество секунд, которые нужно потратить на затухание.
float g_fHudFadeOut = 1.0; //Количество секунд, потраченных на затухание.

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_hurt", Event_PlayerHurt);
}

void OSTopClear()
{
	for(int i = 1; i <= MaxClients; ++i) {
		g_iTopDmg[i][0] = g_iTopInfect[i][0] = 0;
		g_iTopDmg[i][1] = g_iTopInfect[i][1] = 0;
	}
}

void Event_RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	OSTopClear();
}

void Event_RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	OSTopShow();
}

void Event_PlayerHurt(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iAttacker = GetClientOfUserId(hEvent.GetInt("attacker"));

	if(0 < iAttacker <= MaxClients)
	{
		g_iTopDmg[iAttacker][0] = iAttacker;
		g_iTopDmg[iAttacker][1] += hEvent.GetInt("dmg_health");
	}
}

public void ZR_OnClientInfected(int client, int iAttacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(0 < iAttacker <= MaxClients)
	{
		g_iTopInfect[iAttacker][0] = iAttacker;
		++g_iTopInfect[iAttacker][1];
	}
}

void OSTopShow()
{
	OSTopForming();

	int iTopNum;

	SetHudTextParams(g_fHudX[0], g_fHudY[0], g_fHudHoldTime, g_iHudColor[0][0], g_iHudColor[0][1], g_iHudColor[0][2], g_iHudColor[0][3],
		g_iHudEffect, g_fHudFxTime, g_fHudFadeIn, g_fHudFadeOut);

	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "TOP DEFENDERS\n====================\n");
	for(int i = MaxClients; i > MaxClients - g_iTopMax; --i)
	{
		if(g_iTopDmg[i][0] > 0 && IsClientInGame(g_iTopDmg[i][0]))
		{
			++iTopNum;
			Format(sBuffer, sizeof(sBuffer), "%s#%i %N - %i DMG\n", sBuffer, iTopNum, g_iTopDmg[i][0], g_iTopDmg[i][1]);
		}
	}
	Format(sBuffer, sizeof(sBuffer), "%s====================", sBuffer);
	for(int iClient = 1; iClient <= MaxClients; ++iClient) {
		if(IsClientInGame(iClient)) ShowHudText(iClient, 1, "%s", sBuffer);
	}

	iTopNum = 0;
	sBuffer = "";

	SetHudTextParams(g_fHudX[1], g_fHudY[1], g_fHudHoldTime, g_iHudColor[1][0], g_iHudColor[1][1], g_iHudColor[1][2], g_iHudColor[1][3],
		g_iHudEffect, g_fHudFxTime, g_fHudFadeIn, g_fHudFadeOut);

	Format(sBuffer, sizeof(sBuffer), "TOP INFECTORS\n====================\n");
	for(int i = MaxClients; i > MaxClients - g_iTopMax; --i)
	{
		if(g_iTopInfect[i][0] > 0 && IsClientInGame(g_iTopInfect[i][0]))
		{
			++iTopNum;
			Format(sBuffer, sizeof(sBuffer), "%s#%i %N - %i INFECTED\n", sBuffer, iTopNum, g_iTopInfect[i][0], g_iTopInfect[i][1]);
		}
	}
	Format(sBuffer, sizeof(sBuffer), "%s====================", sBuffer);
	for(int iClient = 1; iClient <= MaxClients; ++iClient) {
		if(IsClientInGame(iClient)) ShowHudText(iClient, 2, "%s", sBuffer);
	}
}

void OSTopForming()
{
	for(int i = 1; i <= MaxClients; ++i)
	{
		for(int j = 1; j < MaxClients; ++j)
		{
			if(g_iTopDmg[j][1] > g_iTopDmg[j+1][1])
			{
				OnDistribution(j);
			}
			if(g_iTopInfect[j][1] > g_iTopInfect[j+1][1])
			{
				OnDistribution2(j);
			}
		}
	}
}

void OnDistribution(int j)
{
	int iIndex = g_iTopDmg[j][0];
	int iDmg = g_iTopDmg[j][1];
	g_iTopDmg[j][0] = g_iTopDmg[j+1][0];
	g_iTopDmg[j][1] = g_iTopDmg[j+1][1];
	g_iTopDmg[j+1][0] = iIndex;
	g_iTopDmg[j+1][1] = iDmg;
}

void OnDistribution2(int j)
{
	int iIndex = g_iTopInfect[j][0];
	int iInfect = g_iTopInfect[j][1];
	g_iTopInfect[j][0] = g_iTopInfect[j+1][0];
	g_iTopInfect[j][1] = g_iTopInfect[j+1][1];
	g_iTopInfect[j+1][0] = iIndex;
	g_iTopInfect[j+1][1] = iInfect;
}
