PNK_Scratchpad =
{
        meta =
        {
                name      = 'PNK_Scratchpad',
                author    = 'Hurubon',
                interface = '30300',

                version =
                {
                        major = 1,
                        minor = 0,
                        stage = 'beta',
                },

                theme =
                {
                        r = 0.13333333333333333,
                        g = 0.9019607843137255,
                        b = 0.8235294117647058,
                        hex = '22E6D2',
                },
        },
};

function PNK_Scratchpad.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                PNK_Scratchpad.meta.theme.hex,
                PNK_Scratchpad.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
