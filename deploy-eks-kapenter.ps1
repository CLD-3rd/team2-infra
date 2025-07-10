# EKS 클러스터 배포 스크립트
param(
    [string]$ClusterName = "savemypodo-cluster",
    [string]$Region = "ap-northeast-2",
    [string]$AccountId
)

# 계정 ID 가져오기
if (-not $AccountId) {
    $AccountId = (aws sts get-caller-identity --query Account --output text)
}

Write-Host "=== EKS 클러스터 배포 시작 ===" -ForegroundColor Green
Write-Host "클러스터 이름: $ClusterName" -ForegroundColor Yellow
Write-Host "리전: $Region" -ForegroundColor Yellow
Write-Host "계정 ID: $AccountId" -ForegroundColor Yellow

# 1. kubectl 설정
Write-Host "`n1. kubectl 설정 중..." -ForegroundColor Cyan
aws eks update-kubeconfig --region $Region --name $ClusterName

# 2. 초기화 매니페스트 파일 업데이트 및 설치
Write-Host "`n2. 초기화 매니페스트 파일 업데이트 중..." -ForegroundColor Cyan
Set-Location manifests\init

# 계정 ID와 클러스터 이름으로 매니페스트 파일 업데이트
$files = @(
    "karpenter.yaml"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        (Get-Content $file) -replace 'ACCOUNT_ID', $AccountId -replace 'CLUSTER_NAME', $ClusterName | Set-Content $file
        Write-Host "업데이트됨: $file" -ForegroundColor Green
    }
}

#  Karpenter 설치
Write-Host "` Karpenter 설치 중..." -ForegroundColor Cyan
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version v0.32.1 `
    --namespace karpenter --create-namespace `
    --set settings.aws.clusterName=$ClusterName `
    --set settings.aws.defaultInstanceProfile="$ClusterName-KarpenterNodeInstanceProfile" `
    --set settings.aws.interruptionQueueName="$ClusterName" `
    --wait

kubectl apply -f karpenter.yaml