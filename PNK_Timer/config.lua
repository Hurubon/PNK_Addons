PNK_Timer =
{
        meta =
        {
                name      = 'PNK_Timer',
                author    = 'Hurubon',
                interface = '30300',

                version =
                {
                        major = 1,
                        minor = 1,
                        stage = 'beta',
                },

                theme =
                {
                        r = 0.9490196078431372,
                        g = 0.1411764705882353,
                        b = 0.5176470588235295,
                        hex = 'F22484',
                },
        },
};

function PNK_Timer.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                PNK_Timer.meta.theme.hex,
                PNK_Timer.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
