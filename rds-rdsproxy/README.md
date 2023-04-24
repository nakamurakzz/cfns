## RDSインスタンス、RDSプロキシ、踏み台サーバーの構築

## 概要
- VPC、RDSインスタンス、RDSプロキシ、踏み台サーバーの構築を行う
  - VPC
    - 1つのパブリックサブネット、2つのプライベートサブネットを持つ
    - VPC、各サブネットのCIDRはCloudformationによるリソース作成ときに指定する
  - RDSインスタンス
    - シングル構成
    - データベース：MySQL8.0
    - データベース名、ユーザー名、パスワードはCloudFormationによるリソース作成ときに指定し、Secrets Managerに保存する
  - RDSプロキシ
    - 作成したRDSインスタンスをターゲットグループに指定する
  - 踏み台サーバ
    - RDSインスタンスと同じVPC、パブリックサブネットに配置する

## 前提
- 各リソースを作成する権限を持つユーザが作成されていること
- AWS CLIの設定ファイルが作成されていること
- EC2のキーペアが作成されていること

## 作成手順
### Cloudformation用のIAMロールの作成
```bash
sh create_iam_role.sh
```
- 作成するAWSアカウント用のAWS_PROFILEを指定する
  - AWS_PROFILEはAWS CLIの設定ファイルに記載する
- 作成するIAMロール名を指定する

### Cloudformationによるリソース作成
<!-- TODO: CLIで作成できるように修正したい -->
- AWSコンソールにログイン
- Cloudformationのコンソールを開く
- スタックの作成をクリック
- cloudformation/rds-rdsproxy.yamlをアップロード
- スタック名を入力
- 以下のパラメータを入力
  - EnvironmentName： 環境名（dev, stg, prod）
  - KeyName： 踏み台サーバーに使用するキーペア名
  - VpcCidr： VPCのCIDR
  - PublicSubnet1Cidr： パブリックサブネット1のCIDR
  - PrivateSubnet1Cidr： プライベートサブネット1のCIDR
  - PrivateSubnet2Cidr： プライベートサブネット2のCIDR
  - DBName： RDSインスタンスのデータベース名
  - DBUser： RDSインスタンスのユーザー名
  - DBPassword： RDSインスタンスのパスワード
- create_iam_role.shで作成したIAMロールをCloudformationに設定する

## リソース削除手順
<!-- CLIで削除する -->
### Cloudformationのスタック削除
- AWSコンソールにログイン
- Cloudformationのコンソールを開く
- スタックを削除する

### IAMロールの削除
- AWSコンソールにログイン
- IAMのコンソールを開く
- 作成したIAMロールを削除する

### IAMポリシーの削除
- AWSコンソールにログイン
- IAMのコンソールを開く
- 作成したIAMポリシーを削除する
