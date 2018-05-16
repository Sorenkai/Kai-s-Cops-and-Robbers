//- /cuff (PlayerName/ID)
//- /m(egaphone) (Message)
//- Roadblocks
//- /search (PlayerName/ID)
//- /suspect (PlayerName/ID) (Reason)
//- /ticket (PlayerName/ID)
//- /payticket
//- /pu (PlayerName/ID)
//- /arrest (PlayerName/ID)
//- /detain (PlayerName/ID)
//- /dropoff (PlayerName/ID)
//- /911 (Message) - For Civilians.

CMD:cuff(playerid,params[])
{
    new targetid, string[128];
    if(sscanf(params,"i" , targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /cuff <playerid>");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not cuff fellow police officers");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can cuff other players");
    if(IsCuffed[targetid] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is already cuffed");
    if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER || GetPlayerState(targetid) == PLAYER_STATE_PASSENGER) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not cuff players while they're in a vehicle");
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not cuff players while you are in a vehicle");

    new crand = random(100);
    if(crand < 30) return SendClientMessage(playerid, COLOR_RED, "ERROR: Cuff failed, try again");
    if(GetDistanceBetweenPlayers(playerid,targetid) <= 4 && crand > 30)
    {
        format(string, sizeof(string), "You have placed cuffs on %s(%i) They are now frozen",PlayerName(targetid),targetid);
        SendClientMessage(playerid, COLOR_BLUE, string);
        format(string, sizeof(string), "You have been cuffed by %s(%i) You can no longer move", PlayerName(playerid),playerid);
        SendClientMessage(targetid, COLOR_BLUE, string);
        TogglePlayerControllable(targetid, 0);
        LoopAnim(targetid, "ped", "cower", 3.0, 1, 0, 0, 0, 0);
        IsCuffed[targetid] = 1;
    }
    return 1;
}