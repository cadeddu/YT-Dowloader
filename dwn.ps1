

$Config = Get-Content /home/pi/yt-downloader/schedule.json | ConvertFrom-Json
$Config.Config | Foreach-Object -Parallel  {

    $DownloadFolder = $_.download_folder
    $ReferenceDate = (Get-Date).AddDays( - $_.days)

    if (Test-Path $DownloadFolder) {
        Get-ChildItem -Path $DownloadFolder -File | Where-Object { $_.LastWriteTime -lt $ReferenceDate } | Remove-Item -Force
    }


    Write-Output "Downloading $($_.Name)"
    

    $cmd = "/usr/local/bin/yt-dlp --http-chunk-size 10M --extractor-args `"youtube:player_client=ios,web`" --break-on-existing --download-archive `"/home/pi/yt-downloader/archives/$($_.Name).txt`""
    

    if($_.max_download -ne $null){
        $cmd += " --max-downloads $($_.max_download)"
    }

    if($_.is_reversed){
         $cmd += " --playlist-reverse"
    }

    if($_.days -ne $null){    
        $cmd += " --match-filters `"upload_date >= $((Get-Date).AddDays(- $_.days).ToString('yyyyMMdd'))`""
     }

    $cmd += " -f `"bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best`" --output `"$DownloadFolder%(upload_date)s_%(title)s.%(ext)s`" `"$($_.playlist_url)`""

    Write-Host "$cmd" 
    Invoke-Expression $cmd


   

} -ThrottleLimit 5

