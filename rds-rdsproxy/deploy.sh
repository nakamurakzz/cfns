#!/bin/bash

# AWS_PROFILEを入力
read -p "Enter the AWS profile to use: " aws_profile

# カスタムポリシーを定義したcustom_policy.jsonファイルがあることを確認
if [ ! -f custom_policy.json ]; then
    echo "custom_policy.json not found. Please create it with your custom policy."
    exit 1
fi

if [ ! -f trust_policy.json ]; then
    echo "trust_policy.json not found. Please create it with your custom policy."
    exit 1
fi

# IAMロール名を入力
read -p "Enter the IAM role name: " role_name

# カスタムポリシーの作成
policy_arn=$(aws --profile "${aws_profile}" iam create-policy --policy-name ${role_name}_CustomPolicy --policy-document file://custom_policy.json --query 'Policy.Arn' --output text)

# IAMロールの作成
aws --profile "${aws_profile}" iam create-role --role-name "${role_name}" --assume-role-policy-document file://trust_policy.json

# カスタムポリシーをIAMロールにアタッチ
aws --profile "${aws_profile}" iam attach-role-policy --role-name "${role_name}" --policy-arn "${policy_arn}"

echo "Successfully created and attached custom policy to IAM role ${role_name}"

# CloudFormationスタック名を入力
read -p "Enter the CloudFormation stack name: " stack_name

# CloudFormationテンプレートファイルがあることを確認
if [ ! -f cloudformation_template.yaml ]; then
    echo "cloudformation_template.yaml not found. Please create it with your CloudFormation template."
    exit 1
fi

# IAMロールのARNを取得
role_arn=$(aws --profile "${aws_profile}" iam get-role --role-name "${role_name}" --query 'Role.Arn' --output text)

# CloudFormationスタックの作成
aws --profile "${aws_profile}" cloudformation create-stack --stack-name "${stack_name}" --template-body file://cloudformation_template.yaml --role-arn "${role_arn}"

echo "CloudFormation stack ${stack_name} creation started using IAM role ${role_name}"
