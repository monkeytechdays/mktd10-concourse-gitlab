
# Exercice 2: Publication du build

Le but de cet exercice est de publier des `artifacts`, pour pouvoir ensuite les archiver et les télécharger à la demande depuis l'interface de Gitlab.

Toujours avec l'application `my-react-app`, dont nous avons vérifier qu'elle build correctement à l'exercice précédent, nous allons publier le répertoire `build`. 

Ce répertoire `build` pourra ensuite être téléchargé et déployé dans un server web.

Pour tester le déploiement:

- téléchargez l'archive de build,
- la décompresser,
- utilisez le script fourni pour cet exercice: `./node-server <chemin vers l'archive décompressée>`
- ouvrez un navigateur à l'url: http://localhost:5000/

Pour résoudre cet exercice, indices pour chez vous:

- la documentation: https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html
- le mot clef `artifacts`: https://docs.gitlab.com/ee/ci/yaml/README.html#artifacts
