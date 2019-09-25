MKTD #10 - Concourse - 02 Input/Output
===

## Présentation

Toute la spécifité de Concourse réside dans son concept d'entrée/sortie. C'est ce qui permet d'établir un _pipeline_ sous la forme d'un véritable _workflow_. Mais avant de voir comment cela s'intègre dans un _pipeline_, intéressons nous au niveau de la tâche. Les entrées/sorties sont représentées par un **répertoire** au niveau de la tâche.

Une tâche DOIT déclarer ses entrées/sorties :

* `src/tasks/greet.yml`
```yaml
platform: linux
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/alpine
        tag: 3.10
        insecure_registries: [ "nexus:8083" ]

inputs:
  - name: src               # Mandatory.
  - name: recipient         # Mandatory.
    path: inputs/recipient  # Optional. Default to "name". Relative to Current Working Directory.
    optional: true          # Optional. Default to "false"

outputs:
  - name: message           # Mandatory.
    path: outputs/message   # Optional. Default to "name". Relative to CWD.

run:
    path: src/scripts/greet.sh
```

Pour exécuter la tâche, il faut spécifier les entrées via le paramètre `--input=NAME=PATH` et les sorties via `--output=NAME=PATH`. A noter que les entrées optionnels ou les sorties ne sont pas obligatoires. Cependant, préciser les sorties permet de vérifier le résultat plus facilement sans avoir à se connecter au conteneur.

```bash
# Long format
fly --target 'local' execute --config 'src/tasks/greet.yml' --input 'src=src' --output 'message=resources/message'

# Short format
fly -t local e -c src/tasks/greet.yml -i 'src=src' -o 'message=resources/message'
```

## Exercice 02a - Génération d'un projet Rust

* Réalisez une tâche qui génère un projet Rust dans une sortie
* Vérifiez en local ce qui a été généré

## Exercice 02b - Compilation d'un projet Rust

* Réalisez une tâche qui effectue la compilation du projet (e.g. `cargo build`) avec :
    * les sources générées précédemment en entrée
    * le résultat de compilation en sortie (fouillez le conteneur pour trouver où se trouve le binaire)
