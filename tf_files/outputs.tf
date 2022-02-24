output "instance_id" {
    value = aws_instance.xe_code_challenge_ec2_instance.id
}

output "instance_public_ip"{
    value = aws_instance.xe_code_challenge_ec2_instance.public_ip
}

output "instance_public_subnet" {
    value = aws_instance.xe_code_challenge_ec2_instance.subnet_id
}

output "sns_topic_id" {
    value = aws_sns_topic.xe-code-challenge-sns-topic.id
}

output "sqs_updates_id" {
    value = aws_sqs_queue.xe-code-challenge-updates-queue.id
}

output "sqs_updates_url" {
    value = aws_sqs_queue.xe-code-challenge-updates-queue.url
}

resource "local_file" "ansible_inventory" {
    content = templatefile("templates/inventory.tmpl",
        {
            instance-dns = aws_instance.xe_code_challenge_ec2_instance.*.public_dns,
            instance-id = aws_instance.xe_code_challenge_ec2_instance.*.id,
            instance-ip= aws_instance.xe_code_challenge_ec2_instance.*.public_ip
            sqs-id = aws_sqs_queue.xe-code-challenge-updates-queue.id,
            environment = var.env
            region = var.aws_region
        }
    )
    filename = "../ansible_files/inventories/servers"
}
