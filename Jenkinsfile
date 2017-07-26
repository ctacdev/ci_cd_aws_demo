node {

    def stackName = 'CiCdDemoCloudFormationStack'
    def app
    def repoUri

    def silentSh = { cmd ->
        sh('#!/bin/sh -e\n' + cmd)
    }

    stage('Clone repository') {
        checkout scm
    }

    stage('Create image') {
        sh 'javac Server.java'
        login_command = sh(
            script: 'aws ecr get-login --region us-east-1',
            returnStdout: true
        )
        silentSh "${login_command} 2> /dev/null"
        repoUri = sh(
            script: 'aws ecr describe-repositories --region us-east-1 --output text | grep ci-cd-demo | cut -f6',
            returnStdout: true
        ).trim()
        sh 'docker build -t ci-cd-demo .'
    }

    stage('Push image') {
        sh "docker tag ci-cd-demo:latest ${repoUri}"
        sh "docker push ${repoUri}:latest"
    }
}