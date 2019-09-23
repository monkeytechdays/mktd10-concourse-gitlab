import org.sonatype.nexus.blobstore.api.BlobStoreManager

if (!repository.repositoryManager.exists('docker-internal')) {
    log.info('Create "docker-internal" repository')
    repository.createDockerHosted('docker-internal', 8082, null)
}

if (!repository.repositoryManager.exists('docker-hub')) {
    log.info('Create "docker-internal" repository')
    repository.createDockerProxy(
        'docker-hub',                   // name
        'https://registry-1.docker.io', // remoteUrl
        'HUB',                          // indexType
        null,                           // indexUrl
        null,                           // httpPort
        null,                           // httpsPort
        BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName
        true, // strictContentTypeValidation
        true  // v1Enabled
    )
}


if (!repository.repositoryManager.exists('docker-all')) {
    def groupMembers = ['docker-hub', 'docker-internal']
    repository.createDockerGroup('docker-all', 8083, null, groupMembers, true)
}

"Repositories: [docker-internal, docker-hub, docker-all]"
