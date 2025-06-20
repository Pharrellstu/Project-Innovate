# PowerShell script to add proper spacing between CSS selectors
$cssFiles = Get-ChildItem -Path "src" -Recurse -Filter "*.css"

foreach ($file in $cssFiles) {
    Write-Host "Processing: $($file.FullName)"
    
    # Read the file content
    $content = Get-Content $file.FullName -Raw
    
    # Add spacing after closing braces (but not at end of file)
    # This regex looks for } followed by a newline and then immediately another selector (not whitespace)
    $content = $content -replace '}(\r?\n)([^\s\r\n}])', '}$1$1$2'
    
    # Add spacing after import statements
    $content = $content -replace '(@import[^;]+;)(\r?\n)([^\s\r\n@])', '$1$2$2$3'
    
    # Ensure there's spacing before media queries
    $content = $content -replace '}(\r?\n)(@media)', '}$1$1$2'
    
    # Write back to file
    Set-Content $file.FullName $content -NoNewline
    
    Write-Host "Completed: $($file.Name)"
}

Write-Host "CSS spacing formatting completed!"
