MKTD #10 - Concourse - 03 Ressources
===

## Présentation

Précédemment, nous avons vu comment passer des entrées/sorties d'une tâche à une autre en se reposant parfois sur des scripts qui font eux-mêmes partis des entrées. Cela fonctionne bien en local car il est possible d'utiliser le système de fichiers. Cependant dans le cadre d'un _pipeline_ cela n'est pas possible car il est exécuté sur un agent Concourse.

Il est alors nécessaire d'utiliser une ressource externe qui va contenir les fichiers et dont on pourra se servir comme entrée.

Pour rappel le premier _pipeline_ se présentait comme suit:

```yaml
jobs:
  - name: ...
    plan:
      - task: ...
        config: ...
```

Un _job_ représente à la fois une unité (i.e. boîte) du _pipeline_ dans l'interface graphique mais aussi une unité d'exécution pour l'agent Concourse. En effet, un _build_ (exécution d'un _job_) est affecté à un agent qui aura en charge d'en exécuter tout le contenu et assurant ainsi la disponibilité des entrées/sorties qui seront stockées sous forme de volumes.

Pour consulter les _builds_ et les _volumes_, il faut utiliser les commandes suivantes :

```bash
# Long format
fly --target 'local' builds
fly --target 'local' volumes

# Short format
fly -t local bs
fly -t local vs
```

Les [ressources](https://concourse-ci.org/resources.html) sont un deuxième type d'objet de premier niveau. Elles sont au coeur du système de Concourse. Dans sa version actuelle, une ressource Concourse représente un élément externe et est constitué d'une séquence continue de version. Lorsque l'on manipule une ressource, c'est en réalité une version bien spécifique qui est traitée.

Il existe [différents types de ressource](https://github.com/concourse/concourse/wiki/Resource-Types) (liste non-exhaustive) :

* [`git`](https://github.com/concourse/git-resource)
* [`s3`](https://github.com/concourse/s3-resource)
* [`semver`](https://github.com/concourse/semver-resource)

Par convention, elles sont déclarées AVANT les _jobs_ :

 ```yaml
resources:
  - name: project
    type: git
    icon: git        # from https://materialdesignicons.com/
    check_every: 10s # Default to 1m
    source:
        uri: http://gogs:10080/mktd10-concourse/03-resource-demo.git
        branch: master

jobs:
  - name: ...
    plan: ...
 ```

Les propriétés `name` et `type` sont obligatoires et le contenu de `source` est optionnel et spécifique à chaque type de ressource.

Pour récupérer une ressource, il faut utiliser l'étape `get` :

```yaml
jobs:
  - name: checkout
    plan:
      - get: src           # Mandatory. Directory name to access resource
        resource: project  # Optional. Resource name to fetch. Default to "get" value.
```

Il également possible de "pousser" une ressource avec l'étape `put` :

```yaml
resources:
  - name: messages
    type: s3
    icon: folder-open
    check_every: 1h
    source:
        endpoint: http://s3:9000
        disable_ssl: true
        bucket: concourse
        regexp: 03-resource/demo/message-(.*).txt
        access_key_id: minio-access-key
        secret_access_key: minio-secret-key

jobs:
  - name: generate-message
    plan:
      - task: write-message
        file: src/ci/tasks/write-message.yml
      - put: messages
        params:
            file: messages/message-*.txt
```

Enfin, notez qu'il est possible d'utiliser des noms différents entre les entrées/sorties d'une tâche et les ressources utilisées. Pour cela au niveau de l'étape `task` du _pipeline_, il utiliser les propriétés `input_mapping`/`output_mapping` qui sont des dictionnaires sont les clés sont les noms utilisés par la tâche et les valeurs les noms utilisés par le _pipeline_.

```yaml
jobs:
  - name: process-recipients-1-to-3
    plan:
      - get: recipient-1
      - task: process-recipient
        input_mapping:
            recipient: recipient-1
      - get: recipient-2
      - task: process-recipient
        input_mapping:
            recipient: recipient-2

```

## Exercice 03a - Premier pipeline Rust

* Créez un dépôt sous Gogs (http://localhost:10080) pour stocker les scripts et les tâches
* Réalisez un _pipeline_ qui :
    * génère deux projets Rust
    * compile les deux projets Rust
    * transfert chaque binaire sous S3

Note : réutilisez les mêmes tâches pour les deux projets
