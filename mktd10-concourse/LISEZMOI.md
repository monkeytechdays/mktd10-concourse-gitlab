MKTD #10 - Concourse
===

Ceci est un projet [Docker Compose](https://docs.docker.com/compose/) permettant de déployer une mini [forge logicielle](https://fr.wikipedia.org/wiki/Forge_(informatique)).


Cette forge comprant différents services:

* [`gogs`](https://gogs.io/) : Gestionnaire/Hébergement de dépôts de sources ([Git](https://git-scm.com/))
* [`s3`](https://min.io/) : Stockage de fichiers compatible avec l'API d'[AWS S3](https://aws.amazon.com/fr/s3/)
* [`nexus`](https://fr.sonatype.com/product-nexus-repository) : Gestionnaire/Hébergement de dépôt de binaires ([NPM](https://www.npmjs.com/), [Maven](https://maven.apache.org/), [Docker](https://www.docker.com/products/image-registry), ...)
* ['vault`](https://www.vaultproject.io/) : Gestionnaire de secrets
* ['concourse`](https://concourse-ci.org/) : Outil de CI/CD


Un processus d'initialisation permet d'effectuer une première configuration des outils :

* `gogs` : Configuration l'outil afin de terminer le processus d'installation
* `s3` : Création du bucket (i.e. répertoire racine) S3 `/concourse`
* `vault` : Création du secret (i.e. répertoire racine) `/concourse` et du token `<CONCOURSE_VAULT_CLIENT_TOKEN>` pour le manipuler
* `nexus` : Création des dépôts locaux (pour le stockage des librairies) et proxy (pour mettre en cache) pour NPM et Docker


Certains éléments peuvent être personnalisés en modifiant le fichier `/.env`. Consulter les commentaires pour plus d'informations.
