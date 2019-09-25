MKTD #10 - Concourse - 00 Prise en main
===

Ceci n'est pas réellement un exercice mais sert de préambule pour configurer votre environnement de travail.

## Connection à l'interface Web

> Rappel des valeurs par défaut :
>
> * Lien : [`http://localhost:8080`](http://localhost:8080)
> * Utilisateur : `test`
> * Mot de passe : `test`

* Ouvrir l'interface Web de Concourse
* Cliquer sur le lien `login` dans le coin supérieur droit
* Renseigner les identifiants de connexion
* Cliquer sur le bouton `login`

Vous devriez être connecté. Par défaut, vous êtes rattachés à l'équipe `main` mais qui ne contient pas de _pipeline_.

## Connection avec la ligne de commande

> Rappel des valeurs par défaut :
>
> * Liens de téléchargement :
>     * Mac OS : [`http://localhost:8080/api/v1/cli?arch=amd64&platform=darwin`](http://localhost:8080/api/v1/cli?arch=amd64&platform=darwin)
>     * Windows : [`http://localhost:8080/api/v1/cli?arch=amd64&platform=windows`](http://localhost:8080/api/v1/cli?arch=amd64&platform=windows)
>     * Linux : [`http://localhost:8080/api/v1/cli?arch=amd64&platform=linux`](http://localhost:8080/api/v1/cli?arch=amd64&platform=linux)
> * Équipe : `main`
> * Mot de passe : `test`

Concourse vient avec un outil en ligne de commande nommé `fly`.

* Télécharger l'outil en ligne de commande soit depuis l'interface Web, soit depuis la ligne de commande
```bash
# Example
wget -o './fly' 'http://localhost:8080/api/v1/cli?arch=amd64&platform=linux'
```
* Ajouter les droits d'exécution (si nécessaire)
* Ajouter l'outil dans le `PATH`

Contrairement à d'autres outils en ligne de commande, `fly` ne mémorise pas de contexte implicitement. A chaque exécution, vous devez spécifier la _`target`_.

Pour ajouter/modifier une `target`, vous devez utilisez la commande `login` :

```bash
# Long format
fly --target 'local' login --concourse-url 'http://localhost:8080'

# Short format
fly -t 'local' login -c 'http://localhost:8080'
```

La commande étant interactive, il suffit de suivre les instructions. La solution la plus simple est d'ouvrir le lien fournit (ou d'ajouter l'option `-b`) qui permet de renseigner les idenfiants directement depuis le navigateur.

Pour lister les cibles déjà renseignées, il suffit d'exécuter la commande `targets`.

## Création d'un premier _pipeline_

Pour créer (ou mettre à jour) un _pipeline_, il faut utiliser la commande `set-pipeline` :

```bash
# Long format
fly --target 'local' set-pipeline --pipeline '00-getting-started' --config 'pipeline.yml'

# Short format
fly -t local sp -p 00-getting-started -c pipeline.yml
```

A chaque modification d'un _pipeline_, `fly` affiche un _diff_ qui résume les modifications. Si vous consultez à nouveau l'interface Web, celle-ci s'est mise à jour avec le nouveau _pipeline_.

Depuis la ligne de commande :

```bash
# Long format
fly --target 'local' jobs --pipeline '00-getting-started'

# Short format
fly -t local js -p 00-getting-started
```

## Execution d'un premier _pipeline_

Lorsqu'un _pipeline_ est créé, il est par défaut en pause. Il faut donc en premier lieu le rendre actif :

```bash
# Long format
fly --target 'local' unpause-pipeline --pipeline '00-getting-started'

# Short format
fly -t local up -p 00-getting-started
```

Puis il est possible de lancer l'exécution d'un _job_ :

```bash
# Long format
fly --target 'local' trigger-job --job '00-getting-started/greet' --watch

# Short format
fly -t local tj -j 00-getting-started/greet -w
```
