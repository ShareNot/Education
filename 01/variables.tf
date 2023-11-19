#============ main ================
variable "default_zone" {
  description = "The default zone"
  type        = string
  default     = "ru-central1-b"
}
variable "cloud_id" {
  description = "The cloud ID"
  type        = string
  sensitive = true
}
variable "folder_id" {
  description = "The folder ID"
  type        = string
  sensitive = true
}
variable "token_iam" {
  description = "The IAM token"
  type        = string
  sensitive = true
}
#=========== network ==============
variable "network_name" {
  description = "The name of main network"
  type        = string
  default = "tf-testnetwork"
}
#=========== instance =============
variable "instance_name" {
  description = "The name of instance"
  type        = string
  default = "test-vm"
}
variable "image_id" {
  description = "The Image ID"
  type        = string
  default = "fd8vmcue7aajpmeo39kk"
}
variable "username" {
  type = string
  default = "ubuntu"
  description = "The ssh username"
}