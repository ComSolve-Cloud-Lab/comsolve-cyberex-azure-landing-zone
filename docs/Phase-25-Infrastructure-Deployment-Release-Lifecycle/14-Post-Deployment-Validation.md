# 🚀 Phase 25.14 — Post Deployment Validation

<p align="center">

![Azure](https://img.shields.io/badge/Azure-Validation-0078D4)
![CLI](https://img.shields.io/badge/Azure%20CLI-Read--Only-blue)
![Status](https://img.shields.io/badge/Status-Completed-success)

</p>

## 🎯 Objective

CD deployment के बाद Azure में actual resources successfully deployed हैं या नहीं verify करना।

---

## 🔍 Validation Areas

```text
Resource Groups
      ↓
VNet
      ↓
Subnets
      ↓
NSG
      ↓
NSG Associations
      ↓
NIC
      ↓
Storage Backend
```

---

## 🔧 Azure CLI Validation

### Resource Groups

```powershell
az group list --query "[?starts_with(name, 'rg-comsolve-cyberex')].{Name:name,Location:location,State:properties.provisioningState}" -o table
```

### VNet

```powershell
az network vnet show -g rg-comsolve-cyberex-network -n vnet-comsolve-cyberex-dev --query "{Name:name,Location:location,AddressSpace:addressSpace.addressPrefixes,State:provisioningState}" -o table
```

### Subnets

```powershell
az network vnet subnet list -g rg-comsolve-cyberex-network --vnet-name vnet-comsolve-cyberex-dev --query "[].{Name:name,Prefix:addressPrefix,State:provisioningState}" -o table
```

### NSG

```powershell
az network nsg show -g rg-comsolve-cyberex-network -n cyberex-nsg --query "{Name:name,State:provisioningState}" -o table
```

---

## 🏁 Acceptance

Azure CLI verification confirms that deployed infrastructure exists in Azure and is in a successful provisioning state.


---