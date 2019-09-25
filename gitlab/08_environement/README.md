Exercice 8: Déployer dans différent environements
===

Le but de cet exercice est de déployer des applications dans différents environements.

Toujours avec le projet `my-spark-app`, l'image Docker buildée précédement va être lancée dans Docker. On symbolisera les différents environements de déploiement par l'écoute sur des ports différents.

Une fois que vous aurez configuré le `.gitlab-ci.yml`, vous pourrez trouver la gestion des environements dans GitLab sous `Operations` > `Environments` du projet.

Pour résoudre cet exercice, indices chez vous:

- la documentation: https://docs.gitlab.com/ee/ci/environments.html
- le mot clef `environment`: https://docs.gitlab.com/ee/ci/yaml/README.html#environment
