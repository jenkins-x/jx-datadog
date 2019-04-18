terraform {
  backend "gcs" {
    bucket  = "jenkins-x-infra-mole"
    prefix  = "terraform/state"
  }
}
