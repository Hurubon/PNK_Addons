PNK_Stack =
{
        meta =
        {
                name      = 'PNK_Stack',
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
                        r = 0.9490196078431372,
                        g = 0.1411764705882353,
                        b = 0.5176470588235295,
                        hex = 'F22484',
                },
        },

        container = {},
};

function PNK_Stack.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                PNK_Stack.meta.theme.hex,
                PNK_Stack.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
