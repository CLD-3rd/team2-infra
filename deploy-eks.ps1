# EKS 클러스터 배포 스크립트
param(
    [string]$ClusterName = "savemypodo-cluster",
    [string]$Region = "ap-northeast-2",
    [string]$AccountId,
    [string]$Domain = "savemypodo.shop",
    [string]$NodegroupName = "savemypodo-cluster-bootstrap",
    [string]$ServiceName = "savemypodo",
    [string]$LBType = "internal" # "internal" 또는 "internet-facing"
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

# 3. Cert-Manager 설치
Write-Host "`n3. Cert-Manager 설치 중..." -ForegroundColor Cyan
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
Start-Sleep -Seconds 30
kubectl apply -f cert-manager.yaml

# 4. AWS Load Balancer Controller 설치
Write-Host "`n4. AWS Load Balancer Controller 설치 중..." -ForegroundColor Cyan
kubectl apply -f aws-load-balancer-controller.yaml 

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system `
    --set clusterName=$ClusterName `
    --set serviceAccount.create=false `
    --set serviceAccount.name=aws-load-balancer-controller `
    --set region=$Region `
    --set vpcId=$(aws eks describe-cluster --name $ClusterName --query "cluster.resourcesVpcConfig.vpcId" --output text)


# 5. External DNS 설치
Write-Host "`n5. External DNS 설치 중..." -ForegroundColor Cyan
kubectl apply -f external-dns.yaml

Write-Host "External DNS 준비 대기 중..." -ForegroundColor Yellow
kubectl wait deployment external-dns `
    --namespace=external-dns `
    --for=condition=Available `
    --timeout=120s

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

# 6. Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'


# 7. Kube-ops-view 설치
Write-Host "`n7. Kube-ops-view 설치 중..." -ForegroundColor Cyan
helm repo add geek-cookbook https://geek-cookbook.github.io/charts/ --force-update
helm repo update
helm upgrade --install kube-ops-view geek-cookbook/kube-ops-view `
--version 1.2.2 `
--set service.main.type=LoadBalancer `
--set service.main.ports.http.port=8080 `
--set service.main.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=$LBType `
--namespace kube-system `
--wait
kubectl annotate service kube-ops-view -n kube-system "external-dns.alpha.kubernetes.io/hostname=kubeopsview.$Domain"
Write-Host "Kube Ops View URL = http://kubeopsview.$MyDomain:8080"

# 8. Fluent Bit 설치 (CloudWatch 로깅)
Write-Host "`n8. Fluent Bit 설치 중..." -ForegroundColor Cyan

# 네임스페이스 생성
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

# 변수 설정
$CLUSTER_NAME = $ClusterName
$FluentBitHttpServer = "On"
$FluentBitHttpPort = "2020"
$FluentBitReadFromHead = "Off"
$FluentBitReadFromTail = "On"
$AWS_DEFAULT_REGION = "ap-northeast-2"

# ConfigMap 생성 (cluster info)
kubectl create configmap fluent-bit-cluster-info `
--from-literal=cluster.name=$CLUSTER_NAME `
--from-literal=http.server=$FluentBitHttpServer `
--from-literal=http.port=$FluentBitHttpPort `
--from-literal=read.head=$FluentBitReadFromHead `
--from-literal=read.tail=$FluentBitReadFromTail `
--from-literal=logs.region=$AWS_DEFAULT_REGION `
-n amazon-cloudwatch

# Fluent Bit 구성 적용 (DaemonSet + ConfigMap 포함)
kubectl apply -f fluent-bit.yaml


# # 9. X-Ray 데몬 설치 (현재 필요하지 않음)
# Write-Host "`n9. X-Ray 데몬 설치 중..." -ForegroundColor Cyan
# kubectl apply -f xray-daemon.yaml

# # 10. Karpenter 설치
# Write-Host "`n10. Karpenter 설치 중..." -ForegroundColor Cyan
# $KarpenterVersion = "1.5.2"
# kubectl create namespace karpenter

# helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version $KarpenterVersion `
#     --namespace karpenter --create-namespace `
#     --set settings.clusterName=$ClusterName `
#     --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:aws:iam::${AccountId}:role/${ClusterName}-karpenter" `
#     --set settings.interruptionQueue=$ClusterName `
#     --set controller.resources.requests.cpu=1 `
#     --set controller.resources.requests.memory=1Gi `
#     --set controller.resources.limits.cpu=1 `
#     --set controller.resources.limits.memory=1Gi > karpenter-patched.yaml

# # dnsPolicy 수정
# # $filePath = "karpenter-patched.yaml"
# # $content = Get-Content -Path $filePath
# # $content = $content -replace 'dnsPolicy: ClusterFirst', 'dnsPolicy: Default'
# # Set-Content -Path $filePath -Value $content
# # Select-String -Path $filePath -Pattern 'dnsPolicy'

# # karpenter CRD 등록
# kubectl create -f "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v$KarpenterVersion/pkg/apis/crds/karpenter.sh_nodepools.yaml"
# kubectl create -f "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v$KarpenterVersion/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
# kubectl create -f "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v$KarpenterVersion/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"

# Write-Host "`nCRD가 준비될 때까지 대기 중..." -ForegroundColor Yellow
# kubectl wait --for=condition=Established crd/ec2nodeclasses.karpenter.k8s.aws --timeout=60s
# kubectl wait --for=condition=Established crd/nodeclaims.karpenter.sh --timeout=60s
# kubectl wait --for=condition=Established crd/nodepools.karpenter.sh --timeout=60s

# kubectl apply -f karpenter-patched.yaml

# # Karpenter Pod가 Ready 상태가 될 때까지 대기
# Write-Host "`nKarpenter 컨트롤러 Pod가 준비될 때까지 대기 중..." -ForegroundColor Yellow
# kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=karpenter --namespace karpenter --timeout=180s

# kubectl apply -f karpenter.yaml


# prometheus, grafana 설치
# kubectl get storageclass으로 EKS에서 제공하는 스토리지 클래스 확인 (gp2로 확인됨)
Write-Host "`n=== Prometheus 및 Grafana 설치 ===" -ForegroundColor Cyan
$GrafanaPw=$(aws ssm get-parameter --name "/$ServiceName/grafana/admin_password" --with-decryption --query Parameter.Value --output text)

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack `
    -n monitoring `
    -f prometheus-stack-values.yaml `
    --set grafana.adminPassword="$GrafanaPw"

# 에러 발생 시 아래 명령어로 기존 리소스 삭제 후 재설치
# kubectl delete statefulset prometheus-prometheus-stack-kube-prom-prometheus -n monitoring
# kubectl delete pvc prometheus-prometheus-stack-kube-prom-prometheus-db-prometheus-prometheus-stack-kube-prom-prometheus-0 -n monitoring
# helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack `
#     -n monitoring `
#     -f prometheus-stack-values.yaml `
#     --set grafana.adminPassword="$GrafanaPw"


# influxdb 설치
# Write-Host "`n=== InfluxDB 설치 ===" -ForegroundColor Cyan
# helm repo add influxdata https://helm.influxdata.com/
# helm repo update
# helm upgrade --install influxdb influxdata/influxdb `
#     -n monitoring `
#     --set service.type=LoadBalancer `
#     --set service.port=8086 `
#     --set service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"="influx.$DomainName" `
#     --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=$LBType


# # DB 생성 (influx CLI 사용)
# # monitoring 네임스페이스에서 influxdb Pod 이름 자동 조회
# $podName = kubectl get pods -n monitoring -l app.kubernetes.io/name=influxdb -o jsonpath='{.items[0].metadata.name}'
# Write-Host "InfluxDB Pod 이름: $podName"

# # Pod가 Ready 상태가 될 때까지 최대 180초(3분) 기다리기
# kubectl wait pod/$podName -n monitoring --for=condition=Ready --timeout=180s

# # Pod 내부에서 influxdb CLI로 k6 데이터베이스 생성
# if ($LASTEXITCODE -eq 0) {
#     Write-Host "InfluxDB Pod가 Ready 상태입니다. DB 생성 명령 실행합니다."
#     kubectl exec -n monitoring $podName -- influx -execute "CREATE DATABASE k6"
#     Write-Host "k6 데이터베이스가 생성되었습니다."
# } else {
#     Write-Host "InfluxDB Pod가 지정 시간 내에 Ready 상태가 되지 않았습니다." -ForegroundColor Red
# }

# # Sealed Secrets Controller 설치
# Write-Host "`n=== Sealed Secrets Controller 설치 ===" -ForegroundColor Cyan
# kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/controller.yaml


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
    Write-Host "URL: http://$kubeOpsLB:8080" -ForegroundColor White
}

Write-Host "`n=== EKS 클러스터 배포 완료 ===" -ForegroundColor Green
Write-Host "다음 명령어로 클러스터 상태를 확인하세요:" -ForegroundColor Yellow
Write-Host "kubectl get nodes" -ForegroundColor White
Write-Host "kubectl get pods --all-namespaces" -ForegroundColor White
Write-Host "kubectl logs -n amazon-cloudwatch -l k8s-app=fluent-bit" -ForegroundColor White
Write-Host "kubectl logs -n external-dns -l app=external-dns" -ForegroundColor White
Write-Host "kubectl get pods,svc -n monitoring" -ForegroundColor White