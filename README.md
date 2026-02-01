# Mini Curso DevOps e AWS - Dia 04

Infraestrutura EKS com Karpenter auto-scaling usando Terraform.

## Pré-requisitos

- AWS CLI configurado
- Terraform >= 1.0
- kubectl instalado

## Como Executar

### 1️⃣ Criar Cluster EKS (sem Karpenter)

```bash
cd terraform/main-stack
terraform init
terraform plan
terraform apply
```

**O que é criado:**
- VPC (4 subnets em 2 AZs)
- EKS Cluster v1.31 com 2 nós t3.medium
- OIDC provider
- ECR repositories

**Tempo:** ~20 minutos

### 2️⃣ Instalar Karpenter (depois que o cluster estiver pronto)

```bash
terraform apply -var="enable_karpenter=true"
```

**O que é criado:**
- CRDs (NodeClaim, EC2NodeClass, NodePool)
- Karpenter controller (Helm)
- IAM Role para Karpenter
- NodePool configurado em us-east-1a/b

**Tempo:** ~5 minutos

## Validação

```bash
# Verificar Karpenter rodando
kubectl get pods -n kube-system | grep karpenter

# Verificar NodePool
kubectl get nodepool

# Testar auto-scaling
kubectl create deployment nginx --image=nginx --replicas=10
kubectl get nodes -w
```

## Destruir

```bash
# Desabilitar Karpenter primeiro
terraform apply -var="enable_karpenter=false" -auto-approve

# Depois destruir tudo
terraform destroy
```

### ⚠️ Problema com Finalizers

Se o `terraform destroy` travar com erro de timeout no EC2NodeClass, execute:

```bash
# 1. Deletar workloads que usam nodes do Karpenter
kubectl delete deployment nginx -n default  # Se houver

# 2. Deletar NodePools (remove nodes provisionados)
kubectl delete nodepool --all

# 3. Aguardar NodeClaims serem removidos
kubectl get nodeclaim -w  # Ctrl+C quando vazio

# 4. Remover finalizer manualmente
kubectl patch ec2nodeclass default -p '{"metadata":{"finalizers":null}}' --type=merge

# 5. Tentar novamente
terraform destroy -var="enable_karpenter=true"
```

**Ordem correta:** Workloads → NodePools → NodeClaims → Terraform destroy

## Notas

- `enable_karpenter=true`: Habilita CRDs, Controller e NodePool
- `enable_karpenter=false`: Desabilita (padrão)
- NodePool padrão: on-demand, zonas us-east-1a/b, instance types t/m
- Edit `manifests/karpenter.node-pool.yml` para customizar
