---
title: Un conteneur Docker dans Azure
---

--sep--
---
title: Introduction
---

# Introduction

Ce [repository](https://github.com/thomasrannou/container-workshop) contient le code ainsi que les instructions vous permettant de 
réaliser le workshop **déployer vos conteneurs Docker dans Azure**.

Au menu aujourd'hui, depuis notre application .Net 5 et son Dockerfile nous allons :

- Déployer notre image Docker dans un Azure Container Registry
- Déployer notre application dans une Azure Container Instance
- Déployer notre application dans une Azure Web App
- Déployer notre application dans un cluster Kubernetes grâce à un fichier yaml.

## Pré-requis

Afin de réaliser ce workshop, vous aurez besoin: 

- D'un PC (ou Mac) de développement, sur lequel il faudra installer un certain nombre d'outils,
- D'un abonnement Azure (d'essai, payant ou MSDN)

--sep--
---
title: Objectif du workshop
---

# Objectif du workshop

Ce workshop, accessible à **tous les développeurs même sans connaissance de Docker ou d'Azure**, vous permettra de découvrir le déploiement d'application conteneurisée au travers de différents services Azure.

![Logo du projet Docker](media/docker-logo.png)

--sep--
---
title: Préparez votre machine de dev
---

# Préparer sa machine de dev

Afin de pouvoir provisionner votre environnement et y déployer l'application vous aurez besoin de plusieurs outils (gratuits) : 

- [.NET 5](https://dotnet.microsoft.com/download)
- [Visual Studio Code](https://code.visualstudio.com/?wt.mc_id=WTMCID)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Azure CLI](https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli)
- En environnement Windows : [Powershell 7](https://github.com/PowerShell/PowerShell/releases/tag/v7.1.2)
- En environnement Linux : Bash
--sep--
---
title: Préparez votre environnement Azure
---

# Préparer son environnement Azure

Afin de réaliser cet atelier, vous aurez besoin d'une souscription Azure. Il y a plusieurs moyens d'en obtenir une: 

- (**Obligation**) Si vous lisez cet atelier durant le Roadshow, vous pouvez utiliser l'Azure Pass que nous vous fournissons,
- Ou si vous êtes abonnés MSDN, utiliser les crédits offerts par votre abonnement.
- Ou créer un [abonnement d'essai](https://azure.microsoft.com/en-us/free/?wt.mc_id=WTMCID).

## Utiliser votre Azure Pass

1. Rendez-vous sur [microsoftazurepass.com](https://www.microsoftazurepass.com/?wt.mc_id=WTMCID) et cliquez sur **Start**,
![Démarrer l'utilisation du pass](media/redeempass-1.jpg)
2. Connectez vous avec un compte Microsoft Live **Vous devez utiliser un compte Microsoft qui n'est associé à aucune
 autre souscription Azure**
3. Vérifiez l'email du compte utilisé et cliquez sur **Confirm Microsoft Account**
![Confirmer le compte](media/redeempass-2.jpg)
4. Entrez le code que nous vous avons communiqués, puis cliquez sur **Claim Promo Code** (et non, le code présent sur la
 capture d'écran n'est pas valide ;) ),
![Indiquer son code](media/redeempass-3.jpg)
5. Nous validons votre compte, cela prend quelques secondes
![Validation du code](media/redeempass-4.jpg)
6. Nous serez ensuite redirigé vers une dernière page d'inscrption. Remplissez les informations, puis cliquez sur **Suivant**
![Entrer les informations](media/redeempass-5.jpg)
7. Il ne vous restera plus que la partie légale: accepter les différents contrats et déclarations. Cochez les cases que 
vous acceptez, et si c'est possible, cliquez sur le bouton **Inscription**
![Accepter les conditions légales](media/redeempass-6.jpg)

Encore quelques minutes d'attente, et voilà, votre compte est créé ! Prenez quelques minutes afin d'effectuer la 
visite et de vous familiariser avec l'interface du portail Azure.

![Accueil du portail Azure](media/redeempass-7.jpg)

--sep--
---
title: Docker, pour qui ? Pour quoi ?
---

# Docker, pour qui ? Pour quoi ?

## La conteneurisation applicative

Conteneuriser c'est empaqueter une application et ses dépendances dans un conteneur isolé, qui pourra être exécuté sur n'importe quel serveur. 
Cela permet d'étendre la flexibilité et la portabilité d’exécution d'une application, que ce soit sur la machine locale, un cloud privé ou public, une machine nue, etc.

## Introduction à Docker 

Docker offre une interface permettant de facilement isoler un processus et un filesystem. 
Cela permet d’exécuter des applications (conteneurs) de manière isolé les unes des autres. 
Docker permet également de construire des images via un système d’empilement de couches (Dockerfile). Ces images sont immuables et peuvent être instanciées (conteneur).

--sep--
---
title: Un projet .Net 5
---

# Un projet .Net 5

Le but de ce tutoriel est de parcourir les différentes manières de déployer une application web .Net 5 conteneurisée dans Azure.

## Génération d'une image Docker de notre projet

Pour les utilisateurs sous Windows, configurer votre Docker en mode "Linux containers".
Sous Windows toujours, Docker pourra etre paramétré pour utiliser WSL2 ou la virtualisation HyperV. Les deux fonctionneront.

Le projet en lui même est à télécharger [ici](https://github.com/thomasrannou/container-workshop/tree/main/ApplicationDemoWorkshop).

On va donc commencer par récupérer le projet puis ouvrir une fenêtre Powershell. Dans un premier temps, vous allez devoir générer une image Docker et donc compiler le projet que vous avez récupéré. Dans votre fenêtre powershell, positionnez vous à la racine de votre repertoire projet et executez :

_docker build -f "ApplicationDemoWorkshop/Dockerfile" . -t aksworkshop_

![Génération de l'image Docker](media/1-build.PNG)

On peux maintenant demander la création d'un conteneur basé sur cette image :

_docker run -d -p 8080:80 --name conteneurdemo aksworkshop_

![Execution d'un conteneur](media/2-execution.PNG)

Et accéder à : http://localhost:8080/ pour valider le bon fonctionnement de notre site :

![Validation du site web](media/3-website.PNG)

--sep--
---
title: Un environnement Azure
---

# Un environnement Azure

## Créer un resource group

Toujours dans votre fenêtre Powershell, executez un _az login_ pour vous connecter à votre souscription Azure.

Nous allons commencer par créer un groupe de ressources (_resource group_). C'est un conteneur logique pour l'ensemble des services que vous allez créer ensuite. 
Chaque service Azure doit absolument être déployé dans un resource group. Ici le groupe de ressource va accueillir l'ensemble de mes futurs déploiements dans Azure :

_az group create --name rg-workshop --location francecentral_

![Creation du ressource group](media/4-ressourcegroup.PNG)

## Déploiement du projet dans un Azure Container Registry

Ce [registry](https://azure.microsoft.com/fr-fr/services/container-registry) vous permettra de gérer vos images Docker pour ensuite pouvoir les déployer facilement dans une Azure Web App, dans une Azure Container Instance ou dans un cluster Kubernetes.

Vous pouvez demander la création de votre Container Registry grâce à cette commande :

_az acr create --resource-group rg-workshop --name acrworkshopdevcongalaxy --sku Basic_

![Creation du container registry](media/5-registrycreate.PNG)

Connectez vous maintenant à cette registry :

_az acr login --name acrworkshopdevcongalaxy_

L'authentification se fait ici de façon implicite car vous êtes connecté à votre souscription Azure.

![Connexion au container registry](media/6-registryconnect.PNG)

Nous pouvons maintenant y publier notre image Docker.
Pour cela, vous devrez tout d'abord tagguer votre image locale avec le nom de votre registry Azure :

_docker tag aksworkshop acrworkshopdevcongalaxy.azurecr.io/appworkshop:v1_

Puis effectuez un push de l'image : 

_docker push acrworkshopdevcongalaxy.azurecr.io/appworkshop:v1_

Ce qui aura pour effet de démarer l'upload vers votre registry :

![Push de l'image](media/7-registrypush.PNG)

![Fin du push de l'image](media/7-registrypush-end.PNG)

Ces opérations réalisées, si on se rend sur portal.azure.com, on doit trouver un ressourcegroup rg-workshop contenant un Azure Container Registry :

![Vérification sur le portail](media/8-portail-rg.PNG)

Hébergeant lui même une image Docker nommée appworkshop :

![Vérification sur le portail](media/9-portail-registry.PNG)

--sep--
---
title: Azure Container Instance
---

## Azure Container Instance

Azure Container Instance (ou ACI) est le moyen le plus simple d’exécuter un conteneur Docker dans Azure. Un simple _az container create_ permet de déployer en quelques secondes une image Docker dans une ACI. 

Cette solution est donc plutôt orienté :

- Exécution temporaire d’un conteneur
- A la demande par exemple pour un traitement ponctuel
- Serverless (on ne configure pas de vm ni de runtime d'execution, on fournit juste l'image Docker à exécuter)
- Paiement à l’utilisation (au conteneur actif)

Attention, pour pouvoir déployer le container de cette manière, vous devrez activer l'authentification via le compte Admin sur la Registry :

![Compte Administrateur sur l'ACR](media/acrwithadmin.PNG)

Notez ensuite le username et le password affiché à l'écran.

_az container create --resource-group rg-workshop --name dotnetappaci --image acrworkshopdevcongalaxy.azurecr.io/appworkshop:v1 --registry-login-server acrworkshopdevcongalaxy.azurecr.io --registry-username $adminuser --registry-password $adminpwd --dns-name-label dotnetappaci --ports 80_

Il y a une autre possibilité pour gérer l'authentification à votre registry, via un service principal. Plutot que d'utiliser un comtpe lié à la registry, vous allez créer une identité Azure à laquelle vous allez donner un droit "AcrPull" sur votre registry.
Un exemple ici :
- https://docs.microsoft.com/fr-fr/azure/container-registry/container-registry-auth-aci

Pour récupérer l'URL d'accès à votre ACI, vous pouvez utiliser cette commande :

_az container show --resource-group rg-workshop --name dotnetappaci --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table_

![Déploiement ACR](media/aciup.PNG)

Et celle-ci pour accéder aux logs :

_az container logs --resource-group rg-workshop --name dotnetappaci_

--sep--
---
title: Azure App Services
---

## Azure App Services

### Présentation

Azure App Service est une offre de type PaaS qui vous permet d’héberger des applications web, des back-ends mobiles et des API REST dans le langage de programmation de votre choix (le runtime applicatif sera à définir au moment de la création de la web app : .Net, Python, Java, Node.js).
Ce service offre une mise à l’échelle automatique et une haute disponibilité, prend en charge à la fois Windows et Linux sans toutefois avoir à gérer l’infrastructure sous jacente.

De la même façon que pour une WebAPI ou un site ASP.Net “standard” il est possible de déployer un conteneur dans une App Services.

### Déploiement 

Je dois d'abord créé un service plan qui représente la puissance CPU et RAM affecté à mon application. Ici je choisis un plan de type B1. Mon application disposer de 1 VCPU et 1,75 Go de RAM. Le cout de ce plan s'élève à 0,064€ de l'heure soit 47€ par mois.
Pour avoir la liste complete des plan disponible, je vous propose ce [lien](https://azure.microsoft.com/fr-fr/pricing/details/app-service/windows/)

_az appservice plan create --name plan-workshop --resource-group rg-workshop --is-linux --sku B1_

Je créé ma webapp :

_az webapp create --resource-group rg-workshop --plan plan-workshop --name dotnetappservices --deployment-container-image-name acrworkshopdevcongalaxy.azurecr.io/appworkshop:v1_

![Déploiement App Service](media/appserviceup.PNG)

L'accès aux logs se fait via cette commande :

_az webapp log tail --name dotnetappservices --resource-group rg-workshop_

--sep--
---
title: AKS : le service managé k8s dans Azure
---

# AKS : Le service managé K8S dans Azure

Avant de présenter Azure Kubernetes Service en tant que produit Azure, il faut s’intéresser à l’outil Kubernetes lui même.

Kubernetes est une plateforme open source d’orchestration de containers créée par Google, puis offert à la Cloud Native Computing Foundation en 2015.
Kubernetes permet d’automatiser le déploiement et la gestion d’applications conteneurisées. Il gère le cycle de vie des services en proposant scalabilité et haute disponibilité.

Kubernetes peut fonctionner avec n’importe quel système de container conforme au standard Open Container Initiative et notamment le plus connu d’entre eux : Docker.

## Architecture de Kubernetes

![Architecture de Kubernetes](media/Kubernetes-architecture.png)

**Master** : Le Kubernetes master est responsable du maintien de l’état souhaité pour votre cluster. Il gère la disponibilité des nodes.

**etcd** : les données de configuration du cluster. Il représente l’état du cluster à n’importe quel instant.

**Node** : Machine virtuelle ou physique permettant l’exécution de pods.

**Kubelet** : il est responsable de l’état d’exécution de chaque nœud. Il prend en charge le démarrage, l’arrêt, et la maintenance des conteneurs d’applications organisés en pods.

**kubeproxy** : Il est responsable d’effectuer le routage du trafic vers le conteneur approprié.

**Pod** : unité d’exécution de K8s. Contient un ou plusieurs conteneur. Un Pod représente un processus en cours d’exécution dans votre cluster.

## Kubernetes dans Azure

En mars 2016, Microsoft lance Azure Container Service. ACS est une offre PAAS, aujourd’hui obsolète, permettant de déployer rapidement un cluster Kubernetes, DC/OS ou Docker Swarm pour provisionner et manager des conteneur Docker.

Aussi, compte tenu de l’engouement autour de Kubernetes, Microsoft a décidé avec AKS (Azure Kubernetes Services) d’investir fortement sur l’intégration de Kubernetes dans Azure et d’en faire un service managé. Azure gère pour nous les tâches critiques telles que le déploipement, l’analyse de l’intégrité et la maintenance.  Nous devons uniquement nous soucier des nœuds de notre cluster.

Grâce à AKS, plateforme de choix pour la mise en oeuvre de microservices, Microsoft nous propose dans Azure une stack technique agile et robuste pour déployer et manager nos containers.

## Création du cluster Azure Kubernetes Services

Je créé maintenant mon Azure Kubernetes Service grace au script initAKS.ps1 présent dans le repo Git. Ce script est très simple, il a pour de but de provisionner un cluster Azure Kubernetes Services tout en configurant ces droits d'accès à la registry demandée via la propriété _attach-acr_. Je demande par ailleurs que mon cluster soit constitués de 3 nodes déployés sur des zones de disponibilités différentes.

Les zones de disponibilité sont des emplacements physiquement séparés au sein d’une région Azure comme France Centre (minimum 3). Chaque zone de disponibilité est composée d’un ou de plusieurs centres de données équipés d’une alimentation, d’un refroidissement et d’un réseau indépendants.

Si vous avez bien suivis, vous comprenez maintenant que les clusters AKS déployés à l’aide de zones de disponibilité peuvent répartir les nœuds sur plusieurs zones au sein d’une même région ! Par exemple, un cluster dans la région  France Centre  peut créer des nœuds dans les trois zones de disponibilité de France Centre. Il y aura des noeuds sur chaque datacenter composant la région !

Grace à cela votre cluster AKS est capable de tolérer une défaillance dans l’une de ces zones ; si un des datacenter de la région est indisponible la continuité de service est assuré. A contrario, si tout les nœuds de notre cluster était déployé au même endroit, le service serait indisponible. Cette notion de zone de disponibilité est fondamentale lorsqu'on s'intéresse à des notions de haute disponibilité et de continuité de service.

![Déploiement du cluster AKS](media/14-deployaksned.PNG)

Nous avons donc provisionner un cluster Azure Kubernetes Service ! Voyons maintenant comment l'administrer en local.
Pour gérer un cluster Kubernetes, on utilise *kubectl*, le client de ligne de commande Kubernetes . Pour installer kubectl, si il n'est pas déja présent, utilisez :

_az aks install-cli_

![Installation de kubectl](media/15-installkubectl.PNG)

L'installeur vous demande de jouer cette commande Powershell : $env:path += 'C:\Users\trannou\.azure-kubelogin' pour poursuivre. Cette modification ne sera valable que pour la fenêtre Powershell courante. Pour une solution pérenne , ajoutez cette même entrée aux gestionnaires de variables d'environnement Windows :

![Gestion des variables d'environnement](media/16-environnementvar.PNG)

Maintenant pour pouvoir utiliser votre cluster en local, il faut executer :

_az aks get-credentials --resource-group rg-workshop --name aksdemoworkshop_

![Connexion au cluster AKS](media/17-credentialsaks.PNG)

Cette commande permet de renseigner le kubeconfig local contenant les informations nécessaires pour accéder au cluster distant :
- L’utilisateur et ses certificats/clés
- L’adresse vers l’API server
- Le namespace par défaut

Notre cluster est déployé et j'y ai accès depuis mon poste local, nous allons pouvoir passer au déploiement de l'application !

--sep--
---
title: Déploiement de l'application
---

# Déploiement de l'application

Je vous propose d'utiliser un fichier yaml pour déployer une instance de notre image Docker (hebergé dans mon container registry) dans mon cluster AKS. 
Le fichier yaml à utiliser est présent sur le repo, dans le dossier de l'application.

Attention à la ligne 22, le champ containers/image spécifie le chemin vers mon image dans mon ACR.
Si vous avez choisis un nom différent du mien, il faudra modifier le fichier.

## Déploiement via un fichier Yaml

Il est constitué d'une partie Deployment contenant :
- la description du ReplicaSet qui conditionne le nombre de pods actifs.
- la stratégie de rolling update pour les montée de versions.
- la configuration des conteneurs que nous déployons (image, ressources, port exposé)

Ainsi qu'une partie Service pour rendre accessible mes pods de l'extérieur au travers d'un Service de type LoadBalancer.

La commande à executer pour utiliser ce fichier et créer une instance de conteneur à partir de mon image est :

_kubectl apply -f .\deploytoaks.yaml_

En résultat vous devez obtenir ceci :

![Yaml Apply](media/18-apply.PNG)

Vérifions que ce nous avons déployé !

![Vérification du déploiement](media/19-check.PNG)

Je trouve normalement sur mon cluster un deployment qui execute un pod ainsi qu'un service pour exposer mon application.
Vous voyez également une ip externe à été affectée à mon service. Si vous la renseignez dans votre navigateur vous devriez retomber sur une interface connue.

![Vérification du service](media/20-checkservice.PNG)

Maintenant que notre application est déployée, telle que je l'ai demandé, on peux commencer à appréhender la puissance de Kubernetes. Si je demande la suppression de mon pod :

_kubectl delete pod idpod_

Grace au replicaset, un nouveau pod est automatiquement créé pour le remplacer.

![Création automatique d'un nouveau pod](media/21-checkdeployment.PNG)

--sep--
---
title: Azure Container Apps
---

Annoncé lors du Microsoft Ignite 2021 de début Novembre, un nouveau service fait son apparition (actuellement en preview) pour du déploiement de containers dans Azure !

Azure Container Apps !
https://docs.microsoft.com/fr-fr/azure/container-apps/overview

Je completerai cette section après avoir testé ce nouveau composant.

--sep--
---
title: Un peu de ménage !
---

# Un peu de ménage

Pour éviter les mauvaises surprises au niveau de la tarification, n'oubliez pas de supprimer vos ressources. 
Pour cela vous pouvez supprimer le groupe de ressource rg-workshop directement sur le portail Azure ou bien grace à cette commande :

_az group delete --name rg-workshop_

--sep--
---
title: Conclusion
---

# Conclusion

Bravo, vous avez fini le workshop !

En résumé, depuis notre application .Net 5 et son Dockerfile nous avons :

- Déployer notre image dans un Azure Container Registry
- Déployer notre application dans une Azure Container Instance
- Déployer notre application dans une Azure Web App
- Déployer notre application dans un cluster Kubernetes grâce à un fichier yaml.

Maintenant que nous avons une vue d'ensemble des services Azure utilisable pour executer un conteneur, voici un bilan des solutions pour savoir quand les utiliser :
- Stocker et gérer des images de conteneurs pour vos déploiements dans Azure --> ACR
- Exécuter facilement un conteneur par une simple commande --> ACI
- Déployer une application web conteneurisée dans Azure --> App services
- Gérer l’orchestration et la scalabilité de multiples applications --> Azure Kubernetes Services

## Pour aller plus loin

Pour mieux connaitre Azure Kubernetes Services, je vous invite à lire le workshop "Déployer votre premier cluster Kubernetes dans Azure"

## Crédit

Ce workshop a été créé par [Thomas Rannou](https://twitter.com/thomas_rannou) puis relu par [Olivier Leplus](https://twitter.com/olivierleplus) et [Yohan Lasorsa](https://twitter.com/sinedied). 
