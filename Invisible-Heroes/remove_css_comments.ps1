# PowerShell script to remove CSS comments from files
$cssFiles = @(
    "src\components\homepage\FeaturesSection.css",
    "src\components\homepage\FindingHomeSection.css",
    "src\components\homepage\StudentStoriesSection.css",
    "src\components\homepage\RegisterNowSection.css",
    "src\components\homepage\ContactSection.css",
    "src\components\homepage\HeroSection.css",
    "src\components\homepage\AboutSection.css",
    "src\components\about\AboutStorySection.css",
    "src\components\about\AboutHeroSection.css",
    "src\components\about\LonelinessTypesSection.css",
    "src\components\about\MeetTheTeamSection.css",
    "src\components\layout\Navigation.css",
    "src\components\layout\Footer.css",
    "src\components\layout\FooterSimple.css",
    "src\components\ui\Button.css",
    "src\components\ui\LoadingScreen.css",
    "src\components\ui\ScrollToTop.css"
)

foreach ($file in $cssFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "Processing: $file"
        
        # Read the file content
        $content = Get-Content $fullPath -Raw
        
        # Remove CSS comments (/* ... */) using regex
        # This handles both single-line and multi-line comments
        $contentWithoutComments = $content -replace '/\*[\s\S]*?\*/', ''
        
        # Remove empty lines that might be left after comment removal
        $contentWithoutComments = $contentWithoutComments -replace '\r?\n\s*\r?\n', "`n"
        
        # Write back to file
        Set-Content $fullPath $contentWithoutComments -NoNewline
        
        Write-Host "Completed: $file"
    } else {
        Write-Host "File not found: $file"
    }
}

Write-Host "CSS comment removal completed!"
