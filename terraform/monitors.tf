resource "datadog_monitor" "pipeline_errors" {
  name               = "pipelinerunner errors"
  type               = "log alert"
  message            = "Restart pipelinerunner pod @slack-Cloudbees-topic-jenkins-x-infra"

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

  silenced {
    "*" = 0
  }

  tags = ["infra:tekton-mole"]
}
