node {
    
    /* 
        Definieer een object variable voor de container 
        Hiermee kan je de instantie opslaan in het object en zo functies uitvoeren over dat object, zoals het pushen van de image.
    */
    def container
    
    /* 
        De pipeline begint altijd met een gitlab event (webhook) richting Jenkins.
        De webhook triggert de Job.
        De Job checkt de repository uit, d.m.v. 'checkout scm', de repository dat uitgeckeckt wordt staat geconfigureerd in de Job.
        Standaard slaan we de short en long hash van de laatste commit op voor traceerbaarheid.
    */
    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */
        checkout scm
        shortCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
        longCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()

    }
    /* 
        De image bouwen, in de repository moet er uiteraard een Dockerfile aanwezig zijn om de image te kunnen bouwen.
        Het gebouwde image wordt opgeslagen in het object 'container', hiermee pushen we later de image naar de private registry.
    */
    stage('Build image') {
        container = docker.build("library/centos7-karaf-sba")
        println " -> Generated image; " + container.id
    }
    
    /*
        Deze regel slaat het resultaat op van een functie onderaan de script. De functie leest de vesie nummer uit de pm.xml file.
    */
    releasedVersion = getReleasedVersion()

    /*
        Met het object dat we eerder hebben aangemaakt kunnen we nu de image pushen naar de registry.
        We taggen de image met een aantal belangrijke informatie:
            - Katello Content View
            - Jenkins Build nummer
            - Git Hash Commit
            - Versie nummer van de software (uit pom.xml gelezen)
    */
    stage('Push image') {
        CONTENT_VIEW_VERSION = sh (
            script: 'docker inspect hub.rinis.cloud/library/centos7:latest | jq -r \'.[0].Config.Labels["katello_content_view_version"]\'',
            returnStdout: true
        ).trim()
        echo "Katello Content View Version: ${CONTENT_VIEW_VERSION}"
        imageTag = "kcv-${CONTENT_VIEW_VERSION}_build-${env.BUILD_NUMBER}_git-${shortCommit}_v-${releasedVersion}"
        echo "Image Tag : ${imageTag}"

        docker.withRegistry('https://hub.rinis.cloud', 'docker-hub-credentials') {
            container.push("${imageTag}")
        }
    }
    /*
        Met ook een deployment.yaml bestand kunnen we de image deployen naar Kubernetes.
        Voordat we dat doen moeten we eerst de tag van de image aanpassen in deployment.yaml.
    */
    stage('Update Kubernetes Deployment file') {
        
        // Change tagname in deployment.yaml
        sh "sed -i 's/latest/${imageTag}/g' deployment.yaml"
        // - Check if changes were effective.
        def IMG_NAME = sh(script: 'grep image deployment.yaml', returnStdout: true)
        echo "IMG_NAME: ${IMG_NAME}"
    }

    /*
        Nu de image gebouwd is en de deployment.yaml is geprepareerd kunnen we de image deployen naar Kubernetes.
        Hiervoor is wel een kubeconfig nodig op de Jenkins Server waar we de Pipeline Job uitvoeren
    */
    stage('Apply Kubernetes files') {
        def IMG_DEPLOYED = sh(script: 'kubectl apply -f deployment.yaml', returnStdout: true)
        echo "Deployment succesful? > ${IMG_DEPLOYED}"

    }
}

/* Functie om de versie uit de pom.xml te extraheren. */
def getReleasedVersion() {
    return (readFile('source/pom.xml') =~ '<version>(.+)</version>')[0][1]
}

/*
    Functie om de controleren of de container draait. 
*/
def curlRun (url, out) {
    echo "Running curl on ${url}"

    script {
        if (out.equals('')) {
            out = 'http_code'
        }
        echo "Getting ${out}"
            def result = sh (
                returnStdout: true,
                script: "curl --output /dev/null --silent --connect-timeout 5 --max-time 5 --retry 5 --retry-delay 5 --retry-max-time 30 --write-out \"%{${out}}\" ${url}"
        )
        echo "Result (${out}): ${result}"
    }
}