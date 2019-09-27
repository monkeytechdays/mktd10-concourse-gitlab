MKTD #10 - Concourse - 07 Variables
===

## Présentation

Précédemment, il a été montré qu'il est possible de variabiliser les tâches à l'aide de la syntaxe `((ma-variable))`. La même syntaxe peut également être appliquée sur le _pipeline_ :

```yaml
resources:
  - name: src
    type: git
    source:
        uri: http://localhost:10080/mktd10-concourse/((project)).git
        branch: master
  - name: bin
    type: s3
    source:
        endpoint: http://s3:9000
        disable_ssl: true
        bucket: concourse
        regexp: binaries/((project))/((project))-(.*).zip
        access_key_id: minio-access-key
        secret_access_key: minio-secret-key
```

Le _pipeline_ peut ainsi être plus facilement partagé (i.e. mise en commun) entre différentes équipes/projets.

Pour résoudre ces valeurs, il existe deux sources de données. La première est lors de l'enregistrement du _pipeline_ via les options `--var=[NAME=STRING]`, `--yaml-var=[NAME=YAML]` et `--load-vars-from⁼[PATH]` :

```bash
# Long format
fly --target 'local' set-pipeline --pipeline '07-variable-demo' --config 'pipeline.yml' --var 'project=07-variable-demo'
fly --target 'local' set-pipeline --pipeline '07-variable-demo' --config 'pipeline.yml' --yaml-var 'project="07-variable-demo"'
fly --target 'local' set-pipeline --pipeline '07-variable-demo' --config 'pipeline.yml' --load-vars-from './variables.yaml'

# Short format
fly -t local  sp --p '07-variable-demo' -c 'pipeline.yml' -v 'project=07-variable-demo'
fly -t local  sp --p '07-variable-demo' -c 'pipeline.yml' -y 'project="07-variable-demo"'
fly -t local  sp --p '07-variable-demo' -c 'pipeline.yml' -l './variables.yaml'
```

L'autre source de données est [le gestionnaire de secret](https://concourse-ci.org/creds.html) (e.g. Vault dans le cas présent). Dans le cadre de Vault, il cherche la valeur dans l'un des secrets suivant l'ordre :

* `/concourse/<TEAM>/<PIPELINE>/<VARIABLE>`
* `/concourse/<TEAM>/<VARIABLE>`

Chaque secret étant composé de paires clé-valeur, si la variable ne contient pas de séparateur (`.`), c'est la clé `value` qui sera utilisée. Autrement, le premier niveau sera utilisé pour localiser le secret, puis la(es) propriété(s) correspondantes du secret seront lues.

Certaines variables pouvant être fournies sur la ligne de commande ou bien via un gestionnaire de secret, il est recommandé d'utiliser l'option `--check-creds` qui permet de valider le _pipeline_.

## Exercice 07a - Auto-update

Jusqu'à maintenant des tâches relativement génériques ont été utilisées et avec l'introduction des variables au niveau _pipeline_, il est désormais possible de généraliser et de partager entre plusieurs projets les différents éléments d'un _pipeline_.

Il existe également une ressource [`concourse-pipeline`](https://github.com/concourse/concourse-pipeline-resource) qui permet de mettre à jour un _pipeline_.

Réalisez l'ensemble des éléments qui permettent de partager en configuration tous les éléments du _pipeline_ et qui permettent de mettre à jour automatiquement le _pipeline_ dès que le projet Git commun est modifié.
