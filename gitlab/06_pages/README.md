Exercice 6: Publier un site
===

Le but de cet exercice est de publier des pages html pour les faire servir par GitLab.

Cette fonctionnalité a été prévu essentiellement pour la publication de site web via la génération de site static. Nous allons ici publier le site généré par Maven.

Quelques informations utiles:

- la commande pour générer le site par Maven est: `mvn site`
- le site sera construit dans le répertoire `target/site`.

Vous pourrez vérifier que le site est correctement généré dans la page de `Settings` > `Pages` du projet. Vous y trouverez le lien vers le site web généré.

Pour résoudre cet exercice, indices chez vous:

- la documentation: https://docs.gitlab.com/ee/user/project/pages/
- le mot clef `pages`: https://docs.gitlab.com/ee/ci/yaml/README.html#pages
