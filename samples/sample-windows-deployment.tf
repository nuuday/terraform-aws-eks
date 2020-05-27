locals {
  iis_sample_hostname = "iis.${var.dns_zone}"
  iis_cluster_issuer  = var.samples_use_production_cert_issuer ? "letsencrypt-prod" : "letsencrypt-staging"
}

resource "kubernetes_namespace" "iis" {
  count = var.windows_workers_count > 0 ? 1 : 0

  metadata {
    name = "iis-sample"
  }
}

resource "kubernetes_deployment" "iis" {
  count = var.windows_workers_count > 0 ? 1 : 0

  metadata {
    name      = "windows-iis"
    namespace = kubernetes_namespace.iis.0.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "windows-iis"
      }
    }

    template {
      metadata {
        labels = {
          app = "windows-iis"
        }
      }

      spec {
        container {
          image = "mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019"
          name  = "iis"

          port {
            name           = "http"
            container_port = 80
          }

          resources {
            requests {
              cpu    = "0.25"
              memory = "100Mi"
            }
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "windows"
        }
      }
    }
  }

  depends_on = [
    # If the Pod is submitted *before* the Windows admissions webhooks,
    # the pods will not be decorated appropriately, and will not be able to
    # be scheduled onto the Windows workers.
    #
    # This minimizes the risk of that happening.
    null_resource.windows_support,
  ]
}

resource "kubernetes_service" "iis" {
  count = var.windows_workers_count > 0 ? 1 : 0

  metadata {
    name      = "windows-iis"
    namespace = kubernetes_namespace.iis.0.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.iis.0.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 8080
      target_port = kubernetes_deployment.iis.0.spec.0.template.0.spec.0.container.0.port.0.container_port
    }
  }
}

resource "kubernetes_ingress" "iis" {
  count = var.windows_workers_count > 0 ? 1 : 0

  metadata {
    name      = "windows-iis"
    namespace = kubernetes_namespace.iis.0.metadata.0.name

    annotations = {
      # Ensures this Ingress object is picked up by our Nginx Ingress Controller
      "kubernetes.io/ingress.class" = "nginx"

      # Ensures cert-manager generates a cert for us to use.
      #
      # Note: Using the staging issuer to avoid hitting any limits on
      # Let's Encrypt's production issuer.
      "cert-manager.io/cluster-issuer" = local.iis_cluster_issuer
    }
  }

  spec {
    rule {
      host = local.iis_sample_hostname

      http {
        path {
          backend {
            service_name = kubernetes_service.iis.0.metadata.0.name
            service_port = kubernetes_service.iis.0.spec.0.port.0.port
          }
        }
      }
    }

    tls {
      hosts = [
        local.iis_sample_hostname
      ]

      # Name of the 'Secret' which will hold the cert's private key
      secret_name = "windows-iis-tls"
    }
  }

  depends_on = [
    helm_release.cert_manager,
    helm_release.external_dns,
  ]
}

output "iis_sample_url" {
  description = "URL for the Windows IIS sample app. It will take a few minutes to be available due to DNS propagation."
  value       = "https://${local.iis_sample_hostname}"
}
