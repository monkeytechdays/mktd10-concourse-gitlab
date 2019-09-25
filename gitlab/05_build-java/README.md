Exercice 5: Build Java
===

Le but de cet exercice est de builder un projet Java, avec cache et tests.

Dans cet exercice nous travaillerons avec le project `my-spark-app`.

# Importez le projet

Donc commencez par importer le projet dans GitLab. Suivez la même procédure que pour le projet `my-react-app` du premier exercice. 

# Un pipeline fonctionnel

Ensuite il vous faudra configurer la CI via le fichier `.gitlab-ci.yml`.

Nous voudrons ici avoir un pipeline en deux étapes: une étape de build, puis une étape de test. Il conviendra donc d'avoir deux jobs distincts.

Pour optimiser, nous voudrons aussi mettre en cache de Gitlab le cache de dépendances Java téléchargées par Maven.

Nous voudrons enfin publier le `.jar` buildé.

Pour information:
- voici la commande pour builder un jar: `mvn -Dskip.test=true package`
- la commande précédente produit un `.jar` dans le répertoire `target`.
- voici la commande pour faire passer les tests: `mvn verify`
- par défaut, Maven a son cache de dépendance dans le répertoire `.m2` du répertoire HOME de l'utilisateur

# Stages

Après avoir eu un pipeline fonctionnel, introduisez volontairement une erreur de compilation dans le code Java, et propagez cette modification dans le projet dans GitLab.

Les deux jobs, dédié au build et aux tests sont lancés et tous les deux sont alors en erreur.

Nous vondront alors éviter cette double erreur, et ne lancer les tests que si la compilation a réussi.

Pour cela, utilisez des `stage` (cf https://docs.gitlab.com/ee/ci/yaml/#stages).

# "Retry" de job

Un build peut dépendre de resources externes, de son environement d'exécution, comme par exemple une bonne connection Internet pour télécharger des dépendances.

Vous allons simuler cette incertitude en modifiant un test unitaire et le rendre dépendant d'un random.

Dans le fichier `src/test/java/io/monkeypatch/mktd10/MainTests.java` du projet, ajoutez le test suivant: 

```java
    @Test
    void testMonkey() {
        assertEquals("monkey", Math.random() > .5 ? "banana" : "monkey");
    }
```

Ajoutez aussi un autre `stage` de déploiement, qui devra s'exécuter après celui des tests. Pour l'instant, faites juste un job dont le script est un simple `echo "deploy!"`.

Committez, poussez, et après l'exécution du pipeline correspondant à ce nouveau code, vous pourrez relancer le job correspondant aux tests et voir les effets sur le reste du pipeline.

# Indices

- le nom d'une image Docker pour compiler avec Maven: `maven:3.6.2-jdk-8`
- la propriété Maven `maven.repo.local`
