
# 📦 Azure Infrastructure - Terraform Modulaire

Cette infrastructure déployée via Terraform provisionne une architecture Azure complète et sécurisée, incluant des VM, App Service, SQL PaaS, DNS privé, Bastion et plus.

---

## 🧱 Architecture Générale

```
Modules Terraform :
├── network/         → VNet, Subnet, NSG
├── vm/              → VM Windows + SSMS
├── sqlserver/       → SQL Server PaaS, base de données, Private Endpoint
├── security/        → Règles NSG, Bastion
├── appservice/      → App Service Windows, VNet Integration
├── keyvault/        → Accès aux secrets
├── dns/             → Private DNS Zone
```

---


## 🔗 Connexions entre modules

- La **VM** et **App Service** se connectent au **SQL Server PaaS** via **Private Endpoint** et **DNS privé**.
- Le **Key Vault** fournit les secrets aux autres modules.
- L’**App Service** s’authentifie au SQL avec **Managed Identity AAD**.
- Le **Bastion** donne accès à la VM sans IP publique.

---

## ⚙️ Détails par module

### `network/`
- Provisionne le VNet principal (`vnet-poc`) avec sous-réseaux (`subnet-vm`, `subnet-appservice`)
- NSG lié au subnet de la VM
- VNet peering avec `vnet-sql`

### `vm/`
- Provisionne une VM Windows avec NSG
- Installe SSMS via `CustomScriptExtension`
- Accède à Key Vault pour les mots de passe

### `sqlserver/`
- Crée un SQL Server PaaS avec base de données
- Private Endpoint dans `vnet-sql`
- Désactive l'accès public
- DNS privé pour résolution du nom

### `security/`
- Règles NSG (RDP, HTTP, etc.)
- Déploiement d’un Bastion Host

### `appservice/`
- Plan App Service Windows
- Web App avec Managed Identity
- Connection string SQL avec AAD
- VNet Integration dans `subnet-appservice`

### `keyvault/`
- Secrets récupérés via `data` source
- Utilisé dans les modules `vm`, `sqlserver`, `appservice`

### `dns/`
- Création de la zone DNS privée
- Enregistrement `A` du SQL Server lié au Private Endpoint

---

## ✅ Sécurité
- Aucun accès public au SQL Server
- Accès VM via Bastion uniquement
- Secrets stockés dans Azure Key Vault
- App Service utilise l’authentification AAD via Identity managée
- VNet Integration sécurise les communications internes

---

## 🔐 Authentification Terraform
- Authentification via **OIDC GitHub Actions** :
```hcl
provider "azurerm" {
  features {}
  use_oidc = true
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
}
```

---

## 🚀 Déploiement CI/CD
- GitHub Actions utilise 3 workflows :
  1. **Infrastructure** (Terraform)
  2. **Restore DB** (si nécessaire)
  3. **Code AppService** (dotnet publish + az webapp deploy)

---

## 📎 Diagramme d’architecture
![Architecture](azure_terraform_architecture.png)

---

## 📁 Backend
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateprod"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

---

## 🧪 Tests / Validation
- VM connectée au SQL via DNS privé
- App Service communique avec SQL via AAD et VNet Integration
- Résolution DNS vérifiée via `nslookup` sur la VM
