#pragma semicolon 1

#include <sourcemod>

#define BM_MAGIC 0xBAADF00D
#define BINARY_FORMAT_VERSION 0x01
#define ADDITIONAL_FIELD_TELEPORTED_ORIGIN (1<<0)
#define ADDITIONAL_FIELD_TELEPORTED_ANGLES (1<<1)
#define ADDITIONAL_FIELD_TELEPORTED_VELOCITY (1<<2)
#define FRAME_INFO_SIZE 15
#define AT_SIZE 10
#define ORIGIN_SNAPSHOT_INTERVAL 500
#define FILE_HEADER_LENGTH 74

enum FrameInfo
{
	playerButtons = 0,
	playerImpulse,
	Float:actualVelocity[3],
	Float:predictedVelocity[3],
	Float:predictedAngles[2],
	CSWeaponID:newWeapon,
	playerSubtype,
	playerSeed,
	additionalFields,
	pause,
}

enum AdditionalTeleport
{
	Float:atOrigin[3],
	Float:atAngles[3],
	Float:atVelocity[3],
	atFlags
}

enum FileHeader
{
	FH_binaryFormatVersion = 0,
	String:FH_Time[32],
	String:FH_Playername[32],
	FH_Checkpoints,
	FH_tickCount,
	Float:FH_initialPosition[3],
	Float:FH_initialAngles[3],
	Handle:FH_frames
}

public Plugin myinfo =  {
	name = "Replay Converter",
	author = "Bara",
	description = "Convert old replays to the format with emum struct support",
	version = "1.0.0",
	url = "github.com/Bara"
};

public void OnPluginStart()
{
	ReadRecordsDirectory();
}

void ReadRecordsDirectory()
{
	char sDir[PLATFORM_MAX_PATH + 1];
	BuildPath(Path_SM, sDir, sizeof(sDir), "data/replays");

	if (DirExists(sDir))
	{
		DirectoryListing dDir = OpenDirectory(sDir);

		if (dDir != null)
		{
			char sFile[PLATFORM_MAX_PATH +1];
			FileType fType;

			while (dDir.GetNext(sFile, sizeof(sFile), fType))
			{
				if (fType == FileType_File)
				{
					if (StringEndsWith(sFile, ".rec"))
					{
						ReadRecord(sDir, sFile);
					}
				}
			}
		}

		delete dDir;
	}
}

void ReadRecord(const char[] directory, const char[] file)
{
	char sBuffer[PLATFORM_MAX_PATH + 1];
	Format(sBuffer, sizeof(sBuffer), "%s/%s", directory, file);

	File fFile = OpenFile(sBuffer, "rb");
	if (fFile == null)
		return;

	int iMagic;
	ReadFileCell(fFile, iMagic, 4);
	if (iMagic != BM_MAGIC)
	{
		delete fFile;
		return;
	}
	int headerInfo[FILE_HEADER_LENGTH];

	int iBinaryFormatVersion;
	ReadFileCell(fFile, iBinaryFormatVersion, 1);
	headerInfo[view_as<int>(FH_binaryFormatVersion)] = iBinaryFormatVersion;

	if (iBinaryFormatVersion > BINARY_FORMAT_VERSION)
	{
		delete fFile;
		return;
	}

	int iNameLength;
	ReadFileCell(fFile, iNameLength, 1);
	char szTime[MAX_NAME_LENGTH];
	ReadFileString(fFile, szTime, iNameLength + 1, iNameLength);
	szTime[iNameLength] = '\0';

	int iNameLength2;
	ReadFileCell(fFile, iNameLength2, 1);
	char szName[MAX_NAME_LENGTH];
	ReadFileString(fFile, szName, iNameLength2 + 1, iNameLength2);
	szName[iNameLength2] = '\0';

	int iCp;
	ReadFileCell(fFile, iCp, 4);

	ReadFile(fFile, view_as<int>(headerInfo[view_as<int>(FH_initialPosition)]), 3, 4);
	ReadFile(fFile, view_as<int>(headerInfo[view_as<int>(FH_initialAngles)]), 2, 4);

	int iTickCount;
	ReadFileCell(fFile, iTickCount, 4);

	strcopy(headerInfo[view_as<int>(FH_Time)], 32, szTime);
	strcopy(headerInfo[view_as<int>(FH_Playername)], 32, szName);
	headerInfo[view_as<int>(FH_Checkpoints)] = iCp;
	headerInfo[view_as<int>(FH_tickCount)] = iTickCount;
	headerInfo[view_as<int>(FH_frames)] = null;

	ArrayList aRecordFrames = new ArrayList(view_as<int>(FrameInfo));
	ArrayList aAdditionalTeleport = new ArrayList(AT_SIZE);

	int iFrame[FRAME_INFO_SIZE];
	for (int i = 0; i < iTickCount; i++)
	{
		ReadFile(fFile, iFrame, view_as<int>(FrameInfo), 4);
		aRecordFrames.PushArray(iFrame, view_as<int>(FrameInfo));

		if (iFrame[view_as<int>(additionalFields)] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			int iAT[AT_SIZE];
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				ReadFile(fFile, view_as<int>(iAT[atOrigin]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				ReadFile(fFile, view_as<int>(iAT[atAngles]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				ReadFile(fFile, view_as<int>(iAT[atVelocity]), 3, 4);
			iAT[view_as<int>(atFlags)] = iFrame[view_as<int>(additionalFields)] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY);
			aAdditionalTeleport.PushArray(iAT, AT_SIZE);
		}
	}

	headerInfo[view_as<int>(FH_frames)] = aRecordFrames;

	delete fFile;
	DeleteFile(sBuffer);

	return;
}

/*
	Taken this stock from SMLib
	https://github.com/bcserv/smlib/blob/transitional_syntax/scripting/include/smlib/strings.inc#L203-L228
*/
stock bool StringEndsWith(const char[] str, const char[] subString)
{
	int n_str = strlen(str) - 1;
	int n_subString = strlen(subString) - 1;

	if(n_str < n_subString) {
		return false;
	}

	while (n_str != 0 && n_subString != 0) {

		if (str[n_str--] != subString[n_subString--]) {
			return false;
		}
	}

	return true;
}
