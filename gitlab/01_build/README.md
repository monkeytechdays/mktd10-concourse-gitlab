Exercice 1: mon premier pipeline
===

Le but de cet exercice est de configurer un premier pipeline de build, qui vérifiera donc que le projet compile correctement.

# Importer le projet

Le projet à tester est `my-react-app`, une application web NodeJS/React (créée avec `react-create-app`)

Il vous faut donc dans un premier temps importer le code dans un projet GitLab. Créez pour cela un projet vide, puis laisser vous guider par les instructions pour importer le code.

# Créer une première config

Après avoir importé le projet, un build automatique dit `AutoDevOps` sera déclenché. Dans le cadre de ce MKTD, il n'est pas opérationnel. Ignorez donc ce build en erreur, vous pouvez aussi l'annuler avant sa fin.

Un pipeline de build sera donc à configurer. Il s'agit d'écrire un fichier `.gitlab-ci.yml` à la racine du projet, de le committer, et de le pousser.

Voici un exemple très simple d'un pipeline, composé d'un job `build`, qui lance un script, ici un Hello World.

```yaml
build:
  script:
    - echo "Hello world!"
``` 

# Construire l'application

Pour le projet `my-react-app`, deux commandes sont à exécuter pour construire la version statique de l'application:

- `npm install`
- `npm run build`

Et pour avoir un environement de build, l'image Docker `node:8.16.1-jessie` vous sera utile.

La documentation GitLab vous aidera à trouver comment écrire le fichier `.gitlab-ci.yml`:

- via le tutorial: https://docs.gitlab.com/ee/ci/quick_start/README.html#creating-a-simple-gitlab-ciyml-file
- via la référence du format du fichier: https://docs.gitlab.com/ee/ci/yaml/README.html
