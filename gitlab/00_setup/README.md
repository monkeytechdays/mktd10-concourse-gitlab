
Setup de l'infra
===

# Préparatifs

## Linux

Installer Docker.

## MacOS

Installer Docker Desktop

Editer `/etc/hosts` pour y modifier la ligne suivante:

    127.0.0.1 localhost gitlab.localhost root.gitlab-page.localhost gitlab-page.localhost

## Windows

Installer Docker.

Si Docker Desktop n'est pas supporté par le Windows utilisé, installer Docker Toolbox, basé sur VirtualBox. Puis configurer la machine virtuelle dédiée à Docker pour y ajouter des redirection de ports: 80, 5555, 4567, 4568

Editer `\WINDOWS\system32\drivers\etc\hosts` pour y modifier la ligne suivante:

    127.0.0.1 localhost gitlab.localhost root.gitlab-page.localhost gitlab-page.localhost


# Démarrer GitLab

Traefik va gérer l'exposition des services web de manière dynamique (pas besoin de le redémarrer en cas de changement de configuration ou redémarrage de GitLab).

Pour le démarrer, lancer le script:

    ./traefik

La page d'admin de Traefik sera disponible ici: http://localhost:8080. Vous pourrez y vérifier si Gitlab est recorrectement démarré et prêt à recevoir du traffic web.

Démarrer GitLab:

    ./gitlab

Attendre que GitLab s'auto-configure et soit disponible sur http://gitlab.localhost

Copier le ficher de configuration préparé et redémarrer gitlab:

    docker cp gitlab.rb gitlab:/etc/gitlab/gitlab.rb
    docker exec gitlab gitlab-ctl reconfigure

Attendre la fin de la configuration de GitLab, puis aller sur http://gitlab.localhost pour y créer le premier compte, le compte `root`.

# Démarrer des runners GitLab-CI

Les scripts frounis permettent de gérer autant de runner que souhaité. Il devra être juste donné à chaque runner un identifiant unique. Un nombre peut suffir comme identifiant unique.

Pour faire comminuqer un runner avec GitLab, un token doit être partagé. Pour trouver la valeur de ce token, allez sur la page de configuration des runners GitLab:

 - cliquez sur la clef à molette dans la barre du haut (`Admin Area`), puis dans `Overview` choisir `Runners`
 - ou aller directement ici: http://gitlab.localhost/admin/runners

Copier depuis cette page de configuration des runners le `registration token`.

Pour lancer l'enregistrement auprès de GitLab d'un runner avec l'identifiant unique `1`, lancez:

    ./register-runner 1

L'enregistrement demande des informations: y choisir les valeurs par défaut proposées, à part pour pour le token qui sera spécifique à votre installation.

Et pour lancer le runner, avec le même identifiant `1`:

    ./launch-runner 1

On pourra vérifier que GitLab a bien enregistrer ce nouveau runner sur la page de configuration des runners: http://gitlab.localhost/admin/runners

Ainsi si besoin d'un autre runner, il pourra être démarré avec:

    ./register-runner 2
    ./launch-runner 2

# Logs, stop, restart

Traefik, GitLab et les runners ont des containers nommés dans Docker, respectivement `traefik`, `gitlab`, et `gitlab-runner-${ID}`.

Voici les commandes utiles:

- pour voir la sortie standard: `docker logs $NAME`
- pour arrêter le service: `docker stop $NAME`
- pour arrêter le redémarrer: `docker restart $NAME`
