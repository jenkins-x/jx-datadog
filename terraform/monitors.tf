resource "datadog_monitor" "pipeline_errors" {
  name               = "pipelinerunner errors"
  type               = "log alert"
  message            = <<EOT
{{#is_alert}}
Pipeline runner is unable to clone repositories
  1. Connect to jenkins-x-infra/tekton-mole
  2. Restart the pipelinerunner pod
{{/is_alert}}
{{#is_recovery}}
Pipeline runner - Back to normal
{{/is_recovery}}
@slack-Cloudbees-topic-jenkins-x-infra
EOT

  query = "logs(\"service:pipelinerunner status:error\").index(\"main\").rollup(\"count\").last(\"10m\") > 3"

  thresholds {
    ok                = 0
    warning           = 2
    warning_recovery  = 1
    critical          = 4
    critical_recovery = 3
  }

  notify_no_data    = false
  renotify_interval = 60

  notify_audit = false
  timeout_h    = 60
  include_tags = true

  tags = ["infra:tekton-mole", "terraform:managed"]

  # NOTE: workaround for https://github.com/terraform-providers/terraform-provider-datadog/issues/71
  # we need to ignore changes on 'silenced', otherwise TF always found changes to apply on this property
  lifecycle {
    ignore_changes = [
      "silenced"
    ]
  }
}
