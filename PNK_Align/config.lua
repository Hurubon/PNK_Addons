PNK_Align =
{
        meta =
        {
                name      = 'PNK_Align',
                author    = 'Hurubon',
                interface = '30300',

                version =
                {
                        major = 0,
                        minor = 1,
                        stage = 'alpha',
                },

                theme =
                {
                        hex = '22E6D2',
                        WowRGB = function()
                                return  0.13333333333333333,
                                        0.9019607843137255,
                                        0.8235294117647058;
                        end,

                        axes = {
                                hex = "EEFFCE54",
                                WowRGB = function()
                                        return  1.0,
                                                0.807843137254902,
                                                0.32941176470588235;
                                end,
                                WowRGBA = function()
                                        return  1.0,
                                                0.807843137254902,
                                                0.32941176470588235,
                                                0.933333333333333;
                                end,
                        },
                        gridLines = {
                                hex = "40FFFFFF",
                                WowRGB = function()
                                        return  1.0,
                                                1.0,
                                                1.0;
                                end,
                                WowRGBA = function()
                                        return  1.0,
                                                1.0,
                                                1.0,
                                                0.25;
                                end,
                        },
                },
        },
};

PNK_Align.grid = CreateFrame('Frame');
PNK_Align.grid.activeLines = PNK_Stack:Construct();
PNK_Align.grid.unusedLines = PNK_Stack:Construct();

function PNK_Align.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                PNK_Align.meta.theme.hex,
                PNK_Align.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
