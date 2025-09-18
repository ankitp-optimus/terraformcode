# Quick Pipeline Fix Script
# Run this PowerShell script to update your service connection name

param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceConnectionName
)

Write-Host "🔧 Updating Azure DevOps Pipeline Configuration..." -ForegroundColor Cyan
Write-Host ""

$pipelineFile = "azure-pipelines.yml"
$currentDir = Get-Location

if (-not (Test-Path $pipelineFile)) {
    Write-Host "❌ Error: azure-pipelines.yml not found in current directory" -ForegroundColor Red
    Write-Host "   Make sure you're running this script from the project root" -ForegroundColor Yellow
    exit 1
}

# Read the current pipeline file
$content = Get-Content $pipelineFile -Raw

# Replace the service connection name
$oldPattern = "azureServiceConnection: 'YOUR_AZURE_SERVICE_CONNECTION_NAME'"
$newValue = "azureServiceConnection: '$ServiceConnectionName'"

if ($content -match "YOUR_AZURE_SERVICE_CONNECTION_NAME") {
    $content = $content -replace "YOUR_AZURE_SERVICE_CONNECTION_NAME", $ServiceConnectionName
    Set-Content $pipelineFile -Value $content
    
    Write-Host "✅ Successfully updated service connection name to: $ServiceConnectionName" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Commit and push your changes" -ForegroundColor White
    Write-Host "   2. Go to Azure DevOps and run your pipeline" -ForegroundColor White
    Write-Host "   3. Verify the service connection exists and has proper permissions" -ForegroundColor White
    Write-Host ""
    Write-Host "🔗 Service connection should be created at:" -ForegroundColor Cyan
    Write-Host "   Azure DevOps → Project Settings → Service connections" -ForegroundColor White
} else {
    Write-Host "⚠️  Service connection may already be configured" -ForegroundColor Yellow
    Write-Host "   Current configuration in $pipelineFile:" -ForegroundColor White
    
    # Show current azureServiceConnection line
    $lines = Get-Content $pipelineFile
    $connectionLine = $lines | Where-Object { $_ -match "azureServiceConnection:" }
    if ($connectionLine) {
        Write-Host "   $connectionLine" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "💡 Need help setting up the service connection?" -ForegroundColor Cyan
Write-Host "   Check SERVICE_CONNECTION_SETUP.md for detailed instructions" -ForegroundColor White