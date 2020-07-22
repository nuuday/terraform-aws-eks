apiVersion: v1
preferences: {}
kind: Config

clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: ${cluster_arn}

contexts:
- context:
    cluster: ${cluster_arn}
    user: ${cluster_arn}
  name: ${context_name}

current-context: ${context_name}

users:
- name: ${cluster_arn}
  user:
    token: "${token}"