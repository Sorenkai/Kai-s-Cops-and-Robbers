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

CMD:m(playerid, params[])
{
    new string[128];
    if(!strlen(params)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /m <message>");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can use the megaphone");
    for(new i=0; i<MAX_PLAYERS;i++)
    {
        if(GetDistanceBetweenPlayers(playerid,i)<50)
        {
            format(string, sizeof(string),"[POLICE] %s(%i): %s",PlayerName(playerid),playerid,params);
            SendClientMessage(playerid, COLOR_BLUE, string);
        }
    }
    return 1;
}

CMD:search(playerid, params[])
{
    new string[128], targetid;
    if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /search <playerid>");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can search other players");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not search fellow police officers");
    if(GetDistanceBetweenPlayers(playerid,targetid) > 4) return SendClientMessage(playerid, COLOR_RED, "ERROR: %s(%i) is too far away, you need to get closer");
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot search someone while you are in a vehicle");
    if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER || GetPlayerState(targetid) == PLAYER_STATE_PASSENGER) return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot search someone while they are in a vehicle");
    if(IsCuffed[targetid] == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You need to cuff someone first before you can search them");
    if(HasCoke[targetid] || HasWeed[targetid])
    {
        if(HasCoke[targetid])
        {
            HasCoke[targetid] = 0;
            IncreaseWantedLevel(targetid,4);
            format(string, sizeof(string), "[POLICE] %s(%i) searched %s(%i) and found %i grams of coke. It was confiscated", PlayerName(playerid),playerid,PlayerName(targetid),targetid,HasCoke[targetid]);
            SendClientMessageToAll(COLOR_BLUE, string);
        }
        if(HasWeed[targetid])
        {
            HasWeed[targetid] = 0;
            IncreaseWantedLevel(targetid,4);
            format(string, sizeof(string), "[POLICE] %s(%i) searched %s(%i) and found %i gramms of weed. It was confiscated", PlayerName(playerid),playerid,PlayerName(targetid),targetid,HasWeed[targetid]);
            SendClientMessageToAll(COLOR_BLUE, string);
        }
    } 
    return 1;
}

CMD:suspect(playerid, params[])
{
    new reason[128];
    new targetid;
    new string[128];
    if(sscanf(params, "us[100] ", targetid, reason)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /suspect <playerid> <reason>");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can suspect other players");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not suspect fellow police officers");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not online");
    if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not suspect yourself!");
    if(HasBeenReportedRecently[targetid] > 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player has been reported recently");
    format(string, sizeof(string), "[POLICE] Officer %s(%i) has reported you. Reason: %s", PlayerName(playerid),playerid,reason);
    SendClientMessage(targetid, COLOR_BLUE, string);
    TextDrawSetString(MessageTD[targetid], "TICKET RECIEVED");
    TextDrawShowForPlayer(targetid, MessageTD[targetid]);
    MessageTDTime[targetid] =5;
    IncreaseWantedLevel(targetid, 2);
    HasBeenReportedRecently[targetid] = 60;
    IncreaseScore(playerid, 1);
    return 1;
}

CMD:ticket(playerid, params[])
{
    new targetid, string[128];
    if(sscanf(params,"u", targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /ticket <playerid>");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can issue tickets to other players");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not issue tickets to fellow police officers");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not online");
    if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not issue tickets to yourself");
    if(HasTicket[targetid]) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player already has an open ticket");
    format(string, sizeof string, "[POLICE] Officer %s(%i) has issued you with a $2000 ticket",PlayerName(playerid),playerid);
    SendClientMessage(targetid, COLOR_BLUE, string);
    SendClientMessage(targetid, COLOR_BLUE, "You have 2 minutes to pay this ticket with /payticket. Fail to do so and your wanted level will increase");
    SendClientMessage(playerid, COLOR_BLUE, "[POLICE] You have issued %s(%i) with a $2000 ticket");
    TextDrawSetString(MessageTD[targetid], "TICKET RECIEVED");
    TextDrawShowForPlayer(targetid, MessageTD[targetid]);
    MessageTDTime[targetid] =5;
    TimeToPayTicket[targetid] = 120;
    HasTicket[targetid] = 1;
    return 1;
}

CMD:payticket(playerid,params[])
{
    new string[128];
    if(HasTicket[playerid] != 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You do not have an open ticket to pay");
    SendClientMessage(playerid, COLOR_BLUE, "[TICKET] You have paid your $2000 ticket. Your wanted level has been removed");
    format(string, sizeof string, "[TICKET] %s(%i) has paid their $2000 ticket");
    SendClientMessageToAllCops(string);
    HasTicket[playerid] =0;
    SetPlayerWantedLevel(playerid, 0);
    GivePlayerMoney(playerid, -2000);
    return 1;
}

CMD:po(playerid, params[])
{
    new targetid, string[128];
    if(sscanf(params,"u",targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /po <playerid>");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not online");
    if(!IsPlayerInAnyVehicle(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not in any vehicle");
    if(GetDistanceBetweenPlayers(playerid,targetid) > 50) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is too far away");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can request other players to pull over");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not request fellow police officers");
    format(string, sizeof string, "[POLICE] You have requested %s(%i) to pull over, issue them with a ticket if they refuse to do so", PlayerName(targetid),targetid);
    SendClientMessage(playerid, COLOR_BLUE, string);
    format(string, sizeof string, "[POLICE] Officer %s(%i) has requested you to pull over", PlayerName(playerid),playerid);
    SendClientMessage(targetid, COLOR_BLUE, string);
    TextDrawSetString(MessageTD[targetid], "PULL OVER");
    TextDrawShowForPlayer(targetid , MessageTD[targetid]);
    MessageTDTime[targetid] = 5;
    return 1;
}

CMD:arrest(playerid, params[])
{
    new targetid;
    if(sscanf(params,"u",targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /arrest <playerid>");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not online");
    if(gPlayerClass[playerid] != POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Only law enforcement can arrest other players");
    if(gPlayerClass[targetid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not arrest fellow police officers");
    if(GetDistanceBetweenPlayers(playerid,targetid) > 4) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is too far away");
    if(GetPlayerWantedLevel(targetid) < 3 ) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not arrest this because their wanted level is too low. Do /ticket instead");
    if(IsCuffed[targetid] == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You need to cuff a player before you can arrest them");
    if(playerid == targetid) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not arrest yourself");
    IsArrested[targetid] = 1;
    ArrestTime[targetid] = 180;
    IsCuffed[targetid] = 0;

    //Set player to jail positions, reward playerid, reset vars/guns/wantedlevel targetid



    return 1;
}

CMD:911(playerid, params[])
{
    new string[128];
    if(!strlen(params)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /911 <message>");
    if(gPlayerClass[playerid] == POLICE) return SendClientMessage(playerid, COLOR_RED, "ERROR: Law enforcement do not need to use this command");
    format(string, sizeof string, "(911 Call) %s(%i): %s",PlayerName(playerid),playerid,params);
    SendClientMessageToAllCops(string);
    return 1;
}