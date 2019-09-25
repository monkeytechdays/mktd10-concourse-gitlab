MKTD #10 - GitLab
===

# Contenu

Dans ce répertoire, vous trouverez un premier répertoire, `00_setup` qui contient toutes les instruction et les scripts pour installer, configurer et gérer une installation en local de GitLab.

Puis vous trouver l'ensemble des exercices proposé, à suivre dans l'ordre des numéros de répertoire.

# Architecture réseau

La configuration proposée pour démarrer un GitLab en local est que tous les services soient démarrés dans des containers Docker. Ensuite, ces différents containers sont nommé, puis linké (`--link` de `docker`) entre eux pour des communications réseau entre eux (pas de `network`, les runners Gitlab n'y sont pas compatibles).

Et pour les containers dédiés à la CI, la socket du Docker de la machine hôte est montée. Ainsi, toute image de build peut communiquer avec le Docker de la machine hôte.
