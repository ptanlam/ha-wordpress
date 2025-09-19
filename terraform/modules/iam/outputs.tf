output "webserver_instance_profile_name" {
  description = "The name of the webserver instance profile"
  value       = aws_iam_instance_profile.webserver.name
}

output "image_builder_instance_profile_name" {
  description = "The name of the image builder instance profile"
  value       = aws_iam_instance_profile.image_builder.name
}
