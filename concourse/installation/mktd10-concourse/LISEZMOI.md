MKTD #10 - Concourse
===

# Présentation

Ceci est un projet [Docker Compose](https://docs.docker.com/compose/) permettant de déployer une mini [forge logicielle](https://fr.wikipedia.org/wiki/Forge_(informatique)).


Cette forge comprend différents services :

* [`gogs`](https://gogs.io/) : Gestionnaire/Hébergement de dépôts de sources ([Git](https://git-scm.com/))
* [`s3`](https://min.io/) : Stockage de fichiers compatible avec l'API d'[AWS S3](https://aws.amazon.com/fr/s3/)
* [`nexus`](https://fr.sonatype.com/product-nexus-repository) : Gestionnaire/Hébergement de dépôt de binaires ([NPM](https://www.npmjs.com/), [Maven](https://maven.apache.org/), [Docker](https://www.docker.com/products/image-registry), ...)
* [`vault`](https://www.vaultproject.io/) : Gestionnaire de secrets
* [`concourse`](https://concourse-ci.org/) : Outil de CI/CD


Un processus d'initialisation permet d'effectuer une première configuration des outils :

* `gogs` : Configuration l'outil afin de terminer le processus d'installation
* `s3` : Création du bucket (i.e. répertoire racine) S3 `/concourse`
* `vault` : Création du secret (i.e. répertoire racine) `/concourse` et du token `<CONCOURSE_VAULT_CLIENT_TOKEN>` pour le manipuler
* `nexus` : Création des dépôts locaux (pour le stockage des librairies) et proxy (pour mettre en cache) pour NPM et Docker


Certains éléments peuvent être personnalisés en modifiant le fichier `/.env`. Consultez les commentaires pour plus d'informations.

Les services sont exposés en local afin d'être accessible depuis la machine :

* `gogs`
    * Web UI : http://localhost:10080
    * SSH : ssh://localhost:10022
    * Nom d'utilisateur : `root`
    * Mot de passe : `root`
* `s3`
    * Web UI : http://localhost:9000
    * Access Key : `minio-access-key` (par défaut)
    * Secret Key : `minio-secret-key` (par défaut)
* `nexus`
    * Web UI : http://localhost:8081
    * Docker registry (internal, write) : http://localhost:8082
    * Docker registry (proxy, read) : http://localhost:8083
    * Username : `admin`
    * Password : (voir logs du service `init`)
* `vault`
    * Web UI : http://localhost:8200
    * Token (Root) : `vault-root-token` (par défaut)
    * Token (Concourse) : `concourse-vault-token` (par défaut)
* `concourse`
    * Web UI : http://localhost:8080
    * Username : `test` (par défaut)
    * Password : `test` (par défaut)

# Installation

Pour démarrer la forge, il suffit d'utiliser la commande `docker-compose up --build -d`.

Afin de valider que tout est bien initialisé, vous pouvez consulter les logs du service `init`: `docker-compose logs -f init`

# Suppression

Pour supprimer complètement la forge, il suffit d'utiliser la commande `docker-compose down --remove-orphans --rmi local --volumes`.
