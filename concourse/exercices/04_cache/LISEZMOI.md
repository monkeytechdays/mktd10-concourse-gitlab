MKTD #10 - Concourse - 04 Cache
===

## Présentation

Pour optimiser le temps de traitement d'un _pipeline_ la gestion des dépendances est très importante. Les premiers éléments à intégrer dans une forge pour y parvenir sont des dépôts miroirs/proxys. Par exemple, il est possible d'utiliser les solutions [Nexus](https://fr.sonatype.com/product-nexus-repository) (comme ici) ou [Artifactory](https://jfrog.com/artifactory/). La configuration de miroir peut être plus ou moins complexe selon les outils.

Pour rappel, l'exemple de Docker a déjà été traité :

```yaml
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/rust
        tag: 1.37.0-stretch
        insecure_registries: [ "nexus:8083" ]
```

Pour NPM, il suffit de définir la variable d'environnement `NPM_CONFIG_REGISTRY`

```yaml
platform: linux
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/node
        tag: 10.16.3-stretch
        insecure_registries: [ "nexus:8083" ]

inputs:
  - name: src

run:
    path: npm
    args: ["install"]
    dir: src

params:
    NPM_CONFIG_REGISTRY: http://nexus:8081/repository/npm-all/
```

Pour Maven les choses sont plus complexes. Les miroirs doivent être définis dans un fichier de configuration et le fichier doit être spécifié sur la ligne de commande :

* `settings.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

    <mirrors>

        <mirror>
            <id>mktd10-concourse</id>
            <mirrorOf>central</mirrorOf>
            <name>Local Nexus</name>
            <url>http://nexus:8081/repository/maven-public/</url>
        </mirror>

    </mirrors>
</settings>
```

* `build.sh`
```bash
function mvn() {
    /usr/bin/mvn -s 'maven-settings.xml' "$@"
}
```

Cependant, pour certains cas cela peut ne pas être suffisant. La première alternative est de partager un répertoire de dépendances d'une tâche à une autre. Cependant cela n'est valable que pour l'exécution d'un build.

Concourse possède également une fonctionnalité de [`cache`](https://concourse-ci.org/tasks.html#task-caches) :

```yaml
platform: linux
image_resource:
    type: docker-image
    source:
        repository: nexus:8083/alpine
        tag: 3.10
        insecure_registries: [ "nexus:8083" ]

inputs:
  - name: src
outputs:
  - name: shared

run:
    path: 'ash'
    args: ["-c","date >> cache/dates.txt && cp -r cache/* shared/"]

caches:
  - path: cache
```

Cependant le cache est relatif à l'agent, au nom du job et au nom de la tâche. Ce qui utile si une tâche est dédiée à la récupération des dépendances.

## Exercice 04a - Partage des dépendances Node.js

En Node.js, les dépendances sont installées à la racine du projet dans un répertoire `node_modules`. Pour les récupérer, il faut préalablement exécuté la commande `npm install`.

* Réalisez un _pipeline_ qui :
    * récupère les sources du projet Node.js (voir `/projects/my-react-app`)
    * récupère les dépendances Node.js
    * construit l'application (`npm run build`) avec les dépendances récupérées précédemment
    * exécute les tests (`npm test`) avec les dépendances récupérées précédemment

## Exercice 04b - Cache des dépendances Maven

Avec Maven, les dépendances sont installées sous `$HOME/.m2/repository` afin d'être partagées entre différents projets. Elles sont normalement récupérées au fur et à mesure qu'elles sont nécessaires mais il est possible d'utiliser la commande `mvn dependency:go-offline`

* Réalisez un _pipeline_ qui :
    * récupère les sources du projet Maven (voir `/projects/my-spark-app`)
    * récupère les dépendances Maven (et les met en cache)
    * construit l'application (`mvn package -Dmaven.test.skip=true`) avec les dépendances récupérées précédemment
    * exécute les tests (`mvn test`) avec les dépendances récupérées précédemment

Note: vérifiez que les dépendances ne sont pas récupérées à chaque _build_. Essayez également de changer les dépendances (en ajouter ou modifier les versions) pour observer le comportement.
