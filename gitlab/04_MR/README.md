Exercice 4: CI et Merge Requests
===

Le but de cet exercice est de pratiquer de la CI dans le contexte de Merge Request (MR).

Une MR est une branche que l'on veut merger dans une autre, et d'avoir un processus de validation autour de ce merge, via de la CI et de la revue par un pair.

Nous continuerons dans cet exercice à travailler avec le project `my-react-app`.

## Créer une MR

Commencez par créer une branche Git à partir de `master` et d'y pousser un commit.

Exemple de commandes:

```shell script
git checkout -b my-feature-1
-- EDITER UN FICHIER, PAR EXEMPLE src/App.js --
git add .
git commit -m 'Implement the feature #1'
git push --set-upstream origin my-feature-1
```

Vous pourrez ensuite vérifier que la branche `my-feature-1` est bien récupérée et buildée par la CI.

Et vous pouvez ensuite créer la MR dans l'interface de GitLab. Et dans la page dédiée à cette MR nouvellement créé, le status du pipeline associé.

## Créer une divergence

Afin de vérifier la gestion des MR, créons une divergence entre la branche `master` et la branche de la MR.

Exemple de commandes:

```shell script
git checkout master
-- EDITER UN FICHIER, PAR EXEMPLE src/App.js, EN ESSAYENT DE NE PAS CREER DE CONFLIT DE MERGE --
git add .
git commit -m 'Some fix'
git push
```

Vérifiez ensuite qu'un pipeline est bien lancé pour ce nouveau commit sur `master`.

Vous pouvez vous apercevoir aussi qu'aucun nouveau pipeline n'est lancé à propos de la MR. En l'état, le CI ne vérifie que l'état de la branche, pas le futur état de la branche une fois mergée dans `master`.

C'est une limitation à prendre en compte, limitation levée dans la version Enterprise: https://docs.gitlab.com/ee/ci/merge_request_pipelines/pipelines_for_merged_results/index.html

## Expérimentez

Vous pouvez prendre un peu de temps pour expérimenter les fonctionnalités autour des MR.

Par exemple, créez des commentaires sur le code qui est proposé d'être changé (cf onglet "Changes").

Un système de vote est disponible via des emoticones de pouces (des workflows plus avancés sont disponibles en version Entreprise: https://gitlab.com/help/user/project/merge_requests/merge_request_approvals.html)

Plus d'options sont disponibles autour des MR dans la configuration du projet sous: `Settings` > `General` > `Merge requests`.
