Exercice 7: Build d'une image Docker
===

Le but de cet exercice est de réussir le build d'une image Docker et de la publier dans le registry du projet.

L'image Docker à construire devra contenir l'application web Java, et servira a démarrer l'application web sur un port particulier.

Vous aurez besoin de la commande complète pour démarrer l'application Java:

    java -cp JAR_FILES io.monkeypatch.mktd10.Main

Ainsi l'application Java écoutera ensuite sur le port `4567`.

Une fois l'image contruite, il faudra la publier auprès du registry du projet. Vous trouverez la page dédiée dans GitLab dans `Packages` > `Container Registry`. Vous y trouverez notemment des lignes de commande d'exemple pour construire et y publier une image Docker.

Et pour vérifier la bonne execution du pipeline, vous pourrez démarrer dans votre shell favori un container avec l'image provenant du registry du projet, et vérifier le contenu retourné à l'url http://localhost:4567/hello

Pour résoudre cet exercice, indices chez vous:

- une image docker pour builder une image Docker: `docker:19.03.2-dind`
- une image Docker Java: `openjdk:8u222-jdk`
- une commande pour télécharger tous les jars nécessaire au runtime: `mvn dependency:copy-dependencies -DincludeScope=runtime`. L'ensemble des jars se trouvera alors dans le répertoire `target/dependency`.
- la ligne de commande `java` sait interpréter un classpath sous forme `dir/*`: tous les fichiers du répertoire `dir` seront ajoutés au classpath
- des variables seront utiles pour se connecter au registry Docker du projet via `docker login`: https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
