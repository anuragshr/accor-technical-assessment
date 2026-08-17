resource "aws_kms_key" "custom-key" {
  description              = "AWS KMS Key"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  is_enabled               = true

}

resource "aws_kms_alias" "custom-key-alias" {
  name          = var.key_alias
  target_key_id = aws_kms_key.custom-key.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.custom-key.arn
}

output "kms_key_id" {
  value = aws_kms_key.custom-key.key_id
}

variable "key_alias" {
  type = string
}
