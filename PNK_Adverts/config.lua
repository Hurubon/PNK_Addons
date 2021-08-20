PNK_Adverts =
{
        meta =
        {
                name      = 'PNK_Adverts',
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

PNK_Adverts_OutputChat = PNK_Adverts_OutputChat or 'Global';

function PNK_Adverts.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                PNK_Adverts.meta.theme.hex,
                PNK_Adverts.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
