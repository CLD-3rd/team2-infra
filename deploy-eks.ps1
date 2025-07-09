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
    "argocd.yaml",
    "aws-load-balancer-controller.yaml",
    "cert-manager.yaml",
    "cloudwatch-observability.yaml",
    "external-dns.yaml",
    "fluent-bit.yaml",
    "xray-daemon.yaml",
    "karpenter.yaml"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        (Get-Content $file) -replace 'ACCOUNT_ID', $AccountId -replace 'CLUSTER_NAME', $ClusterName | Set-Content $file
        Write-Host "업데이트됨: $file" -ForegroundColor Green
    }
}

# 3. AWS Load Balancer Controller 설치
Write-Host "`n3. AWS Load Balancer Controller 설치 중..." -ForegroundColor Cyan
kubectl apply -f https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.2/v2_7_2_full.yaml
kubectl apply -f aws-load-balancer-controller.yaml

# 4. Cert-Manager 설치
Write-Host "`n4. Cert-Manager 설치 중..." -ForegroundColor Cyan
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
Start-Sleep -Seconds 30
kubectl apply -f cert-manager.yaml

# 5. External DNS 설치
Write-Host "`n5. External DNS 설치 중..." -ForegroundColor Cyan
kubectl apply -f external-dns.yaml

# 6. ArgoCD 설치
Write-Host "`n6. ArgoCD 설치 중..." -ForegroundColor Cyan
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 서버 준비 대기
Write-Host "ArgoCD 서버 준비 대기 중..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# ArgoCD LoadBalancer 서비스 생성
kubectl apply -f argocd.yaml

Write-Host "`nArgoCD 초기 admin 비밀번호:" -ForegroundColor Cyan
$argoPassword = kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
Write-Host $argoPassword -ForegroundColor White

# 7. Kube-ops-view 설치
Write-Host "`n7. Kube-ops-view 설치 중..." -ForegroundColor Cyan
helm repo add geek-cookbook https://geek-cookbook.github.io/charts/ --force-update
helm repo update
helm upgrade --install kube-ops-view geek-cookbook/kube-ops-view `
    --version 1.2.2 `
    --set env.TZ="Asia/Seoul" `
    --set service.type=LoadBalancer `
    --namespace kube-system `
    --wait


# 8. Fluent Bit 설치 (CloudWatch 로깅)
Write-Host "`n8. Fluent Bit 설치 중..." -ForegroundColor Cyan
kubectl apply -f fluent-bit.yaml

# 9. X-Ray 데몬 설치
Write-Host "`n9. X-Ray 데몬 설치 중..." -ForegroundColor Cyan
kubectl apply -f xray-daemon.yaml

# 10. Karpenter 설치
Write-Host "`n10. Karpenter 설치 중..." -ForegroundColor Cyan
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version v0.32.1 `
    --namespace karpenter --create-namespace `
    --set settings.aws.clusterName=$ClusterName `
    --set settings.aws.defaultInstanceProfile="$ClusterName-KarpenterNodeInstanceProfile" `
    --set settings.aws.interruptionQueueName="$ClusterName" `
    --wait

kubectl apply -f karpenter.yaml

# 11. 서비스 URL 확인
Write-Host "`n=== 서비스 접속 정보 ===" -ForegroundColor Green

Write-Host "`nArgoCD 접속 정보:" -ForegroundColor Yellow
$argoCDLB = kubectl get svc argocd-server-lb -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
if ($argoCDLB) {
    Write-Host "URL: http://$argoCDLB" -ForegroundColor White
    Write-Host "사용자: admin" -ForegroundColor White
    Write-Host "비밀번호: $argoPassword" -ForegroundColor White
}

Write-Host "`nKube-ops-view 접속 정보:" -ForegroundColor Yellow
$kubeOpsLB = kubectl get svc kube-ops-view -n kube-system -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
if ($kubeOpsLB) {
    Write-Host "URL: http://$kubeOpsLB" -ForegroundColor White
}

Write-Host "`n=== EKS 클러스터 배포 완료 ===" -ForegroundColor Green
Write-Host "다음 명령어로 클러스터 상태를 확인하세요:" -ForegroundColor Yellow
Write-Host "kubectl get nodes" -ForegroundColor White
Write-Host "kubectl get pods --all-namespaces" -ForegroundColor White
Write-Host "kubectl logs -n amazon-cloudwatch -l k8s-app=fluent-bit" -ForegroundColor White
Write-Host "kubectl logs -n external-dns -l app=external-dns" -ForegroundColor White