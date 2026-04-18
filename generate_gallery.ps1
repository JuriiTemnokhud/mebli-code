$imageDir = "c:\Users\temny\OneDrive\Рабочий стол\Сайт\images\My Work\Кухні"
$thumbDir = "$imageDir\thumbs"
$files = Get-ChildItem -Path $imageDir -File | Sort-Object Name

$html = ""

foreach ($file in $files) {
    $filename = $file.Name
    $ext = $file.Extension.ToLower()
    $basename = $file.BaseName

    if ($ext -eq ".jpg" -or $ext -eq ".webp" -or $ext -eq ".png") {
        # Check for thumbnail
        $thumbPath = "$thumbDir\$basename.webp"
        $thumbSrc = ""
        
        if (Test-Path $thumbPath) {
            $thumbSrc = "images/My%20Work/Кухні/thumbs/$basename.webp"
        } else {
            # Fallback to full image if no thumb (though we saw thumbs for most)
            # URL encode spaces
            $encodedName = $filename.Replace(" ", "%20")
            $thumbSrc = "images/My%20Work/Кухні/$encodedName"
        }

        $fullSrc = "images/My%20Work/Кухні/" + $filename.Replace(" ", "%20")
        
        $html += "                <div class=""thumb""><img src=""$thumbSrc"" data-full=""$fullSrc"" alt=""$basename""></div>`n"
    }
    elseif ($ext -eq ".mp4") {
        $videoSrc = "images/My%20Work/Кухні/" + $filename.Replace(" ", "%20")
        $html += "                <div class=""thumb""><video src=""$videoSrc"" muted></video></div>`n"
    }
}

$html
