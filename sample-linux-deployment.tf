locals {
  nginx_sample_hostname = "nginx.${var.dns_zone}"
  nginx_cluster_issuer  = var.samples_use_production_cert_issuer ? "letsencrypt-prod" : "letsencrypt-staging"
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx-sample"
  }
}

resource "kubernetes_deployment" "nginx" {
  count = var.linux_workers_count > 0 ? 1 : 0

  metadata {
    name      = "nginx-sample"
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx-sample"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-sample"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"

          port {
            name           = "http"
            container_port = 80
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  count = var.linux_workers_count > 0 ? 1 : 0

  metadata {
    name      = "nginx-sample"
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.nginx.0.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 8080
      target_port = kubernetes_deployment.nginx.0.spec.0.template.0.spec.0.container.0.port.0.container_port
    }
  }
}

resource "kubernetes_ingress" "nginx" {
  count = var.linux_workers_count > 0 ? 1 : 0

  metadata {
    name      = "nginx-sample"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    annotations = {
      # Ensures this Ingress object is picked up by our Nginx Ingress Controller
      "kubernetes.io/ingress.class" = "nginx"

      # Ensures cert-manager generates a cert for us to use.
      #
      # Note: Using the staging issuer to avoid hitting any limits on
      # Let's Encrypt's production issuer.
      #
      # Change 'letsencrypt-staging' to 'letsencrypt-prod' to issue trusted certs.
      "cert-manager.io/cluster-issuer" = local.nginx_cluster_issuer
    }
  }

  spec {
    rule {
      host = local.nginx_sample_hostname

      http {
        path {
          backend {
            service_name = kubernetes_service.nginx.0.metadata.0.name
            service_port = kubernetes_service.nginx.0.spec.0.port.0.port
          }
        }
      }
    }

    tls {
      hosts = [
        local.nginx_sample_hostname
      ]

      # Name of the 'Secret' which will hold the cert's private key
      secret_name = "nginx-sample-tls"
    }
  }

  depends_on = [
    helm_release.cert_manager,
    helm_release.external_dns,
  ]
}
