# sbht-terraform

<details open>
<summary><strong>🇰🇷 한국어</strong></summary>

## 📋 프로젝트 개요

**sbht-terraform**은 AWS 인프라를 코드로 관리하는 Infrastructure as Code (IaC) 프로젝트입니다. Terraform을 사용하여 프로덕션 환경에 적합한 완전한 AWS 클라우드 인프라를 자동으로 프로비저닝합니다.

이 프로젝트는 Softbank Hackerthon 2025를 위한 SBHTDog 조직의 핵심 인프라 저장소입니다.

## 🏗️ 아키텍처 개요

### 배포되는 AWS 리소스

#### 🌐 네트워킹

- **VPC**: 다중 가용 영역(Multi-AZ) 구성의 VPC
  - 퍼블릭 서브넷: ALB, NAT Gateway, Bastion Host용
  - 프라이빗 서브넷: ECS Fargate, RDS용
- **NAT Gateway**: 프라이빗 서브넷의 인터넷 아웃바운드 연결
- **Internet Gateway**: 퍼블릭 서브넷의 인터넷 연결
- **VPC Flow Logs**: 네트워크 트래픽 모니터링

#### 🔐 보안

- **Security Groups**:
  - ALB 보안 그룹 (HTTP/HTTPS/8080 허용)
  - ECS 보안 그룹 (ALB로부터의 트래픽만 허용)
  - RDS 보안 그룹 (ECS와 EC2로부터의 PostgreSQL 연결 허용)
  - EC2 보안 그룹 (SSH, HTTP, HTTPS)
- **IAM Roles**:
  - ECS Task Execution Role
  - ECS Task Role (S3, SSM 액세스)
  - CodeDeploy Role
  - GitHub Actions OIDC Role
- **SSM Parameter Store**: 민감한 설정 정보 보안 저장

#### 🐳 컨테이너 인프라

- **ECR (Elastic Container Registry)**: Docker 이미지 저장소
- **ECS (Elastic Container Service)**:
  - Fargate 클러스터
  - 서비스 자동 배포 및 관리
  - 컨테이너 로그는 CloudWatch로 전송

#### ⚖️ 로드 밸런싱

- **Application Load Balancer (ALB)**:
  - HTTPS 리다이렉트 지원
  - Blue/Green 배포를 위한 이중 타겟 그룹
  - 포트 8080의 테스트 리스너 (Blue/Green 배포용)
  - 헬스 체크 구성

#### 🗄️ 데이터베이스

- **RDS PostgreSQL**:
  - 다중 AZ 배포 (고가용성)
  - 자동 백업 (7일 보관)
  - 암호화 활성화
  - Enhanced Monitoring
  - 두 개의 독립적인 데이터베이스:
    - 메인 애플리케이션용 (프라이빗)
    - Bastion 서비스용 (퍼블릭 액세스)

#### 📦 스토리지

- **S3 Bucket**:
  - 버전 관리 활성화
  - 암호화 적용
  - 라이프사이클 정책:
    - 30일 후 Standard-IA로 이동
    - 90일 후 Glacier로 이동
  - CORS 설정 (웹 애플리케이션 통합)

#### 🚀 배포 자동화

- **CodeDeploy**:
  - Blue/Green 배포 전략
  - ECS 서비스 자동 배포
  - 자동 롤백 기능
  - 배포 준비 상태 확인

#### 📊 모니터링

- **CloudWatch**: 로그 및 메트릭 수집

#### 🖥️ 관리 인스턴스

- **EC2 Bastion Host**:
  - 데이터베이스 관리용
  - 프라이빗 리소스 액세스용

## 📂 디렉토리 구조

```
sbht-terraform/
├── main.tf              # 메인 Terraform 설정
├── variables.tf         # 변수 정의
├── outputs.tf          # 출력 값
├── provider.tf         # AWS 프로바이더 설정
└── modules/
    ├── vpc/           # VPC 및 네트워킹
    ├── ecr/           # Container Registry
    ├── iam/           # IAM 역할 및 정책
    ├── sg/            # 보안 그룹
    ├── ssm/           # Parameter Store
    ├── rds/           # PostgreSQL 데이터베이스
    ├── alb/           # Application Load Balancer
    ├── ecs/           # ECS 클러스터 및 서비스
    ├── codedeploy/    # CodeDeploy 배포 그룹
    ├── s3/            # S3 버킷
    ├── sns/           # SNS 토픽
    └── ec2/           # EC2 인스턴스
```

## 🚀 시작하기

### 사전 요구사항

- Terraform Cloud
- AWS 계정 및 적절한 권한

## ⚙️ 주요 설정 변수

| 변수                    | 설명                                                          | 예시                                         |
| ----------------------- | ------------------------------------------------------------- | -------------------------------------------- |
| `alb_certificate_arn`   | ALB에 사용되는 SSL 인증서                                     | `arn:aws:acm:ap-northeast-2:~:certificate/~` |
| `container_port`        | ECS 컨테이너 포트                                             | `3000`                                       |
| `enable_github_oidc`    | GitHub Actions에서 AWS에 접근하기 위한 OIDC 권한 및 역할 생성 | `true`                                       |
| `enable_nat_gateway`    | VPC Nat Gateway 생성 여부                                     | `true`                                       |
| `github_repo`           | AWS에 접근할 GitHub Actions의 Repository                      | `SBHTDog/sbht-deploy-target`                 |
| `project_name`          | AWS 리소스들의 이름의 접두사 및 태그                          | `sbht-aws`                                   |
| `rds_master_password`   | RDS 관리자 패스워드 (PostgreSQL Admin user password)          | `yourdbpassword`                             |
| `rds_master_username`   | RDS 관리자 유저네임 (PostgreSQL Admin username)               | `true`                                       |
| `AWS_ACCESS_KEY_ID`     | AWS API 접속을 위한 액세스키 환경 변수                        | `AKIA~`                                      |
| `AWS_REGION`            | AWS 리소스 리전 (환경 변수)                                   | `ap-northeast-2`                             |
| `AWS_SECRET_ACCESS_KEY` | AWS API 접속을 위한 비밀 액세스키 환경 변수                   | `~`                                          |

## 🔄 Blue/Green 배포

배포 프로세스:

1. 새 버전(Green)이 별도의 타겟 그룹에 배포
2. 헬스 체크 통과 확인
3. 트래픽을 점진적으로 Green으로 전환 (ELB Target Group 변경)
4. 기존 버전(Blue) 종료

## 📊 모니터링 및 로깅

### CloudWatch Logs

- ECS 컨테이너 로그는 자동으로 CloudWatch로 전송
- 로그 그룹: `/ecs/{project_name}-cluster`

### VPC Flow Logs

- VPC 트래픽 분석
- CloudWatch Logs에 저장

## 🔐 보안 모범 사례

### 구현된 보안 기능

1. **네트워크 분리**: 퍼블릭/프라이빗 서브넷 분리
2. **최소 권한 원칙**: IAM 역할에 필요한 최소 권한만 부여
3. **암호화**:
   - RDS 저장 데이터 암호화
   - S3 버킷 암호화
   - EBS 볼륨 암호화
4. **시크릿 관리**: SSM Parameter Store (SecureString)
5. **네트워크 보안**: 보안 그룹을 통한 트래픽 제어
6. **감사**: VPC Flow Logs를 통한 네트워크 트래픽 모니터링

## 📝 출력 값

배포 후 다음 정보를 얻을 수 있습니다:

- VPC ID 및 서브넷 ID
- ECR 저장소 URL
- ALB DNS 이름
- ECS 클러스터 및 서비스 이름
- RDS 엔드포인트
- S3 버킷 이름

</details>

<details>
<summary><strong>🇯🇵 日本語</strong></summary>

## 📋 プロジェクト概要

**sbht-terraform**は、AWS インフラをコードで管理する Infrastructure as Code (IaC)プロジェクトです。Terraform を使用して、本番環境に適した完全な AWS クラウドインフラを自動的にプロビジョニングします。

このプロジェクトは、Softbank Hackerthon 2025 のための SBHTDog 組織のコアインフラリポジトリです。

## 🏗️ アーキテクチャ概要

### デプロイされる AWS リソース

#### 🌐 ネットワーキング

- **VPC**: マルチアベイラビリティゾーン(Multi-AZ)構成の VPC
  - パブリックサブネット: ALB、NAT ゲートウェイ、Bastion ホスト用
  - プライベートサブネット: ECS Fargate、RDS 用
- **NAT ゲートウェイ**: プライベートサブネットのインターネットアウトバウンド接続
- **インターネットゲートウェイ**: パブリックサブネットのインターネット接続
- **VPC Flow Logs**: ネットワークトラフィックモニタリング

#### 🔐 セキュリティ

- **セキュリティグループ**:
  - ALB セキュリティグループ (HTTP/HTTPS/8080 許可)
  - ECS セキュリティグループ (ALB からのトラフィックのみ許可)
  - RDS セキュリティグループ (ECS と EC2 からの PostgreSQL 接続許可)
  - EC2 セキュリティグループ (SSH、HTTP、HTTPS)
- **IAM ロール**:
  - ECS Task Execution Role
  - ECS Task Role (S3、SSM アクセス)
  - CodeDeploy Role
  - GitHub Actions OIDC Role
- **SSM Parameter Store**: 機密設定情報の安全な保存

#### 🐳 コンテナインフラ

- **ECR (Elastic Container Registry)**: Docker イメージリポジトリ
  - イメージスキャン自動化
  - ライフサイクルポリシー (最新 10 イメージ保持)
- **ECS (Elastic Container Service)**:
  - Fargate クラスター
  - サービス自動デプロイおよび管理
  - コンテナログは CloudWatch に送信

#### ⚖️ ロードバランシング

- **Application Load Balancer (ALB)**:
  - HTTPS リダイレクト対応
  - Blue/Green デプロイメント用の二重ターゲットグループ
  - ポート 8080 のテストリスナー (Blue/Green デプロイメント用)
  - ヘルスチェック設定

#### 🗄️ データベース

- **RDS PostgreSQL**:
  - マルチ AZ デプロイメント (高可用性)
  - 自動バックアップ (7 日保持)
  - 暗号化有効化
  - Enhanced Monitoring
  - 2 つの独立したデータベース:
    - メインアプリケーション用 (プライベート)
    - Bastion サービス用 (パブリックアクセス)

#### 📦 ストレージ

- **S3 バケット**:
  - バージョニング有効化
  - 暗号化適用
  - ライフサイクルポリシー:
    - 30 日後に Standard-IA に移動
    - 90 日後に Glacier に移動
  - CORS 設定 (Web アプリケーション統合)

#### 🚀 デプロイメント自動化

- **CodeDeploy**:
  - Blue/Green デプロイメント戦略
  - ECS サービス自動デプロイ
  - 自動ロールバック機能
  - デプロイ準備状態確認

#### 📊 モニタリング

- **CloudWatch**: ログおよびメトリクス収集

#### 🖥️ 管理インスタンス

- **EC2 Bastion ホスト**:
  - データベース管理用
  - プライベートリソースアクセス用

## 📂 ディレクトリ構造

```
sbht-terraform/
├── main.tf              # メインTerraform設定
├── variables.tf         # 変数定義
├── outputs.tf          # 出力値
├── provider.tf         # AWSプロバイダー設定
└── modules/
    ├── vpc/           # VPCおよびネットワーキング
    ├── ecr/           # Container Registry
    ├── iam/           # IAMロールとポリシー
    ├── sg/            # セキュリティグループ
    ├── ssm/           # Parameter Store
    ├── rds/           # PostgreSQLデータベース
    ├── alb/           # Application Load Balancer
    ├── ecs/           # ECSクラスターとサービス
    ├── codedeploy/    # CodeDeployデプロイメントグループ
    ├── s3/            # S3バケット
    ├── sns/           # SNSトピック
    └── ec2/           # EC2インスタンス
```

## 🚀 はじめに

### 前提条件

- Terraform Cloud
- AWS アカウントおよび適切な権限

## ⚙️ 主要設定変数

| 変数                    | 説明                                                                 | 例                                           |
| ----------------------- | -------------------------------------------------------------------- | -------------------------------------------- |
| `alb_certificate_arn`   | ALB に使用される SSL 証明書                                          | `arn:aws:acm:ap-northeast-2:~:certificate/~` |
| `container_port`        | ECS コンテナポート                                                   | `3000`                                       |
| `enable_github_oidc`    | GitHub Actions から AWS にアクセスするための OIDC 権限とロールを作成 | `true`                                       |
| `enable_nat_gateway`    | VPC Nat Gateway 作成の有無                                           | `true`                                       |
| `github_repo`           | AWS にアクセスする GitHub Actions のリポジトリ                       | `SBHTDog/sbht-deploy-target`                 |
| `project_name`          | AWS リソース名のプレフィックスおよびタグ                             | `sbht-aws`                                   |
| `rds_master_password`   | RDS 管理者パスワード (PostgreSQL Admin user password)                | `yourdbpassword`                             |
| `rds_master_username`   | RDS 管理者ユーザー名 (PostgreSQL Admin username)                     | `true`                                       |
| `AWS_ACCESS_KEY_ID`     | AWS API アクセス用のアクセスキー環境変数                             | `AKIA~`                                      |
| `AWS_REGION`            | AWS リソースリージョン (環境変数)                                    | `ap-northeast-2`                             |
| `AWS_SECRET_ACCESS_KEY` | AWS API アクセス用のシークレットアクセスキー環境変数                 | `~`                                          |

## 🔄 Blue/Green デプロイメント

デプロイメントプロセス:

1. 新バージョン(Green)が別のターゲットグループにデプロイ
2. ヘルスチェック通過確認
3. トラフィックを段階的に Green に切り替え (ELB Target Group 変更)
4. 既存バージョン(Blue)終了

## 📊 モニタリングとロギング

### CloudWatch Logs

- ECS コンテナログは自動的に CloudWatch に送信
- ロググループ: `/ecs/{project_name}-cluster`

### VPC Flow Logs

- VPC トラフィック分析
- CloudWatch Logs に保存

## 🔐 セキュリティのベストプラクティス

### 実装されたセキュリティ機能

1. **ネットワーク分離**: パブリック/プライベートサブネット分離
2. **最小権限の原則**: IAM ロールに必要な最小権限のみ付与
3. **暗号化**:
   - RDS 保存データ暗号化
   - S3 バケット暗号化
   - EBS ボリューム暗号化
4. **シークレット管理**: SSM Parameter Store (SecureString)
5. **ネットワークセキュリティ**: セキュリティグループによるトラフィック制御
6. **監査**: VPC Flow Logs によるネットワークトラフィックモニタリング

## 📝 出力値

配布後、以下の情報を取得できます:

- VPC ID およびサブネット ID
- ECR リポジトリ URL
- ALB DNS 名
- ECS クラスターおよびサービス名
- RDS エンドポイント
- S3 バケット名

</details>
