public Action Command_DatabaseUpgrade(int client, int args)
{
    ReplyToCommand(client, "Starting database upgrade...");

    db_startUpgrading();
}
