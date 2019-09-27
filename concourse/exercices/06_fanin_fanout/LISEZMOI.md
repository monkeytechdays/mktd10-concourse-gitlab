MKTD #10 - Concourse - 06 Fan-In / Fan-Out
===

## Présentation

La plupart des solutions de CI/CD ont une approche séquentielle. Lorsqu'un _build_ se déclenche il exécute séquentiellement des _stages_ (i.e. grandes étapes), chaque _stage_ pouvant exécuter des tâches en parallèle mais en fin de compte toutes les tâches doivent être complétées avant de terminer le _stage_ en cours et pouvoir passer au suivant.

Par son système de ressource, Concourse est beaucoup plus souple. Les jobs vont s'interconnecter par les ressources au rythme où elles sont consommées/produites. Ceci est rendu possible par la propriété `passed` de l'étape `get` :

```yaml
jobs:
  - name: prepare
    plan:
      - get: src
      - ...
      - put: meta

  - name: build
    plan:
      - in_parallel:
          - get: src
            passed: [prepare]
          - get: meta
            passed: [prepare]
```

_Note : Il est conseillé d'effectuer la récupération de plusieurs ressources en parallèle._

Ainsi configurer le _job_ `build` ne traitera que les **couples** de version des ressources `src` et `meta` qui ont été **conjointement** traités par le _job_ `prepare`.

Le principal intérêt est de pouvoir traiter les éléments au plus tôt, en parallèle mais de pouvoir converger. Prenons l'exemple d'un projet multi-module avec ce graphe de dépendance :

```
    + - B - - - E
    |
A - + - C - +
    |       | - F
    + - D - +
```

En considérant qu'il n'y a que deux étapes par module (compiler et tester), on peut soit compiler par niveau de profondeur (`A > B,C,D > E,F`), puis tout tester en parallèle ou bien tester et compiler au fur et à mesure que les dépendances sont rendues disponibles.

Enfin, la propriété `trigger` permet de déclencher un _job_ dès qu'une nouvelle version est disponible. Ce qui est particulièrement intéressant pour enchaîner les _jobs_ de manière automatique :

```yaml
jobs:
  - name: prepare
    plan:
      - get: src
      - ...
  - name: build
    plan:
      - get: src
        passed: [prepare]
        trigger: true
```

## Exercice 06a - Hierarchie de module

Implémentez le _pipeline_ correspondant au cas décrit précédemment (i.e. inutile de code de vrai projet, utilisez des `echo` et des `sleep`).

Pour rappel, voici la description des dépendances :

* `E` requiert `B`
* `F` requiert `C` et `D`
* `B` requiert `A`
* `C` requiert `A`
* `D` requiert `A`

## Exercice 06b - Application multi-tiers

Implémentez le _pipeline_ corresponsant aux spécifications suivantes :

* Dès qu'il y a un _commit_ sur `my-react-app`, générer une nouvelle livraison et lancer la validation (i.e. test unitaire / fonctionnel)
* Dès qu'il y a un _commit_ sur `my-spark-app`, générer une nouvelle livraison et lancer la validation (i.e. test unitaire / fonctionnel)
* Dès qu'il y a une livraison de `my-react-app` ou `my-spark-app`, générer une nouvelle livraison du bundle et lancer la validation  (i.e. test intégration)
* Dès qu'un bundle est entièrement validé (les deux applications + le bundle), générer une notification

_Note: les traitements (génération, validation, notification) peuvent être fictifs pour gagner du temps d'exécution._
