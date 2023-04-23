#!/bin/bash

# AWS_PROFILEを入力
read -p "Enter the AWS profile to use: " aws_profile

# CloudFormationスタック名を入力
read -p "Enter the CloudFormation stack name to delete: " stack_name

# CloudFormationスタックの削除
aws --profile "${aws_profile}" cloudformation delete-stack --stack-name "${stack_name}"

echo "CloudFormation stack ${stack_name} deletion started."

# スタックが削除されるまで待機
aws --profile "${aws_profile}" cloudformation wait stack-delete-complete --stack-name "${stack_name}"
echo "CloudFormation stack ${stack_name} has been deleted."

# IAMロール名を入力
read -p "Enter the IAM role name to delete: " role_name

# カスタムポリシーのARNを取得
policy_arn=$(aws iam list-attached-role-policies --role-name "${role_name}" --query 'AttachedPolicies[0].PolicyArn' --output text)

# カスタムポリシーをIAMロールからデタッチ
aws --profile "${aws_profile}" iam detach-role-policy --role-name "${role_name}" --policy-arn "${policy_arn}"
echo "Detached custom policy from IAM role ${role_name}"

# カスタムポリシーの削除
aws --profile "${aws_profile}" iam delete-policy --policy-arn "${policy_arn}"
echo "Deleted custom policy with ARN ${policy_arn}"

# IAMロールの削除
aws --profile "${aws_profile}" iam delete-role --role-name "${role_name}"
echo "Deleted IAM role ${role_name}"
