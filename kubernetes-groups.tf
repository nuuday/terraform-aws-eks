resource "kubernetes_cluster_role_binding" "administrators" {
  metadata {
    name = "administrators-cluster-admin"
    labels = var.tags
    annotations = {
      Managed-By: terraform
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind = "Group"
    name = "administrators"
  }
}

resource "kubernetes_cluster_role_binding" "powerusers" {
  metadata {
    name = "powerusers-admin"
    labels = var.tags
    annotations = {
      Managed-By: terraform
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind = "Group"
    name = "powerusers"
  }
}

resource "kubernetes_cluster_role_binding" "developers" {
  metadata {
    name = "developers-edit"
    labels = var.tags
    annotations = {
      Managed-By: terraform
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "edit"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind = "Group"
    name = "developers"
  }
}

resource "kubernetes_cluster_role_binding" "readonly_basic_user" {
  metadata {
    name = "readonly-basic-user"
    labels = var.tags
    annotations = {
      Managed-By: terraform
    }
  }


  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "system:basic-user"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind = "Group"
    name = "readonly"
  }
}

resource "kubernetes_cluster_role_binding" "readonly_view" {
  metadata {
    name = "readonly-view"
    labels = var.tags
    annotations = {
      Managed-By: terraform
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "view"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind = "Group"
    name = "readonly"
  }
}