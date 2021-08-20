CombatLogFix =
{
        meta =
        {
                name      = 'CombatLogFix',
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
                        r = 0.9607843137254902,
                        g = 0.6823529411764706,
                        b = 0.23921568627450981,
                        hex = 'F5AE3D',
                },
        },
};

function CombatLogFix.Print(...)
        local prefix = string.format(
                '[|cFF%s%s|r]:',
                CombatLogFix.meta.theme.hex,
                CombatLogFix.meta.name
        );
        local message = string.join(' ', prefix, tostringall(...));

        DEFAULT_CHAT_FRAME:AddMessage(message);
end
