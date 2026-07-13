
# Download all screens from Ultimate Service Marketplace
$screens = @{
    "01_splash_screen" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzY5NDg5MzNkYjYyOTRiNzJiYmM4YmFhMjQ0MDBhZTcwEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "02_login_screen" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzdhZjdhOGNlYWFiZjQwZWZhZmNhZjMwOTYzMmI4NjdjEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "03_user_home_screen" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzhkNDk2Y2QyZGVhNjQ1OGE4MDdkMzAyODJkYjVmMDFlEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "04_provider_profile" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2NlNjJkODVmNTQxYTQ0M2ZhN2QwMDU2MTFkYzEwNWU2EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "05_chat_quote" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2E1ZGVmNDkwOTZiMjRkZDViOGM4NmI3YmYzZTI0MDYyEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "06_live_chat" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzc3MTRhMTM3Y2E4MTQ4NTc4YWQwZWI2NTE4OGJlNmE1EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "07_messages_list" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2Q0OGFkMzgwM2FjNjRlNWE4ZDBiYjIzNDY2MmM4NzhiEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "08_my_orders" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzg1NGNiNGYxMjI0ZTQ1ZWZhMzdjMmQyMWVkZDk4NWFlEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "09_order_details" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2M2YzczZTYzZDg4OTQxNWRhNjhjYjEzYWRkMGQzNDUxEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "10_order_edit_review" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzg5MTFmODQ0YzNjZTQ0OGJiMzAwNDA3YzUwZmZiMGM1EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "11_service_rating" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzdiN2M0MGI3OGU2MjQzMzA5MmZjMjRkNTMzZGE0Yjg3EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "12_wallet" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzJhNzdlZGM5MGI3ZTRlYjJiY2I2ZDRhMWM5ODRhOWRjEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "13_withdrawal_request" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzY4ZWNjMDdiMTJlZjQ1MDdhMTkxNzM4Y2ZlZDVmNDRjEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "14_account_settings" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2M0MTViMTBiYjRkYjQ0OWJiNjhiNTgyODJiYjc3MmEwEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "15_provider_dashboard" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzc5MjY4MzYyMzMxNjQ3ZTc5ZDlkYjU1NjcyNzBlMTYwEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "16_super_admin_dashboard" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzdiNDRhZTgzMTJiNzQ2MjE4YzAzMGIzZTg5ZmJjNTBjEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "17_services_management" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2VlZDdkZjIwYWU3MjRkZGJhNTZmZDA1NTFhYTU1YTczEgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "18_disputes_management" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2YxYmM1OTUwNDk1NDRhMzc4ZjNlOTJjNDg3OGQxNTI0EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
    "19_promotions_management" = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzk5MTM4Y2RkN2E4MjQxN2E4MzQwMWU4NzYwZGI1MDM3EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"
}

$prdUrl = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzkxM2U3OTNhMzZjZTRlOTViNzAyNzNlOGYwMmJmMDQ1EgsSBxC_oJP6pRIYAZIBJAoKcHJvamVjdF9pZBIWQhQxMTcxMTA4MjczMjc4MzQwNTgwNw&filename=&opi=89354086"

$outputDir = "c:\Users\MARAI\Desktop\mashro3\stitch-screens"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "Downloading 19 screens + PRD..." -ForegroundColor Cyan

foreach ($screen in $screens.GetEnumerator()) {
    $filename = "$outputDir\$($screen.Key).html"
    Write-Host "  Downloading $($screen.Key)..." -NoNewline
    try {
        Invoke-WebRequest -Uri $screen.Value -OutFile $filename -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $_" -ForegroundColor Red
    }
}

# Download PRD (markdown)
Write-Host "  Downloading PRD..." -NoNewline
try {
    Invoke-WebRequest -Uri $prdUrl -OutFile "$outputDir\00_shamel_app_prd.md" -UseBasicParsing
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " FAILED: $_" -ForegroundColor Red
}

Write-Host "`nAll done! Files saved to: $outputDir" -ForegroundColor Green
