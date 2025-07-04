# 关于如何在 Linux 上使用 PowerShell:
# https://learn.microsoft.com/zh-cn/powershell/scripting/install/installing-powershell-on-linux

# 设置服务器最大崩溃重启次数
$ServerCrashRestart = 10

# 设置服务器名称
$ServerName = "Minecraft Next"

# 设置 Java 路径
$ServerJava = "java"

# 设置服务器核心路径
$ServerCore = "server.jar"

# 设置服务器使用内存
$ServerMemory = "4G"

# 设置服务器默认文件编码
$ServerEncoding = "UTF-8"

# 设置 Javaagent 路径
# 格式为：路径[=参数]
# 例：
# @(
#     "sugar-0.1.0.jar"
#     "xxx.jar=xxx"
# )
$ServerJavaagents = @()

# 设置 Sugar 日志等级
# 非 Sugar 端可忽略此项
# https://github.com/ideal-state/minecraft-next-runner
$ServerSugarLogLevel = "DEBUG"

# 设置 Sugar Next 环境名称
# 非 Sugar 端可忽略此项
# https://github.com/ideal-state/minecraft-next-runner
$ServerSugarNextEnv = "development"

# 设置服务器额外启动参数，不懂请勿修改！！
# 以下启动参数来自：https://www.zitbbs.com/thread-916-1-1.html
$ServerExtraOptions = @(
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daikars.new.flags=true"
)

function Main {
    param()
    Set-HostColor
    Set-Encoding -Encoding $ServerEncoding
    Show-Banner
    Start-Server
    Quit
}

function Show-Banner {
    param()
    Set-Location -Path $PSScriptRoot
    $Host.UI.RawUI.ForegroundColor = "Green"
    Write-Host "------------------------------------------------------------"
    Write-Host " ███╗   ██╗ ███████╗ ██╗  ██╗ ████████╗"
    Write-Host " ████╗  ██║ ██╔════╝ ╚██╗██╔╝ ╚══██╔══╝"
    Write-Host " ██╔██╗ ██║ █████╗    ╚███╔╝     ██║   "
    Write-Host " ██║╚██╗██║ ██╔══╝    ██╔██╗     ██║   "
    Write-Host " ██║ ╚████║ ███████╗ ██╔╝ ██╗    ██║   "
    Write-Host " ╚═╝  ╚═══╝ ╚══════╝ ╚═╝  ╚═╝    ╚═╝   "
    Write-Host " ideal-state © 2025"
    Write-Host " https://github.com/ideal-state/minecraft-next-runner"
    Write-Host ""
    Write-Host " [服务器名称]`t| $(Limit-Text -Text $ServerName)"
    Write-Host " [工作目录]`t| $(Get-Location)"
    Write-Host " [Java 路径]`t| $(Limit-Text -Delimiter "\" -Text $((Get-Command $ServerJava).Source))"
    Write-Host " [核心路径]`t| $(Limit-Text -Delimiter "\" -Text $ServerCore)"
    Write-Host " [最大内存]`t| $(Limit-Text -Text $ServerMemory)"
    Write-Host " [文件编码]`t| $(Limit-Text -Text $ServerEncoding)"
    Write-Host " [日志等级]`t| $(Limit-Text -Text $ServerSugarLogLevel)"
    Write-Host " [环境名称]`t| $(Limit-Text -Text $ServerSugarNextEnv)"
    Write-Host " [额外参数]`t| $(Limit-Text -Text $ServerExtraOptions)"
    Write-Host "------------------------------------------------------------"
    Write-Host ""
    Start-Countdown -Message "[!] 启动服务器..."
    Set-HostColor -Clear $true
}

function Limit-Text {
    param(
        [string]$Delimiter="",
        [string]$Text,
        [int]$MaxLength = 64
    )
    if ($Text.Length -le $MaxLength) {
        return $Text
    }
    if ($Delimiter -eq "") {
        return $Text.Substring(0, $MaxLength) + "..."
    }
    else {
        $spilt = $Text.Split($Delimiter)
        if ($spilt.Length -eq 1) {
            return $Text.Substring(0, $MaxLength) + "..."
        }
        
        $last = $spilt.Get($spilt.Length - 1)
        $remainingLength = $MaxLength - $last.Length - ($Delimiter.Length * 2)
        $result = ""
        for ($i = 0; $i -lt $spilt.Length - 1; $i++) {
            $temp = $result + $Delimiter + $spilt.Get($i)
            if ($temp.Length -gt $remainingLength) {
                break
            }
            $result = $temp
        }
        if ($result -eq "") {
            return "..." + $Delimiter + $last
        }
        return $result + $Delimiter + "..." + $Delimiter + $last
    }
}

function Set-HostColor {
    param (
        [bool]$Clear=$false
    )
    if ($Clear) { Clear-Host }
    $Host.UI.RawUI.ForegroundColor = "White"
}

function Set-Encoding {
    param(
        [string]$Encoding
    )
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding($Encoding)
        [Console]::InputEncoding = [System.Text.Encoding]::GetEncoding($Encoding)
        $PSDefaultParameterValues['Out-File:Encoding'] = $Encoding
        $PSDefaultParameterValues['Export-Csv:Encoding'] = $Encoding
        $PSDefaultParameterValues['Select-String:Encoding'] = $Encoding
        if ($PSVersionTable.PSVersion.Major -ge 5) {
            $PSDefaultParameterValues['*:Encoding'] = $Encoding
        }
        
        Write-Host "[√] 已将控制台输入/输出编码设置为 $Encoding"
    }
    catch {
        Write-Host "[!] 无法设置编码为 $Encoding : $_" -ForegroundColor Red
        Write-Host "[!] 将使用默认编码: $([Console]::OutputEncoding.EncodingName)" -ForegroundColor Yellow
    }
}

function Start-Countdown {
    param(
        [String]$Message,
        [int]$Seconds=5
    )
    $exit = $false
    $whitespace = "                                                               "
    for ($i = $Seconds; $i -gt 0; $i--) {
        Write-Host "`r$whitespace`r[Enter - 继续 / Escape - 退出]" -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 400
        Write-Host "`r$whitespace`r$Message（倒计时 $i 秒）" -NoNewline -ForegroundColor Yellow
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key) {
                $key = $key.Key
                if ($key -eq "Enter") {
                    break
                }
                elseif ($key -eq "Escape") {
                    $exit = $true
                    break
                }
            }
        }
        Start-Sleep -Milliseconds 600
    }
    Write-Host "`r$whitespace`r"
    if ($exit) {
        Quit
    }
}

function Quit {
    param()
    Write-Host "[√] 程序已退出，按任意键关闭窗口..." -NoNewline -ForegroundColor White
    [Console]::ReadKey($true)
    Exit
}

function Start-Server {
    param(
        [bool]$Restart=$true
    )
    Set-HostColor
    $Host.UI.RawUI.WindowTitle = "$ServerName - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
    
    $arguments = @(
        "-Xms$ServerMemory"
        "-Xmx$ServerMemory"
        "-Dfile.encoding=$ServerEncoding"
        "-Dsugar.log.level=$ServerSugarLogLevel"
        "-Dsugar.next.environment=$ServerSugarNextEnv"
    )
    if ($ServerExtraOptions -and $ServerExtraOptions.Count -gt 0) {
        $ServerExtraOptions | ForEach-Object {
            $arguments += "$_"
        }
    }
    if ($ServerJavaagents -and $ServerJavaagents.Count -gt 0) {
        $ServerJavaagents | ForEach-Object {
            $arguments += "-javaagent:$_"
        }
    }
    $arguments += "-jar", "$ServerCore", "nogui"
    $process = Start-Process -FilePath $ServerJava -ArgumentList $arguments -Wait -PassThru -NoNewWindow

    Set-HostColor
    Write-Host ""
    $exitCode = $process.ExitCode
    Write-Host "退出代码：$exitCode"
    if ($exitCode -ne 0) {
        if ($ServerCrashRestart -gt 0) {
            $ServerCrashRestart--
            Start-Countdown -Message "[!] 服务器已崩溃，即将自动重启...（剩余次数 $ServerCrashRestart）" -Seconds 10
            Start-Server -Restart $Restart
        }
        else {
            Write-Host "[!] 服务器已达到最大崩溃重启次数，不再执行重启..." -ForegroundColor Yellow
        }
    }
    elseif ($Restart) {
        Start-Countdown -Message "[!] 服务器已关闭，即将自动重启..." -Seconds 10
        Start-Server -Restart $Restart
    }
}

Main
