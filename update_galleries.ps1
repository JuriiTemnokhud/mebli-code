$ScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$baseDir = $ScriptRoot
$indexFile = "$baseDir\index.html"
$imagesBase = "images/My%20Work"
$mappingFile = "$baseDir\gallery_mapping.json"

# Read Mappings from JSON (files are ASCII, content is proper Unicode)
if (-not (Test-Path $mappingFile)) {
    Write-Host "Error: gallery_mapping.json not found." -ForegroundColor Red
    exit
}
try {
    $mappings = Get-Content $mappingFile -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "Error parsing JSON mapping." -ForegroundColor Red
    exit
}

# Read index.html content
if (-not (Test-Path $indexFile)) {
    Write-Host "Error: index.html not found at $indexFile" -ForegroundColor Red
    exit
}

# Restore backup if it exists to ensure clean state after previous failed run?
# Optional, but safer to avoid accumulating garbage if we broke it.
if (Test-Path "$indexFile.bak") {
    Copy-Item "$indexFile.bak" $indexFile -Force
    Write-Host "Restored index.html from backup to ensure clean update." -ForegroundColor Yellow
}
else {
    Copy-Item $indexFile "$indexFile.bak" -Force
    Write-Host "Backup created: index.html.bak" -ForegroundColor Gray
}

$content = Get-Content $indexFile -Raw -Encoding UTF8

$props = $mappings.PSObject.Properties

foreach ($prop in $props) {
    $folderName = $prop.Name
    $modalId = $prop.Value
    
    # Filesystem path uses real spaces
    $fsFolderName = $folderName
    $fullFolderPath = "$baseDir\images\My Work\$fsFolderName"
    
    if (-not (Test-Path $fullFolderPath)) {
        Write-Host "Warning: Folder not found: $fullFolderPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing gallery: $folderName ($modalId)..." -ForegroundColor Cyan

    # Generate HTML for images
    $files = Get-ChildItem -Path $fullFolderPath -File | Sort-Object Name
    $galleryHtml = ""

    foreach ($file in $files) {
        $ext = $file.Extension.ToLower()
        $filename = $file.Name
        # URL Encode spaces for src
        $urlName = $filename.Replace(" ", "%20")
        # Ensure we don't double encode if foldername implies it? Foldername in JSON is raw unicode
        # used in src: images/My%20Work/FolderName/Filename
        # We should NOT encode the FolderName in the src text if the existing HTML didn't?
        # The existing HTML had: src="images/My%20Work/Кухні/..."
        # So "Кухні" is NOT encoded. "My Work" IS encoded.
        
        $srcPath = "$imagesBase/$folderName/$urlName"

        if ($ext -in @(".jpg", ".jpeg", ".png", ".webp")) {
            $galleryHtml += "                                                <div class=""thumb""><img src=""$srcPath"" alt=""$folderName""></div>`n"
        }
        elseif ($ext -eq ".mp4") {
            $galleryHtml += "                                                <div class=""thumb""><video src=""$srcPath"" muted></video></div>`n"
        }
    }

    $galleryHtml = $galleryHtml.TrimEnd()

    # Improved Regex:
    # Matches:
    # 1. Header + opening div
    # 2. Content (lazy, until...)
    # 3. ENDING Sequence: </div> followed by whitespace/newline then </div> (Gallery Container Close)
    # This assumes the gallery-grid is the LAST element in the container or at least followed by a closing div.
    # Looking at index.html:
    # <div class="gallery-container"> ... <div class="gallery-grid">...</div> </div>
    # Yes, grid is usually last.
    
    $pattern = '(?s)(id="' + [regex]::Escape($modalId) + '".*?<div class="gallery-grid.*?>)(.*?)(</div>\s*</div>)'
    
    if ($content -match $pattern) {
        # Note: $matches[3] contains "</div></div>". We need to reconstruct it correctly.
        # But we want to insert our content BEFORE the closing div of the grid.
        # Wait, $matches[3] is `</div></div>`.
        # The content we replace is `$matches[2]`.
        # So we replace with: Group1 + NewContent + Group3.
        # Group3 starts with `</div>` which closes the grid!
        # So we just sandwich the new content.
        
        $content = $content -replace $pattern, ('${1}' + "`n$galleryHtml`n                                        " + '${3}')
        Write-Host "  -> Updated HTML successfully." -ForegroundColor Green
    }
    else {
        Write-Host "  -> Could not find HTML structure for $modalId" -ForegroundColor Red
        # Debug:
        # Write-Host "Pattern failed: $pattern"
    }
}

$content | Set-Content $indexFile -Encoding UTF8
Write-Host "Done! index.html updated." -ForegroundColor Green
