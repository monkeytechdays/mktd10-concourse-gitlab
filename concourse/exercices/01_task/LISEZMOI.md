MKTD #10 - Concourse - 01 Tâche
===

## Présentation

Dans Concourse la plus petite unité d'exécution est la [tâche](https://concourse-ci.org/tasks.html#task-run). Une tâche peut-être décrite directement dans le _pipeline_ ou dans un fichier :

```yml
platform: linux
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/<docker-image-name>
        tag: <docker-image-tag>
        insecure_registries: [ "nexus:8083" ]
run:
    path: <command-to-execute>
    args: [<command-arguments>]
params: <environment-variables>
```

L'avantage d'utiliser des fichiers pour les tâches, c'est que contrairement à la plupart des autres solutions, il n'est pas nécessaire d'instancier et d'exécuter le _pipeline_. Finit les _commits_ à répétition pour déveloper le _pipeline_ :

```bash
# Long format
fly --target 'local' execute --config 'echo-helloworld.yml'

# Short format
fly -t local e -c echo-helloworld.yml
```

Il arrive que différentes tâchent ne varient que de quelques éléments. Pour cela, il est possible de variabiliser la tâche avec la syntaxe `((variable))`.

Dans un pipeline, il faut utiliser la propriété `vars` (**NOTE: la propriété `params` permet de définir des variables d'environnement mais pas des variables !**) :

* `pipeline.yaml`
```yaml
jobs:
  - name: greet
    plan:
      - task: Hello World
        file: src/ci/tasks/echo.yml
        vars:
            message: "Hello World!"
```
* `/ci/tasks/echo.yml`
```yaml
platform: linux
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/alpine
        tag: 3.10
        insecure_registries: [ "nexus:8083" ]
run:
    path: echo
    args: ["((message))"]
```

Depuis la ligne de commande, il faut utiliser l'un des paramètres (`--var=[NAME=STRING]`, `--yaml-var=[NAME=YAML]`, `--load-vars-from=[YAML-FILE]`) :

```yaml
# Long format
fly --target 'local' execute --config 'echo.yml' '--var=message=Hello World !'
fly --target 'local' execute --config 'echo.yml' '--yaml-var=message="Hello World !"'
fly --target 'local' execute --config 'echo.yml' '--load-vars-from=var-helloworld.yml'

# Short format
fly -t local e -c echo.yml -v 'message=Hello World !'
fly -t local e -c echo.yml -y 'message="Hello World !"'
fly -t local e -c echo.yml -l 'var-helloworld.yml'
```

Chaque tâche s'exécute dans un conteneur. Il est possible de lister les conteneurs à l'aide de la commande `containers` :

```bash
# Long format
fly --target 'local' containers

# Short format
fly -t local cs
```

Il est également possible de déboguer un conteneur d'une tâche en cours d'exécution ou même terminée avec la commande `hijack` :

```bash
# Long format
fly --target 'local' hijack --handle '1234567-abcd-1234-abcd-123456789012'

# Short format
fly -t 'local' i --handle '1234567-abcd-1234-abcd-123456789012'
```

## Exercice 01a - Génération d'un projet Rust

1. Réalisez une tâche qui permet d'initialiser un projet Rust. Vous pouvez utiliser [l'image Docker officielle](https://hub.docker.com/_/rust). Pour initialiser un nouveau projet, il faut utiliser [`cargo`](https://doc.rust-lang.org/book/ch01-03-hello-cargo.html#creating-a-project-with-cargo).
2. Connectez-vous au conteneur pour parcourir l'arborescence du projet.

## Exercice 01b - Nom de projet dynamique

1. Reprenez la tâche écrite précédemment pour rendre variable le nom du projet.
2. Connectez-vous au conteneur pour vérifier que le nom a bien été pris en compte.
