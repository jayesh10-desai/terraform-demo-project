data "aws_iam_policy_document" "ec2_assume_role" {
    statement {
      actions = [ "sts:AssumeRole" ]
      principals {
        type        = "Service"
        identifiers = [ "ec2.amazonaws.com" ]
      }
    }
}

resource "aws_iam_role" "ec2_iam_role" {
    name = "ec2-iam-role-${terraform.workspace}"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "ec2-instance-profile-${terraform.workspace}"
    role = aws_iam_role.ec2_iam_role.name
}

resource "aws_iam_policy_attachment" "ec2_attach_1" {
  name = "ec2-iam-attachment-${terraform.workspace}"
  roles = [ aws_iam_role.ec2_iam_role.id ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_policy_attachment" "ec2_attach_2" {
  name = "ec2-iam-attachment-${terraform.workspace}"
  roles = [ aws_iam_role.ec2_iam_role.id ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "secrets-manager-policy" {
    name = "secrets-manager-policy-${terraform.workspace}"
    description = "Allow EC2 to access AWS Secrets Manager"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:GetResourcePolicy",
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:ListSecretVersionIds"    
                ],
                "Resource": "${aws_secretsmanager_secret.secretmasterDB.arn}/*"
            }
        ]
      })
}

resource "aws_iam_policy_attachment" "s3_attach" {
  name = "secrets-iam-attachment"
  roles = [ aws_iam_role.ec2_iam_role.id ]
  policy_arn = aws_iam_policy.secrets-manager-policy.arn
}