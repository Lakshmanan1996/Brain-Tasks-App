pipeline {

    agent none

    environment {
        DOCKERHUB_USER = "lakshmanan1996"
        IMAGE_NAME     = "brain-task"
        GIT_REPO       = "https://github.com/Lakshmanan1996/Brain-Tasks-App.git"
    }

    stages {

        /* ================= CHECKOUT ================= */
        stage('Checkout') {
            agent any
            steps {
                git branch: 'main', url: env.GIT_REPO
            }
        }

        /* ================= SONARQUBE ================= */
        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                }
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                      sonar-scanner \
                      -Dsonar.projectKey=brain-task \
                      -Dsonar.projectName=brain-task \
                      -Dsonar.sources=.
                    '''
                }
            }
        }

        /* ================= QUALITY GATE ================= */
        /* stage('Quality Gate') {
            agent {
                docker {
                    image 'sonarsource/sonarcloud-quality-gate'
                }
            }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }*/

        /* ================= DOCKER BUILD ================= */
        stage('Docker Build') {
            agent {
                docker {
                    image 'docker:24-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh '''
                  docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} .
                  docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} \
                             ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                '''
            }
        }

        /* ================= TRIVY ================= */
        stage('Trivy Scan') {
            steps {
                sh '''
                  docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  aquasec/trivy image \
                  --severity HIGH,CRITICAL \
                  ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        /* ================= PUSH IMAGE ================= */
        stage('Push Image') {
            agent {
                docker {
                    image 'docker:24-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                      docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }
    }
}
