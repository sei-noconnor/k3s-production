# K3s Production {version}

Welcome to the **K3s Production**. This virtual machine hosts workforce development apps from the [Software Engineering Institute](https://sei.cmu.edu) at [Carnegie Mellon University](https://cmu.edu).

## Getting started

To get started using the cluster:

1. Download [root-ca.crt](root-ca.crt) and trust it in your keychain/certificate store. This removes browser certificate warnings.
2. Navigate to any of the apps in the following two sections.
3. Unless otherwise noted, the default credentials are:

   | key      | value                   |
   | -------- | ----------------------- |
   | username | `administrator@$DOMAIN` |
   | password | `$ADMIN_PASS`           |
   | code     | `123456`                |

## Common apps

The following Foundry applications are loaded on this cluster:

| location               | api                  | description                                                                                                      |
| ---------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [/identity](/identity) | [api](/identity/api) | _Identity_ manages logins/credentials across all of the apps. It can integrate with any OAuth2/OIDC application. |

## Third-party apps

The following third-party applications are loaded on this cluster:

| location                 | description                                                                                                           |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| [/dashboard](/dashboard) | _Kubernetes Dashboard_ provides details regarding the container deployment for the cluster.                           |
| [/gitea](/gitea)         | _Gitea_ provides a user interface for editing the web content on the cluster (including this page).                   |
| [/pgadmin](/pgadmin)     | _pgAdmin_ provides a GUI for managing the PostgreSQL databases for each app.                                          |
| [/vscode](/vscode)       | _code-server_ runs a browser version of [Visual Studio Code](https://code.visualstudio.com) to configure the cluster. |

## Under the hood

For command line access to the cluster:

```
ssh user@$DOMAIN
```

The SSH password is `tartans@1`. Then you can run normal Kubernetes commands via `kubectl`.

```
kubectl get pods
```

The code for building this virtual machine is [available on GitHub](https://github.com/sei-noconnor/k3s-production)

The cluster runs all of the apps in a Kubernetes cluster provided by [K3s](https://k3s.io/). This provides production-ready deployments in a datacenter or cloud.

![CMU SEI Unitmark](assets/cmu-sei-unitmark.png){: style="width:400px;margin:40px 0px 0px"}
