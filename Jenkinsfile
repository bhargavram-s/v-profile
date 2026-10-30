pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/bhargavram-s/v-profile.git'
            }
        }
        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    mvn -B \
                    org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                    -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=VProfile
                  '''
                }
            }
        }
        stage('Trivy scan'){
            steps {
                sh 'trivy fs --scanners vuln,misconfig --exit-code 0 .'
            }
        }
        stage('Archive'){
            steps {
                archiveArtifacts artifacts: 'target/*.war'
                }
        }
        stage('Docker Build&Push'){
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                        )]){
                            sh '''
                            set +x
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            echo "current build number:$BUILD_NUMBER"
                            docker build -t "$DOCKER_USER"/vprofile:$BUILD_NUMBER .
                            docker push "$DOCKER_USER"/vprofile:$BUILD_NUMBER
                            docker logout
                            '''
                        }
            }
        }
        stage('Deploy to GKE'){
            steps{
            sh '''
             echo "Connecting to GKE..."
             gcloud container clusters get-credentials vprofile-gke-cluster --zone us-central1-a --project vprofile-devops-511904
             echo "Deploying Kubernetes manifest..."
             kubectl apply -f deployment.yaml
             echo "Updating image with Jenkins build number..."
             kubectl set image deployment/vprofile-app vprofile-app=bhargavram2309/vprofile:${BUILD_NUMBER} -n v-profile
             echo "Waiting for deployment..."
             kubectl rollout status deployment/vprofile-app -n v-profile --timeout=300s
             kubectl get pods -n v-profile
            '''
            }
        }
    }
     post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
