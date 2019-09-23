import org.sonatype.nexus.blobstore.api.BlobStoreManager

if (!repository.repositoryManager.exists('npm-internal')) {
    log.info('Create "npm-internal" repository')
    repository.createNpmHosted('npm-internal')
}

if (!repository.repositoryManager.exists('npmjs-org')) {
    log.info('Create "npmjs-org" repository')
    repository.createNpmProxy('npmjs-org', 'https://registry.npmjs.org')
}


if (!repository.repositoryManager.exists('npm-all')) {
    def groupMembers = ['npmjs-org', 'npm-internal']
    repository.createNpmGroup('npm-all', groupMembers)
}

"Repositories: [npm-internal, npmjs-org, npm-all]"
