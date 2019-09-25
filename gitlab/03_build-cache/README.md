Exercice 3: Optimisation via du cache
===

Le but de cet exercice est de raccourcir le temps de build en mettant du cache sur les dépendances téléchargées.

Une application construite avec `npm` va faire télécharger ses dépendances dans un dossier `node_modules` à la racine du projet.

Il s'agit ici d'éviter d'avoir à télécharger depuis internet l'ensemble de ces dépendances à chaque build.

Vous pourrez estimer l'efficacité de l'optimisation en regardant les temps d'éxécution des pipelines.

Pour résoudre cet exercice, indices chez vous:

- la documentation: https://docs.gitlab.com/ee/ci/caching/
- le mot clef `cache`: https://docs.gitlab.com/ee/ci/yaml/README.html#cache
