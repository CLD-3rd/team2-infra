# SaveMyPodo EKS 클러스터 배포 가이드

## 개요
이 프로젝트는 SaveMyPodo 애플리케이션을 위한 완전한 EKS 클러스터 인프라를 제공합니다.

## 아키텍처 특징

### 네트워크 구성
- **VPC**: 192.168.0.0/16
- **Public Subnets**: 3개 AZ에 걸쳐 배치 (ALB용)
- **Private Subnets**: 3개 AZ에 걸쳐 배치 (워커 노드용)
- **NAT Gateway**: 프라이빗 서브넷의 인터넷 접근 제공

### EKS 클러스터 설정
- **Kubernetes 버전**: 1.31
- **엔드포인트 접근**: Public + Private 모두 활성화
- **IRSA**: 활성화 (IAM Roles for Service Accounts)
- **로깅**: API, Audit, Authenticator, ControllerManager, Scheduler

### 설치된 애드온
- **vpc-cni**: VPC 네트워킹
- **kube-proxy**: 네트워크 프록시
- **coredns**: DNS 서비스
- **aws-ebs-csi-driver**: EBS 볼륨 지원
- **aws-efs-csi-driver**: EFS 볼륨 지원

### 보안 설정
- **보안 그룹**: EKS 전용 보안 그룹으로 RDS/ElastiCache 접근 제한
- **IRSA 역할**: AWS Load Balancer Controller, EBS CSI, EFS CSI, Karpenter

### 모니터링 및 관찰성
- **CloudWatch**: 클러스터 로그 및 메트릭
- **X-Ray**: 분산 추적
- **Cert-Manager**: TLS 인증서 자동 관리

### 자동 스케일링
- **Karpenter**: 노드 자동 프로비저닝 및 스케일링

## 사전 요구사항

### 필수 도구
```powershell
# AWS CLI
aws --version

# Terraform
terraform --version

# kubectl
kubectl version --client

# Helm
helm version
```

### AWS 권한
다음 AWS 서비스에 대한 권한이 필요합니다:
- EKS
- EC2 (VPC, Subnets, Security Groups, NAT Gateway)
- IAM (Roles, Policies)
- CloudWatch
- EBS/EFS

## 배포 단계

### 1. 환경 설정
```powershell
# 저장소 클론
git clone <repository-url>
cd team2-infra

# Terraform 변수 설정
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# terraform.tfvars 파일을 편집하여 실제 값 입력
```

### 2. 자동 배포 (권장)
```powershell
# PowerShell 스크립트 실행
./deploy-eks.ps1 -ClusterName "savemypodo-cluster" -Region "ap-northeast-2"
```

### 3. 수동 배포
```powershell
# Terraform 배포
cd terraform
terraform init
terraform plan
terraform apply

# kubectl 설정
aws eks update-kubeconfig --region ap-northeast-2 --name savemypodo-cluster

# Kubernetes 구성 요소 설치
cd ../k8s-manifests
kubectl apply -f aws-load-balancer-controller.yaml
kubectl apply -f cert-manager.yaml
kubectl apply -f cloudwatch-observability.yaml
kubectl apply -f xray-daemon.yaml
kubectl apply -f karpenter.yaml
```

## 배포 후 확인

### 클러스터 상태 확인
```bash
# 노드 확인
kubectl get nodes

# 모든 네임스페이스의 파드 확인
kubectl get pods --all-namespaces

# EKS 애드온 확인
aws eks describe-cluster --name savemypodo-cluster --query cluster.status
```

### 주요 구성 요소 확인
```bash
# AWS Load Balancer Controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# Cert-Manager
kubectl get pods -n cert-manager

# CloudWatch Agent
kubectl get daemonset -n amazon-cloudwatch

# X-Ray Daemon
kubectl get daemonset -n aws-xray

# Karpenter
kubectl get deployment -n karpenter
```

## 애플리케이션 배포 예제

### Ingress를 사용한 웹 애플리케이션
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: savemypodo-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - api.savemypodo.shop
    secretName: savemypodo-tls
  rules:
  - host: api.savemypodo.shop
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: savemypodo-service
            port:
              number: 80
```

## 비용 최적화

### Karpenter 설정
- **Spot 인스턴스**: 비용 절약을 위해 Spot 인스턴스 우선 사용
- **자동 스케일링**: 워크로드에 따른 자동 노드 추가/제거
- **인스턴스 타입**: t3.medium ~ t3.xlarge 범위에서 최적 선택

### 리소스 모니터링
```bash
# 리소스 사용량 확인
kubectl top nodes
kubectl top pods --all-namespaces
```

## 보안 고려사항

### 네트워크 보안
- 워커 노드는 프라이빗 서브넷에 배치
- RDS/ElastiCache는 EKS 노드 보안 그룹에서만 접근 가능
- NAT Gateway를 통한 제한된 인터넷 접근

### IAM 보안
- IRSA를 통한 최소 권한 원칙 적용
- 각 서비스별 전용 IAM 역할 사용

## 문제 해결

### 일반적인 문제
1. **노드가 Ready 상태가 되지 않는 경우**
   - VPC CNI 애드온 상태 확인
   - 보안 그룹 규칙 확인

2. **Load Balancer가 생성되지 않는 경우**
   - AWS Load Balancer Controller 파드 로그 확인
   - 서브넷 태그 확인 (kubernetes.io/role/elb)

3. **인증서가 발급되지 않는 경우**
   - Cert-Manager 파드 로그 확인
   - DNS 설정 확인

### 로그 확인
```bash
# AWS Load Balancer Controller 로그
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Cert-Manager 로그
kubectl logs -n cert-manager deployment/cert-manager

# Karpenter 로그
kubectl logs -n karpenter deployment/karpenter
```

## 정리

### 리소스 삭제
```powershell
# Kubernetes 리소스 먼저 삭제
kubectl delete -f k8s-manifests/

# Terraform 리소스 삭제
cd terraform
terraform destroy
```

## 지원 및 문의
- 이슈 발생 시 GitHub Issues 활용
- 추가 기능 요청은 Pull Request 제출