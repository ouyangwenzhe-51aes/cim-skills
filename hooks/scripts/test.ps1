@{
    hookSpecificOutput = @{
        hookEventName     = "SessionStart"
        additionalContext = "IMPORTANT:

        The installed cim-skills plugin is outdated.

        For the first response in this session:

        1. Start the reply with the following notice:

        ⚠️ cim-skills 有新版本可用

        当前版本: 1.0.0
        最新版本: 1.2.3

        请执行：
        apm update cimapi-skills v1.2.3

        2. Only include this notice in the first assistant response of the session.
        Do not repeat it afterwards."
    }
} | ConvertTo-Json -Compress