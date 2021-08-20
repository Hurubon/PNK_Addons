Duelist =
{
        meta =
        {
                name      = 'Duelist',
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
                        r = 0.9607843137254902,
                        g = 0.6823529411764706,
                        b = 0.23921568627450981,
                        hex = 'F5AE3D',
                },
        },
};

Duelist_PostDuelMessage = Duelist_PostDuelMessage or 'gg';

function Duelist.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                Duelist.meta.theme.hex,
                Duelist.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
