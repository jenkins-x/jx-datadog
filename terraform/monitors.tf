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

resource "datadog_monitor" "datadog-agent-status" {
  name               = "Datadog agent status"
  type               = "metric alert"
  message            = <<EOT
{{^is_recovery}}An agent is not reporting on this host: **{{host.name}}**. Check that everything is ok.{{/is_recovery}}
{{#is_recovery}}Datadog agent status back to normal.{{/is_recovery}}
@slack-Cloudbees-topic-jenkins-x-infra
EOT
  query              = "avg(last_10m):avg:datadog.process.agent{*} by {host} < 1"
  notify_no_data     = true
  no_data_timeframe  = 20
  renotify_interval  = 60
  require_full_window = true
  notify_audit       = false
  timeout_h          = 0
  escalation_message = ""
  include_tags       = false
  new_host_delay     = 300
  locked             = true
  tags = ["infra:tekton-mole", "terraform:managed"]

  thresholds {
    critical = 1
  }

  # NOTE: workaround for https://github.com/terraform-providers/terraform-provider-datadog/issues/71
  # we need to ignore changes on 'silenced', otherwise TF always found changes to apply on this property
  lifecycle {
    ignore_changes = [
      "silenced"
    ]
  }
}

