//
// This file was generated with color_gen.py and should not be used outside of colorlib.inc
//
// Do not edit! Regenerate this file with color_gen.py
//

#if defined _colorlib_map_included
    #endinput
#endif
#define _colorlib_map_included

enum CL_Colors
{
    CL_Color_Default = 0x01,
    CL_Color_Prefix = 0x04,
    CL_Color_Reply2cmd = 0x01,
    CL_Color_Showactivity = 0x01,
    CL_Color_Error = 0x07,
    CL_Color_Highlight = 0x10,
    CL_Color_Player = 0x09,
    CL_Color_Settings = 0x02,
    CL_Color_Command = 0x02,
    CL_Color_Team_0 = 0x08,
    CL_Color_Team_1 = 0x09,
    CL_Color_Team_2 = 0x11,
    CL_Color_Teamcolor = 0x03,
    CL_Color_Gray = 0x08,
    CL_Color_Gray2 = 0x0D,
    CL_Color_Bluegray = 0x0A,
    CL_Color_Steelblue = 0x0D,
    CL_Color_Pink = 0x0E,
    CL_Color_Lightblue = 0x0A,
    CL_Color_Olive = 0x05,
    CL_Color_Red = 0x07,
    CL_Color_Lightred = 0x0F,
    CL_Color_Darkred = 0x02,
    CL_Color_Bluegrey = 0x0A,
    CL_Color_Blue = 0x0B,
    CL_Color_Darkblue = 0x0C,
    CL_Color_Purple = 0x03,
    CL_Color_Orchid = 0x0E,
    CL_Color_Orange = 0x10,
    CL_Color_Yellow = 0x09,
    CL_Color_Gold = 0x10,
    CL_Color_Lightgreen = 0x05,
    CL_Color_Green = 0x04,
    CL_Color_Lime = 0x06,
    CL_Color_Grey = 0x08,
    CL_Color_Grey2 = 0x0D,
};

CL_Colors _CL_ColorMap(char color[16])
{
    if (color[0] == 'd')
    {
        if (color[1] == 'e')
        {
            return CL_Color_Default;
        }
        else if (color[1] == 'a')
        {
            if (color[4] == 'r')
            {
                return CL_Color_Darkred;
            }
            else if (color[4] == 'b')
            {
                return CL_Color_Darkblue;
            }
        }
    }
    else if (color[0] == 'p')
    {
        if (color[1] == 'r')
        {
            return CL_Color_Prefix;
        }
        else if (color[1] == 'l')
        {
            return CL_Color_Player;
        }
        else if (color[1] == 'i')
        {
            return CL_Color_Pink;
        }
        else if (color[1] == 'u')
        {
            return CL_Color_Purple;
        }
    }
    else if (color[0] == 'r')
    {
        if (color[2] == 'p')
        {
            return CL_Color_Reply2cmd;
        }
        else if (color[2] == 'd')
        {
            return CL_Color_Red;
        }
    }
    else if (color[0] == 's')
    {
        if (color[1] == 'h')
        {
            return CL_Color_Showactivity;
        }
        else if (color[1] == 'e')
        {
            return CL_Color_Settings;
        }
        else if (color[1] == 't')
        {
            return CL_Color_Steelblue;
        }
    }
    else if (color[0] == 'e')
    {
        return CL_Color_Error;
    }
    else if (color[0] == 'h')
    {
        return CL_Color_Highlight;
    }
    else if (color[0] == 'c')
    {
        return CL_Color_Command;
    }
    else if (color[0] == 't')
    {
        if (color[4] == ' ')
        {
            if (color[5] == '0')
            {
                return CL_Color_Team_0;
            }
            else if (color[5] == '1')
            {
                return CL_Color_Team_1;
            }
            else if (color[5] == '2')
            {
                return CL_Color_Team_2;
            }
        }
        else if (color[4] == 'c')
        {
            return CL_Color_Teamcolor;
        }
    }
    else if (color[0] == 'g')
    {
        if (color[1] == 'r')
        {
            if (color[2] == 'a')
            {
                if (color[4] == 0x0)
                {
                    return CL_Color_Gray;
                }
                else if (color[4] == '2')
                {
                    return CL_Color_Gray2;
                }
            }
            else if (color[2] == 'e')
            {
                if (color[3] == 'e')
                {
                    return CL_Color_Green;
                }
                else if (color[3] == 'y')
                {
                    if (color[4] == 0x0)
                    {
                        return CL_Color_Grey;
                    }
                    else if (color[4] == '2')
                    {
                        return CL_Color_Grey2;
                    }
                }
            }
        }
        else if (color[1] == 'o')
        {
            return CL_Color_Gold;
        }
    }
    else if (color[0] == 'b')
    {
        if (color[4] == 'g')
        {
            if (color[6] == 'a')
            {
                return CL_Color_Bluegray;
            }
            else if (color[6] == 'e')
            {
                return CL_Color_Bluegrey;
            }
        }
        else if (color[4] == 0x0)
        {
            return CL_Color_Blue;
        }
    }
    else if (color[0] == 'l')
    {
        if (color[2] == 'g')
        {
            if (color[5] == 'b')
            {
                return CL_Color_Lightblue;
            }
            else if (color[5] == 'r')
            {
                return CL_Color_Lightred;
            }
            else if (color[5] == 'g')
            {
                return CL_Color_Lightgreen;
            }
        }
        else if (color[2] == 'm')
        {
            return CL_Color_Lime;
        }
    }
    else if (color[0] == 'o')
    {
        if (color[1] == 'l')
        {
            return CL_Color_Olive;
        }
        else if (color[1] == 'r')
        {
            if (color[2] == 'c')
            {
                return CL_Color_Orchid;
            }
            else if (color[2] == 'a')
            {
                return CL_Color_Orange;
            }
        }
    }
    else if (color[0] == 'y')
    {
        return CL_Color_Yellow;
    }

    return view_as<CL_Colors>(0x00);
}

