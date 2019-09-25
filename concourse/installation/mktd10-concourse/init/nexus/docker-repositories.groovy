import org.sonatype.nexus.security.internal.RealmManagerImpl
import org.sonatype.nexus.blobstore.api.BlobStoreManager

def realmManager = container.lookup(RealmManagerImpl.class.getName())

realmManager.enableRealm('DockerToken', true)

if (!repository.repositoryManager.exists('docker-internal')) {
    log.info('Create "docker-internal" repository')
    repository.createDockerHosted(
        'docker-internal',  // name
        8082,               // httpPort
        null                // httpsPort
    )
}

if (!repository.repositoryManager.exists('docker-hub')) {
    log.info('Create "docker-internal" repository')
    repository.createDockerProxy(
        'docker-hub',                   // name
        'https://registry-1.docker.io', // remoteUrl
        'HUB',                          // indexType
        null,                           // indexUrl
        null,                           // httpPort
        null                            // httpsPort
    )
}


if (!repository.repositoryManager.exists('docker-all')) {
    def groupMembers = ['docker-hub', 'docker-internal']
    repository.createDockerGroup(
        'docker-all',                            // name
        8083,                                    // httpPort
        null,                                    // httpsPort
        groupMembers,                            // members
        true,                                    // v1Enabled
        BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName
        false                                    // forceBasicAuth
    )
}

"Repositories: [docker-internal, docker-hub, docker-all]"
