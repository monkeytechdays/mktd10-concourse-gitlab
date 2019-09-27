MKTD #10 - Concourse - 05 Version
===

## Présentation

Concourse (et ses ressources) sont fondés sur le principe de flux continue (`1 -> 2 -> 3 -> 4`). Ceci peut sembler contre intuitif par rapport à l'organisation des versions en arbre comme on peut en avoir l'habitude mais beaucoup plus proche d'une logique de livraison et déploiement en continue.

Pour faciliter la gestion de version (et son flux), Concourse dispose de la ressource [`semver`](https://github.com/concourse/semver-resource). Le principe est de stocker le numéro de version dans un dépôt (Git, S3, ...) et d'exploiter (lecture/écriture) celui-ci durant l'exécution du pipeline :

```yaml
resources:
  - name: version
    type: semver
    source:
        initial_version: 1.0.0-rc.0
        driver: s3
        bucket: concourse
        key: 05_version/demo/version.txt
        endpoint: http://s3:9000
        disable_ssl: true
        access_key_id: minio-access-key
        secret_access_key: minio-secret-key

jobs:
  - name: read-version
    plan:
      - get: version
      - task: print
        config:
            platform: linux
            image_resource:
                type: docker-image
                source:
                    repository: nexus:8083/alpine
                    tag: 3.10
                    insecure_registries: [ "nexus:8083" ]
            inputs:
              - name: version
            run:
                path: cat
                args: ["version/version"]
```

Les propriétés `bump` et `pre` permettent de modifier le numéro de version soit après la lecture (`get`), soit avant l'écriture (`put`) :

```yaml
jobs:
  - name: new-rc
    plan:
      - put: version
        pre: rc
  - name: prepare-release
    plan:
      - get: version
        bump: major
```

Une fois la stratégie de version mise au point, la difficulté reste de la répercutée sur les différents outils. Voici quelques exemples :

```bash
# Maven
mvn versions:set "-DnewVersion=$(cat version/version)"

# NPM
npm  --no-git-tag-version version "$(cat version/version)"

# Rust (https://crates.io/crates/cargo-bump)
cargo bump "$(cat version/version)"
```

## Exercice 05a - Livraison continue

A partir des projets `my-react-app` et `my-spark-app`, réalisez un _pipeline_ qui pour chaque commit :

* augmente le numéro de version
* change le numéro de version du projet
* construit le projet
* joue les tests
* publie les résultats sous S3 ou Nexus

## Exercice 05b - Cycle de vie

Sur la base de l'exercice précédent, réalisez un _pipeline_ qui :

* pour chaque commit, livre une version `rc`
* à la demande, génère une nouvelle version finale

_Attention : après une nouvelle version finale, la prochaine rc ne doit plus corresponde à la version déjà livrée !_
