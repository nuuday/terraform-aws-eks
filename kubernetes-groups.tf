resource "kubernetes_cluster_role_binding" "administrators_admin" {
  metadata {
    name   = "administrators-cluster-admin"
    labels = local.tags
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "administrators"
  }
}

resource "kubernetes_cluster_role_binding" "powerusers_admin" {
  metadata {
    name   = "powerusers-admin"
    labels = local.tags
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "powerusers"
  }
}

resource "kubernetes_cluster_role_binding" "developers_edit" {
  metadata {
    name   = "developers-edit"
    labels = local.tags
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "developers"
  }
}

resource "kubernetes_cluster_role_binding" "readonly_basic_user" {
  metadata {
    name   = "readonly-basic-user"
    labels = local.tags
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:basic-user"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "readonly"
  }
}

resource "kubernetes_cluster_role_binding" "readonly_view" {
  metadata {
    name   = "readonly-view"
    labels = local.tags
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "readonly"
  }
}