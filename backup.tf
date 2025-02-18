resource "aws_backup_vault" "my_vault" {
  name        = "${terraform.workspace}-vault"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

resource "aws_iam_role" "backup_role" {
  name               = "backup_role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_backup_plan" "my_back_plan" {
  name = "backup-plan-${terraform.workspace}"

  rule {
    rule_name         = "backup-rule"
    target_vault_name = aws_backup_vault.my_vault.name
    schedule          = "cron(50 1 * * ? *)"
    completion_window = 120

    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_selection" "myselection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "test_selection"
  plan_id      = aws_backup_plan.my_back_plan.id

  resources =  aws_instance.web[*].arn
}